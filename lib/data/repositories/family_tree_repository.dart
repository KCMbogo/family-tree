import 'dart:async';

import 'package:uuid/uuid.dart';

import '../../app/constants.dart';
import '../../domain/models/claim_event.dart';
import '../../domain/models/family_tree.dart';
import '../../domain/models/relationship.dart';
import '../../domain/services/claim_projector.dart';
import '../local/database.dart';
import '../local/mappers.dart';
import 'sync_adapter.dart';

const _uuid = Uuid();

/// Owns the tree itself: the claim log, the projections derived from it, the
/// relationship graph, and the sync seam.
///
/// This is the only place in the app that writes claim events. Everything
/// else — `PersonRepository`, every screen — funnels through [recordClaims],
/// which guarantees three invariants hold everywhere at once:
///
/// 1. every mutation is an append to the log, never a field write;
/// 2. the materialised tables are refolded from that log immediately;
/// 3. the sync adapter sees every claim, local or remote, on one path.
class FamilyTreeRepository {
  FamilyTreeRepository({
    required AppDatabase database,
    required this._syncAdapter,
    this._authorId = kLocalAuthorId,
  }) : _db = database;

  final AppDatabase _db;
  final SyncAdapter _syncAdapter;

  /// Phase 1: always [kLocalAuthorId]. Phase 2: the signed-in user.
  final String _authorId;

  StreamSubscription<List<ClaimEvent>>? _incoming;

  /// Starts listening for remote claims. A no-op in Phase 1 because
  /// `NoopSyncAdapter.incomingEvents()` never emits — but the wiring is live,
  /// so a real adapter starts working the moment it is bound.
  void start() {
    _incoming ??= _syncAdapter.incomingEvents().listen(
          applyRemoteClaims,
          onError: (Object _) {
            // A failing remote stream must never take the local app down.
          },
        );
  }

  Future<void> dispose() async {
    await _incoming?.cancel();
    _incoming = null;
  }

  // ---------------------------------------------------------------------
  // Claims
  // ---------------------------------------------------------------------

  /// Builds a claim stamped with the current author and source.
  ///
  /// Centralising this is what makes spec §2 rule 4 hold: no call site can
  /// forget `author_id`, so Phase 2 auth changes one field in one class.
  ClaimEvent buildClaim({
    required String entityId,
    required EntityType entityType,
    required String field,
    required Object? value,
    String source = ClaimSource.userInput,
    double? confidence,
  }) {
    return ClaimEvent.create(
      entityId: entityId,
      entityType: entityType,
      field: field,
      rawValue: value,
      authorId: _authorId,
      source: source,
      confidence: confidence,
    );
  }

  ClaimEvent buildRetraction({
    required String entityId,
    required EntityType entityType,
    required String field,
  }) {
    return ClaimEvent.retraction(
      entityId: entityId,
      entityType: entityType,
      field: field,
      authorId: _authorId,
    );
  }

  /// Appends [events] to the log, refolds every entity they touch, then hands
  /// them to the sync adapter.
  ///
  /// The append and the refold share a transaction so the projection can never
  /// be observed lagging the log. The push happens after the transaction
  /// commits and is deliberately allowed to fail: this app is local-first, and
  /// unpushed claims stay queryable via `ClaimEventDao.pendingEvents()`.
  Future<void> recordClaims(List<ClaimEvent> events) async {
    if (events.isEmpty) return;
    await _appendAndProject(events);
    await _push(events);
  }

  /// Applies claims authored on another device. Identical to [recordClaims]
  /// minus the echo back to the server.
  Future<void> applyRemoteClaims(List<ClaimEvent> events) async {
    if (events.isEmpty) return;
    await _appendAndProject(events);
  }

  Future<void> _appendAndProject(List<ClaimEvent> events) {
    return _db.transaction(() async {
      await _db.claimEventDao.insertEvents(events.map((e) => e.toCompanion()));
      await _refold({
        for (final event in events) event.entityId: event.entityType,
      });
    });
  }

  Future<void> _push(List<ClaimEvent> events) async {
    try {
      await _syncAdapter.pushPendingEvents(events);
    } catch (_) {
      // Local write already succeeded; the claim is not lost. Phase 2's
      // adapter retries from pendingEvents().
    }
  }

  /// Refolds the given entities from their full claim history.
  ///
  /// Always projects from the whole log for an entity rather than patching the
  /// existing row — that is what keeps the projection a true function of the
  /// log, including when a retraction has to resurrect a superseded value.
  Future<void> _refold(Map<String, EntityType> entities) async {
    if (entities.isEmpty) return;

    final rows = await _db.claimEventDao.eventsForEntities(entities.keys);
    final events = rows.map((row) => row.toDomain()).toList();

    final persons = <PersonsCompanion>[];
    final relationships = <RelationshipsCompanion>[];

    for (final entry in entities.entries) {
      switch (entry.value) {
        case EntityType.person:
          persons.add(
              ClaimProjector.projectPerson(entry.key, events).toCompanion());
        case EntityType.relationship:
          relationships
              .add(ClaimProjector.projectRelationship(entry.key, events)
                  .toCompanion());
      }
    }

    if (persons.isNotEmpty) await _db.projectionDao.upsertPersons(persons);
    if (relationships.isNotEmpty) {
      await _db.projectionDao.upsertRelationships(relationships);
    }
  }

