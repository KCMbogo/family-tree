import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../domain/services/timeline_builder.dart';
import '../../../providers/tree_providers.dart';
import '../../widgets/async_view.dart';

/// Feature §6.8 — births and marriages across the whole tree, in order.
class TimelineScreen extends ConsumerWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Timeline')),
      body: AsyncView(
        value: ref.watch(timelineProvider),
        builder: (context, entries) {
          if (entries.isEmpty) {
            return const EmptyState(
              icon: Icons.timeline_outlined,
              title: 'Nothing dated yet',
              message: 'Record a birth year for someone, or the year a couple '
                  'married, and it will appear here.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: entries.length,
            itemBuilder: (context, index) => _TimelineTile(
              entry: entries[index],
              isFirst: index == 0,
              isLast: index == entries.length - 1,
            ),
          );
        },
      ),
    );
  }
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({
    required this.entry,
    required this.isFirst,
    required this.isLast,
  });

  final TimelineEntry entry;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final (icon, tint) = switch (entry.kind) {
      TimelineEventKind.birth => (Icons.child_care_outlined, scheme.primary),
      TimelineEventKind.marriage =>
        (Icons.favorite_outline, scheme.tertiary),
      TimelineEventKind.child =>
        (Icons.family_restroom_outlined, scheme.secondary),
      TimelineEventKind.death =>
        (Icons.local_florist_outlined, scheme.onSurfaceVariant),
    };

    return InkWell(
      onTap: entry.kind == TimelineEventKind.marriage
          ? null
          : () => context.push(Routes.person(entry.entityId)),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 74,
              child: Padding(
                padding: const EdgeInsets.only(top: 16, right: 8),
                child: Text(
                  entry.year?.toString() ?? '—',
                  textAlign: TextAlign.right,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: entry.isDated ? null : scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            // The spine: a continuous rail with a node per event.
            SizedBox(
              width: 32,
              child: Column(
                children: [
                  Expanded(
                    flex: 0,
                    child: Container(
                      width: 2,
                      height: 16,
                      color: isFirst
                          ? Colors.transparent
                          : scheme.outlineVariant,
                    ),
                  ),
                  Container(
                    height: 12,
                    width: 12,
                    decoration: BoxDecoration(
                      color: tint,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isLast
                          ? Colors.transparent
                          : scheme.outlineVariant,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 12, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(icon, size: 17, color: tint),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            entry.title,
                            style: theme.textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                    if (entry.detail != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        entry.detail!,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                    if (entry.subtitle != null || !entry.isDated) ...[
                      const SizedBox(height: 3),
                      Text(
                        [
                          if (!entry.isDated && entry.yearLabel != null)
                            entry.yearLabel!,
                          if (entry.subtitle != null) entry.subtitle!,
                        ].join('  ·  '),
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
