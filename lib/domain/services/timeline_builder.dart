import '../models/person.dart';
import '../models/relationship.dart';

enum TimelineEventKind { birth, marriage }

/// One dated (or undated) event in the family's history.
class TimelineEntry {
  const TimelineEntry({
    required this.kind,
    required this.title,
    required this.entityId,
    this.year,
    this.yearLabel,
    this.subtitle,
  });

  final TimelineEventKind kind;
  final String title;

  /// The person or relationship this entry links to.
  final String entityId;

  /// Parsed year, null when the claim had no recognisable year.
  final int? year;

  /// The year exactly as claimed, e.g. `"around 1932"`.
  final String? yearLabel;

  final String? subtitle;

  bool get isDated => year != null;
}

/// Derives a chronological view of the whole tree from the projections.
///
/// Births and marriages only: those are the two facts Phase 1 actually
/// records a date for. People are marked deceased without a death year, so
/// there is nothing truthful to place on a timeline for that yet — inventing a
/// position would be worse than omitting it.
abstract final class TimelineBuilder {
  static List<TimelineEntry> build({
    required List<Person> persons,
    required List<Relationship> relationships,
  }) {
    final byId = {
      for (final person in persons)
        if (!person.isRetracted) person.id: person,
    };

    final entries = <TimelineEntry>[
      for (final person in byId.values)
        if (person.birthYearRaw != null)
          TimelineEntry(
            kind: TimelineEventKind.birth,
            title: '${person.displayName} was born',
            subtitle: person.birthPlace,
            entityId: person.id,
            year: person.birthYear,
            yearLabel: person.birthYearRaw,
          ),
      for (final relationship in relationships)
        if (relationship.isComplete &&
            relationship.type == RelationshipType.spouseOf &&
            relationship.marriageYearRaw != null &&
            byId.containsKey(relationship.personAId) &&
            byId.containsKey(relationship.personBId))
          TimelineEntry(
            kind: TimelineEventKind.marriage,
            title: '${byId[relationship.personAId]!.displayName} and '
                '${byId[relationship.personBId]!.displayName} married',
            entityId: relationship.id,
            year: relationship.marriageYear,
            yearLabel: relationship.marriageYearRaw,
          ),
    ];

    // Dated entries first in chronological order; undated ones keep a stable
    // alphabetical order at the end rather than being dropped, because "we
    // know this happened but not when" is real family knowledge.
    entries.sort((a, b) {
      if (a.year != null && b.year != null) {
        final byYear = a.year!.compareTo(b.year!);
        return byYear != 0 ? byYear : a.title.compareTo(b.title);
      }
      if (a.year != null) return -1;
      if (b.year != null) return 1;
      return a.title.compareTo(b.title);
    });

    return entries;
  }
}
