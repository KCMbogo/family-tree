import 'package:family_tree/domain/models/person.dart';
import 'package:family_tree/domain/models/relationship.dart';
import 'package:family_tree/domain/services/timeline_builder.dart';
import 'package:flutter_test/flutter_test.dart';

Person born(String id, String name, String? raw, int? year) => Person(
      id: id,
      fullName: name,
      birthYearRaw: raw,
      birthYear: year,
    );

void main() {
  test('births appear in chronological order', () {
    final entries = TimelineBuilder.build(
      persons: [
        born('b', 'Asha', '1960', 1960),
        born('a', 'Juma', '1932', 1932),
        born('c', 'Neema', '1985', 1985),
      ],
      relationships: const [],
    );

    expect(entries.map((e) => e.year), [1932, 1960, 1985]);
    expect(entries.first.title, contains('Juma'));
  });

  test('people with no birth year produce no entry', () {
    final entries = TimelineBuilder.build(
      persons: [born('a', 'Juma', null, null)],
      relationships: const [],
    );

    expect(entries, isEmpty);
  });

  test('an approximate birth year still appears, dated by its parse', () {
    final entries = TimelineBuilder.build(
      persons: [born('a', 'Juma', 'around 1932', 1932)],
      relationships: const [],
    );

    expect(entries.single.year, 1932);
    expect(entries.single.yearLabel, 'around 1932');
  });

  test('an unparseable date is kept, and sorted after the dated events', () {
    final entries = TimelineBuilder.build(
      persons: [
        born('a', 'Juma', 'during the war', null),
        born('b', 'Asha', '1960', 1960),
      ],
      relationships: const [],
    );

    expect(entries.map((e) => e.title).toList(),
        [contains('Asha'), contains('Juma')]);
    expect(entries.last.isDated, isFalse);
    expect(entries.last.yearLabel, 'during the war');
  });

  test('a birth names the parents it belongs to', () {
    final entries = TimelineBuilder.build(
      persons: [
        born('dad', 'Juma', '1930', 1930),
        born('mum', 'Asha', '1934', 1934),
        born('kid', 'Neema', '1960', 1960),
      ],
      relationships: [
        const Relationship(
          id: 'r1', personAId: 'dad', personBId: 'kid',
          type: RelationshipType.parentOf,
        ),
        const Relationship(
          id: 'r2', personAId: 'mum', personBId: 'kid',
          type: RelationshipType.parentOf,
        ),
      ],
    );

    final birth = entries.firstWhere(
      (e) => e.kind == TimelineEventKind.birth && e.entityId == 'kid',
    );
    expect(birth.detail, 'to Juma and Asha');
  });

  test('a couple having a child is its own event', () {
    final entries = TimelineBuilder.build(
      persons: [
        born('dad', 'Juma', '1930', 1930),
        born('mum', 'Asha', '1934', 1934),
        const Person(
          id: 'kid', fullName: 'Neema', birthYearRaw: '1960',
          birthYear: 1960, gender: Gender.female,
        ),
      ],
      relationships: [
        const Relationship(
          id: 'm', personAId: 'dad', personBId: 'mum',
          type: RelationshipType.spouseOf,
          marriageYearRaw: '1955', marriageYear: 1955,
        ),
        const Relationship(
          id: 'r1', personAId: 'dad', personBId: 'kid',
          type: RelationshipType.parentOf,
        ),
        const Relationship(
          id: 'r2', personAId: 'mum', personBId: 'kid',
          type: RelationshipType.parentOf,
        ),
      ],
    );

    final arrival =
        entries.firstWhere((e) => e.kind == TimelineEventKind.child);
    expect(arrival.title, contains('had a daughter'));
    expect(arrival.title, contains('Neema'));
    expect(arrival.detail, 'married 1955');

    // The story reads in order: marriage, then the child.
    final marriageAt =
        entries.indexWhere((e) => e.kind == TimelineEventKind.marriage);
    final childAt = entries.indexOf(arrival);
    expect(marriageAt, lessThan(childAt));
  });

  test('a child of one parent is flagged as such, not invented into a couple',
      () {
    final entries = TimelineBuilder.build(
      persons: [
        born('dad', 'Juma', '1930', 1930),
        born('kid', 'Baraka', '1966', 1966),
      ],
      relationships: [
        const Relationship(
          id: 'r1', personAId: 'dad', personBId: 'kid',
          type: RelationshipType.parentOf,
        ),
      ],
    );

    final arrival =
        entries.firstWhere((e) => e.kind == TimelineEventKind.child);
    expect(arrival.title, startsWith('Juma had'));
    expect(arrival.detail, 'recorded with one parent');
  });

  test('a duplicated parent link does not repeat a name', () {
    // Real data contained the same parent_of fact as two edges.
    final entries = TimelineBuilder.build(
      persons: [
        born('dad', 'Elias', '1940', 1940),
        born('mum', 'Marietha', '1945', 1945),
        born('kid', 'Charles', '1970', 1970),
      ],
      relationships: [
        const Relationship(
          id: 'p1', personAId: 'dad', personBId: 'kid',
          type: RelationshipType.parentOf,
        ),
        const Relationship(
          id: 'p1dup', personAId: 'dad', personBId: 'kid',
          type: RelationshipType.parentOf,
        ),
        const Relationship(
          id: 'p2', personAId: 'mum', personBId: 'kid',
          type: RelationshipType.parentOf,
        ),
      ],
    );

    final birth = entries.firstWhere(
      (e) => e.kind == TimelineEventKind.birth && e.entityId == 'kid',
    );
    expect(birth.detail, 'to Elias and Marietha');

    final arrivals =
        entries.where((e) => e.kind == TimelineEventKind.child);
    expect(arrivals, hasLength(1));
  });

  test('a marriage recorded from both sides appears once', () {
    final entries = TimelineBuilder.build(
      persons: [born('a', 'Elias', '1940', 1940), born('b', 'Marietha', null, null)],
      relationships: [
        const Relationship(
          id: 'm1', personAId: 'a', personBId: 'b',
          type: RelationshipType.spouseOf,
          marriageYearRaw: '1965', marriageYear: 1965,
        ),
        const Relationship(
          id: 'm2', personAId: 'b', personBId: 'a',
          type: RelationshipType.spouseOf,
          marriageYearRaw: '1965', marriageYear: 1965,
        ),
      ],
    );

    expect(
      entries.where((e) => e.kind == TimelineEventKind.marriage),
      hasLength(1),
    );
  });

  group('a future reader can tell who everyone is', () {
    // Joyce has no parents in the tree. Without context her birth entry is
    // just an unexplained name.
    List<TimelineEntry> threeGenerations() => TimelineBuilder.build(
          persons: [
            born('elias', 'Elias', '1940', 1940),
            born('marietha', 'Marietha', '1945', 1945),
            born('charles', 'Charles', '1970', 1970),
            born('joyce', 'Joyce', '1974', 1974),
          ],
          relationships: [
            const Relationship(
              id: 'm1', personAId: 'elias', personBId: 'marietha',
              type: RelationshipType.spouseOf,
              marriageYearRaw: '1965', marriageYear: 1965,
            ),
            const Relationship(
              id: 'm2', personAId: 'charles', personBId: 'joyce',
              type: RelationshipType.spouseOf,
              marriageYearRaw: '1996', marriageYear: 1996,
            ),
            const Relationship(
              id: 'p1', personAId: 'elias', personBId: 'charles',
              type: RelationshipType.parentOf,
            ),
            const Relationship(
              id: 'p2', personAId: 'marietha', personBId: 'charles',
              type: RelationshipType.parentOf,
            ),
          ],
        );

    TimelineEntry birthOf(String id) => threeGenerations().firstWhere(
          (e) => e.kind == TimelineEventKind.birth && e.entityId == id,
        );

    test('someone who married in is introduced as such', () {
      final joyce = birthOf('joyce');

      expect(joyce.era, 'Married into the family');
      expect(joyce.detail, contains('married Charles'));
      expect(joyce.detail, contains('joining the family'));
    });

    test('a child born into the family names its parents', () {
      final charles = birthOf('charles');

      expect(charles.era, isNull, reason: 'blood family needs no heading');
      expect(charles.detail, 'to Elias and Marietha');
    });

    test('the oldest couple are founders, not in-laws', () {
      // Neither has parents recorded, so neither married "into" anything.
      expect(birthOf('elias').era, 'Where the family begins');
      expect(birthOf('marietha').era, 'Where the family begins');
    });

    test('a marriage says who joined whom', () {
      final marriage = threeGenerations().firstWhere(
        (e) => e.kind == TimelineEventKind.marriage && e.entityId == 'm2',
      );

      expect(marriage.detail, 'Joyce joined the family');
    });

    test('a founding marriage does not claim anyone joined', () {
      final marriage = threeGenerations().firstWhere(
        (e) => e.kind == TimelineEventKind.marriage && e.entityId == 'm1',
      );

      expect(marriage.detail, isNull);
    });
  });

  test('an undated marriage still appears', () {
    final entries = TimelineBuilder.build(
      persons: [born('a', 'Juma', '1930', 1930), born('b', 'Asha', null, null)],
      relationships: [
        const Relationship(
          id: 'm', personAId: 'a', personBId: 'b',
          type: RelationshipType.spouseOf,
        ),
      ],
    );

    final marriage =
        entries.firstWhere((e) => e.kind == TimelineEventKind.marriage);
    expect(marriage.isDated, isFalse,
        reason: 'a wedding with no year recorded is still a wedding');
  });

  test('a deceased person gets an undated death entry', () {
    final entries = TimelineBuilder.build(
      persons: [
        const Person(
          id: 'a', fullName: 'Juma', birthYearRaw: '1930',
          birthYear: 1930, isDeceased: true,
        ),
      ],
      relationships: const [],
    );

    final death =
        entries.firstWhere((e) => e.kind == TimelineEventKind.death);
    expect(death.title, 'Juma died');
    expect(death.isDated, isFalse);
    expect(entries.last, death, reason: 'undated events sort to the end');
  });

  test('marriages are included and named after both spouses', () {
    final entries = TimelineBuilder.build(
      persons: [
        born('a', 'Juma', '1932', 1932),
        born('b', 'Asha', '1936', 1936),
      ],
      relationships: [
        const Relationship(
          id: 'r1',
          personAId: 'a',
          personBId: 'b',
          type: RelationshipType.spouseOf,
          marriageYearRaw: '1959',
          marriageYear: 1959,
        ),
      ],
    );

    final marriage =
        entries.firstWhere((e) => e.kind == TimelineEventKind.marriage);
    expect(marriage.title, allOf(contains('Juma'), contains('Asha')));
    expect(marriage.year, 1959);
  });

  test('a marriage with no year is shown undated, not given a date', () {
    final entries = TimelineBuilder.build(
      persons: [born('a', 'Juma', null, null), born('b', 'Asha', null, null)],
      relationships: [
        const Relationship(
          id: 'r1',
          personAId: 'a',
          personBId: 'b',
          type: RelationshipType.spouseOf,
        ),
      ],
    );

    expect(entries.where((e) => e.isDated), isEmpty);
  });

  test('retracted people drop out of the timeline entirely', () {
    final entries = TimelineBuilder.build(
      persons: [
        const Person(
          id: 'a',
          fullName: 'Juma',
          birthYearRaw: '1932',
          birthYear: 1932,
          isRetracted: true,
        ),
        born('b', 'Asha', '1960', 1960),
      ],
      relationships: const [],
    );

    expect(entries.map((e) => e.entityId), ['b']);
  });
}
