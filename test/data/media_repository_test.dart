import 'dart:io';

import 'package:drift/native.dart';
import 'package:family_tree/data/local/database.dart';
import 'package:family_tree/data/repositories/media_repository.dart';
import 'package:family_tree/domain/models/media_item.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  late AppDatabase db;
  late Directory root;
  late Directory mediaDir;
  late MediaRepository media;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    root = Directory.systemTemp.createTempSync('family_tree_media_test');
    mediaDir = Directory(p.join(root.path, 'media'));
    media = MediaRepository(
      database: db,
      directoryResolver: () async => mediaDir,
    );
  });

  tearDown(() async {
    await db.close();
    if (root.existsSync()) root.deleteSync(recursive: true);
  });

  File sourceFile(String name, String contents) {
    final file = File(p.join(root.path, name));
    file.writeAsStringSync(contents);
    return file;
  }

  test('an attached photo is copied into app storage and hashed', () async {
    final item = await media.attach(
      linkedEntityId: 'person-1',
      file: sourceFile('photo.jpg', 'pretend jpeg bytes'),
    );

    expect(item.contentHash, hasLength(64));
    expect(item.mediaType, MediaType.photo);
    expect(File(item.localPath).existsSync(), isTrue);
    expect(p.dirname(item.localPath), mediaDir.path);
  });

  test('the file is named by content, not by the original filename', () async {
    final item = await media.attach(
      linkedEntityId: 'person-1',
      file: sourceFile('IMG_4021.jpg', 'bytes'),
    );

    expect(p.basenameWithoutExtension(item.localPath), item.contentHash);
    expect(p.extension(item.localPath), '.jpg');
  });

  test('identical bytes produce the same hash from different filenames',
      () async {
    final first = await media.attach(
      linkedEntityId: 'person-1',
      file: sourceFile('a.jpg', 'same bytes'),
    );
    final second = await media.attach(
      linkedEntityId: 'person-2',
      file: sourceFile('b.jpg', 'same bytes'),
    );

    expect(first.contentHash, second.contentHash);
    expect(first.id, isNot(second.id),
        reason: 'two people each have their own attachment');
    expect(mediaDir.listSync(), hasLength(1),
        reason: 'the bytes are stored once');
  });

  test('different bytes produce different hashes', () async {
    final first = await media.attach(
      linkedEntityId: 'person-1',
      file: sourceFile('a.jpg', 'one'),
    );
    final second = await media.attach(
      linkedEntityId: 'person-2',
      file: sourceFile('b.jpg', 'two'),
    );

    expect(first.contentHash, isNot(second.contentHash));
  });

  test('attaching the same file to the same person twice is idempotent',
      () async {
    final first = await media.attach(
      linkedEntityId: 'person-1',
      file: sourceFile('a.jpg', 'bytes'),
    );
    final second = await media.attach(
      linkedEntityId: 'person-1',
      file: sourceFile('a-copy.jpg', 'bytes'),
    );

    expect(second.id, first.id);
    expect(await media.watchForEntity('person-1').first, hasLength(1));
  });

  test('a stale stored path is repaired from the content hash', () async {
    final item = await media.attach(
      linkedEntityId: 'person-1',
      file: sourceFile('a.jpg', 'bytes'),
    );

    // Simulate the app container moving: the row still points at the old
    // absolute path, but the bytes are present under the current media dir.
    final moved = MediaItem(
      id: item.id,
      contentHash: item.contentHash,
      localPath: p.join('/nonexistent/old-container/media',
          p.basename(item.localPath)),
      linkedEntityId: item.linkedEntityId,
      mediaType: item.mediaType,
      createdAt: item.createdAt,
    );

    final resolved = await media.resolveFile(moved);

    expect(resolved, isNotNull);
    expect(resolved!.existsSync(), isTrue);
    expect(resolved.path, item.localPath);
  });

  test('resolving genuinely missing bytes returns null instead of throwing',
      () async {
    final resolved = await media.resolveFile(
      MediaItem(
        id: 'm1',
        contentHash: 'deadbeef',
        localPath: '/nonexistent/missing.jpg',
        linkedEntityId: 'person-1',
        mediaType: MediaType.photo,
        createdAt: DateTime.now().toUtc(),
      ),
    );

    expect(resolved, isNull);
  });

  test('captions can be set and cleared', () async {
    final item = await media.attach(
      linkedEntityId: 'person-1',
      file: sourceFile('a.jpg', 'bytes'),
    );

    await media.setCaption(item.id, '  Wedding day  ');
    expect((await media.findById(item.id))!.caption, 'Wedding day');

    await media.setCaption(item.id, '   ');
    expect((await media.findById(item.id))!.caption, isNull);
  });

  test('detaching keeps the bytes while another person still uses them',
      () async {
    final first = await media.attach(
      linkedEntityId: 'person-1',
      file: sourceFile('a.jpg', 'shared'),
    );
    final second = await media.attach(
      linkedEntityId: 'person-2',
      file: sourceFile('b.jpg', 'shared'),
    );

    await media.remove(first.id);

    expect(await media.findById(first.id), isNull);
    expect(File(second.localPath).existsSync(), isTrue);

    await media.remove(second.id);
    expect(File(second.localPath).existsSync(), isFalse);
  });
}