  /// Drops and rebuilds every projection from the claim log.
  ///
  /// Never needed in normal operation — it exists because being able to run it
  /// at any time is the proof that the materialised tables hold no state of
  /// their own. Phase 2 runs this after a large sync backfill.
  Future<void> rebuildAllProjections() async {
    await _db.transaction(() async {
      final rows = await _db.claimEventDao.allEvents();
      final events = rows.map((row) => row.toDomain()).toList();

      await _db.projectionDao.clear();
      await _db.projectionDao.upsertPersons(
        ClaimProjector.projectAllPersons(events)
            .values
            .map((p) => p.toCompanion()),
      );
      await _db.projectionDao.upsertRelationships(
        ClaimProjector.projectAllRelationships(events)
            .values
            .map((r) => r.toCompanion()),
      );
    });
  }

  /// Every claim ever written, newest first. Backs the global history view.
  Stream<List<ClaimEvent>> watchAllClaims() {
    return _db.claimEventDao.watchAllEvents().map(_toNewestFirst);
  }

  /// The raw claim log for one entity, newest first.
  Stream<List<ClaimEvent>> watchClaimsFor(String entityId) {
    return _db.claimEventDao.watchEventsForEntity(entityId).map(_toNewestFirst);
  }

  /// Orders history with the same comparator the projector folds with.
  ///
  /// SQLite compares the stored timestamps as text, and Dart's ISO-8601 format
  /// prints three fractional digits when the microseconds happen to be zero and
  /// six otherwise — so `.392Z` would sort *after* `.392788Z`. Re-sorting here
  /// keeps what the history tab shows identical to what the fold actually did.
  static List<ClaimEvent> _toNewestFirst(List<ClaimEventRow> rows) {
    return rows.map((row) => row.toDomain()).toList()
      ..sort((a, b) => ClaimProjector.compare(b, a));
  }

  /// Claims not yet pushed to a backend. Everything, in Phase 1.
  Future<List<ClaimEvent>> pendingClaims() async {
    final rows = await _db.claimEventDao.pendingEvents();
    return rows.map((row) => row.toDomain()).toList();
  }

  // ---------------------------------------------------------------------
  // Trees
  // ---------------------------------------------------------------------

  /// Creates a tree. Trees are plain rows, not claims: a tree is a container
  /// the user owns, not an assertion about a person that anyone could dispute.
  Future<FamilyTree> createTree(String name) async {
    final tree = FamilyTree(
      id: _uuid.v4(),
      name: name.trim().isEmpty ? kDefaultTreeName : name.trim(),
      createdAt: DateTime.now().toUtc(),
    );
    await _db.familyTreeDao.insertTree(tree.toCompanion());
    return tree;
  }

  Future<void> renameTree(String id, String name) =>
      _db.familyTreeDao.renameTree(id, name.trim());

  Future<FamilyTree?> primaryTree() async =>
      (await _db.familyTreeDao.primaryTree())?.toDomain();

  Stream<FamilyTree?> watchPrimaryTree() =>
      _db.familyTreeDao.watchPrimaryTree().map((row) => row?.toDomain());

  Stream<List<FamilyTree>> watchTrees() => _db.familyTreeDao
      .watchTrees()
      .map((rows) => rows.map((row) => row.toDomain()).toList());

  // ---------------------------------------------------------------------
  // Relationships
  // ---------------------------------------------------------------------

  /// Records a relationship as a set of claims — one per field — so an edge is
  /// as revisable and as attributable as any other fact.
  ///
  /// For [RelationshipType.parentOf], A is the parent of B; the other two
  /// types are symmetric.
  Future<String> addRelationship({
    required String personAId,
    required String personBId,
    required RelationshipType type,
    String? marriageYear,
  }) async {
    if (personAId == personBId) {
      throw ArgumentError('A person cannot be related to themselves.');
    }

    final id = _uuid.v4();
    final claims = <ClaimEvent>[
      buildClaim(
        entityId: id,
        entityType: EntityType.relationship,
        field: ClaimFields.personAId,
        value: personAId,
      ),
      buildClaim(
        entityId: id,
        entityType: EntityType.relationship,
        field: ClaimFields.personBId,
        value: personBId,
      ),
      buildClaim(
        entityId: id,
        entityType: EntityType.relationship,
        field: ClaimFields.relationshipType,
        value: type.wireName,
      ),
      if (type == RelationshipType.spouseOf &&
          marriageYear != null &&
          marriageYear.trim().isNotEmpty)
        buildClaim(
          entityId: id,
          entityType: EntityType.relationship,
          field: ClaimFields.marriageYear,
          value: marriageYear.trim(),
        ),
    ];

    await recordClaims(claims);
    return id;
  }

  /// Removes a relationship by retracting it. The claims that created it stay
  /// in the log, so "this link was here and someone removed it" is still
  /// answerable — which is the whole point of the event model.
  Future<void> removeRelationship(String relationshipId) {
    return recordClaims([
      buildRetraction(
        entityId: relationshipId,
        entityType: EntityType.relationship,
        field: ClaimFields.wholeEntity,
      ),
    ]);
  }

  Stream<List<Relationship>> watchRelationships() {
    return _db.projectionDao.watchRelationships().map(
        (rows) => rows.map((row) => row.toDomain()).toList());
  }

  Stream<List<Relationship>> watchRelationshipsFor(String personId) {
    return _db.projectionDao
        .watchRelationshipsFor(personId)
        .map((rows) => rows.map((row) => row.toDomain()).toList());
  }

  Future<Relationship?> findRelationship(String id) async =>
      (await _db.projectionDao.findRelationship(id))?.toDomain();
}
