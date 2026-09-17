import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/person.dart';
import '../../providers/tree_providers.dart';

/// A person's profile photo, falling back to their initials.
///
/// Photo lookup goes through the media repository (which repairs stale paths
/// from the content hash), so a moved app container shows the photo rather
/// than a broken image.
class PersonAvatar extends ConsumerWidget {
  const PersonAvatar({required this.person, this.radius = 24, super.key});

  final Person person;
  final double radius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final mediaId = person.photoMediaId;

    final file = mediaId == null
        ? null
        : ref.watch(mediaFileProvider(mediaId)).value;

    return CircleAvatar(
      radius: radius,
      backgroundColor: scheme.primaryContainer,
      foregroundImage: file == null ? null : FileImage(file),
      child: Text(
        _initials(person.displayName),
        style: TextStyle(
          color: scheme.onPrimaryContainer,
          fontSize: radius * 0.72,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }
}
