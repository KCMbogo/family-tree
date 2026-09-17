import 'package:meta/meta.dart';

enum Gender {
  male('male', 'Male'),
  female('female', 'Female'),
  other('other', 'Other');

  const Gender(this.wireName, this.label);

  final String wireName;
  final String label;

  static Gender? fromWire(String? value) {
    if (value == null) return null;
    for (final g in values) {
      if (g.wireName == value) return g;
    }
    return null;
  }
}

/// A person's *current* facts, derived by folding their claim events.
///
/// This is a read model. Nothing ever mutates a [Person]; to change a fact you
/// append a new `ClaimEvent` and the projection is rebuilt.
@immutable
class Person {
  const Person({
    required this.id,
    this.fullName,
    this.birthYearRaw,
    this.birthYear,
    this.birthPlace,
    this.gender,
    this.isDeceased = false,
    this.photoMediaId,
    this.lastUpdatedAt,
    this.isRetracted = false,
  });

  final String id;
  final String? fullName;

  /// Birth year exactly as the user typed it, e.g. `"around 1932"`.
  /// Approximate dates are the norm for oral family history, so the raw text
  /// is preserved and [birthYear] is only the best-effort parse of it.
  final String? birthYearRaw;

  /// Parsed four-digit year from [birthYearRaw], for sorting and filtering.
  final int? birthYear;

  final String? birthPlace;
  final Gender? gender;
  final bool isDeceased;
  final String? photoMediaId;

  /// Timestamp of the most recent claim about this person.
  final DateTime? lastUpdatedAt;

  /// True when the latest claim retracted the whole entity.
  final bool isRetracted;

  String get displayName {
    final name = fullName?.trim();
    return (name == null || name.isEmpty) ? 'Unnamed person' : name;
  }

  /// True when no surviving claim says anything about this person.
  bool get isEmpty =>
      fullName == null &&
      birthYearRaw == null &&
      birthPlace == null &&
      gender == null &&
      photoMediaId == null;

  @override
  bool operator ==(Object other) =>
      other is Person &&
      other.id == id &&
      other.fullName == fullName &&
      other.birthYearRaw == birthYearRaw &&
      other.birthYear == birthYear &&
      other.birthPlace == birthPlace &&
      other.gender == gender &&
      other.isDeceased == isDeceased &&
      other.photoMediaId == photoMediaId &&
      other.isRetracted == isRetracted;

  @override
  int get hashCode => Object.hash(id, fullName, birthYearRaw, birthYear,
      birthPlace, gender, isDeceased, photoMediaId, isRetracted);

  @override
  String toString() => 'Person($id, $fullName, $birthYearRaw)';
}
