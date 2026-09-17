import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../domain/models/person.dart';
import '../../../domain/models/relationship.dart';
import '../../../providers/app_providers.dart';
import '../../../providers/tree_providers.dart';
import '../../widgets/async_view.dart';
import '../../widgets/claim_history_list.dart';
import '../../widgets/person_avatar.dart';
import '../../widgets/person_card.dart';
import 'person_media_strip.dart';

/// Feature §6.5 — current facts, photos, relationships, and the raw claim log
/// that produced them.
class PersonProfileScreen extends ConsumerWidget {
  const PersonProfileScreen({required this.personId, super.key});

  final String personId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AsyncView(
      value: ref.watch(personProvider(personId)),
      loading: const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      builder: (context, person) {
        if (person == null || person.isRetracted) {
          return Scaffold(
            appBar: AppBar(),
            body: const EmptyState(
              icon: Icons.person_off_outlined,
              title: 'Not in the tree',
              message: 'This person has been removed. Their recorded history '
                  'is kept, but they no longer appear in the tree.',
            ),
          );
        }
        return _ProfileView(person: person);
      },
    );
  }
}

class _ProfileView extends ConsumerWidget {
  const _ProfileView({required this.person});

  final Person person;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(person.displayName),
          actions: [
            IconButton(
              tooltip: 'Edit',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => context.push(Routes.editPerson(person.id)),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'remove') _confirmRemoval(context, ref);
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'remove',
                  child: Text('Remove from tree'),
                ),
              ],
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Details'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _DetailsTab(person: person),
            AsyncView(
              value: ref.watch(personHistoryProvider(person.id)),
              builder: (context, events) => ClaimHistoryList(events: events),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmRemoval(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove ${person.displayName}?'),
        content: const Text(
          'They will no longer appear in the tree. Everything recorded about '
          'them is kept in their history, and the removal is recorded too.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    await ref.read(personRepositoryProvider).removePerson(person.id);
    if (context.mounted) context.pop();
  }
}

class _DetailsTab extends ConsumerWidget {
  const _DetailsTab({required this.person});

  final Person person;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        const SizedBox(height: 20),
        Center(child: PersonAvatar(person: person, radius: 48)),
        const SizedBox(height: 14),
        Center(
          child: Text(
            person.displayName,
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        if (person.isDeceased) ...[
          const SizedBox(height: 8),
          const Center(
            child: Chip(
              label: Text('Deceased'),
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
        const SizedBox(height: 24),
        _FactRow(
          icon: Icons.cake_outlined,
          label: 'Born',
          value: person.birthYearRaw,
        ),
        _FactRow(
          icon: Icons.place_outlined,
          label: 'Birth place',
          value: person.birthPlace,
        ),
        _FactRow(
          icon: Icons.person_outline,
          label: 'Gender',
          value: person.gender?.label,
        ),
        const SizedBox(height: 8),
        PersonMediaStrip(person: person),
        const SizedBox(height: 8),
        _RelationshipsSection(person: person),
      ],
    );
  }
}

class _FactRow extends StatelessWidget {
  const _FactRow({required this.icon, required this.label, this.value});

  final IconData icon;
  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final known = value != null && value!.isNotEmpty;

    return ListTile(
      dense: true,
      leading: Icon(icon, color: theme.colorScheme.onSurfaceVariant),
      title: Text(label, style: theme.textTheme.bodySmall),
      subtitle: Text(
        known ? value! : 'Not recorded',
        style: theme.textTheme.bodyLarge?.copyWith(
          color: known ? null : theme.colorScheme.onSurfaceVariant,
          fontStyle: known ? null : FontStyle.italic,
        ),
      ),
    );
  }
}

class _RelationshipsSection extends ConsumerWidget {
  const _RelationshipsSection({required this.person});

  final Person person;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final people = ref.watch(personsByIdProvider);

    return AsyncView(
      value: ref.watch(personRelationshipsProvider(person.id)),
      loading: const SizedBox.shrink(),
      builder: (context, relationships) {
        final groups = _group(relationships, person.id);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Family', style: theme.textTheme.titleMedium),
                  TextButton.icon(
                    onPressed: () =>
                        context.push(Routes.addRelationship(person.id)),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add'),
                  ),
                ],
              ),
            ),
            if (groups.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'No relationships recorded yet.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            for (final group in groups.entries) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Text(
                  group.key,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              for (final entry in group.value)
                if (people[entry.personId] case final related?)
                  PersonListTile(
                    person: related,
                    subtitle: entry.detail,
                    onTap: () => context.push(Routes.person(related.id)),
                    trailing: IconButton(
                      tooltip: 'Remove this link',
                      icon: const Icon(Icons.link_off, size: 20),
                      onPressed: () => ref
                          .read(familyTreeRepositoryProvider)
                          .removeRelationship(entry.relationshipId),
                    ),
                  ),
            ],
          ],
        );
      },
    );
  }

  /// Turns the undirected edge list into the four groups people expect to see.
  static Map<String, List<_RelatedPerson>> _group(
    List<Relationship> relationships,
    String personId,
  ) {
    final groups = <String, List<_RelatedPerson>>{};

    // One row per related person per group. Older data can hold the same fact
    // as two edges (it was once possible to record a child from each parent's
    // profile), and a relative must never be listed twice because of that.
    final seen = <String>{};

    void add(String label, _RelatedPerson entry) {
      if (!seen.add('$label|${entry.personId}')) return;
      groups.putIfAbsent(label, () => []).add(entry);
    }

    for (final relationship in relationships) {
      if (!relationship.isComplete) continue;
      final other = relationship.otherPerson(personId);
      if (other == null) continue;

      final entry = _RelatedPerson(
        personId: other,
        relationshipId: relationship.id,
        detail: relationship.type == RelationshipType.spouseOf &&
                relationship.marriageYearRaw != null
            ? 'Married ${relationship.marriageYearRaw}'
            : null,
      );

      switch (relationship.type!) {
        case RelationshipType.parentOf:
          add(relationship.personAId == personId ? 'Children' : 'Parents',
              entry);
        case RelationshipType.spouseOf:
          add('Spouses', entry);
        case RelationshipType.siblingOf:
          add('Siblings', entry);
      }
    }

    // A stable, generationally sensible order.
    const order = ['Parents', 'Spouses', 'Siblings', 'Children'];
    return {
      for (final label in order)
        if (groups.containsKey(label)) label: groups[label]!,
    };
  }
}

class _RelatedPerson {
  const _RelatedPerson({
    required this.personId,
    required this.relationshipId,
    this.detail,
  });

  final String personId;
  final String relationshipId;
  final String? detail;
}
