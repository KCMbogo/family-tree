import 'package:drift/drift.dart';

/// Read-optimised projection of the relationship claim events (spec §5.3).
///
/// Same rule as `Persons`: derived only, rebuilt from the log, never edited.
@DataClassName('RelationshipRow')
class Relationships extends Table {
  TextColumn get id => text()();

  TextColumn get personAId => text().named('person_a_id').nullable()();

  TextColumn get personBId => text().named('person_b_id').nullable()();

  /// `parent_of` | `spouse_of` | `sibling_of`.
  TextColumn get relationshipType =>
      text().named('relationship_type').nullable()();

  /// Provenance link to the claim event that established the current type.
  TextColumn get claimEventId => text().named('claim_event_id').nullable()();

  /// Optional, spouse relationships only. Free text like birth years.
  TextColumn get marriageYearRaw =>
      text().named('marriage_year_raw').nullable()();

  IntColumn get marriageYear => integer().named('marriage_year').nullable()();

  DateTimeColumn get lastUpdatedAt =>
      dateTime().named('last_updated_at').nullable()();

  BoolColumn get isRetracted =>
      boolean().named('is_retracted').withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
