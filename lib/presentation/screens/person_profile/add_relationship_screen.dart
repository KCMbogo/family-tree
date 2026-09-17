import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/models/person.dart';
import '../../../domain/models/relationship.dart';
import '../../../providers/app_providers.dart';
import '../../../providers/tree_providers.dart';
import '../../widgets/async_view.dart';
import '../../widgets/person_avatar.dart';
import '../../widgets/person_card.dart';

/// Feature §6.3 — link two existing people.
///
/// The relationship is phrased from the current person's point of view
/// ("Juma is the parent of …"), because that is how someone entering family
/// history thinks about it, and the repository stores the direction the
/// projector expects.
class AddRelationshipScreen extends ConsumerStatefulWidget {
  const AddRelationshipScreen({required this.personId, super.key});

  final String personId;

  @override
  ConsumerState<AddRelationshipScreen> createState() =>
      _AddRelationshipScreenState();
}

/// How the link reads from the subject's side, and which direction to store.
enum _LinkKind {
  parent('Parent of', 'is the parent of'),
  child('Child of', 'is the child of'),
  spouse('Spouse of', 'is married to'),
  sibling('Sibling of', 'is a sibling of');

  const _LinkKind(this.label, this.phrase);

  final String label;
  final String phrase;

  RelationshipType get type => switch (this) {
        _LinkKind.parent || _LinkKind.child => RelationshipType.parentOf,
        _LinkKind.spouse => RelationshipType.spouseOf,
        _LinkKind.sibling => RelationshipType.siblingOf,
      };

  /// `parent_of` always runs A → B as parent → child, so "child of" is the
  /// same edge with the endpoints swapped.
  bool get subjectIsPersonA => this != _LinkKind.child;
}

class _AddRelationshipScreenState
    extends ConsumerState<AddRelationshipScreen> {
  _LinkKind _kind = _LinkKind.parent;
  String? _otherId;
  final _marriageYear = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _marriageYear.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final otherId = _otherId;
    if (otherId == null) return;

    setState(() => _saving = true);
    try {
      await ref.read(familyTreeRepositoryProvider).addRelationship(
            personAId: _kind.subjectIsPersonA ? widget.personId : otherId,
            personBId: _kind.subjectIsPersonA ? otherId : widget.personId,
            type: _kind.type,
            marriageYear: _marriageYear.text,
          );
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subject = ref.watch(personProvider(widget.personId)).value;

    return Scaffold(
      appBar: AppBar(title: const Text('Add relationship')),
      body: AsyncView(
        value: ref.watch(personsProvider),
        builder: (context, people) {
          final candidates =
              people.where((p) => p.id != widget.personId).toList();

          if (candidates.isEmpty) {
            return const EmptyState(
              icon: Icons.group_add_outlined,
              title: 'Nobody to link to yet',
              message: 'Add another person to the tree first, then come back '
                  'to record how they are related.',
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              if (subject != null)
                Row(
                  children: [
                    PersonAvatar(person: subject, radius: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text.rich(
                        TextSpan(children: [
                          TextSpan(
                            text: subject.displayName,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600),
                          ),
                          TextSpan(text: ' ${_kind.phrase}…'),
                        ]),
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 24),
              Text('Relationship', style: theme.textTheme.labelLarge),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: [
                  for (final kind in _LinkKind.values)
                    ChoiceChip(
                      label: Text(kind.label),
                      selected: _kind == kind,
                      onSelected: (_) => setState(() => _kind = kind),
                    ),
                ],
              ),
              if (_kind == _LinkKind.spouse) ...[
                const SizedBox(height: 20),
                TextField(
                  controller: _marriageYear,
                  decoration: const InputDecoration(
                    labelText: 'Year married (optional)',
                    prefixIcon: Icon(Icons.favorite_outline),
                    helperText: 'Approximate is fine',
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Text('Who?', style: theme.textTheme.labelLarge),
              const SizedBox(height: 4),
              for (final person in candidates)
                _CandidateTile(
                  person: person,
                  selected: _otherId == person.id,
                  onTap: () => setState(() => _otherId = person.id),
                ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _otherId == null || _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save relationship'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CandidateTile extends StatelessWidget {
  const _CandidateTile({
    required this.person,
    required this.selected,
    required this.onTap,
  });

  final Person person;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: selected ? scheme.primaryContainer : null,
        border: Border.all(
          color: selected ? scheme.primary : scheme.outlineVariant,
        ),
      ),
      child: PersonListTile(
        person: person,
        onTap: onTap,
        trailing: selected
            ? Icon(Icons.check_circle, color: scheme.primary)
            : null,
      ),
    );
  }
}
