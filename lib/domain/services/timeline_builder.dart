import '../models/person.dart';
import '../models/relationship.dart';

enum TimelineEventKind { birth, marriage, child, death }

/// One dated (or undated) event in the family's history.
class TimelineEntry {
  const TimelineEntry({
    required this.kind,
    required this.title,
    required this.entityId,
    this.year,
    this.yearLabel,
    this.subtitle,
    this.detail,
  });

  final TimelineEventKind kind;

  /// The headline, e.g. `Juma and Asha married`.
  final String title;

  /// The person or relationship this entry links to.
  final String entityId;

  /// Parsed year, null when the claim had no recognisable year.
  final int? year;

  /// The year exactly as claimed, e.g. `"around 1932"`.
  final String? yearLabel;

  /// Where it happened, when known.
  final String? subtitle;

  /// The relational context that turns a bare fact into a story — who the
  /// parents were, how long a couple had been married.
  final String? detail;

  bool get isDated => year != null;
}

/// Derives a chronological narrative of the family from the projections.
///
/// A list of "X was born" lines is not a family history. Each event is placed
/// in its relational context instead: a birth names the parents, a marriage
/// names both spouses, and a couple's children appear as their own arrivals.
/// That is what lets the timeline read as "they married, then their first
/// child came, then the next" rather than as disconnected facts.
///
/// Only claims the user actually recorded are used. Nothing is inferred or
/// invented to fill a gap — an undated event is shown as undated.
abstract final class TimelineBuilder {
  static List<TimelineEntry> build({
    required List<Person> persons,
    required List<Relationship> relationships,
  }) {
    final byId = {
      for (final person in persons)
        if (!person.isRetracted) person.id: person,
    };

    final usable = relationships
        .where((r) =>
            r.isComplete &&
            byId.containsKey(r.personAId) &&
            byId.containsKey(r.personBId))
        .toList();

    // Parents of each child, so a birth can name them.
    //
    // Deduplicated: the same parent→child fact can exist as two edges in
    // older data, which would otherwise print a parent's name twice.
    final parentIdsOf = <String, Set<String>>{};
    for (final r in usable) {
      if (r.type != RelationshipType.parentOf) continue;
      parentIdsOf.putIfAbsent(r.personBId!, () => {}).add(r.personAId!);
    }
    final parentsOf = {
      for (final entry in parentIdsOf.entries) entry.key: entry.value.toList(),
    };

    final entries = <TimelineEntry>[
      ..._births(byId, parentsOf),
      ..._marriages(byId, usable),
      ..._childArrivals(byId, usable, parentsOf),
      ..._deaths(byId),
    ];

    // Dated entries in chronological order; undated ones keep a stable
    // alphabetical order at the end rather than being dropped, because "we
    // know this happened but not when" is real family knowledge.
    entries.sort((a, b) {
      if (a.year != null && b.year != null) {
        final byYear = a.year!.compareTo(b.year!);
        if (byYear != 0) return byYear;
        // Within a year, births read before the marriages they enable.
        final byKind = a.kind.index.compareTo(b.kind.index);
        if (byKind != 0) return byKind;
        return a.title.compareTo(b.title);
      }
      if (a.year != null) return -1;
      if (b.year != null) return 1;
      return a.title.compareTo(b.title);
    });

    return entries;
  }

  static Iterable<TimelineEntry> _births(
    Map<String, Person> byId,
    Map<String, List<String>> parentsOf,
  ) sync* {
    for (final person in byId.values) {
      if (person.birthYearRaw == null) continue;

      final parents = (parentsOf[person.id] ?? const <String>[])
          .map((id) => byId[id]?.displayName)
          .whereType<String>()
          .toList();

      yield TimelineEntry(
        kind: TimelineEventKind.birth,
        title: '${person.displayName} was born',
        // Naming the parents is what ties a birth into the family rather
        // than leaving it as a standalone date.
        detail: parents.isEmpty ? null : 'to ${_join(parents)}',
        subtitle: person.birthPlace,
        entityId: person.id,
        year: person.birthYear,
        yearLabel: person.birthYearRaw,
      );
    }
  }

