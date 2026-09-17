import 'package:meta/meta.dart';

enum RelationshipType {
  /// [Relationship.personAId] is the parent of [Relationship.personBId].
  parentOf('parent_of', 'Parent of'),
  spouseOf('spouse_of', 'Spouse of'),
  siblingOf('sibling_of', 'Sibling of');

  const RelationshipType(this.wireName, this.label);

  final String wireName;
  final String label;

  /// True when A→B and B→A mean the same thing.
  bool get isSymmetric => this != RelationshipType.parentOf;

  static RelationshipType? fromWire(String? value) {
    if (value == null) return null;
    for (final t in values) {
      if (t.wireName == value) return t;
    }
    return null;
  }
}

/// An edge between two persons, derived by folding its claim events.
@immutable
class Relationship {
  const Relationship({
    required this.id,
    this.personAId,
    this.personBId,
    this.type,
    this.claimEventId,
    this.marriageYearRaw,
    this.marriageYear,
    this.lastUpdatedAt,
    this.isRetracted = false,
  });

  final String id;
  final String? personAId;
  final String? personBId;
  final RelationshipType? type;

  /// Provenance: the claim event that established the current
  /// [type]. The full history is still in `claim_events`.
  final String? claimEventId;

  /// Optional, spouse relationships only. Free text, as with birth years.
  final String? marriageYearRaw;
  final int? marriageYear;

  final DateTime? lastUpdatedAt;
  final bool isRetracted;

  /// A relationship is only usable once both endpoints and a type are known.
  bool get isComplete =>
      personAId != null && personBId != null && type != null && !isRetracted;

  /// The other endpoint of this edge, or null if [personId] is not on it.
  String? otherPerson(String personId) {
    if (personAId == personId) return personBId;
    if (personBId == personId) return personAId;
    return null;
  }

  bool involves(String personId) =>
      personAId == personId || personBId == personId;

  @override
  bool operator ==(Object other) =>
      other is Relationship &&
      other.id == id &&
      other.personAId == personAId &&
      other.personBId == personBId &&
      other.type == type &&
      other.marriageYearRaw == marriageYearRaw &&
      other.isRetracted == isRetracted;

  @override
  int get hashCode => Object.hash(
      id, personAId, personBId, type, marriageYearRaw, isRetracted);

  @override
  String toString() =>
      'Relationship($personAId ${type?.wireName ?? '?'} $personBId)';
}
