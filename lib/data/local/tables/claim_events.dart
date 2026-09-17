import 'package:drift/drift.dart';

/// The append-only log that is the app's source of truth (spec §5.1).
///
/// Rows are only ever INSERTed. Corrections are new claims; deletions are
/// retraction claims (`field = '_retracted'`). `ClaimEventDao` deliberately
/// exposes no update or delete methods, because once Phase 2 sync exists a
/// destructive write here would be unreplayable on other devices.
@DataClassName('ClaimEventRow')
class ClaimEvents extends Table {
  /// Client-generated UUID v4.
  TextColumn get id => text()();

  /// The person or relationship this claim is about.
  TextColumn get entityId => text().named('entity_id')();

  /// `'person'` | `'relationship'`.
  TextColumn get entityType => text().named('entity_type')();

  /// e.g. `'birth_year'`, `'name'`, `'relationship_type'`.
  TextColumn get field => text()();

  /// JSON-encoded, so one column carries strings, numbers and booleans.
  TextColumn get value => text()();

  /// Hardcoded local-user UUID in Phase 1; the signed-in user in Phase 2.
  TextColumn get authorId => text().named('author_id')();

  /// e.g. `'user_input'`, `'imported'`.
  TextColumn get source => text()();

  /// Reserved for Phase 2 AI-extracted claims; unused now.
  RealColumn get confidence => real().nullable()();

  /// Device local time, stored as UTC.
  DateTimeColumn get createdAt => dateTime().named('created_at')();

  /// Always false in Phase 1; the sync adapter owns this in Phase 2.
  BoolColumn get synced =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
