import '../models/person.dart';
import '../models/relationship.dart';

enum TimelineEventKind { birth, marriage, child, death }

/// How a person entered the family, which is what a reader years from now
/// needs in order to place a name they have never heard.
enum FamilyEntry {
  /// Born into the family — has a recorded parent here.
  born,

  /// Married someone who was born into the family.
  marriedIn,

  /// The oldest recorded couple: nobody above them, so they are the family's
  /// starting point rather than in-laws.
  founder,

  /// Nothing yet connects them.
  unconnected,
}

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
    this.era,
  });

  final TimelineEventKind kind;

  /// The headline, e.g. `Juma and Asha married`.
  final String title;

  /// Groups entries under a generation heading, so the timeline reads as
  /// chapters rather than one flat run of dates.
  final String? era;

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

    // Who married whom, so someone with no parents here can be introduced as
    // having married in rather than appearing as an unexplained name.
    final spousesOf = <String, List<String>>{};
    for (final r in usable) {
      if (r.type != RelationshipType.spouseOf) continue;
      spousesOf.putIfAbsent(r.personAId!, () => []).add(r.personBId!);
      spousesOf.putIfAbsent(r.personBId!, () => []).add(r.personAId!);
    }

    final entries = <TimelineEntry>[
      ..._births(byId, parentsOf, spousesOf),
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
    Map<String, List<String>> spousesOf,
  ) sync* {
    for (final person in byId.values) {
      if (person.birthYearRaw == null) continue;

      final parents = (parentsOf[person.id] ?? const <String>[])
          .map((id) => byId[id]?.displayName)
          .whereType<String>()
          .toList();

      final spouses = (spousesOf[person.id] ?? const <String>[])
          .map((id) => byId[id]?.displayName)
          .whereType<String>()
          .toList();

      // Someone reading this in fifty years needs to know who the name
      // belongs to. A birth with no parents recorded here is otherwise just
      // an unexplained person: say how they joined the family instead.
      final entry = _entryFor(
        parents: parents,
        spouses: spouses,
        spouseBornHere: (spousesOf[person.id] ?? const <String>[])
            .any((id) => (parentsOf[id] ?? const <String>[]).isNotEmpty),
      );

      yield TimelineEntry(
        kind: TimelineEventKind.birth,
        title: '${person.displayName} was born',
        detail: switch (entry) {
          FamilyEntry.born => 'to ${_join(parents)}',
          FamilyEntry.marriedIn =>
            'later married ${_join(spouses)}, joining the family',
          FamilyEntry.founder => 'married ${_join(spouses)}',
          FamilyEntry.unconnected => null,
        },
        subtitle: person.birthPlace,
        entityId: person.id,
        year: person.birthYear,
        yearLabel: person.birthYearRaw,
        era: _eraFor(entry),
      );
    }
  }

  /// Someone only "married in" if their spouse was born into this tree.
  /// When neither has parents recorded, they are the founding couple — the
  /// start of the family, not in-laws.
  static FamilyEntry _entryFor({
    required List<String> parents,
    required List<String> spouses,
    required bool spouseBornHere,
  }) {
    if (parents.isNotEmpty) return FamilyEntry.born;
    if (spouses.isEmpty) return FamilyEntry.unconnected;
    return spouseBornHere ? FamilyEntry.marriedIn : FamilyEntry.founder;
  }

  static String? _eraFor(FamilyEntry entry) => switch (entry) {
        FamilyEntry.marriedIn => 'Married into the family',
        FamilyEntry.founder => 'Where the family begins',
        _ => null,
      };

  static Iterable<TimelineEntry> _marriages(
    Map<String, Person> byId,
    List<Relationship> relationships,
  ) sync* {
    final seen = <String>{};

    // Whether each spouse has parents in this tree, which decides who is
    // understood to have married in.
    final hasParentsHere = <String, bool>{};
    for (final r in relationships) {
      if (r.type != RelationshipType.parentOf) continue;
      hasParentsHere[r.personBId!] = true;
    }

    for (final r in relationships) {
      if (r.type != RelationshipType.spouseOf) continue;

      // A marriage recorded from both sides is still one wedding.
      final pair = ([r.personAId!, r.personBId!]..sort()).join('|');
      if (!seen.add(pair)) continue;

      final a = byId[r.personAId]!;
      final b = byId[r.personBId]!;

      final aIsBlood = hasParentsHere[a.id] ?? false;
      final bIsBlood = hasParentsHere[b.id] ?? false;

      // Naming who joined whom is what stops an in-law reading as a stranger.
      final String? joining;
      if (aIsBlood && !bIsBlood) {
        joining = '${b.displayName} joined the family';
      } else if (bIsBlood && !aIsBlood) {
        joining = '${a.displayName} joined the family';
      } else {
        joining = null;
      }

      yield TimelineEntry(
        kind: TimelineEventKind.marriage,
        title: '${a.displayName} and ${b.displayName} married',
        detail: joining,
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
