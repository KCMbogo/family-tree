import '../../domain/models/claim_event.dart';

/// The seam between local storage and a future backend (spec §7).
///
/// This exists in Phase 1 as a no-op on purpose. `FamilyTreeRepository`
/// already pushes every locally-written claim through [pushPendingEvents] and
/// already applies anything arriving on [incomingEvents] through the same
/// projector it uses for local writes. So Phase 2 is: implement
/// `RemoteSyncAdapter`, change one provider binding, ship. No screen, no
/// repository call, and no table changes.
abstract class SyncAdapter {
  /// Called after claims are durably written locally. Local-first: a failure
  /// here must never lose or block the local write.
  Future<void> pushPendingEvents(List<ClaimEvent> events);

  /// Claims authored elsewhere. They are applied exactly like local ones —
  /// appended to the log, then folded — which is why conflict handling needs
  /// no separate code path: "latest claim wins" already covers it.
  Stream<List<ClaimEvent>> incomingEvents();
}

/// Phase 1 implementation: accepts everything, emits nothing.
class NoopSyncAdapter implements SyncAdapter {
  const NoopSyncAdapter();

  @override
  Future<void> pushPendingEvents(List<ClaimEvent> events) async {
    // Intentionally empty: there is no backend in Phase 1.
  }

  @override
  Stream<List<ClaimEvent>> incomingEvents() =>
      const Stream<List<ClaimEvent>>.empty();
}
