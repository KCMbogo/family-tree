# Family Heritage — Phase 1

A mobile-first family heritage app for Flutter, Android-first. Fully
standalone and offline: no login, no server, no network calls.

It is built on an append-only claim log rather than mutable records, so the
question "who said this about this person, and when?" is answerable from day
one — and so adding a backend later is additive rather than a rewrite.

## Running it

```bash
flutter pub get
dart run build_runner build        # generates lib/data/local/database.g.dart
flutter run                        # or: flutter test
```

Re-run `build_runner` after changing anything under `lib/data/local/tables/`.

## How the data model works

Nothing in this app writes a field on a person. Every fact is a `ClaimEvent`
appended to `claim_events`, and the `persons` / `relationships` tables are
projections folded from that log by `ClaimProjector`.

```
UI (widgets)
  → repositories (FamilyTreeRepository, PersonRepository, MediaRepository)
     → claim_events  (append-only, the source of truth)
     → ClaimProjector.fold()  (pure function, no I/O)
        → persons / relationships  (read-optimised projections)
     → SyncAdapter.pushPendingEvents()  (no-op in Phase 1)
```

Consequences worth knowing before changing anything:

- **Editing a fact appends a new claim.** The old value is superseded, never
  overwritten, and stays visible in a person's History tab.
- **Deleting is a retraction claim** (`field = '_retracted'`), not a row
  delete. Retracting `'*'` removes the whole entity from view. The claims that
  created it — and the removal itself — remain in the log.
- **The projections hold no state of their own.** `rebuildAllProjections()`
  drops and rebuilds them from the log at any time; a test asserts the result
  is identical.
- **Every id is a client-generated UUID v4**, so ids from two devices can never
  collide once sync exists.
- **Every claim carries `author_id` and `source`**, even though Phase 1 has a
  single hardcoded local author (`lib/app/constants.dart`).

### Ordering

"Latest claim wins" is decided by `ClaimProjector.compare`: `created_at`, then
event id as a deterministic tiebreaker. Two details make that reliable:

- timestamps are stored as ISO-8601 **text** (`build.yaml`), not unix seconds,
  so edits made moments apart stay distinguishable;
- history lists are re-sorted in Dart rather than by SQL, because Dart's
  ISO-8601 output varies between three and six fractional digits and would sort
  inconsistently as text.

## Layout

```
lib/
  app/           constants (local author id), theme, router
  data/
    local/       Drift database, tables, row↔model mappers
    repositories/ the only things that touch the database
  domain/
    models/      Person, Relationship, ClaimEvent, MediaItem, FamilyTree
    services/    ClaimProjector, TreeLayoutBuilder, TimelineBuilder — all pure
  presentation/  screens and widgets
  providers/     Riverpod bindings over the repositories
```

Two rules keep this honest and are worth enforcing in review:

1. **No widget imports anything from `data/local/`.** Drift types stop at the
   repository boundary; `mappers.dart` is the only translation point.
2. **Only `FamilyTreeRepository.recordClaims` writes claims.** It appends,
   refolds and pushes to the sync adapter in one place, so no call site can
   skip a step or forget the author id.

## The tree chart

`TreeLayoutBuilder` produces a genealogical chart, not a grid. The recursive
unit is a **family** (a couple plus their children) rather than a person:

- generations are assigned by relaxation, keeping spouses and siblings level
  and tolerating cycles in hand-entered data;
- couples are packed as one block, sitting side by side;
- subtrees are packed left to right, then a bottom-up `_recentre()` pass slides
  each couple onto the midpoint of its children, so parents sit centred above
  their sibling group;
- children of one couple share a single descent origin, which is what draws as
  a sibling bar.

Positions are **continuous** (`TreeNode.x`, in card pitches) and mean a card's
*centre*. An integer column grid cannot place a child at the midpoint between
two parents, which is the single most recognisable feature of a family tree —
that was the original bug, and `test/domain/tree_layout_test.dart` now pins the
centring, ordering and no-overlap properties.

## Media

Files are identified by the SHA-256 of their bytes, not by path. The path is
treated as a cache that can go stale — `MediaRepository.resolveFile` repairs it
from the hash when the app container moves. Identical bytes are stored once.

## Adding the backend (Phase 2)

The seam is `lib/data/repositories/sync_adapter.dart`:

```dart
abstract class SyncAdapter {
  Future<void> pushPendingEvents(List<ClaimEvent> events);
  Stream<List<ClaimEvent>> incomingEvents();
}
```

`FamilyTreeRepository` already pushes every local claim through it and already
applies incoming claims through the same projector as local writes. To go live:

1. implement `RemoteSyncAdapter`;
2. change `syncAdapterProvider` in `lib/providers/app_providers.dart` to return
   it;
3. replace `kLocalAuthorId` with the signed-in user's id.

No screen, no repository call and no table changes. `ClaimEventDao` exposes
`pendingEvents()` for the backlog, and `synced` and `confidence` columns are
already in place for the sync bookkeeping and AI-extracted claims.

Conflict handling needs no new code path: remote claims fold by the same
"latest wins, history preserved" rule as local ones.

## Tests

```bash
flutter test
```

87 tests. The ones that matter most:

- `test/data/event_sourcing_test.dart` and `test/domain/claim_projector_test.dart`
  pin the behaviour the whole trust model depends on: two conflicting claims
  leave the latest winning in the projection while both stay in the history.
- `test/domain/tree_layout_test.dart` pins the chart's genealogical properties
  (centring, sibling order, no overlap, nobody dropped).
- `test/presentation/tree_render_test.dart` renders a real three-generation
  family through the app and checks the geometry in pixels.

## Not in this phase

Accounts, any network call, sharing/invites, payments, AI transcription,
multi-device sync, family book generation, and dispute resolution. The History
tab is read-only provenance, not an approval flow.
