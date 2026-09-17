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
  const AddRelationshipScreen({
    required this.personId,
    this.isNewPerson = false,
    super.key,
  });

  final String personId;

  /// True when this screen follows straight on from creating the person, in
  /// which case it is a step in a flow rather than a standalone edit — so it
  /// offers Skip and confirms who was just added.
  final bool isNewPerson;

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

  /// The second parent for a new child. Null means "only this person" — how a
  /// child born outside the marriage is recorded.
  String? _secondParentId;
  bool _secondParentChosen = false;

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
    final trees = ref.read(familyTreeRepositoryProvider);

    try {
      switch (_kind) {
        case _LinkKind.parent:
          // Record both parents together, so the child is never momentarily
          // attached to one parent only — which would read as a different
          // family in the chart.
          await trees.addChild(
            childId: otherId,
            parentIds: [
              widget.personId,
              ?_secondParentId,
            ],
          );
        case _LinkKind.child:
          await trees.addChild(
            childId: widget.personId,
            parentIds: [
              otherId,
              ?_secondParentId,
            ],
          );
        case _LinkKind.spouse:
        case _LinkKind.sibling:
          await trees.addRelationship(
            personAId: widget.personId,
            personBId: otherId,
            type: _kind.type,
            marriageYear: _marriageYear.text,
          );
      }
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// Resets the second parent whenever the question it answers changes.
  void _setKind(_LinkKind kind) => setState(() {
        _kind = kind;
        _secondParentId = null;
        _secondParentChosen = false;
      });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subject = ref.watch(personProvider(widget.personId)).value;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isNewPerson
            ? 'How are they related?'
            : 'Add relationship'),
        actions: [
          if (widget.isNewPerson)
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Skip'),
            ),
        ],
      ),
      body: AsyncView(
        value: ref.watch(personsProvider),
        builder: (context, people) {
          final candidates =
              people.where((p) => p.id != widget.personId).toList();

          if (candidates.isEmpty) {
            return EmptyState(
              icon: Icons.group_add_outlined,
              title: 'Nobody to link to yet',
              message: widget.isNewPerson
                  ? 'This is the first person in your tree. Add someone else, '
                      'and you will be able to record how they are related.'
                  : 'Add another person to the tree first, then come back '
                      'to record how they are related.',
              action: widget.isNewPerson
                  ? FilledButton(
                      onPressed: () => context.pop(),
                      child: const Text('Done'),
                    )
                  : null,
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
                      onSelected: (_) => _setKind(kind),
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
              if (_kind == _LinkKind.parent || _kind == _LinkKind.child) ...[
                const SizedBox(height: 24),
                _OtherParentPicker(
                  // For "child of", the parent being picked is the other
                  // person, so their spouses are the candidates.
                  parentId:
                      _kind == _LinkKind.parent ? widget.personId : _otherId,
                  childId:
                      _kind == _LinkKind.parent ? _otherId : widget.personId,
                  selectedId: _secondParentId,
                  hasChosen: _secondParentChosen,
                  onChanged: (id) => setState(() {
                    _secondParentId = id;
                    _secondParentChosen = true;
                  }),
                  onDefaulted: (id) {
                    // Preselect the only spouse without rebuilding mid-build.
                    if (_secondParentChosen) return;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted || _secondParentChosen) return;
                      setState(() {
                        _secondParentId = id;
                        _secondParentChosen = true;
                      });
                    });
                  },
                ),
              ],
              const SizedBox(height: 24),
              Text(_kind == _LinkKind.parent ? 'Which child?' : 'Who?',
                  style: theme.textTheme.labelLarge),
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
                    : Text(widget.isNewPerson
                        ? 'Save and finish'
                        : 'Save relationship'),
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

    // The tile needs its own Material: a ListTile paints its background and
    // ink splash onto the nearest Material ancestor, so wrapping it in a
    // coloured Container would hide the tap ripple — the selection would feel
    // dead on a real device.
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Material(
        color: selected ? scheme.primaryContainer : Colors.transparent,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
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
      ),
    );
  }
}

/// Chooses the child's second parent.
///
/// A child belongs to a *pair* of parents, not one: recording only one leaves
/// the other spouse unlinked, and the chart then hangs the child off a single
/// person instead of the couple. When someone has several spouses there is no
/// safe guess, so the choice is explicit.
///
/// "Only `<name>`" is a first-class option, not an afterthought: children born
/// outside a marriage genuinely have one recorded parent here, and the layout
/// groups by the exact parent set, so such a child correctly forms their own
/// group rather than being absorbed into a couple's children.
class _OtherParentPicker extends ConsumerWidget {
  const _OtherParentPicker({
    required this.parentId,
    required this.childId,
    required this.selectedId,
    required this.hasChosen,
    required this.onChanged,
    required this.onDefaulted,
  });

  /// The parent whose spouses are offered. Null until picked.
  final String? parentId;

  /// The child being attached, excluded from the candidates.
  final String? childId;

  final String? selectedId;
  final bool hasChosen;
  final ValueChanged<String?> onChanged;
  final ValueChanged<String> onDefaulted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final id = parentId;
    if (id == null) return const SizedBox.shrink();

    final people = ref.watch(personsByIdProvider);
    final parent = people[id];
    final relationships =
        ref.watch(personRelationshipsProvider(id)).value ?? const [];

    final spouses = relationships
        .where((r) => r.isComplete && r.type == RelationshipType.spouseOf)
        .map((r) => r.otherPerson(id))
        .whereType<String>()
        .where((s) => s != childId)
        .toSet()
        .toList();

    if (spouses.isEmpty) return const SizedBox.shrink();

    // With exactly one spouse, that spouse is overwhelmingly the other parent,
    // so preselect it — but still show the choice, because the exception
    // matters and must stay one tap away.
    if (spouses.length == 1 && !hasChosen) onDefaulted(spouses.first);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Other parent', style: theme.textTheme.labelLarge),
        const SizedBox(height: 4),
        Text(
          'Who is the child’s other parent?',
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        RadioGroup<String?>(
          groupValue: selectedId,
          onChanged: onChanged,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final spouseId in spouses)
                if (people[spouseId] case final spouse?)
                  RadioListTile<String?>(
                    value: spouseId,
                    contentPadding: EdgeInsets.zero,
                    title: Text(spouse.displayName),
                    subtitle:
                        Text(_marriageLabel(relationships, id, spouseId)),
                  ),
              RadioListTile<String?>(
                value: null,
                contentPadding: EdgeInsets.zero,
                title: Text('Only ${parent?.displayName ?? 'this person'}'),
                subtitle: const Text('No second parent recorded'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _marriageLabel(
    List<Relationship> relationships,
    String parentId,
    String spouseId,
  ) {
    for (final r in relationships) {
      if (r.type != RelationshipType.spouseOf) continue;
      if (r.otherPerson(parentId) != spouseId) continue;
      if (r.marriageYearRaw != null) return 'Married ${r.marriageYearRaw}';
    }
    return 'Spouse';
  }
}
