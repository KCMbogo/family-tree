import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/media_item.dart';
import '../../../domain/models/person.dart';
import '../../../providers/app_providers.dart';
import '../../../providers/tree_providers.dart';
import '../../widgets/photo_picker.dart';

/// Feature §6.7 — photos attached to a person.
class PersonMediaStrip extends ConsumerWidget {
  const PersonMediaStrip({required this.person, super.key});

  final Person person;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final photos = ref.watch(mediaForEntityProvider(person.id)).value ??
        const <MediaItem>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
          child: Text('Photos', style: theme.textTheme.titleMedium),
        ),
        SizedBox(
          height: 108,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: photos.length + 1,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              if (index == 0) {
                return _AddPhotoTile(
                  onTap: () => _addPhoto(context, ref),
                );
              }
              final photo = photos[index - 1];
              return _PhotoThumbnail(
                item: photo,
                isProfilePhoto: person.photoMediaId == photo.id,
                onTap: () => _showOptions(context, ref, photo),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _addPhoto(BuildContext context, WidgetRef ref) async {
    final file = await pickPhoto(context);
    if (file == null) return;

    final media = await ref.read(mediaRepositoryProvider).attach(
          linkedEntityId: person.id,
          file: file,
        );

    // The first photo someone adds is almost always meant as the portrait.
    if (person.photoMediaId == null) {
      await ref
          .read(personRepositoryProvider)
          .setProfilePhoto(person.id, media.id);
    }
  }

  Future<void> _showOptions(
    BuildContext context,
    WidgetRef ref,
    MediaItem item,
  ) async {
    final isProfile = person.photoMediaId == item.id;

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isProfile)
              ListTile(
                leading: const Icon(Icons.account_circle_outlined),
                title: const Text('Use as profile photo'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  ref
                      .read(personRepositoryProvider)
                      .setProfilePhoto(person.id, item.id);
                },
              ),
            ListTile(
              leading: const Icon(Icons.edit_note_outlined),
              title: Text(item.caption == null
                  ? 'Add a caption'
                  : 'Edit caption'),
              onTap: () {
                Navigator.pop(sheetContext);
                _editCaption(context, ref, item);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Remove photo'),
              onTap: () {
                Navigator.pop(sheetContext);
                ref.read(mediaRepositoryProvider).remove(item.id);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _editCaption(
    BuildContext context,
    WidgetRef ref,
    MediaItem item,
  ) async {
    final controller = TextEditingController(text: item.caption ?? '');

    final caption = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Caption'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            hintText: 'e.g. At the farm in Moshi, 1974',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    controller.dispose();
    if (caption == null) return;
    await ref.read(mediaRepositoryProvider).setCaption(item.id, caption);
  }
}

class _AddPhotoTile extends StatelessWidget {
  const _AddPhotoTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 96,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: scheme.outlineVariant),
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo_outlined, color: scheme.primary),
            const SizedBox(height: 6),
            Text(
              'Add photo',
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoThumbnail extends ConsumerWidget {
  const _PhotoThumbnail({
    required this.item,
    required this.isProfilePhoto,
    required this.onTap,
  });

  final MediaItem item;
  final bool isProfilePhoto;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final file = ref.watch(mediaFileProvider(item.id)).value;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 96,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: scheme.surfaceContainerHighest,
          border: isProfilePhoto
              ? Border.all(color: scheme.primary, width: 2)
              : Border.all(color: scheme.outlineVariant),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (file != null)
              Image.file(file, fit: BoxFit.cover)
            else
              Icon(Icons.image_not_supported_outlined,
                  color: scheme.onSurfaceVariant),
            if (isProfilePhoto)
              Positioned(
                top: 4,
                right: 4,
                child: CircleAvatar(
                  radius: 10,
                  backgroundColor: scheme.primary,
                  child: Icon(Icons.check,
                      size: 13, color: scheme.onPrimary),
                ),
              ),
            if (item.caption != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  color: Colors.black.withValues(alpha: 0.55),
                  child: Text(
                    item.caption!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
