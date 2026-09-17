import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/person.dart';
import '../../providers/tree_providers.dart';

/// A photo-first card for the Portraits style.
///
/// The picture is the point: the photo fills the card and the name sits over
/// it, so a tree of relatives you recognise reads at a glance. People without
/// a photo fall back to their initials on a tinted panel rather than leaving
/// an empty frame.
class PortraitCard extends ConsumerWidget {
  const PortraitCard({
    required this.person,
    required this.onTap,
    required this.width,
    required this.height,
    super.key,
  });

  final Person person;
  final VoidCallback onTap;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final mediaId = person.photoMediaId;
    final file =
        mediaId == null ? null : ref.watch(mediaFileProvider(mediaId)).value;

    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: scheme.surfaceContainerHighest,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: scheme.outlineVariant),
        ),
        child: InkWell(
          onTap: onTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (file != null)
                Image.file(file, fit: BoxFit.cover)
              else
                Container(
                  color: scheme.primaryContainer,
                  alignment: Alignment.center,
                  child: Text(
                    _initials(person.displayName),
                    style: TextStyle(
                      color: scheme.onPrimaryContainer,
                      fontSize: height * 0.26,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              // A scrim so the name stays legible over any photo.
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 16, 10, 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.78),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        person.displayName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1.15,
                        ),
                      ),
                      if (person.birthYearRaw != null)
                        Text(
                          person.isDeceased
                              ? '${person.birthYearRaw}  ·  †'
                              : 'b. ${person.birthYearRaw}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}
