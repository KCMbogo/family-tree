import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../domain/models/media_item.dart';
import '../local/database.dart';
import '../local/mappers.dart';

const _uuid = Uuid();

/// Where media files live. Injectable so tests can use a temp directory
/// instead of the platform's documents directory.
typedef MediaDirectoryResolver = Future<Directory> Function();

/// Stores photos, audio and documents on disk and indexes them by content.
///
/// Files are named by their SHA-256, so identical bytes are stored once no
/// matter how many people they are attached to, and so Phase 2 can dedupe
/// across devices — the hash is the identity, the path is a cache.
class MediaRepository {
  MediaRepository({
    required AppDatabase database,
    MediaDirectoryResolver? directoryResolver,
  })  : _db = database,
        _resolveDirectory = directoryResolver ?? _defaultDirectory;

  final AppDatabase _db;
  final MediaDirectoryResolver _resolveDirectory;

  static Future<Directory> _defaultDirectory() async {
    final documents = await getApplicationDocumentsDirectory();
    return Directory(p.join(documents.path, 'media'));
  }

  /// Copies [file] into app storage and records it against [linkedEntityId].
  ///
  /// Attaching the same bytes to the same entity twice returns the existing
  /// item rather than creating a duplicate.
  Future<MediaItem> attach({
    required String linkedEntityId,
    required File file,
    MediaType mediaType = MediaType.photo,
    String? caption,
  }) async {
    final contentHash = await _hashOf(file);

    final existing =
        await _db.mediaDao.findByHash(contentHash, linkedEntityId);
    if (existing != null) {
      return (await _revalidate(existing.toDomain())) ?? existing.toDomain();
    }

    final directory = await _mediaDirectory();
    final extension = p.extension(file.path).toLowerCase();
    final destination = File(p.join(directory.path, '$contentHash$extension'));

    // Same bytes may already be on disk from another attachment.
    if (!destination.existsSync()) {
      await file.copy(destination.path);
    }

    final item = MediaItem(
      id: _uuid.v4(),
      contentHash: contentHash,
      localPath: destination.path,
      linkedEntityId: linkedEntityId,
      mediaType: mediaType,
      caption: _normalise(caption),
      createdAt: DateTime.now().toUtc(),
    );

    await _db.mediaDao.upsertMedia(item.toCompanion());
    return item;
  }

  /// Returns the file for [item], repairing the stored path if the app's
  /// container moved (which happens on iOS between launches and on Android
  /// after a restore). The content hash is what makes this recoverable.
  Future<File?> resolveFile(MediaItem item) async {
    final stored = File(item.localPath);
    if (stored.existsSync()) return stored;

    final repaired = await _revalidate(item);
    if (repaired == null) return null;
    return File(repaired.localPath);
  }

  Future<MediaItem?> _revalidate(MediaItem item) async {
    if (File(item.localPath).existsSync()) return item;

    final directory = await _mediaDirectory();
    final candidate =
        File(p.join(directory.path, p.basename(item.localPath)));
    if (!candidate.existsSync()) return null;

    final repaired = item.copyWith(localPath: candidate.path);
    await _db.mediaDao.upsertMedia(repaired.toCompanion());
    return repaired;
  }

  Future<MediaItem?> findById(String id) async =>
      (await _db.mediaDao.findById(id))?.toDomain();

  Stream<List<MediaItem>> watchForEntity(String linkedEntityId) => _db.mediaDao
      .watchForEntity(linkedEntityId)
      .map((rows) => rows.map((row) => row.toDomain()).toList());

  Stream<List<MediaItem>> watchAll() => _db.mediaDao
      .watchAll()
      .map((rows) => rows.map((row) => row.toDomain()).toList());

  /// Sets or clears a caption. Passing null or blank clears it.
  Future<void> setCaption(String id, String? caption) async {
    final row = await _db.mediaDao.findById(id);
    if (row == null) return;

    final trimmed = caption?.trim();
    final item = row.toDomain();
    await _db.mediaDao.upsertMedia(
      MediaItem(
        id: item.id,
        contentHash: item.contentHash,
        localPath: item.localPath,
        linkedEntityId: item.linkedEntityId,
        mediaType: item.mediaType,
        caption: (trimmed == null || trimmed.isEmpty) ? null : trimmed,
        createdAt: item.createdAt,
      ).toCompanion(),
    );
  }

  /// Detaches media. The file itself is only deleted once nothing else refers
  /// to the same bytes.
  Future<void> remove(String id) async {
    final row = await _db.mediaDao.findById(id);
    if (row == null) return;

    await _db.mediaDao.deleteMedia(id);

    // Another person may have the same photo attached; those rows still point
    // at this file, so only the last reference may delete the bytes.
    final remaining = await _db.mediaDao.findAllByHash(row.contentHash);
    if (remaining.isNotEmpty) return;

    final file = File(row.localPath);
    if (file.existsSync()) {
      try {
        await file.delete();
      } on FileSystemException {
        // Leaving an orphaned file is harmless; failing the detach is not.
      }
    }
  }

  Future<Directory> _mediaDirectory() async {
    final directory = await _resolveDirectory();
    if (!directory.existsSync()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  static String? _normalise(String? text) {
    final trimmed = text?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }

  /// Streams the file rather than loading it, so a large photo or a long audio
  /// recording does not have to fit in memory on a low-end device.
  static Future<String> _hashOf(File file) async {
    final digest = await sha256.bind(file.openRead()).first;
    return digest.toString();
  }
}
