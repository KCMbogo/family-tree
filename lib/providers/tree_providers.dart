import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/claim_event.dart';
import '../domain/models/family_tree.dart';
import '../domain/models/media_item.dart';
import '../domain/models/person.dart';
import '../domain/models/relationship.dart';
import '../domain/services/timeline_builder.dart';
import '../domain/services/tree_layout.dart';
import 'app_providers.dart';

/// The user's primary tree, or null before onboarding.
final primaryTreeProvider = StreamProvider<FamilyTree?>((ref) {
  return ref.watch(familyTreeRepositoryProvider).watchPrimaryTree();
});

/// Everyone in the tree, from the materialised projection.
final personsProvider = StreamProvider<List<Person>>((ref) {
  return ref.watch(personRepositoryProvider).watchPersons();
});

final personProvider = StreamProvider.family<Person?, String>((ref, id) {
  return ref.watch(personRepositoryProvider).watchPerson(id);
});

/// The raw claim log for one entity — the provenance view.
final personHistoryProvider =
    StreamProvider.family<List<ClaimEvent>, String>((ref, id) {
  return ref.watch(personRepositoryProvider).watchHistory(id);
});

final relationshipsProvider = StreamProvider<List<Relationship>>((ref) {
  return ref.watch(familyTreeRepositoryProvider).watchRelationships();
});

final personRelationshipsProvider =
    StreamProvider.family<List<Relationship>, String>((ref, personId) {
  return ref
      .watch(familyTreeRepositoryProvider)
      .watchRelationshipsFor(personId);
});

final mediaForEntityProvider =
    StreamProvider.family<List<MediaItem>, String>((ref, entityId) {
  return ref.watch(mediaRepositoryProvider).watchForEntity(entityId);
});

final allMediaProvider = StreamProvider<List<MediaItem>>((ref) {
  return ref.watch(mediaRepositoryProvider).watchAll();
});

/// Resolves a media id to a file on disk, repairing a stale path if needed.
/// Returns null when the bytes are genuinely gone, so widgets can fall back
/// instead of showing a broken image.
final mediaFileProvider =
    FutureProvider.autoDispose.family<File?, String>((ref, mediaId) async {
  final media = ref.watch(mediaRepositoryProvider);
  final item = await media.findById(mediaId);
  if (item == null) return null;
  return media.resolveFile(item);
});

/// People indexed by id, for the many screens that need to resolve a
/// relationship's endpoints into names.
final personsByIdProvider = Provider<Map<String, Person>>((ref) {
  final persons = ref.watch(personsProvider).value ?? const <Person>[];
  return {for (final person in persons) person.id: person};
});

/// The generational layout, recomputed whenever people or links change.
final treeLayoutProvider = Provider<AsyncValue<TreeLayout>>((ref) {
  return _combine(
    ref.watch(personsProvider),
    ref.watch(relationshipsProvider),
    (persons, relationships) => TreeLayoutBuilder.compute(
      persons: persons,
      relationships: relationships,
    ),
  );
});

/// Births and marriages across the whole tree, in chronological order.
final timelineProvider = Provider<AsyncValue<List<TimelineEntry>>>((ref) {
  return _combine(
    ref.watch(personsProvider),
    ref.watch(relationshipsProvider),
    (persons, relationships) => TimelineBuilder.build(
      persons: persons,
      relationships: relationships,
    ),
  );
});

/// Joins two async sources into one, staying in loading until both have data
/// so the UI never renders a tree that is missing half its edges.
AsyncValue<R> _combine<A, B, R>(
  AsyncValue<A> first,
  AsyncValue<B> second,
  R Function(A, B) build,
) {
  if (first.hasError) {
    return AsyncValue.error(first.error!, first.stackTrace ?? StackTrace.empty);
  }
  if (second.hasError) {
    return AsyncValue.error(
        second.error!, second.stackTrace ?? StackTrace.empty);
  }
  if (!first.hasValue || !second.hasValue) return AsyncValue<R>.loading();
  return AsyncValue.data(build(first.requireValue, second.requireValue));
}
