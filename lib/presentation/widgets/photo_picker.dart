import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Asks where the photo should come from, then returns the chosen file.
///
/// Returns null if the user backs out or the pick fails — callers should treat
/// that as "no change", never as an error.
Future<File?> pickPhoto(BuildContext context) async {
  final source = await showModalBottomSheet<ImageSource>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Choose from gallery'),
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: const Text('Take a photo'),
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );

  if (source == null) return null;

  try {
    final picked = await ImagePicker().pickImage(
      source: source,
      // Family photos get viewed, not printed. Downscaling keeps storage
      // reasonable on the low-end Android devices this targets.
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 85,
    );
    return picked == null ? null : File(picked.path);
  } on Exception {
    return null;
  }
}
