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

    expect(entries, hasLength(3));
    expect(entries.last.kind, TimelineEventKind.marriage);
    expect(entries.last.title, allOf(contains('Juma'), contains('Asha')));
  });

  test('a marriage with no recorded year is not invented onto the timeline',
      () {
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

    expect(entries, isEmpty);
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
