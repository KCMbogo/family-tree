import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/models/person.dart';
import '../../../providers/app_providers.dart';
import '../../../providers/tree_providers.dart';
import '../../widgets/async_view.dart';
import '../../widgets/photo_picker.dart';

/// Features §6.2 and §6.6 — add a person, and edit their facts.
///
/// Editing looks like a normal form, but `PersonRepository.updateFacts` turns
/// each changed field into a new claim rather than overwriting anything. The
/// old value stays in the History tab.
class AddPersonScreen extends ConsumerWidget {
  const AddPersonScreen({this.personId, super.key});

  /// Null when adding someone new.
  final String? personId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = personId;
    if (id == null) return const _PersonForm();

    return AsyncView(
      value: ref.watch(personProvider(id)),
      builder: (context, person) => person == null
          ? const Scaffold(
              body: Center(child: Text('This person no longer exists.')),
            )
          : _PersonForm(person: person),
    );
  }
}

class _PersonForm extends ConsumerStatefulWidget {
  const _PersonForm({this.person});

  final Person? person;

  @override
  ConsumerState<_PersonForm> createState() => _PersonFormState();
}

class _PersonFormState extends ConsumerState<_PersonForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _birthYear;
  late final TextEditingController _birthPlace;

  Gender? _gender;
  bool _isDeceased = false;
  File? _pickedPhoto;
  bool _saving = false;

  bool get _isEditing => widget.person != null;

  @override
  void initState() {
    super.initState();
    final person = widget.person;
    _name = TextEditingController(text: person?.fullName ?? '');
    _birthYear = TextEditingController(text: person?.birthYearRaw ?? '');
    _birthPlace = TextEditingController(text: person?.birthPlace ?? '');
    _gender = person?.gender;
    _isDeceased = person?.isDeceased ?? false;
  }

  @override
  void dispose() {
    _name.dispose();
    _birthYear.dispose();
    _birthPlace.dispose();
    super.dispose();
  }

  Future<void> _choosePhoto() async {
    final file = await pickPhoto(context);
    if (file == null || !mounted) return;

    if (_isEditing) {
      await _attachPhoto(widget.person!.id, file);
    } else {
      // The person does not exist yet, so the photo is held until save.
      setState(() => _pickedPhoto = file);
    }
  }

  Future<void> _attachPhoto(String personId, File file) async {
    final media = await ref.read(mediaRepositoryProvider).attach(
          linkedEntityId: personId,
          file: file,
        );
    await ref.read(personRepositoryProvider).setProfilePhoto(
          personId,
          media.id,
        );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      final repository = ref.read(personRepositoryProvider);

      if (_isEditing) {
        await repository.updateFacts(
          widget.person!.id,
          fullName: _name.text,
          birthYear: _birthYear.text,
          birthPlace: _birthPlace.text,
          gender: (value: _gender),
          isDeceased: _isDeceased,
        );
      } else {
        final id = await repository.addPerson(
          fullName: _name.text,
          birthYear: _birthYear.text,
          birthPlace: _birthPlace.text,
          gender: _gender,
          isDeceased: _isDeceased,
        );
        final photo = _pickedPhoto;
        if (photo != null) await _attachPhoto(id, photo);
      }

      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit person' : 'Add person'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Center(child: _PhotoField(
              person: widget.person,
              pending: _pickedPhoto,
              onTap: _choosePhoto,
            )),
            const SizedBox(height: 28),
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Full name',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'A name is required'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _birthYear,
              decoration: const InputDecoration(
                labelText: 'Birth year',
                prefixIcon: Icon(Icons.cake_outlined),
                helperText: "Approximate is fine — e.g. 'around 1932'",
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _birthPlace,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Birth place',
                prefixIcon: Icon(Icons.place_outlined),
              ),
            ),
            const SizedBox(height: 24),
            Text('Gender', style: theme.textTheme.labelLarge),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: [
                for (final gender in Gender.values)
                  ChoiceChip(
                    label: Text(gender.label),
                    selected: _gender == gender,
                    onSelected: (selected) => setState(
                      () => _gender = selected ? gender : null,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              value: _isDeceased,
              onChanged: (value) => setState(() => _isDeceased = value),
              title: const Text('Deceased'),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_isEditing ? 'Save changes' : 'Add to tree'),
            ),
            if (_isEditing) ...[
              const SizedBox(height: 8),
              Text(
                'Saving records what changed as a new entry in this '
                "person's history. Nothing is overwritten.",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PhotoField extends ConsumerWidget {
  const _PhotoField({
    required this.person,
    required this.pending,
    required this.onTap,
  });

  final Person? person;
  final File? pending;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final mediaId = person?.photoMediaId;

    final existing =
        mediaId == null ? null : ref.watch(mediaFileProvider(mediaId)).value;
    final file = pending ?? existing;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          CircleAvatar(
            radius: 52,
            backgroundColor: scheme.primaryContainer,
            foregroundImage: file == null ? null : FileImage(file),
            child: Icon(
              Icons.person_outline,
              size: 44,
              color: scheme.onPrimaryContainer,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: scheme.primary,
              shape: BoxShape.circle,
              border: Border.all(color: scheme.surface, width: 2),
            ),
            child: Icon(
              Icons.photo_camera_outlined,
              size: 17,
              color: scheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
