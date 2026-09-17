import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:family_tree/data/local/database.dart';
import 'package:family_tree/data/repositories/family_tree_repository.dart';
import 'package:family_tree/data/repositories/person_repository.dart';
import 'package:family_tree/data/repositories/sync_adapter.dart';
import 'package:family_tree/domain/models/relationship.dart';
import 'package:family_tree/main.dart';
import 'package:family_tree/providers/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Renders a real three-generation family through the actual app, so the
/// chart is verified as pixels on screen and not only as layout numbers.
void main() {
  late AppDatabase db;
  late FamilyTreeRepository trees;
  late PersonRepository people;

  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    trees = FamilyTreeRepository(
      database: db,
      syncAdapter: const NoopSyncAdapter(),
    );
    people = PersonRepository(database: db, claims: trees);
  });

  tearDown(() => db.close());

  testWidgets('unconnected people are prompted to be linked', (tester) async {
    await trees.createTree('Mbogo Family');
    await people.addPerson(fullName: 'Juma', birthYear: '1930');
    await people.addPerson(fullName: 'Asha', birthYear: '1934');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const FamilyHeritageApp(),
      ),
    );
    await tester.pump();
    await tester.pumpAndSettle();

    try {
      expect(find.text('Connect'), findsOneWidget);
      expect(find.textContaining('Nobody is connected yet'), findsOneWidget);
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 10));
    }
  });

  testWidgets('the prompt disappears once people are linked', (tester) async {
    await trees.createTree('Mbogo Family');
    final a = await people.addPerson(fullName: 'Juma');
    final b = await people.addPerson(fullName: 'Asha');
    await trees.addRelationship(
      personAId: a, personBId: b, type: RelationshipType.spouseOf,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const FamilyHeritageApp(),
      ),
    );
    await tester.pump();
    await tester.pumpAndSettle();

    try {
      expect(find.text('Connect'), findsNothing);
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 10));
    }
  });

  testWidgets('a three-generation family renders as a chart', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await trees.createTree('Mbogo Family');

    final juma = await people.addPerson(fullName: 'Juma', birthYear: '1930');
    final asha = await people.addPerson(fullName: 'Asha', birthYear: '1934');
    final neema = await people.addPerson(fullName: 'Neema', birthYear: '1958');
    final baraka = await people.addPerson(fullName: 'Baraka', birthYear: '1956');
    final salim = await people.addPerson(fullName: 'Salim', birthYear: '1960');
    final amina = await people.addPerson(fullName: 'Amina', birthYear: '1985');

    await trees.addRelationship(
      personAId: juma, personBId: asha,
      type: RelationshipType.spouseOf, marriageYear: '1955',
    );
    for (final kid in [neema, salim]) {
      for (final parent in [juma, asha]) {
        await trees.addRelationship(
          personAId: parent, personBId: kid,
          type: RelationshipType.parentOf,
        );
      }
    }
    await trees.addRelationship(
      personAId: neema, personBId: baraka,
      type: RelationshipType.spouseOf,
    );
    for (final parent in [neema, baraka]) {
      await trees.addRelationship(
        personAId: parent, personBId: amina,
        type: RelationshipType.parentOf,
      );
    }

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const FamilyHeritageApp(),
      ),
    );
    await tester.pump();
    await tester.pumpAndSettle();

    try {
      // Everyone is on the chart.
      for (final name in ['Juma', 'Asha', 'Neema', 'Baraka', 'Salim', 'Amina']) {
        expect(find.text(name), findsOneWidget, reason: '$name missing');
      }

      Offset centreOf(String name) => tester.getCenter(find.text(name));

      // Generations stack vertically, oldest at the top.
      expect(centreOf('Juma').dy, lessThan(centreOf('Neema').dy));
      expect(centreOf('Neema').dy, lessThan(centreOf('Amina').dy));

      // Spouses share a row.
      expect(centreOf('Juma').dy, closeTo(centreOf('Asha').dy, 1.0));
      expect(centreOf('Neema').dy, closeTo(centreOf('Baraka').dy, 1.0));

      // Siblings share a row.
      expect(centreOf('Neema').dy, closeTo(centreOf('Salim').dy, 1.0));

      // The child sits between their parents horizontally.
      final parentsMid =
          (centreOf('Neema').dx + centreOf('Baraka').dx) / 2;
      expect(centreOf('Amina').dx, closeTo(parentsMid, 2.0));
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 10));
    }
  });
}
