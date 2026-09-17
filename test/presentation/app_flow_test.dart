import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:family_tree/data/local/database.dart';
import 'package:family_tree/data/repositories/family_tree_repository.dart';
import 'package:family_tree/data/repositories/person_repository.dart';
import 'package:family_tree/data/repositories/sync_adapter.dart';
import 'package:family_tree/domain/models/claim_event.dart';
import 'package:family_tree/main.dart';
import 'package:family_tree/providers/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late FamilyTreeRepository trees;
  late PersonRepository people;

  setUpAll(() {
    // Each test builds its own in-memory database on purpose.
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
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

  /// Runs [body] against the real app backed by an in-memory database.
  /// Everything else — the repositories, the router, the projections — is the
  /// production wiring, which is what makes these tests worth having: they
  /// prove the UI reaches the data only through repositories.
  ///
  /// The widget tree is disposed inside the test rather than left to the
  /// framework: Drift schedules a timer when its query streams are cancelled,
  /// and the binding fails a test that ends with a timer still pending.
  Future<void> withApp(
    WidgetTester tester,
    Future<void> Function() body,
  ) async {
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
      // A non-zero elapse is required: the timer Drift schedules on cancel is
      // zero-duration, and a zero-duration pump does not run it.
      await tester.pump(const Duration(milliseconds: 10));
    }
  }

  testWidgets('a first launch asks for a family name', (tester) async {
    await withApp(tester, () async {
      expect(find.text('Start your family tree'), findsOneWidget);
      expect(find.text('Create tree'), findsOneWidget);
    });
  });

  testWidgets('naming the family opens the empty tree', (tester) async {
    await withApp(tester, () async {
      await tester.enterText(find.byType(TextFormField), 'Mbogo Family');
      await tester.tap(find.text('Create tree'));
      await tester.pumpAndSettle();

      expect(find.text('Mbogo Family'), findsOneWidget);
      expect(find.text('Your tree is empty'), findsOneWidget);
    });
  });

  testWidgets('an existing tree skips straight to the tree view',
      (tester) async {
    await trees.createTree('Mbogo Family');

    await withApp(tester, () async {
      expect(find.text('Start your family tree'), findsNothing);
      expect(find.text('Mbogo Family'), findsOneWidget);
    });
  });

  testWidgets('people in the tree are rendered as cards', (tester) async {
    await trees.createTree('Mbogo Family');
    await people.addPerson(fullName: 'Juma Mbogo', birthYear: '1932');
    await people.addPerson(fullName: 'Asha Mbogo', birthYear: '1936');

    await withApp(tester, () async {
      expect(find.text('Juma Mbogo'), findsOneWidget);
      expect(find.text('Asha Mbogo'), findsOneWidget);
      expect(find.text('b. 1932'), findsOneWidget);
    });
  });

  testWidgets('tapping a person opens their profile', (tester) async {
    await trees.createTree('Mbogo Family');
    await people.addPerson(
      fullName: 'Juma Mbogo',
      birthYear: '1932',
      birthPlace: 'Moshi',
    );

    await withApp(tester, () async {
      await tester.tap(find.text('Juma Mbogo'));
      await tester.pumpAndSettle();

      expect(find.text('Details'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
      expect(find.text('Moshi'), findsOneWidget);
    });
  });

  testWidgets(
    'the history tab shows superseded claims alongside the current one',
    (tester) async {
      await trees.createTree('Mbogo Family');
      final id = await people.addPerson(fullName: 'Juma Mbogo');
      await people.addClaim(id, ClaimFields.birthYear, '1932');
      await people.addClaim(id, ClaimFields.birthYear, '1934');

      await withApp(tester, () async {
        await tester.tap(find.text('Juma Mbogo'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('History'));
        await tester.pumpAndSettle();

        // Both claims are listed; only the newer one wins.
        expect(find.text('Birth year: 1934'), findsOneWidget);
        expect(find.text('Birth year: 1932'), findsOneWidget);
        expect(find.text('Current'), findsNWidgets(2)); // name + birth year
      });
    },
  );

  testWidgets('the timeline lists births oldest first', (tester) async {
    await trees.createTree('Mbogo Family');
    await people.addPerson(fullName: 'Asha Mbogo', birthYear: '1960');
    await people.addPerson(fullName: 'Juma Mbogo', birthYear: 'around 1932');

    await withApp(tester, () async {
      await tester.tap(find.byIcon(Icons.timeline_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Juma Mbogo was born'), findsOneWidget);
      expect(find.text('1932'), findsOneWidget);

      final juma = tester.getTopLeft(find.text('Juma Mbogo was born'));
      final asha = tester.getTopLeft(find.text('Asha Mbogo was born'));
      expect(juma.dy, lessThan(asha.dy));
    });
  });

  testWidgets('the gallery explains how to add photos when empty',
      (tester) async {
    await trees.createTree('Mbogo Family');

    await withApp(tester, () async {
      await tester.tap(find.byIcon(Icons.photo_library_outlined));
      await tester.pumpAndSettle();

      expect(find.text('No photos yet'), findsOneWidget);
    });
  });

  testWidgets('editing a fact through the form appends a claim',
      (tester) async {
    await trees.createTree('Mbogo Family');
    final id = await people.addPerson(fullName: 'Juma', birthYear: '1932');

    await withApp(tester, () async {
      await tester.tap(find.text('Juma'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit_outlined));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Juma'),
        'Juma Mbogo',
      );
      await tester.dragUntilVisible(
        find.text('Save changes'),
        find.byType(ListView),
        const Offset(0, -120),
      );
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();
    });

    final nameClaims = (await db.claimEventDao.eventsForEntity(id))
        .where((e) => e.field == ClaimFields.name)
        .map((e) => e.value)
        .toList();

    expect(nameClaims, containsAll(<String>['"Juma"', '"Juma Mbogo"']));
    expect((await people.findPerson(id))!.fullName, 'Juma Mbogo');
  });
}
