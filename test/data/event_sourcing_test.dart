import 'dart:async';

import 'package:drift/native.dart';
import 'package:family_tree/data/local/database.dart';
import 'package:family_tree/data/repositories/family_tree_repository.dart';
import 'package:family_tree/data/repositories/person_repository.dart';
import 'package:family_tree/data/repositories/sync_adapter.dart';
import 'package:family_tree/domain/models/claim_event.dart';
import 'package:family_tree/domain/models/person.dart';
import 'package:family_tree/domain/models/relationship.dart';
import 'package:flutter_test/flutter_test.dart';

/// Captures what the app hands to the backend seam, so Phase 1 can prove the
/// Phase 2 contract without a backend existing.
class RecordingSyncAdapter implements SyncAdapter {
  final List<List<ClaimEvent>> pushes = [];
  final _incoming = StreamController<List<ClaimEvent>>.broadcast();

  List<ClaimEvent> get pushedEvents =>
      [for (final batch in pushes) ...batch];

  @override
  Future<void> pushPendingEvents(List<ClaimEvent> events) async {
    pushes.add(events);
  }

  @override
  Stream<List<ClaimEvent>> incomingEvents() => _incoming.stream;

  /// Simulates claims arriving from another device.
  void deliver(List<ClaimEvent> events) => _incoming.add(events);

  Future<void> close() => _incoming.close();
}

