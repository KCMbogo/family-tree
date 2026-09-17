import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:family_tree/data/local/database.dart';
import 'package:family_tree/data/repositories/family_tree_repository.dart';
import 'package:family_tree/data/repositories/person_repository.dart';
import 'package:family_tree/data/repositories/sync_adapter.dart';
import 'package:family_tree/domain/models/relationship.dart';
import 'package:family_tree/domain/models/tree_style.dart';
import 'package:family_tree/main.dart';
import 'package:family_tree/providers/app_providers.dart';
import 'package:family_tree/providers/tree_style_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Every style must draw the same family — a style is a drawing concern, so
/// switching one must never change who appears or how they are related.
void main() {
  late AppDatabase db;
  late FamilyTreeRepository trees;
  late PersonRepository people;

  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    // There is no platform preference store under `flutter test`, so the
    // style controller would await a call that never returns.
    SharedPreferences.setMockInitialValues({});
  });

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    trees = FamilyTreeRepository(
      database: db,
      syncAdapter: const NoopSyncAdapter(),
    );
    people = PersonRepository(database: db, claims: trees);
  });

  tearDown(() => db.close());

  Future<void> seedFamily() async {
    await trees.createTree('Mbogo Family');
    final dad = await people.addPerson(fullName: 'Elias', birthYear: '1940');
    final mum = await people.addPerson(fullName: 'Marietha', birthYear: '1945');
    final kid = await people.addPerson(fullName: 'Charles', birthYear: '1970');

    await trees.addRelationship(
      personAId: dad, personBId: mum,
      type: RelationshipType.spouseOf, marriageYear: '1965',
    );
    await trees.addChild(childId: kid, parentIds: [dad, mum]);
  }

  Future<void> pumpWithStyle(WidgetTester tester, TreeStyle style) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const FamilyHeritageApp(),
      ),
    );
    await tester.pump();
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
    );
    await container.read(treeStyleProvider.notifier).select(style);
    await tester.pumpAndSettle();
  }

  for (final style in TreeStyle.values) {
    testWidgets('the ${style.label} style renders the whole family',
        (tester) async {
      await seedFamily();
      await pumpWithStyle(tester, style);

      try {
        for (final name in ['Elias', 'Marietha', 'Charles']) {
          expect(find.text(name), findsOneWidget, reason: '$name missing');
        }
        expect(tester.takeException(), isNull);

        // Compare the cards, not the labels: the Portraits style puts the
        // name at the bottom of the card rather than through its middle.
        Offset centreOf(String n) => tester.getCenter(
              find.ancestor(
                of: find.text(n),
                matching: find.byType(Material),
              ).first,
            );

        // Generations still stack, and the child still sits between the
        // parents, whatever the style.
        expect(centreOf('Elias').dy, lessThan(centreOf('Charles').dy));
        expect(centreOf('Elias').dy, closeTo(centreOf('Marietha').dy, 1.0));

        final parentsMid =
            (centreOf('Elias').dx + centreOf('Marietha').dx) / 2;
        expect(centreOf('Charles').dx, closeTo(parentsMid, 2.0));
      } finally {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(milliseconds: 10));
      }
    });
  }

  testWidgets('the style picker offers every style', (tester) async {
    await seedFamily();
    await pumpWithStyle(tester, TreeStyle.chart);

    try {
      await tester.tap(find.byIcon(Icons.palette_outlined));
      await tester.pumpAndSettle();

      for (final style in TreeStyle.values) {
        expect(
          find.widgetWithText(RadioListTile<TreeStyle>, style.label),
          findsOneWidget,
          reason: '${style.label} missing from the picker',
        );
        expect(find.text(style.description), findsOneWidget);
      }
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 10));
    }
  });

  test('an unknown stored style falls back to the default', () {
    expect(TreeStyle.fromWire(null), TreeStyle.chart);
    expect(TreeStyle.fromWire('nonsense'), TreeStyle.chart);
    expect(TreeStyle.fromWire('organic'), TreeStyle.organic);
  });
}
