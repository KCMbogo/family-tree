import 'package:family_tree/domain/models/claim_event.dart';
import 'package:family_tree/domain/models/person.dart';
import 'package:family_tree/domain/models/relationship.dart';
import 'package:family_tree/domain/services/claim_projector.dart';
import 'package:flutter_test/flutter_test.dart';

const _author = 'author-1';
const _personId = 'person-1';

ClaimEvent claim(
  String field,
  Object? value, {
  required int minute,
  String entityId = _personId,
  EntityType type = EntityType.person,
  String? id,
  String author = _author,
}) {
  return ClaimEvent.create(
    entityId: entityId,
    entityType: type,
    field: field,
    rawValue: value,
    authorId: author,
    id: id,
    createdAt: DateTime.utc(2024, 1, 1, 0, minute),
  );
}

void main() {
  group('folding produces current state', () {
    test('the latest claim for a field wins', () {
      final person = ClaimProjector.projectPerson(_personId, [
        claim(ClaimFields.birthYear, '1932', minute: 0),
        claim(ClaimFields.birthYear, '1934', minute: 5),
      ]);

      expect(person.birthYearRaw, '1934');
      expect(person.birthYear, 1934);
    });

    test('order of the input list does not matter, only timestamps do', () {
      final earlier = claim(ClaimFields.name, 'Asha', minute: 0);
      final later = claim(ClaimFields.name, 'Asha Mbogo', minute: 9);

      expect(
        ClaimProjector.projectPerson(_personId, [later, earlier]).fullName,
        'Asha Mbogo',
        reason: 'the fold must sort, not trust insertion order',
      );
    });

    test('claims about different fields all survive', () {
      final person = ClaimProjector.projectPerson(_personId, [
        claim(ClaimFields.name, 'Juma Mbogo', minute: 0),
        claim(ClaimFields.birthPlace, 'Moshi', minute: 1),
        claim(ClaimFields.gender, 'male', minute: 2),
        claim(ClaimFields.isDeceased, true, minute: 3),
      ]);

      expect(person.fullName, 'Juma Mbogo');
      expect(person.birthPlace, 'Moshi');
      expect(person.gender, Gender.male);
      expect(person.isDeceased, isTrue);
    });

    test('claims about other entities are ignored', () {
      final person = ClaimProjector.projectPerson(_personId, [
        claim(ClaimFields.name, 'Mine', minute: 0),
        claim(ClaimFields.name, 'Someone else',
            minute: 5, entityId: 'person-2'),
      ]);

      expect(person.fullName, 'Mine');
    });

    test('events in the same instant fold deterministically by id', () {
      final a = claim(ClaimFields.name, 'A', minute: 0, id: 'aaa');
      final b = claim(ClaimFields.name, 'B', minute: 0, id: 'bbb');

      expect(ClaimProjector.projectPerson(_personId, [a, b]).fullName, 'B');
      expect(ClaimProjector.projectPerson(_personId, [b, a]).fullName, 'B');
    });

    test('a person with no claims projects to an empty person, not an error',
        () {
      final person = ClaimProjector.projectPerson(_personId, const []);

      expect(person.id, _personId);
      expect(person.isEmpty, isTrue);
      expect(person.displayName, 'Unnamed person');
    });
  });

  group('retraction', () {
    test('clears the field it names and leaves others alone', () {
      final person = ClaimProjector.projectPerson(_personId, [
        claim(ClaimFields.name, 'Juma', minute: 0),
        claim(ClaimFields.birthYear, '1932', minute: 1),
        ClaimEvent.retraction(
          entityId: _personId,
          entityType: EntityType.person,
          field: ClaimFields.birthYear,
          authorId: _author,
          createdAt: DateTime.utc(2024, 1, 1, 0, 2),
        ),
      ]);

      expect(person.birthYearRaw, isNull);
      expect(person.fullName, 'Juma', reason: 'retraction is field-scoped');
    });

    test('a later claim can re-establish a retracted field', () {
      final person = ClaimProjector.projectPerson(_personId, [
        claim(ClaimFields.birthYear, '1932', minute: 0),
        ClaimEvent.retraction(
          entityId: _personId,
          entityType: EntityType.person,
          field: ClaimFields.birthYear,
          authorId: _author,
          createdAt: DateTime.utc(2024, 1, 1, 0, 1),
        ),
        claim(ClaimFields.birthYear, '1935', minute: 2),
      ]);

      expect(person.birthYearRaw, '1935');
    });

    test('retracting the whole entity clears every field', () {
      final person = ClaimProjector.projectPerson(_personId, [
        claim(ClaimFields.name, 'Juma', minute: 0),
        claim(ClaimFields.birthPlace, 'Moshi', minute: 1),
        ClaimEvent.retraction(
          entityId: _personId,
          entityType: EntityType.person,
          field: ClaimFields.wholeEntity,
          authorId: _author,
          createdAt: DateTime.utc(2024, 1, 1, 0, 2),
        ),
      ]);

      expect(person.isRetracted, isTrue);
      expect(person.fullName, isNull);
      expect(person.birthPlace, isNull);
    });

    test('a retraction never removes anything from the log itself', () {
      final events = [
        claim(ClaimFields.birthYear, '1932', minute: 0),
        ClaimEvent.retraction(
          entityId: _personId,
          entityType: EntityType.person,
          field: ClaimFields.birthYear,
          authorId: _author,
          createdAt: DateTime.utc(2024, 1, 1, 0, 1),
        ),
      ];

      ClaimProjector.projectPerson(_personId, events);

      expect(events, hasLength(2));
      expect(events.first.value, '"1932"');
    });
  });

  group('provenance survives the fold', () {
    test('the surviving claim keeps its author and source', () {
      final folded = ClaimProjector.fold([
        claim(ClaimFields.name, 'Old', minute: 0, author: 'author-old'),
        claim(ClaimFields.name, 'New', minute: 1, author: 'author-new'),
      ]);

      expect(folded[ClaimFields.name]!.authorId, 'author-new');
      expect(folded[ClaimFields.name]!.source, ClaimSource.userInput);
    });
  });

  group('relationships', () {
    const relationshipId = 'rel-1';

    ClaimEvent relClaim(String field, Object? value, {required int minute}) =>
        claim(field, value,
            minute: minute,
            entityId: relationshipId,
            type: EntityType.relationship);

    test('folds its endpoint and type claims into one edge', () {
      final relationship =
          ClaimProjector.projectRelationship(relationshipId, [
        relClaim(ClaimFields.personAId, 'person-a', minute: 0),
        relClaim(ClaimFields.personBId, 'person-b', minute: 0),
        relClaim(ClaimFields.relationshipType, 'parent_of', minute: 0),
      ]);

      expect(relationship.personAId, 'person-a');
      expect(relationship.personBId, 'person-b');
      expect(relationship.type, RelationshipType.parentOf);
      expect(relationship.isComplete, isTrue);
    });

    test('links back to the claim that established the current type', () {
      final typeClaim =
          relClaim(ClaimFields.relationshipType, 'sibling_of', minute: 3);

      final relationship =
          ClaimProjector.projectRelationship(relationshipId, [
        relClaim(ClaimFields.relationshipType, 'spouse_of', minute: 0),
        typeClaim,
      ]);

      expect(relationship.type, RelationshipType.siblingOf);
      expect(relationship.claimEventId, typeClaim.id);
    });

    test('an incomplete edge is not usable', () {
      final relationship = ClaimProjector.projectRelationship(
        relationshipId,
        [relClaim(ClaimFields.personAId, 'person-a', minute: 0)],
      );

      expect(relationship.isComplete, isFalse);
    });
  });

  group('year parsing keeps the raw text authoritative', () {
    test('extracts a year from approximate phrasing', () {
      expect(ClaimProjector.parseYear('1932'), 1932);
      expect(ClaimProjector.parseYear('around 1932'), 1932);
      expect(ClaimProjector.parseYear('c. 1888'), 1888);
      expect(ClaimProjector.parseYear('born 2001 in Arusha'), 2001);
    });

    test('returns null rather than guessing', () {
      expect(ClaimProjector.parseYear(null), isNull);
      expect(ClaimProjector.parseYear('during the war'), isNull);
      expect(ClaimProjector.parseYear('12'), isNull);
    });

    test('an unparseable year is still preserved verbatim', () {
      final person = ClaimProjector.projectPerson(
        _personId,
        [claim(ClaimFields.birthYear, 'during the war', minute: 0)],
      );

      expect(person.birthYear, isNull);
      expect(person.birthYearRaw, 'during the war');
    });
  });
}
