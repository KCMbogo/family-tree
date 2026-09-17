import 'package:drift/drift.dart';

import '../../domain/models/claim_event.dart';
import '../../domain/models/family_tree.dart';
import '../../domain/models/media_item.dart';
import '../../domain/models/person.dart';
import '../../domain/models/relationship.dart';
import 'database.dart';

/// Translation between Drift rows and domain models.
///
/// Keeping this in one file is what enforces spec §2 rule 3: Drift types stop
/// at the repository boundary, and no widget ever sees a `*Row`.
///
/// Writes always go through companions with every column explicitly set —
/// including the null ones. Handing Drift a data class instead would let it
/// treat a null field as "leave unchanged", so a retraction would appear to
/// succeed while the stale value stayed in the projection.
extension ClaimEventRowMapper on ClaimEventRow {
  ClaimEvent toDomain() => ClaimEvent(
        id: id,
        entityId: entityId,
        entityType: EntityType.fromWire(entityType),
        field: field,
        value: value,
        authorId: authorId,
        source: source,
        confidence: confidence,
        createdAt: createdAt,
        synced: synced,
      );
}

extension ClaimEventMapper on ClaimEvent {
  ClaimEventsCompanion toCompanion() => ClaimEventsCompanion(
        id: Value(id),
        entityId: Value(entityId),
        entityType: Value(entityType.wireName),
        field: Value(field),
        value: Value(value),
        authorId: Value(authorId),
        source: Value(source),
        confidence: Value(confidence),
        createdAt: Value(createdAt),
        synced: Value(synced),
      );
}

extension PersonRowMapper on PersonRow {
  Person toDomain() => Person(
        id: id,
        fullName: fullName,
        birthYearRaw: birthYearRaw,
        birthYear: birthYear,
        birthPlace: birthPlace,
        gender: Gender.fromWire(gender),
        isDeceased: isDeceased,
        photoMediaId: photoMediaId,
        lastUpdatedAt: lastUpdatedAt,
        isRetracted: isRetracted,
      );
}

extension PersonMapper on Person {
  PersonsCompanion toCompanion() => PersonsCompanion(
        id: Value(id),
        fullName: Value(fullName),
        birthYearRaw: Value(birthYearRaw),
        birthYear: Value(birthYear),
        birthPlace: Value(birthPlace),
        gender: Value(gender?.wireName),
        isDeceased: Value(isDeceased),
        photoMediaId: Value(photoMediaId),
        lastUpdatedAt: Value(lastUpdatedAt),
        isRetracted: Value(isRetracted),
      );
}

extension RelationshipRowMapper on RelationshipRow {
  Relationship toDomain() => Relationship(
        id: id,
        personAId: personAId,
        personBId: personBId,
        type: RelationshipType.fromWire(relationshipType),
        claimEventId: claimEventId,
        marriageYearRaw: marriageYearRaw,
        marriageYear: marriageYear,
        lastUpdatedAt: lastUpdatedAt,
        isRetracted: isRetracted,
      );
}

extension RelationshipMapper on Relationship {
  RelationshipsCompanion toCompanion() => RelationshipsCompanion(
        id: Value(id),
        personAId: Value(personAId),
        personBId: Value(personBId),
        relationshipType: Value(type?.wireName),
        claimEventId: Value(claimEventId),
        marriageYearRaw: Value(marriageYearRaw),
        marriageYear: Value(marriageYear),
        lastUpdatedAt: Value(lastUpdatedAt),
        isRetracted: Value(isRetracted),
      );
}

extension MediaRowMapper on MediaRow {
  MediaItem toDomain() => MediaItem(
        id: id,
        contentHash: contentHash,
        localPath: localPath,
        linkedEntityId: linkedEntityId,
        mediaType: MediaType.fromWire(mediaType),
        caption: caption,
        createdAt: createdAt,
      );
}

extension MediaItemMapper on MediaItem {
  MediaItemsCompanion toCompanion() => MediaItemsCompanion(
        id: Value(id),
        contentHash: Value(contentHash),
        localPath: Value(localPath),
        linkedEntityId: Value(linkedEntityId),
        mediaType: Value(mediaType.wireName),
        caption: Value(caption),
        createdAt: Value(createdAt),
      );
}

extension FamilyTreeRowMapper on FamilyTreeRow {
  FamilyTree toDomain() =>
      FamilyTree(id: id, name: name, createdAt: createdAt);
}

extension FamilyTreeMapper on FamilyTree {
  FamilyTreesCompanion toCompanion() => FamilyTreesCompanion(
        id: Value(id),
        name: Value(name),
        createdAt: Value(createdAt),
      );
}