void main() {
  late AppDatabase db;
  late RecordingSyncAdapter sync;
  late FamilyTreeRepository trees;
  late PersonRepository people;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    sync = RecordingSyncAdapter();
    trees = FamilyTreeRepository(
      database: db,
      syncAdapter: sync,
      authorId: 'local-user',
    );
    trees.start();
    people = PersonRepository(database: db, claims: trees);
  });

  tearDown(() async {
    await trees.dispose();
    await sync.close();
    await db.close();
  });

  Future<List<ClaimEventRow>> allEvents() => db.claimEventDao.allEvents();

  group('the event-sourcing contract', () {
    test(
      'two conflicting claims: the latest wins in the projection, '
      'and both stay visible in the history',
      () async {
        final id = await people.addPerson(fullName: 'Juma Mbogo');

        await people.addClaim(id, ClaimFields.birthYear, '1932');
        await people.addClaim(id, ClaimFields.birthYear, '1934');

        // The materialised view — what the tree and profile screens read.
        final person = await people.findPerson(id);
        expect(person!.birthYearRaw, '1934');
        expect(person.birthYear, 1934);

        // The log — what the history tab reads. Nothing was overwritten.
        final history = await db.claimEventDao.eventsForEntity(id);
        final birthYearClaims =
            history.where((e) => e.field == ClaimFields.birthYear).toList();

        expect(birthYearClaims, hasLength(2));
        expect(
          birthYearClaims.map((e) => e.value),
          containsAll(<String>['"1932"', '"1934"']),
        );
      },
    );

    test('the projection is a pure function of the log', () async {
      final id = await people.addPerson(
        fullName: 'Asha Mbogo',
        birthYear: 'around 1940',
        birthPlace: 'Moshi',
        gender: Gender.female,
      );
      await people.addClaim(id, ClaimFields.birthYear, '1941');
      await people.retractFact(id, ClaimFields.birthPlace);

      final before = await people.findPerson(id);

      // Throw the entire projection away and rebuild it from claims alone.
      await trees.rebuildAllProjections();
      final after = await people.findPerson(id);

      expect(after, equals(before));
      expect(after!.birthYearRaw, '1941');
      expect(after.birthPlace, isNull);
    });

    test('editing a fact appends rather than mutating', () async {
      final id = await people.addPerson(fullName: 'Juma');
      final afterCreate = (await allEvents()).length;

      await people.updateFacts(id, fullName: 'Juma Mbogo');
      final afterEdit = await allEvents();

      expect(afterEdit.length, afterCreate + 1);
      expect(
        afterEdit.where((e) => e.field == ClaimFields.name).map((e) => e.value),
        containsAll(<String>['"Juma"', '"Juma Mbogo"']),
      );
    });

    test('saving an unchanged form writes no claims', () async {
      final id = await people.addPerson(
        fullName: 'Juma Mbogo',
        birthPlace: 'Moshi',
      );
      final before = (await allEvents()).length;

      await people.updateFacts(
        id,
        fullName: 'Juma Mbogo',
        birthPlace: 'Moshi',
      );

      expect((await allEvents()).length, before,
          reason: 'history records changes, not save-button presses');
    });

    test('clearing a field writes a retraction, not a delete', () async {
      final id =
          await people.addPerson(fullName: 'Juma', birthPlace: 'Moshi');

      await people.updateFacts(id, birthPlace: '');

      expect((await people.findPerson(id))!.birthPlace, isNull);

      final events = await db.claimEventDao.eventsForEntity(id);
      expect(events.any((e) => e.field == ClaimFields.retracted), isTrue);
      expect(
        events.any((e) => e.field == ClaimFields.birthPlace),
        isTrue,
        reason: 'the original claim must survive its own retraction',
      );
    });

    test('an omitted field is left alone, a cleared one is retracted',
        () async {
      final id = await people.addPerson(
        fullName: 'Juma Mbogo',
        gender: Gender.male,
        birthPlace: 'Moshi',
      );

      // Omitting gender must not disturb it.
      await people.updateFacts(id, birthPlace: 'Arusha');
      expect((await people.findPerson(id))!.gender, Gender.male);

      // Explicitly passing no gender clears it.
      await people.updateFacts(id, gender: (value: null));
      final person = await people.findPerson(id);
      expect(person!.gender, isNull);
      expect(person.birthPlace, 'Arusha');
    });

    test('removing a person hides them but keeps their history', () async {
      final id = await people.addPerson(fullName: 'Juma Mbogo');
      final eventsBefore = (await allEvents()).length;

      await people.removePerson(id);

      expect(await people.watchPersons().first, isEmpty);
      expect((await people.findPerson(id))!.isRetracted, isTrue);
      expect((await allEvents()).length, eventsBefore + 1);
    });

    test('every claim carries an author and a source', () async {
      final id = await people.addPerson(
        fullName: 'Juma Mbogo',
        birthPlace: 'Moshi',
      );
      await people.addClaim(id, ClaimFields.birthYear, '1932');

      final events = await allEvents();

      expect(events, isNotEmpty);
      for (final event in events) {
        expect(event.authorId, 'local-user');
        expect(event.source, ClaimSource.userInput);
        expect(event.confidence, isNull,
            reason: 'confidence is reserved for Phase 2 AI claims');
        expect(event.synced, isFalse);
      }
    });

    test('ids are client-generated UUIDs, not sequential integers', () async {
      final first = await people.addPerson(fullName: 'A');
      final second = await people.addPerson(fullName: 'B');

      final uuidV4 = RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      );

      expect(uuidV4.hasMatch(first), isTrue, reason: first);
      expect(uuidV4.hasMatch(second), isTrue, reason: second);
      expect(first, isNot(second));

      for (final event in await allEvents()) {
        expect(uuidV4.hasMatch(event.id), isTrue, reason: event.id);
      }
    });

    test('claims ordered within the same millisecond stay deterministic',
        () async {
      final id = await people.addPerson(fullName: 'Juma');
      final now = DateTime.now().toUtc();

      // Hand-built claims sharing a timestamp, as a device clock with coarse
      // resolution — or a sync merge — can produce.
      await trees.recordClaims([
        ClaimEvent.create(
          entityId: id,
          entityType: EntityType.person,
          field: ClaimFields.birthPlace,
          rawValue: 'Arusha',
          authorId: 'local-user',
          id: 'aaaaaaaa-0000-4000-8000-000000000000',
          createdAt: now,
        ),
        ClaimEvent.create(
          entityId: id,
          entityType: EntityType.person,
          field: ClaimFields.birthPlace,
          rawValue: 'Moshi',
          authorId: 'local-user',
          id: 'ffffffff-0000-4000-8000-000000000000',
          createdAt: now,
        ),
      ]);

      expect((await people.findPerson(id))!.birthPlace, 'Moshi');

      await trees.rebuildAllProjections();
      expect((await people.findPerson(id))!.birthPlace, 'Moshi',
          reason: 'a replay must not reshuffle tied events');
    });
  });

  group('the sync seam', () {
    test('every locally written claim is offered to the adapter', () async {
      final id = await people.addPerson(fullName: 'Juma Mbogo');
      await people.addClaim(id, ClaimFields.birthYear, '1932');

      final pushedIds = sync.pushedEvents.map((e) => e.id).toSet();
      final storedIds = (await allEvents()).map((e) => e.id).toSet();

      expect(pushedIds, equals(storedIds));
    });

    test('a failing backend never loses the local write', () async {
      final failing = _FailingSyncAdapter();
      final repository = FamilyTreeRepository(
        database: db,
        syncAdapter: failing,
        authorId: 'local-user',
      );
      final repo = PersonRepository(database: db, claims: repository);

      final id = await repo.addPerson(fullName: 'Juma Mbogo');

      expect((await repo.findPerson(id))!.fullName, 'Juma Mbogo');
      expect(await repository.pendingClaims(), isNotEmpty);
    });

    test('remote claims are applied through the same projector', () async {
      final id = await people.addPerson(fullName: 'Juma Mbogo');

      sync.deliver([
        ClaimEvent.create(
          entityId: id,
          entityType: EntityType.person,
          field: ClaimFields.birthPlace,
          rawValue: 'Dodoma',
          authorId: 'another-device-user',
          source: ClaimSource.confirmedByOtherMember,
          createdAt: DateTime.now().toUtc().add(const Duration(minutes: 1)),
        ),
      ]);

      await pumpEventQueue();

      final person = await people.findPerson(id);
      expect(person!.birthPlace, 'Dodoma');
      expect(person.fullName, 'Juma Mbogo');
    });

    test('a remote claim is not echoed back to the backend', () async {
      final id = await people.addPerson(fullName: 'Juma Mbogo');
      sync.pushes.clear();

      sync.deliver([
        ClaimEvent.create(
          entityId: id,
          entityType: EntityType.person,
          field: ClaimFields.birthPlace,
          rawValue: 'Dodoma',
          authorId: 'another-device-user',
        ),
      ]);
      await pumpEventQueue();

      expect(sync.pushes, isEmpty);
    });

    test('a redelivered claim is stored once', () async {
      final id = await people.addPerson(fullName: 'Juma Mbogo');
      final duplicate = ClaimEvent.create(
        entityId: id,
        entityType: EntityType.person,
        field: ClaimFields.birthPlace,
        rawValue: 'Dodoma',
        authorId: 'another-device-user',
      );

      sync.deliver([duplicate]);
      await pumpEventQueue();
      sync.deliver([duplicate]);
      await pumpEventQueue();

      final stored = (await allEvents()).where((e) => e.id == duplicate.id);
      expect(stored, hasLength(1));
    });
  });

  group('relationships', () {
    test('are recorded as claims and projected into edges', () async {
      final parent = await people.addPerson(fullName: 'Juma Mbogo');
      final child = await people.addPerson(fullName: 'Asha Mbogo');

      final relationshipId = await trees.addRelationship(
        personAId: parent,
        personBId: child,
        type: RelationshipType.parentOf,
      );

      final relationship = await trees.findRelationship(relationshipId);
      expect(relationship!.personAId, parent);
      expect(relationship.personBId, child);
      expect(relationship.type, RelationshipType.parentOf);
      expect(relationship.claimEventId, isNotNull,
          reason: 'the edge must point at the claim that established it');

      final events = await db.claimEventDao.eventsForEntity(relationshipId);
      expect(events, hasLength(3));
      expect(
        events.every((e) => e.entityType == EntityType.relationship.wireName),
        isTrue,
      );
    });

    test('a spouse link can carry an approximate marriage year', () async {
      final a = await people.addPerson(fullName: 'Juma');
      final b = await people.addPerson(fullName: 'Asha');

      final id = await trees.addRelationship(
        personAId: a,
        personBId: b,
        type: RelationshipType.spouseOf,
        marriageYear: 'around 1959',
      );

      final relationship = await trees.findRelationship(id);
      expect(relationship!.marriageYearRaw, 'around 1959');
      expect(relationship.marriageYear, 1959);
    });

    test('removing an edge retracts it and keeps the claims', () async {
      final a = await people.addPerson(fullName: 'Juma');
      final b = await people.addPerson(fullName: 'Asha');
      final id = await trees.addRelationship(
        personAId: a,
        personBId: b,
        type: RelationshipType.siblingOf,
      );

      await trees.removeRelationship(id);

      expect(await trees.watchRelationships().first, isEmpty);
      expect(
        await db.claimEventDao.eventsForEntity(id),
        hasLength(4),
        reason: '3 creating claims plus the retraction',
      );
    });

    test('a person cannot be related to themselves', () async {
      final id = await people.addPerson(fullName: 'Juma');

      expect(
        () => trees.addRelationship(
          personAId: id,
          personBId: id,
          type: RelationshipType.siblingOf,
        ),
        throwsArgumentError,
      );
    });
  });

  group('trees', () {
    test('the oldest tree is the primary one', () async {
      await trees.createTree('Mbogo Family');
      await trees.createTree('Second Tree');

      expect((await trees.primaryTree())!.name, 'Mbogo Family');
    });

    test('an unnamed tree falls back to a default name', () async {
      final tree = await trees.createTree('   ');
      expect(tree.name, isNotEmpty);
    });
  });
}

class _FailingSyncAdapter implements SyncAdapter {
  @override
  Future<void> pushPendingEvents(List<ClaimEvent> events) async {
    throw const SocketExceptionStub();
  }

  @override
  Stream<List<ClaimEvent>> incomingEvents() =>
      const Stream<List<ClaimEvent>>.empty();
}

class SocketExceptionStub implements Exception {
  const SocketExceptionStub();
}
