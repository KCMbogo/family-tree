import '../models/claim_event.dart';
import '../models/person.dart';
import '../models/relationship.dart';

/// The result of folding one entity's claim log.
///
/// [fields] holds the surviving claim per field — the event itself, not just
/// its value, so callers keep provenance (who claimed it, when, from where).
class FoldedClaims {
  const FoldedClaims({
    required this.fields,
    required this.isRetracted,
    required this.lastUpdatedAt,
  });

  final Map<String, ClaimEvent> fields;
  final bool isRetracted;
  final DateTime? lastUpdatedAt;

  ClaimEvent? operator [](String field) => fields[field];

  String? stringOf(String field) => fields[field]?.valueAsString;

  bool boolOf(String field) => fields[field]?.valueAsBool ?? false;
}

/// Folds `ClaimEvent`s into current state.
///
/// Deliberately a pure function over lists: no database, no I/O, no Flutter.
/// Everything the app shows is produced here, so this is the one place the
/// "latest claim wins, history is never lost" rule is implemented.
abstract final class ClaimProjector {
  /// Chronological order, with the event id as a tiebreaker so two claims
  /// written in the same millisecond still fold deterministically (important
  /// once Phase 2 merges events from several devices).
  static int compare(ClaimEvent a, ClaimEvent b) {
    final byTime = a.createdAt.compareTo(b.createdAt);
    return byTime != 0 ? byTime : a.id.compareTo(b.id);
  }

  /// Reduces [events] to the surviving claim per field.
  ///
  /// Rules:
  /// - later claims supersede earlier ones for the same field;
  /// - a retraction removes the field it names, and a later claim may set it
  ///   again;
  /// - a whole-entity retraction clears every field, and any later claim
  ///   revives the entity.
  ///
  /// Nothing is ever dropped from the log itself — superseded events stay
  /// visible in the history UI.
  static FoldedClaims fold(Iterable<ClaimEvent> events) {
    final sorted = events.toList()..sort(compare);
    final surviving = <String, ClaimEvent>{};
    var isRetracted = false;
    DateTime? lastUpdatedAt;

    for (final event in sorted) {
      lastUpdatedAt = event.createdAt;

      if (event.isRetraction) {
        final target = event.valueAsString;
        if (target == ClaimFields.wholeEntity) {
          surviving.clear();
          isRetracted = true;
        } else if (target != null) {
          surviving.remove(target);
        }
        continue;
      }

      // Asserting anything about a retracted entity brings it back.
      isRetracted = false;
      surviving[event.field] = event;
    }

    return FoldedClaims(
      fields: surviving,
      isRetracted: isRetracted,
      lastUpdatedAt: lastUpdatedAt,
    );
  }

  /// Folds a person's claim log into their current facts.
  ///
  /// [events] may include events for other entities; they are filtered out, so
  /// callers can hand over an unsorted, unfiltered batch.
  static Person projectPerson(String personId, Iterable<ClaimEvent> events) {
    final folded = fold(events.where(
      (e) => e.entityId == personId && e.entityType == EntityType.person,
    ));

    final birthYearRaw = folded.stringOf(ClaimFields.birthYear);

    return Person(
      id: personId,
      fullName: folded.stringOf(ClaimFields.name),
      birthYearRaw: birthYearRaw,
      birthYear: parseYear(birthYearRaw),
      birthPlace: folded.stringOf(ClaimFields.birthPlace),
      gender: Gender.fromWire(folded.stringOf(ClaimFields.gender)),
      isDeceased: folded.boolOf(ClaimFields.isDeceased),
      photoMediaId: folded.stringOf(ClaimFields.photoMediaId),
      lastUpdatedAt: folded.lastUpdatedAt,
      isRetracted: folded.isRetracted,
    );
  }

  /// Folds a relationship's claim log into its current shape.
  static Relationship projectRelationship(
    String relationshipId,
    Iterable<ClaimEvent> events,
  ) {
    final folded = fold(events.where(
      (e) =>
          e.entityId == relationshipId &&
          e.entityType == EntityType.relationship,
    ));

    final marriageYearRaw = folded.stringOf(ClaimFields.marriageYear);

    return Relationship(
      id: relationshipId,
      personAId: folded.stringOf(ClaimFields.personAId),
      personBId: folded.stringOf(ClaimFields.personBId),
      type: RelationshipType.fromWire(
          folded.stringOf(ClaimFields.relationshipType)),
      claimEventId: folded[ClaimFields.relationshipType]?.id,
      marriageYearRaw: marriageYearRaw,
      marriageYear: parseYear(marriageYearRaw),
      lastUpdatedAt: folded.lastUpdatedAt,
      isRetracted: folded.isRetracted,
    );
  }

  /// Projects every person mentioned in [events], keyed by person id.
  static Map<String, Person> projectAllPersons(Iterable<ClaimEvent> events) {
    final byEntity = _groupByEntity(events, EntityType.person);
    return {
      for (final entry in byEntity.entries)
        entry.key: projectPerson(entry.key, entry.value),
    };
  }

  /// Projects every relationship mentioned in [events], keyed by id.
  static Map<String, Relationship> projectAllRelationships(
      Iterable<ClaimEvent> events) {
    final byEntity = _groupByEntity(events, EntityType.relationship);
    return {
      for (final entry in byEntity.entries)
        entry.key: projectRelationship(entry.key, entry.value),
    };
  }

  static Map<String, List<ClaimEvent>> _groupByEntity(
    Iterable<ClaimEvent> events,
    EntityType type,
  ) {
    final grouped = <String, List<ClaimEvent>>{};
    for (final event in events) {
      if (event.entityType != type) continue;
      grouped.putIfAbsent(event.entityId, () => []).add(event);
    }
    return grouped;
  }

  /// Best-effort year extraction from free text such as `"around 1932"` or
  /// `"late 1800s"`. Returns null when no plausible year is present.
  ///
  /// The raw text is always kept alongside the parse, so a wrong guess here
  /// never destroys what the user actually said.
  static int? parseYear(String? raw) {
    if (raw == null) return null;
    final match = RegExp(r'\b(1\d{3}|20\d{2})\b').firstMatch(raw);
    if (match == null) return null;
    return int.tryParse(match.group(0)!);
  }
}
