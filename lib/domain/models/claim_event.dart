import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// The kind of entity a [ClaimEvent] asserts something about.
enum EntityType {
  person('person'),
  relationship('relationship');

  const EntityType(this.wireName);

  /// The value stored in `claim_events.entity_type`.
  final String wireName;

  static EntityType fromWire(String value) =>
      values.firstWhere((e) => e.wireName == value);
}

/// Where a claim came from.
///
/// Stored as free text rather than an enum column so Phase 2 can introduce
/// `ai_transcription` / `confirmed_by_other_member` without a migration.
abstract final class ClaimSource {
  static const String userInput = 'user_input';
  static const String imported = 'imported';

  // Reserved for Phase 2; listed here so the vocabulary lives in one place.
  static const String aiTranscription = 'ai_transcription';
  static const String confirmedByOtherMember = 'confirmed_by_other_member';
}

/// The `field` vocabulary used by claim events.
abstract final class ClaimFields {
  /// Marks a retraction. The claim's `value` is the JSON-encoded name of the
  /// field being retracted, or [wholeEntity] to retract the entity entirely.
  ///
  /// Retraction is how corrections and deletions work, because `claim_events`
  /// is append-only — nothing is ever UPDATEd or DELETEd there (spec §5.1).
  static const String retracted = '_retracted';

  /// Sentinel [retracted] value meaning "retract this entity completely".
  static const String wholeEntity = '*';

  // --- person fields ---
  static const String name = 'name';
  static const String birthYear = 'birth_year';
  static const String birthPlace = 'birth_place';
  static const String gender = 'gender';
  static const String isDeceased = 'is_deceased';
  static const String photoMediaId = 'photo_media_id';

  // --- relationship fields ---
  static const String personAId = 'person_a_id';
  static const String personBId = 'person_b_id';
  static const String relationshipType = 'relationship_type';
  static const String marriageYear = 'marriage_year';

  /// Human-readable label for a field key, used by the history UI.
  static String label(String field) => switch (field) {
        retracted => 'Retracted',
        name => 'Name',
        birthYear => 'Birth year',
        birthPlace => 'Birth place',
        gender => 'Gender',
        isDeceased => 'Deceased',
        photoMediaId => 'Profile photo',
        personAId => 'Person A',
        personBId => 'Person B',
        relationshipType => 'Relationship type',
        marriageYear => 'Marriage year',
        _ => field,
      };
}

/// An immutable, append-only assertion that someone made about an entity.
///
/// This is the app's source of truth. Current state (see `Person`,
/// `Relationship`) is *derived* by folding these — never stored directly.
@immutable
class ClaimEvent {
  const ClaimEvent({
    required this.id,
    required this.entityId,
    required this.entityType,
    required this.field,
    required this.value,
    required this.authorId,
    required this.source,
    required this.createdAt,
    this.confidence,
    this.synced = false,
  });

  /// Builds a claim, generating a v4 UUID and JSON-encoding [rawValue].
  factory ClaimEvent.create({
    required String entityId,
    required EntityType entityType,
    required String field,
    required Object? rawValue,
    required String authorId,
    String source = ClaimSource.userInput,
    double? confidence,
    DateTime? createdAt,
    String? id,
  }) {
    return ClaimEvent(
      id: id ?? _uuid.v4(),
      entityId: entityId,
      entityType: entityType,
      field: field,
      value: jsonEncode(rawValue),
      authorId: authorId,
      source: source,
      confidence: confidence,
      createdAt: (createdAt ?? DateTime.now()).toUtc(),
    );
  }

  /// Builds a retraction of [field] on [entityId]. Pass
  /// [ClaimFields.wholeEntity] to retract the entity itself.
  factory ClaimEvent.retraction({
    required String entityId,
    required EntityType entityType,
    required String field,
    required String authorId,
    String source = ClaimSource.userInput,
    DateTime? createdAt,
    String? id,
  }) {
    return ClaimEvent.create(
      entityId: entityId,
      entityType: entityType,
      field: ClaimFields.retracted,
      rawValue: field,
      authorId: authorId,
      source: source,
      createdAt: createdAt,
      id: id,
    );
  }

  /// Client-generated UUID v4.
  final String id;

  /// The person or relationship this claim is about.
  final String entityId;
  final EntityType entityType;

  /// Field key, e.g. `birth_year`. See [ClaimFields].
  final String field;

  /// JSON-encoded value, so strings, numbers and booleans share one column.
  final String value;

  /// Who asserted this. Always [kLocalAuthorId] in Phase 1.
  final String authorId;

  /// See [ClaimSource].
  final String source;

  /// Reserved for Phase 2 AI-extracted claims; always null in Phase 1.
  final double? confidence;

  /// Device local time, stored as UTC.
  final DateTime createdAt;

  /// Always false in Phase 1; the sync adapter flips it in Phase 2.
  final bool synced;

  bool get isRetraction => field == ClaimFields.retracted;

  /// The decoded [value]. Returns null when the JSON is malformed rather than
  /// throwing, so one bad row can never break a whole projection.
  Object? get decodedValue {
    try {
      return jsonDecode(value);
    } on FormatException {
      return null;
    }
  }

  String? get valueAsString {
    final decoded = decodedValue;
    return decoded is String ? decoded : decoded?.toString();
  }

  bool? get valueAsBool {
    final decoded = decodedValue;
    if (decoded is bool) return decoded;
    if (decoded is String) return decoded == 'true';
    return null;
  }

  ClaimEvent copyWith({bool? synced}) => ClaimEvent(
        id: id,
        entityId: entityId,
        entityType: entityType,
        field: field,
        value: value,
        authorId: authorId,
        source: source,
        confidence: confidence,
        createdAt: createdAt,
        synced: synced ?? this.synced,
      );

  @override
  bool operator ==(Object other) => other is ClaimEvent && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'ClaimEvent($field=$value on $entityId at ${createdAt.toIso8601String()})';
}
