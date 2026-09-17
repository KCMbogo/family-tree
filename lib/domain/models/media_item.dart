import 'package:meta/meta.dart';

enum MediaType {
  photo('photo'),
  audio('audio'),
  document('document');

  const MediaType(this.wireName);

  final String wireName;

  static MediaType fromWire(String value) =>
      values.firstWhere((t) => t.wireName == value, orElse: () => photo);
}

/// A file attached to a person or claim event.
///
/// Identity is the [contentHash], not [localPath]: the path is an
/// implementation detail that changes across reinstalls and devices, while the
/// hash lets Phase 2 sync dedupe the same photo uploaded from two phones.
@immutable
class MediaItem {
  const MediaItem({
    required this.id,
    required this.contentHash,
    required this.localPath,
    required this.linkedEntityId,
    required this.mediaType,
    required this.createdAt,
    this.caption,
  });

  final String id;

  /// SHA-256 of the file bytes — the durable cross-device identity.
  final String contentHash;

  /// Resolved lazily and never assumed stable; see `MediaRepository.resolve`.
  final String localPath;

  final String linkedEntityId;
  final MediaType mediaType;
  final String? caption;
  final DateTime createdAt;

  MediaItem copyWith({String? localPath, String? caption}) => MediaItem(
        id: id,
        contentHash: contentHash,
        localPath: localPath ?? this.localPath,
        linkedEntityId: linkedEntityId,
        mediaType: mediaType,
        caption: caption ?? this.caption,
        createdAt: createdAt,
      );

  @override
  bool operator ==(Object other) =>
      other is MediaItem &&
      other.id == id &&
      other.localPath == localPath &&
      other.caption == caption;

  @override
  int get hashCode => Object.hash(id, localPath, caption);
}
