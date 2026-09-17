import 'package:drift/drift.dart';

/// Local media, addressed by content hash (spec §5.4).
///
/// [contentHash] — not [localPath] — is the durable identity: paths change
/// between reinstalls and devices, while the hash lets Phase 2 sync dedupe the
/// same photo uploaded from two phones without rewriting how media is
/// referenced anywhere else in the app.
@DataClassName('MediaRow')
class MediaItems extends Table {
  @override
  String get tableName => 'media';

  TextColumn get id => text()();

  /// SHA-256 of the file bytes.
  TextColumn get contentHash => text().named('content_hash')();

  /// Resolved lazily; not assumed stable.
  TextColumn get localPath => text().named('local_path')();

  /// The person or claim event this file is attached to.
  TextColumn get linkedEntityId => text().named('linked_entity_id')();

  /// `'photo'` | `'audio'` | `'document'`.
  TextColumn get mediaType => text().named('media_type')();

  TextColumn get caption => text().nullable()();

  DateTimeColumn get createdAt => dateTime().named('created_at')();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        // The same file attached to the same entity twice is one attachment.
        {contentHash, linkedEntityId},
      ];
}
