import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/database.dart';
import '../data/repositories/family_tree_repository.dart';
import '../data/repositories/media_repository.dart';
import '../data/repositories/person_repository.dart';
import '../data/repositories/sync_adapter.dart';

/// The local database. Nothing outside `data/` should ever watch this.
final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

/// The Phase 1 binding of the sync seam.
///
/// This single line is what Phase 2 changes:
/// `Provider<SyncAdapter>((ref) => RemoteSyncAdapter(...))`. Every screen and
/// every repository call stays exactly as it is.
final syncAdapterProvider = Provider<SyncAdapter>((ref) {
  return const NoopSyncAdapter();
});

final familyTreeRepositoryProvider = Provider<FamilyTreeRepository>((ref) {
  final repository = FamilyTreeRepository(
    database: ref.watch(databaseProvider),
    syncAdapter: ref.watch(syncAdapterProvider),
  );
  repository.start();
  ref.onDispose(repository.dispose);
  return repository;
});

final personRepositoryProvider = Provider<PersonRepository>((ref) {
  return PersonRepository(
    database: ref.watch(databaseProvider),
    claims: ref.watch(familyTreeRepositoryProvider),
  );
});

final mediaRepositoryProvider = Provider<MediaRepository>((ref) {
  return MediaRepository(database: ref.watch(databaseProvider));
});
