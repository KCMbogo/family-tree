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
            itemBuilder: (context, index) {
              final entry = entries[index];
              // A heading whenever the kind of event changes, so in-laws and
              // undated events are visibly separated rather than blending
              // into the run of births.
              final previous = index == 0 ? null : entries[index - 1];
              final heading = _headingFor(entry, previous);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (heading != null) _SectionHeading(text: heading),
                  _TimelineTile(
                    entry: entry,
                    isFirst: index == 0 || heading != null,
                    isLast: index == entries.length - 1,
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

/// The heading shown above [entry], or null when it continues the last one.
String? _headingFor(TimelineEntry entry, TimelineEntry? previous) {
  final current = _sectionOf(entry);
  if (previous == null) return current;
  return current == _sectionOf(previous) ? null : current;
}

String _sectionOf(TimelineEntry entry) {
  if (!entry.isDated) return 'Undated';
  if (entry.era != null) return entry.era!;
  return 'The family';
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 6),
      child: Row(
        children: [
          Text(
            text.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Divider(color: theme.colorScheme.outlineVariant),
          ),
        ],
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
