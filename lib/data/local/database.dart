import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/claim_events.dart';
import 'tables/family_trees.dart';
import 'tables/media.dart';
import 'tables/persons.dart';
import 'tables/relationships.dart';

part 'database.g.dart';

/// The local SQLite database.
///
/// Nothing outside `data/` may import this file: the UI talks to repositories
/// only (spec §2 rule 3), which is what lets Phase 2 swap storage or add sync
/// without touching a single widget.
@DriftDatabase(
  tables: [ClaimEvents, Persons, Relationships, MediaItems, FamilyTrees],
  daos: [ClaimEventDao, ProjectionDao, MediaDao, FamilyTreeDao],
)
class AppDatabase extends _$AppDatabase {
  /// Pass an [executor] to run against an in-memory database in tests.
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'family_tree'));

  @override
  int get schemaVersion => 1;
}

/// Reads and appends the claim log.
///
/// There is intentionally **no update and no delete** here. `claim_events` is
/// append-only (spec §5.1): corrections are new claims and deletions are
/// retraction claims, so the log always replays to the same state on every
/// device. Phase 2 will add exactly one narrow mutation — marking events
/// synced — and nothing else.
@DriftAccessor(tables: [ClaimEvents])
class ClaimEventDao extends DatabaseAccessor<AppDatabase>
    with _$ClaimEventDaoMixin {
  ClaimEventDao(super.db);

  /// Appends [rows]. Idempotent by primary key, because Phase 2 sync can
  /// redeliver an event the device already has.
  Future<void> insertEvents(Iterable<ClaimEventsCompanion> rows) {
    return batch((b) => b.insertAll(
          claimEvents,
          rows.toList(),
          mode: InsertMode.insertOrIgnore,
        ));
  }

  Future<List<ClaimEventRow>> allEvents() => select(claimEvents).get();

  Future<List<ClaimEventRow>> eventsForEntity(String entityId) {
    return (select(claimEvents)..where((t) => t.entityId.equals(entityId)))
        .get();
  }

  Future<List<ClaimEventRow>> eventsForEntities(Iterable<String> entityIds) {
    if (entityIds.isEmpty) return Future.value(const []);
    return (select(claimEvents)
          ..where((t) => t.entityId.isIn(entityIds.toList())))
        .get();
  }

  /// Newest first — this backs the person profile's history tab.
  Stream<List<ClaimEventRow>> watchEventsForEntity(String entityId) {
    return (select(claimEvents)
          ..where((t) => t.entityId.equals(entityId))
          ..orderBy([
            (t) => OrderingTerm.desc(t.createdAt),
            (t) => OrderingTerm.desc(t.id),
          ]))
        .watch();
  }

  Stream<List<ClaimEventRow>> watchAllEvents() {
    return (select(claimEvents)
          ..orderBy([
            (t) => OrderingTerm.desc(t.createdAt),
            (t) => OrderingTerm.desc(t.id),
          ]))
        .watch();
  }

  /// Events not yet pushed. Always everything in Phase 1 (nothing is ever
  /// marked synced); Phase 2's adapter drains this on reconnect.
  Future<List<ClaimEventRow>> pendingEvents() {
    return (select(claimEvents)
          ..where((t) => t.synced.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }
}

/// Owns the materialised `persons` and `relationships` tables.
///
/// These are caches of the claim log and nothing else. Every write here comes
/// from `ClaimProjector`; no feature code may write them directly.
@DriftAccessor(tables: [Persons, Relationships])
class ProjectionDao extends DatabaseAccessor<AppDatabase>
    with _$ProjectionDaoMixin {
  ProjectionDao(super.db);

  Future<void> upsertPersons(Iterable<PersonsCompanion> rows) {
    return batch((b) => b.insertAllOnConflictUpdate(persons, rows.toList()));
  }

  Future<void> upsertRelationships(Iterable<RelationshipsCompanion> rows) {
    return batch(
        (b) => b.insertAllOnConflictUpdate(relationships, rows.toList()));
  }

  Stream<PersonRow?> watchPerson(String id) {
    return (select(persons)..where((t) => t.id.equals(id)))
        .watchSingleOrNull();
  }

  Future<PersonRow?> findPerson(String id) {
    return (select(persons)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Stream<List<PersonRow>> watchPersons() {
    return (select(persons)
          ..where((t) => t.isRetracted.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.fullName)]))
        .watch();
  }

  Stream<List<RelationshipRow>> watchRelationships() {
    return (select(relationships)..where((t) => t.isRetracted.equals(false)))
        .watch();
  }

  Stream<List<RelationshipRow>> watchRelationshipsFor(String personId) {
    return (select(relationships)
          ..where((t) =>
              t.isRetracted.equals(false) &
              (t.personAId.equals(personId) | t.personBId.equals(personId))))
        .watch();
  }

  Future<List<RelationshipRow>> allRelationships() =>
      select(relationships).get();

  Future<RelationshipRow?> findRelationship(String id) {
    return (select(relationships)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Drops both projections so they can be rebuilt from the log. Safe by
  /// construction: no state lives here that the log does not already hold.
  Future<void> clear() async {
    await delete(persons).go();
    await delete(relationships).go();
  }
}

/// Media is plain mutable storage, not event-sourced: the bytes are the fact.
@DriftAccessor(tables: [MediaItems])
class MediaDao extends DatabaseAccessor<AppDatabase> with _$MediaDaoMixin {
  MediaDao(super.db);

  Future<void> upsertMedia(MediaItemsCompanion row) {
    return into(mediaItems).insert(row, mode: InsertMode.insertOrReplace);
  }

  Future<MediaRow?> findById(String id) {
    return (select(mediaItems)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Every attachment sharing these bytes, across all entities. Used to decide
  /// whether the file on disk is still referenced.
  Future<List<MediaRow>> findAllByHash(String contentHash) {
    return (select(mediaItems)
          ..where((t) => t.contentHash.equals(contentHash)))
        .get();
  }

  Future<MediaRow?> findByHash(String contentHash, String linkedEntityId) {
    return (select(mediaItems)
          ..where((t) =>
              t.contentHash.equals(contentHash) &
              t.linkedEntityId.equals(linkedEntityId)))
        .getSingleOrNull();
  }

  Stream<List<MediaRow>> watchForEntity(String linkedEntityId) {
    return (select(mediaItems)
          ..where((t) => t.linkedEntityId.equals(linkedEntityId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  Stream<List<MediaRow>> watchAll() {
    return (select(mediaItems)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  Future<void> deleteMedia(String id) {
    return (delete(mediaItems)..where((t) => t.id.equals(id))).go();
  }
}

@DriftAccessor(tables: [FamilyTrees])
class FamilyTreeDao extends DatabaseAccessor<AppDatabase>
    with _$FamilyTreeDaoMixin {
  FamilyTreeDao(super.db);

  Future<void> insertTree(FamilyTreesCompanion row) =>
      into(familyTrees).insert(row, mode: InsertMode.insertOrReplace);

  Future<FamilyTreeRow?> primaryTree() {
    return (select(familyTrees)
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
          ..limit(1))
        .getSingleOrNull();
  }

  /// The oldest tree is the primary one in Phase 1.
  Stream<FamilyTreeRow?> watchPrimaryTree() {
    return (select(familyTrees)
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
          ..limit(1))
        .watchSingleOrNull();
  }

  Stream<List<FamilyTreeRow>> watchTrees() {
    return (select(familyTrees)
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .watch();
  }

  Future<void> renameTree(String id, String name) {
    return (update(familyTrees)..where((t) => t.id.equals(id)))
        .write(FamilyTreesCompanion(name: Value(name)));
  }
}