  static Iterable<TimelineEntry> _marriages(
    Map<String, Person> byId,
    List<Relationship> relationships,
  ) sync* {
    final seen = <String>{};

    for (final r in relationships) {
      if (r.type != RelationshipType.spouseOf) continue;
      if (r.marriageYearRaw == null) continue;

      // A marriage recorded from both sides is still one wedding.
      final pair = ([r.personAId!, r.personBId!]..sort()).join('|');
      if (!seen.add(pair)) continue;

      final a = byId[r.personAId]!;
      final b = byId[r.personBId]!;

      yield TimelineEntry(
        kind: TimelineEventKind.marriage,
        title: '${a.displayName} and ${b.displayName} married',
        entityId: r.id,
        year: r.marriageYear,
        yearLabel: r.marriageYearRaw,
      );
    }
  }

  /// A couple's children, told from the parents' side.
  ///
  /// The same birth already appears as the child's own entry; this is the
  /// other half of the story — "and then they had a daughter" — which is what
  /// makes a marriage read as the start of a family rather than an endpoint.
  static Iterable<TimelineEntry> _childArrivals(
    Map<String, Person> byId,
    List<Relationship> relationships,
    Map<String, List<String>> parentsOf,
  ) sync* {
    final marriedTo = <String, Relationship>{};
    for (final r in relationships) {
      if (r.type != RelationshipType.spouseOf) continue;
      marriedTo['${r.personAId}|${r.personBId}'] = r;
      marriedTo['${r.personBId}|${r.personAId}'] = r;
    }

    for (final entry in parentsOf.entries) {
      final child = byId[entry.key];
      if (child == null || child.birthYearRaw == null) continue;

      final parents = entry.value
          .map((id) => byId[id])
          .whereType<Person>()
          .toList();
      if (parents.isEmpty) continue;

      final names = parents.map((p) => p.displayName).toList();
      final relation = _parentRelation(parents, marriedTo);

      yield TimelineEntry(
        kind: TimelineEventKind.child,
        title: '${_join(names)} had ${_childNoun(child)}, '
            '${child.displayName}',
        detail: relation,
        entityId: child.id,
        year: child.birthYear,
        yearLabel: child.birthYearRaw,
      );
    }
  }

  static Iterable<TimelineEntry> _deaths(Map<String, Person> byId) sync* {
    for (final person in byId.values) {
      if (!person.isDeceased) continue;
      // No death year is recorded in this phase, so the entry carries no
      // date and sits with the other undated events rather than being
      // invented onto a point in the chart.
      yield TimelineEntry(
        kind: TimelineEventKind.death,
        title: '${person.displayName} died',
        entityId: person.id,
      );
    }
  }

  /// Flags a birth outside the recorded marriage, without editorialising.
  static String? _parentRelation(
    List<Person> parents,
    Map<String, Relationship> marriedTo,
  ) {
    if (parents.length == 1) return 'recorded with one parent';
    if (parents.length != 2) return null;

    final match = marriedTo['${parents[0].id}|${parents[1].id}'];
    if (match == null) return 'not recorded as married';
    if (match.marriageYearRaw != null) {
      return 'married ${match.marriageYearRaw}';
    }
    return null;
  }

  static String _childNoun(Person child) => switch (child.gender) {
        Gender.male => 'a son',
        Gender.female => 'a daughter',
        _ => 'a child',
      };

  /// `a`, `a and b`, `a, b and c`.
  static String _join(List<String> names) {
    if (names.isEmpty) return '';
    if (names.length == 1) return names.first;
    return '${names.sublist(0, names.length - 1).join(', ')} '
        'and ${names.last}';
  }
}
