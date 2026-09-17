import 'package:drift/drift.dart';

/// Named trees (spec §5.5).
///
/// Phase 1 uses a single primary tree, but the table exists so multi-tree
/// support is additive rather than a migration.
@DataClassName('FamilyTreeRow')
class FamilyTrees extends Table {
  TextColumn get id => text()();

  TextColumn get name => text()();

  DateTimeColumn get createdAt => dateTime().named('created_at')();

  @override
  Set<Column> get primaryKey => {id};
}
