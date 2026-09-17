import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:family_tree/data/local/database.dart';
import 'package:family_tree/data/repositories/family_tree_repository.dart';
import 'package:family_tree/data/repositories/person_repository.dart';
import 'package:family_tree/data/repositories/sync_adapter.dart';
import 'package:family_tree/main.dart';
import 'package:family_tree/providers/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Drives the relationship screens through the real app.
///
/// These exist because the picker's failures are *visual* — a swallowed ink
/// splash or a silently-dropped second parent analyses clean and only shows up
/// on a device.
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

  Future<void> withApp(
    WidgetTester tester,
    Future<void> Function() body,
  ) async {
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

    try {
      await body();
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 10));
    }
  }

  testWidgets('adding a person leads straight into linking them',
      (tester) async {
    await trees.createTree('Mbogo Family');
    await people.addPerson(fullName: 'Juma');

    await withApp(tester, () async {
      await tester.tap(find.text('Add person'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Full name'),
        'Asha',
      );
      await tester.ensureVisible(find.text('Add to tree'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add to tree'));
      await tester.pumpAndSettle();

      // Straight into the relationship step — no hunting for them first.
      expect(find.text('How are they related?'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Juma'), findsOneWidget);
    });
  });

  testWidgets('selecting a candidate shows a tick and no framework error',
      (tester) async {
    await trees.createTree('Mbogo Family');
    final juma = await people.addPerson(fullName: 'Juma');
    await people.addPerson(fullName: 'Asha');

    await withApp(tester, () async {
      await tester.tap(find.text('Juma'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ListTile, 'Asha').last);
      await tester.pumpAndSettle();

      // A swallowed ink splash raises a framework assertion rather than
      // failing a finder, so assert on that directly.
      expect(tester.takeException(), isNull);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    expect(juma, isNotEmpty);
  });

}
