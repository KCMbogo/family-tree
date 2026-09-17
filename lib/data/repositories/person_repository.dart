import 'package:uuid/uuid.dart';

import '../../domain/models/claim_event.dart';
import '../../domain/models/person.dart';
import '../local/database.dart';
import '../local/mappers.dart';
import 'family_tree_repository.dart';

const _uuid = Uuid();

/// Reads and writes facts about people.
///
/// Reads come from the materialised `persons` projection (fast). Writes go to
/// [FamilyTreeRepository.recordClaims] (append-only). Nothing here ever sets a
/// field on a person — spec §2 rule 1 — which is why the history tab can
/// always reconstruct how a fact came to be.
class PersonRepository {
  PersonRepository({
    required AppDatabase database,
    required this._claims,
  }) : _db = database;

  final AppDatabase _db;
  final FamilyTreeRepository _claims;

  // ---------------------------------------------------------------------
  // Writes
  // ---------------------------------------------------------------------

  /// Creates a person as a batch of claims and returns the new UUID.
  ///
  /// Only fields the user actually filled in produce claims: an empty birth
  /// place is an absence of knowledge, not a claim that the place is unknown.
  Future<String> addPerson({
    required String fullName,
    String? birthYear,
    String? birthPlace,
    Gender? gender,
    bool isDeceased = false,
  }) async {
    final id = _uuid.v4();

    await _claims.recordClaims([
      _claim(id, ClaimFields.name, fullName.trim()),
      if (_isPresent(birthYear)) _claim(id, ClaimFields.birthYear, birthYear!.trim()),
      if (_isPresent(birthPlace))
        _claim(id, ClaimFields.birthPlace, birthPlace!.trim()),
      if (gender != null) _claim(id, ClaimFields.gender, gender.wireName),
      if (isDeceased) _claim(id, ClaimFields.isDeceased, true),
    ]);

    return id;
  }

  /// Applies an edit from the profile form.
  ///
  /// Looks like a field update to the UI; underneath it appends one claim per
  /// *changed* field. Unchanged fields are skipped so the history stays a
  /// record of what actually changed rather than of how often Save was
  /// pressed. Clearing a field writes a retraction, never a delete.
  ///
  /// Omitting an argument means "leave this fact alone". For the text fields
  /// an empty string is the clear signal; [gender] has no such empty value, so
  /// it is wrapped — `gender: (value: null)` clears it, omitting it does not.
  Future<void> updateFacts(
    String personId, {
    String? fullName,
    String? birthYear,
    String? birthPlace,
    ({Gender? value})? gender,
    bool? isDeceased,
  }) async {
    final current = await findPerson(personId);
    final claims = <ClaimEvent>[];

    void diffText(String field, String? next, String? previous) {
      if (next == null) return;
      final trimmed = next.trim();
      final was = previous?.trim() ?? '';
      if (trimmed == was) return;
      claims.add(trimmed.isEmpty
          ? _retract(personId, field)
          : _claim(personId, field, trimmed));
    }

    diffText(ClaimFields.name, fullName, current?.fullName);
    diffText(ClaimFields.birthYear, birthYear, current?.birthYearRaw);
    diffText(ClaimFields.birthPlace, birthPlace, current?.birthPlace);

    if (gender != null && gender.value != current?.gender) {
      claims.add(gender.value == null
          ? _retract(personId, ClaimFields.gender)
          : _claim(personId, ClaimFields.gender, gender.value!.wireName));
    }
    if (isDeceased != null && isDeceased != (current?.isDeceased ?? false)) {
      claims.add(_claim(personId, ClaimFields.isDeceased, isDeceased));
    }

    await _claims.recordClaims(claims);
  }

  /// Appends a single claim. The general-purpose escape hatch used by the
  /// "add a fact" flows and by tests.
  Future<void> addClaim(
    String personId,
    String field,
    Object? value, {
    String source = ClaimSource.userInput,
  }) {
    return _claims.recordClaims([
      _claims.buildClaim(
        entityId: personId,
        entityType: EntityType.person,
        field: field,
        value: value,
        source: source,
      ),
    ]);
  }

  /// Clears one fact without erasing that it was ever claimed.
  Future<void> retractFact(String personId, String field) =>
      _claims.recordClaims([_retract(personId, field)]);

  /// Removes a person from the tree by retracting the whole entity. Their
  /// claim history survives, so the removal itself is auditable.
  Future<void> removePerson(String personId) =>
      _claims.recordClaims([_retract(personId, ClaimFields.wholeEntity)]);

  /// Points the person's profile photo at [mediaId]. Which photo represents
  /// someone is a claim like any other, so it is versioned too.
  Future<void> setProfilePhoto(String personId, String mediaId) =>
      addClaim(personId, ClaimFields.photoMediaId, mediaId);

  // ---------------------------------------------------------------------
  // Reads
  // ---------------------------------------------------------------------

  Stream<Person?> watchPerson(String id) =>
      _db.projectionDao.watchPerson(id).map((row) => row?.toDomain());

  Stream<List<Person>> watchPersons() => _db.projectionDao
      .watchPersons()
      .map((rows) => rows.map((row) => row.toDomain()).toList());

  Future<Person?> findPerson(String id) async =>
      (await _db.projectionDao.findPerson(id))?.toDomain();

  /// The raw claim log for this person, newest first — the provenance view
  /// behind the profile's History tab.
  Stream<List<ClaimEvent>> watchHistory(String personId) =>
      _claims.watchClaimsFor(personId);

  // ---------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------

  static bool _isPresent(String? value) =>
      value != null && value.trim().isNotEmpty;

  ClaimEvent _claim(String personId, String field, Object? value) =>
      _claims.buildClaim(
        entityId: personId,
        entityType: EntityType.person,
        field: field,
        value: value,
      );

  ClaimEvent _retract(String personId, String field) => _claims.buildRetraction(
        entityId: personId,
        entityType: EntityType.person,
        field: field,
      );
}
