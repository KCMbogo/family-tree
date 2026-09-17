import 'package:flutter/material.dart';

import '../../domain/models/claim_event.dart';
import '../../domain/services/claim_projector.dart';
import 'async_view.dart';
import 'formatters.dart';

/// The raw claim log for one entity.
///
/// This is both the Phase 1 test harness for the event model and a preview of
/// the Phase 2 provenance UI: it shows every assertion ever made, marks which
/// one currently wins, and never hides what was superseded.
class ClaimHistoryList extends StatelessWidget {
  const ClaimHistoryList({required this.events, super.key});

  /// Newest first.
  final List<ClaimEvent> events;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const EmptyState(
        icon: Icons.history,
        title: 'No history yet',
        message: 'Every fact you record about this person will be listed '
            'here, with what was claimed and when.',
      );
    }

    // Folding client-side is how the list knows which claim is the one the
    // profile is currently showing — the same function the projection uses.
    final current = ClaimProjector.fold(events)
        .fields
        .values
        .map((event) => event.id)
        .toSet();

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: events.length,
      separatorBuilder: (_, _) => const Divider(indent: 64),
      itemBuilder: (context, index) => _ClaimTile(
        event: events[index],
        isCurrent: current.contains(events[index].id),
      ),
    );
  }
}

class _ClaimTile extends StatelessWidget {
  const _ClaimTile({required this.event, required this.isCurrent});

  final ClaimEvent event;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final (icon, tint) = switch ((event.isRetraction, isCurrent)) {
      (true, _) => (Icons.backspace_outlined, scheme.error),
      (false, true) => (Icons.check_circle_outline, scheme.primary),
      (false, false) => (Icons.history_toggle_off, scheme.onSurfaceVariant),
    };

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: tint.withValues(alpha: 0.12),
        child: Icon(icon, color: tint, size: 20),
      ),
      title: Text(
        describeClaim(event),
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
          color: isCurrent ? null : scheme.onSurfaceVariant,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          '${formatTimestamp(event.createdAt)}  ·  '
          '${describeSource(event.source)}',
          style: theme.textTheme.bodySmall
              ?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ),
      trailing: isCurrent && !event.isRetraction
          ? Chip(
              label: const Text('Current'),
              labelStyle: theme.textTheme.labelSmall
                  ?.copyWith(color: scheme.onPrimaryContainer),
              backgroundColor: scheme.primaryContainer,
              side: BorderSide.none,
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
            )
          : null,
      isThreeLine: false,
    );
  }
}
