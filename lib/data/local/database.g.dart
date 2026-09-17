// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ClaimEventsTable extends ClaimEvents
    with TableInfo<$ClaimEventsTable, ClaimEventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClaimEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fieldMeta = const VerificationMeta('field');
  @override
  late final GeneratedColumn<String> field = GeneratedColumn<String>(
    'field',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorIdMeta = const VerificationMeta(
    'authorId',
  );
  @override
  late final GeneratedColumn<String> authorId = GeneratedColumn<String>(
    'author_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entityId,
    entityType,
    field,
    value,
    authorId,
    source,
    confidence,
    createdAt,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'claim_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<ClaimEventRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('field')) {
      context.handle(
        _fieldMeta,
        field.isAcceptableOrUnknown(data['field']!, _fieldMeta),
      );
    } else if (isInserting) {
      context.missing(_fieldMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('author_id')) {
      context.handle(
        _authorIdMeta,
        authorId.isAcceptableOrUnknown(data['author_id']!, _authorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_authorIdMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ClaimEventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClaimEventRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      field: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}field'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      authorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author_id'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
    );
  }

  @override
  $ClaimEventsTable createAlias(String alias) {
    return $ClaimEventsTable(attachedDatabase, alias);
  }
}

class ClaimEventRow extends DataClass implements Insertable<ClaimEventRow> {
  /// Client-generated UUID v4.
  final String id;

  /// The person or relationship this claim is about.
  final String entityId;

  /// `'person'` | `'relationship'`.
  final String entityType;

  /// e.g. `'birth_year'`, `'name'`, `'relationship_type'`.
  final String field;

  /// JSON-encoded, so one column carries strings, numbers and booleans.
  final String value;

  /// Hardcoded local-user UUID in Phase 1; the signed-in user in Phase 2.
  final String authorId;

  /// e.g. `'user_input'`, `'imported'`.
  final String source;

  /// Reserved for Phase 2 AI-extracted claims; unused now.
  final double? confidence;

  /// Device local time, stored as UTC.
  final DateTime createdAt;

  /// Always false in Phase 1; the sync adapter owns this in Phase 2.
  final bool synced;
  const ClaimEventRow({
    required this.id,
    required this.entityId,
    required this.entityType,
    required this.field,
    required this.value,
    required this.authorId,
    required this.source,
    this.confidence,
    required this.createdAt,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entity_id'] = Variable<String>(entityId);
    map['entity_type'] = Variable<String>(entityType);
    map['field'] = Variable<String>(field);
    map['value'] = Variable<String>(value);
    map['author_id'] = Variable<String>(authorId);
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || confidence != null) {
      map['confidence'] = Variable<double>(confidence);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  ClaimEventsCompanion toCompanion(bool nullToAbsent) {
    return ClaimEventsCompanion(
      id: Value(id),
      entityId: Value(entityId),
      entityType: Value(entityType),
      field: Value(field),
      value: Value(value),
      authorId: Value(authorId),
      source: Value(source),
      confidence: confidence == null && nullToAbsent
          ? const Value.absent()
          : Value(confidence),
      createdAt: Value(createdAt),
      synced: Value(synced),
    );
  }

  factory ClaimEventRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ClaimEventRow(
      id: serializer.fromJson<String>(json['id']),
      entityId: serializer.fromJson<String>(json['entityId']),
      entityType: serializer.fromJson<String>(json['entityType']),
      field: serializer.fromJson<String>(json['field']),
      value: serializer.fromJson<String>(json['value']),
      authorId: serializer.fromJson<String>(json['authorId']),
      source: serializer.fromJson<String>(json['source']),
      confidence: serializer.fromJson<double?>(json['confidence']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entityId': serializer.toJson<String>(entityId),
      'entityType': serializer.toJson<String>(entityType),
      'field': serializer.toJson<String>(field),
      'value': serializer.toJson<String>(value),
      'authorId': serializer.toJson<String>(authorId),
      'source': serializer.toJson<String>(source),
      'confidence': serializer.toJson<double?>(confidence),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  ClaimEventRow copyWith({
    String? id,
    String? entityId,
    String? entityType,
    String? field,
    String? value,
    String? authorId,
    String? source,
    Value<double?> confidence = const Value.absent(),
    DateTime? createdAt,
    bool? synced,
  }) => ClaimEventRow(
    id: id ?? this.id,
    entityId: entityId ?? this.entityId,
    entityType: entityType ?? this.entityType,
    field: field ?? this.field,
    value: value ?? this.value,
    authorId: authorId ?? this.authorId,
    source: source ?? this.source,
    confidence: confidence.present ? confidence.value : this.confidence,
    createdAt: createdAt ?? this.createdAt,
    synced: synced ?? this.synced,
  );
  ClaimEventRow copyWithCompanion(ClaimEventsCompanion data) {
    return ClaimEventRow(
      id: data.id.present ? data.id.value : this.id,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      field: data.field.present ? data.field.value : this.field,
      value: data.value.present ? data.value.value : this.value,
      authorId: data.authorId.present ? data.authorId.value : this.authorId,
      source: data.source.present ? data.source.value : this.source,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClaimEventRow(')
          ..write('id: $id, ')
          ..write('entityId: $entityId, ')
          ..write('entityType: $entityType, ')
          ..write('field: $field, ')
          ..write('value: $value, ')
          ..write('authorId: $authorId, ')
          ..write('source: $source, ')
          ..write('confidence: $confidence, ')
          ..write('createdAt: $createdAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entityId,
    entityType,
    field,
    value,
    authorId,
    source,
    confidence,
    createdAt,
    synced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClaimEventRow &&
          other.id == this.id &&
          other.entityId == this.entityId &&
          other.entityType == this.entityType &&
          other.field == this.field &&
          other.value == this.value &&
          other.authorId == this.authorId &&
          other.source == this.source &&
          other.confidence == this.confidence &&
          other.createdAt == this.createdAt &&
          other.synced == this.synced);
}

class ClaimEventsCompanion extends UpdateCompanion<ClaimEventRow> {
  final Value<String> id;
  final Value<String> entityId;
  final Value<String> entityType;
  final Value<String> field;
  final Value<String> value;
  final Value<String> authorId;
  final Value<String> source;
  final Value<double?> confidence;
  final Value<DateTime> createdAt;
  final Value<bool> synced;
  final Value<int> rowid;
  const ClaimEventsCompanion({
    this.id = const Value.absent(),
    this.entityId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.field = const Value.absent(),
    this.value = const Value.absent(),
    this.authorId = const Value.absent(),
    this.source = const Value.absent(),
    this.confidence = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ClaimEventsCompanion.insert({
    required String id,
    required String entityId,
    required String entityType,
    required String field,
    required String value,
    required String authorId,
    required String source,
    this.confidence = const Value.absent(),
    required DateTime createdAt,
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       entityId = Value(entityId),
       entityType = Value(entityType),
       field = Value(field),
       value = Value(value),
       authorId = Value(authorId),
       source = Value(source),
       createdAt = Value(createdAt);
  static Insertable<ClaimEventRow> custom({
    Expression<String>? id,
    Expression<String>? entityId,
    Expression<String>? entityType,
    Expression<String>? field,
    Expression<String>? value,
    Expression<String>? authorId,
    Expression<String>? source,
    Expression<double>? confidence,
    Expression<DateTime>? createdAt,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityId != null) 'entity_id': entityId,
      if (entityType != null) 'entity_type': entityType,
      if (field != null) 'field': field,
      if (value != null) 'value': value,
      if (authorId != null) 'author_id': authorId,
      if (source != null) 'source': source,
      if (confidence != null) 'confidence': confidence,
      if (createdAt != null) 'created_at': createdAt,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ClaimEventsCompanion copyWith({
    Value<String>? id,
    Value<String>? entityId,
    Value<String>? entityType,
    Value<String>? field,
    Value<String>? value,
    Value<String>? authorId,
    Value<String>? source,
    Value<double?>? confidence,
    Value<DateTime>? createdAt,
    Value<bool>? synced,
    Value<int>? rowid,
  }) {
    return ClaimEventsCompanion(
      id: id ?? this.id,
      entityId: entityId ?? this.entityId,
      entityType: entityType ?? this.entityType,
      field: field ?? this.field,
      value: value ?? this.value,
      authorId: authorId ?? this.authorId,
      source: source ?? this.source,
      confidence: confidence ?? this.confidence,
      createdAt: createdAt ?? this.createdAt,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (field.present) {
      map['field'] = Variable<String>(field.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (authorId.present) {
      map['author_id'] = Variable<String>(authorId.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClaimEventsCompanion(')
          ..write('id: $id, ')
          ..write('entityId: $entityId, ')
          ..write('entityType: $entityType, ')
          ..write('field: $field, ')
          ..write('value: $value, ')
          ..write('authorId: $authorId, ')
          ..write('source: $source, ')
          ..write('confidence: $confidence, ')
          ..write('createdAt: $createdAt, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PersonsTable extends Persons with TableInfo<$PersonsTable, PersonRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PersonsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fullNameMeta = const VerificationMeta(
    'fullName',
  );
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
    'full_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _birthYearRawMeta = const VerificationMeta(
    'birthYearRaw',
  );
  @override
  late final GeneratedColumn<String> birthYearRaw = GeneratedColumn<String>(
    'birth_year_raw',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _birthYearMeta = const VerificationMeta(
    'birthYear',
  );
  @override
  late final GeneratedColumn<int> birthYear = GeneratedColumn<int>(
    'birth_year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _birthPlaceMeta = const VerificationMeta(
    'birthPlace',
  );
  @override
  late final GeneratedColumn<String> birthPlace = GeneratedColumn<String>(
    'birth_place',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
    'gender',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDeceasedMeta = const VerificationMeta(
    'isDeceased',
  );
  @override
  late final GeneratedColumn<bool> isDeceased = GeneratedColumn<bool>(
    'is_deceased',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deceased" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _photoMediaIdMeta = const VerificationMeta(
    'photoMediaId',
  );
  @override
  late final GeneratedColumn<String> photoMediaId = GeneratedColumn<String>(
    'photo_media_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastUpdatedAtMeta = const VerificationMeta(
    'lastUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastUpdatedAt =
      GeneratedColumn<DateTime>(
        'last_updated_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _isRetractedMeta = const VerificationMeta(
    'isRetracted',
  );
  @override
  late final GeneratedColumn<bool> isRetracted = GeneratedColumn<bool>(
    'is_retracted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_retracted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    fullName,
    birthYearRaw,
    birthYear,
    birthPlace,
    gender,
    isDeceased,
    photoMediaId,
    lastUpdatedAt,
    isRetracted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'persons';
  @override
  VerificationContext validateIntegrity(
    Insertable<PersonRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('full_name')) {
      context.handle(
        _fullNameMeta,
        fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta),
      );
    }
    if (data.containsKey('birth_year_raw')) {
      context.handle(
        _birthYearRawMeta,
        birthYearRaw.isAcceptableOrUnknown(
          data['birth_year_raw']!,
          _birthYearRawMeta,
        ),
      );
    }
    if (data.containsKey('birth_year')) {
      context.handle(
        _birthYearMeta,
        birthYear.isAcceptableOrUnknown(data['birth_year']!, _birthYearMeta),
      );
    }
    if (data.containsKey('birth_place')) {
      context.handle(
        _birthPlaceMeta,
        birthPlace.isAcceptableOrUnknown(data['birth_place']!, _birthPlaceMeta),
      );
    }
    if (data.containsKey('gender')) {
      context.handle(
        _genderMeta,
        gender.isAcceptableOrUnknown(data['gender']!, _genderMeta),
      );
    }
    if (data.containsKey('is_deceased')) {
      context.handle(
        _isDeceasedMeta,
        isDeceased.isAcceptableOrUnknown(data['is_deceased']!, _isDeceasedMeta),
      );
    }
    if (data.containsKey('photo_media_id')) {
      context.handle(
        _photoMediaIdMeta,
        photoMediaId.isAcceptableOrUnknown(
          data['photo_media_id']!,
          _photoMediaIdMeta,
        ),
      );
    }
    if (data.containsKey('last_updated_at')) {
      context.handle(
        _lastUpdatedAtMeta,
        lastUpdatedAt.isAcceptableOrUnknown(
          data['last_updated_at']!,
          _lastUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('is_retracted')) {
      context.handle(
        _isRetractedMeta,
        isRetracted.isAcceptableOrUnknown(
          data['is_retracted']!,
          _isRetractedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PersonRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PersonRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      fullName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_name'],
      ),
      birthYearRaw: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}birth_year_raw'],
      ),
      birthYear: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}birth_year'],
      ),
      birthPlace: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}birth_place'],
      ),
      gender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gender'],
      ),
      isDeceased: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deceased'],
      )!,
      photoMediaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_media_id'],
      ),
      lastUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_updated_at'],
      ),
      isRetracted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_retracted'],
      )!,
    );
  }

  @override
  $PersonsTable createAlias(String alias) {
    return $PersonsTable(attachedDatabase, alias);
  }
}

class PersonRow extends DataClass implements Insertable<PersonRow> {
  final String id;
  final String? fullName;

  /// The birth year exactly as claimed, e.g. `"around 1932"`. Oral family
  /// history is approximate, so the raw text is preserved verbatim and
  /// [birthYear] holds only the parsed form used for sorting.
  final String? birthYearRaw;
  final int? birthYear;
  final String? birthPlace;
  final String? gender;
  final bool isDeceased;
  final String? photoMediaId;
  final DateTime? lastUpdatedAt;

  /// True when the latest claim retracted this person entirely. Kept as a flag
  /// rather than a row delete so the projection mirrors the log exactly.
  final bool isRetracted;
  const PersonRow({
    required this.id,
    this.fullName,
    this.birthYearRaw,
    this.birthYear,
    this.birthPlace,
    this.gender,
    required this.isDeceased,
    this.photoMediaId,
    this.lastUpdatedAt,
    required this.isRetracted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || fullName != null) {
      map['full_name'] = Variable<String>(fullName);
    }
    if (!nullToAbsent || birthYearRaw != null) {
      map['birth_year_raw'] = Variable<String>(birthYearRaw);
    }
    if (!nullToAbsent || birthYear != null) {
      map['birth_year'] = Variable<int>(birthYear);
    }
    if (!nullToAbsent || birthPlace != null) {
      map['birth_place'] = Variable<String>(birthPlace);
    }
    if (!nullToAbsent || gender != null) {
      map['gender'] = Variable<String>(gender);
    }
    map['is_deceased'] = Variable<bool>(isDeceased);
    if (!nullToAbsent || photoMediaId != null) {
      map['photo_media_id'] = Variable<String>(photoMediaId);
    }
    if (!nullToAbsent || lastUpdatedAt != null) {
      map['last_updated_at'] = Variable<DateTime>(lastUpdatedAt);
    }
    map['is_retracted'] = Variable<bool>(isRetracted);
    return map;
  }

  PersonsCompanion toCompanion(bool nullToAbsent) {
    return PersonsCompanion(
      id: Value(id),
      fullName: fullName == null && nullToAbsent
          ? const Value.absent()
          : Value(fullName),
      birthYearRaw: birthYearRaw == null && nullToAbsent
          ? const Value.absent()
          : Value(birthYearRaw),
      birthYear: birthYear == null && nullToAbsent
          ? const Value.absent()
          : Value(birthYear),
      birthPlace: birthPlace == null && nullToAbsent
          ? const Value.absent()
          : Value(birthPlace),
      gender: gender == null && nullToAbsent
          ? const Value.absent()
          : Value(gender),
      isDeceased: Value(isDeceased),
      photoMediaId: photoMediaId == null && nullToAbsent
          ? const Value.absent()
          : Value(photoMediaId),
      lastUpdatedAt: lastUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastUpdatedAt),
      isRetracted: Value(isRetracted),
    );
  }

  factory PersonRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PersonRow(
      id: serializer.fromJson<String>(json['id']),
      fullName: serializer.fromJson<String?>(json['fullName']),
      birthYearRaw: serializer.fromJson<String?>(json['birthYearRaw']),
      birthYear: serializer.fromJson<int?>(json['birthYear']),
      birthPlace: serializer.fromJson<String?>(json['birthPlace']),
      gender: serializer.fromJson<String?>(json['gender']),
      isDeceased: serializer.fromJson<bool>(json['isDeceased']),
      photoMediaId: serializer.fromJson<String?>(json['photoMediaId']),
      lastUpdatedAt: serializer.fromJson<DateTime?>(json['lastUpdatedAt']),
      isRetracted: serializer.fromJson<bool>(json['isRetracted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'fullName': serializer.toJson<String?>(fullName),
      'birthYearRaw': serializer.toJson<String?>(birthYearRaw),
      'birthYear': serializer.toJson<int?>(birthYear),
      'birthPlace': serializer.toJson<String?>(birthPlace),
      'gender': serializer.toJson<String?>(gender),
      'isDeceased': serializer.toJson<bool>(isDeceased),
      'photoMediaId': serializer.toJson<String?>(photoMediaId),
      'lastUpdatedAt': serializer.toJson<DateTime?>(lastUpdatedAt),
      'isRetracted': serializer.toJson<bool>(isRetracted),
    };
  }

  PersonRow copyWith({
    String? id,
    Value<String?> fullName = const Value.absent(),
    Value<String?> birthYearRaw = const Value.absent(),
    Value<int?> birthYear = const Value.absent(),
    Value<String?> birthPlace = const Value.absent(),
    Value<String?> gender = const Value.absent(),
    bool? isDeceased,
    Value<String?> photoMediaId = const Value.absent(),
    Value<DateTime?> lastUpdatedAt = const Value.absent(),
    bool? isRetracted,
  }) => PersonRow(
    id: id ?? this.id,
    fullName: fullName.present ? fullName.value : this.fullName,
    birthYearRaw: birthYearRaw.present ? birthYearRaw.value : this.birthYearRaw,
    birthYear: birthYear.present ? birthYear.value : this.birthYear,
    birthPlace: birthPlace.present ? birthPlace.value : this.birthPlace,
    gender: gender.present ? gender.value : this.gender,
    isDeceased: isDeceased ?? this.isDeceased,
    photoMediaId: photoMediaId.present ? photoMediaId.value : this.photoMediaId,
    lastUpdatedAt: lastUpdatedAt.present
        ? lastUpdatedAt.value
        : this.lastUpdatedAt,
    isRetracted: isRetracted ?? this.isRetracted,
  );
  PersonRow copyWithCompanion(PersonsCompanion data) {
    return PersonRow(
      id: data.id.present ? data.id.value : this.id,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      birthYearRaw: data.birthYearRaw.present
          ? data.birthYearRaw.value
          : this.birthYearRaw,
      birthYear: data.birthYear.present ? data.birthYear.value : this.birthYear,
      birthPlace: data.birthPlace.present
          ? data.birthPlace.value
          : this.birthPlace,
      gender: data.gender.present ? data.gender.value : this.gender,
      isDeceased: data.isDeceased.present
          ? data.isDeceased.value
          : this.isDeceased,
      photoMediaId: data.photoMediaId.present
          ? data.photoMediaId.value
          : this.photoMediaId,
      lastUpdatedAt: data.lastUpdatedAt.present
          ? data.lastUpdatedAt.value
          : this.lastUpdatedAt,
      isRetracted: data.isRetracted.present
          ? data.isRetracted.value
          : this.isRetracted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PersonRow(')
          ..write('id: $id, ')
          ..write('fullName: $fullName, ')
          ..write('birthYearRaw: $birthYearRaw, ')
          ..write('birthYear: $birthYear, ')
          ..write('birthPlace: $birthPlace, ')
          ..write('gender: $gender, ')
          ..write('isDeceased: $isDeceased, ')
          ..write('photoMediaId: $photoMediaId, ')
          ..write('lastUpdatedAt: $lastUpdatedAt, ')
          ..write('isRetracted: $isRetracted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    fullName,
    birthYearRaw,
    birthYear,
    birthPlace,
    gender,
    isDeceased,
    photoMediaId,
    lastUpdatedAt,
    isRetracted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PersonRow &&
          other.id == this.id &&
          other.fullName == this.fullName &&
          other.birthYearRaw == this.birthYearRaw &&
          other.birthYear == this.birthYear &&
          other.birthPlace == this.birthPlace &&
          other.gender == this.gender &&
          other.isDeceased == this.isDeceased &&
          other.photoMediaId == this.photoMediaId &&
          other.lastUpdatedAt == this.lastUpdatedAt &&
          other.isRetracted == this.isRetracted);
}

class PersonsCompanion extends UpdateCompanion<PersonRow> {
  final Value<String> id;
  final Value<String?> fullName;
  final Value<String?> birthYearRaw;
  final Value<int?> birthYear;
  final Value<String?> birthPlace;
  final Value<String?> gender;
  final Value<bool> isDeceased;
  final Value<String?> photoMediaId;
  final Value<DateTime?> lastUpdatedAt;
  final Value<bool> isRetracted;
  final Value<int> rowid;
  const PersonsCompanion({
    this.id = const Value.absent(),
    this.fullName = const Value.absent(),
    this.birthYearRaw = const Value.absent(),
    this.birthYear = const Value.absent(),
    this.birthPlace = const Value.absent(),
    this.gender = const Value.absent(),
    this.isDeceased = const Value.absent(),
    this.photoMediaId = const Value.absent(),
    this.lastUpdatedAt = const Value.absent(),
    this.isRetracted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PersonsCompanion.insert({
    required String id,
    this.fullName = const Value.absent(),
    this.birthYearRaw = const Value.absent(),
    this.birthYear = const Value.absent(),
    this.birthPlace = const Value.absent(),
    this.gender = const Value.absent(),
    this.isDeceased = const Value.absent(),
    this.photoMediaId = const Value.absent(),
    this.lastUpdatedAt = const Value.absent(),
    this.isRetracted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<PersonRow> custom({
    Expression<String>? id,
    Expression<String>? fullName,
    Expression<String>? birthYearRaw,
    Expression<int>? birthYear,
    Expression<String>? birthPlace,
    Expression<String>? gender,
    Expression<bool>? isDeceased,
    Expression<String>? photoMediaId,
    Expression<DateTime>? lastUpdatedAt,
    Expression<bool>? isRetracted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fullName != null) 'full_name': fullName,
      if (birthYearRaw != null) 'birth_year_raw': birthYearRaw,
      if (birthYear != null) 'birth_year': birthYear,
      if (birthPlace != null) 'birth_place': birthPlace,
      if (gender != null) 'gender': gender,
      if (isDeceased != null) 'is_deceased': isDeceased,
      if (photoMediaId != null) 'photo_media_id': photoMediaId,
      if (lastUpdatedAt != null) 'last_updated_at': lastUpdatedAt,
      if (isRetracted != null) 'is_retracted': isRetracted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PersonsCompanion copyWith({
    Value<String>? id,
    Value<String?>? fullName,
    Value<String?>? birthYearRaw,
    Value<int?>? birthYear,
    Value<String?>? birthPlace,
    Value<String?>? gender,
    Value<bool>? isDeceased,
    Value<String?>? photoMediaId,
    Value<DateTime?>? lastUpdatedAt,
    Value<bool>? isRetracted,
    Value<int>? rowid,
  }) {
    return PersonsCompanion(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      birthYearRaw: birthYearRaw ?? this.birthYearRaw,
      birthYear: birthYear ?? this.birthYear,
      birthPlace: birthPlace ?? this.birthPlace,
      gender: gender ?? this.gender,
      isDeceased: isDeceased ?? this.isDeceased,
      photoMediaId: photoMediaId ?? this.photoMediaId,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      isRetracted: isRetracted ?? this.isRetracted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (birthYearRaw.present) {
      map['birth_year_raw'] = Variable<String>(birthYearRaw.value);
    }
    if (birthYear.present) {
      map['birth_year'] = Variable<int>(birthYear.value);
    }
    if (birthPlace.present) {
      map['birth_place'] = Variable<String>(birthPlace.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (isDeceased.present) {
      map['is_deceased'] = Variable<bool>(isDeceased.value);
    }
    if (photoMediaId.present) {
      map['photo_media_id'] = Variable<String>(photoMediaId.value);
    }
    if (lastUpdatedAt.present) {
      map['last_updated_at'] = Variable<DateTime>(lastUpdatedAt.value);
    }
    if (isRetracted.present) {
      map['is_retracted'] = Variable<bool>(isRetracted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PersonsCompanion(')
          ..write('id: $id, ')
          ..write('fullName: $fullName, ')
          ..write('birthYearRaw: $birthYearRaw, ')
          ..write('birthYear: $birthYear, ')
          ..write('birthPlace: $birthPlace, ')
          ..write('gender: $gender, ')
          ..write('isDeceased: $isDeceased, ')
          ..write('photoMediaId: $photoMediaId, ')
          ..write('lastUpdatedAt: $lastUpdatedAt, ')
          ..write('isRetracted: $isRetracted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RelationshipsTable extends Relationships
    with TableInfo<$RelationshipsTable, RelationshipRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RelationshipsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _personAIdMeta = const VerificationMeta(
    'personAId',
  );
  @override
  late final GeneratedColumn<String> personAId = GeneratedColumn<String>(
    'person_a_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _personBIdMeta = const VerificationMeta(
    'personBId',
  );
  @override
  late final GeneratedColumn<String> personBId = GeneratedColumn<String>(
    'person_b_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _relationshipTypeMeta = const VerificationMeta(
    'relationshipType',
  );
  @override
  late final GeneratedColumn<String> relationshipType = GeneratedColumn<String>(
    'relationship_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _claimEventIdMeta = const VerificationMeta(
    'claimEventId',
  );
  @override
  late final GeneratedColumn<String> claimEventId = GeneratedColumn<String>(
    'claim_event_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _marriageYearRawMeta = const VerificationMeta(
    'marriageYearRaw',
  );
  @override
  late final GeneratedColumn<String> marriageYearRaw = GeneratedColumn<String>(
    'marriage_year_raw',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _marriageYearMeta = const VerificationMeta(
    'marriageYear',
  );
  @override
  late final GeneratedColumn<int> marriageYear = GeneratedColumn<int>(
    'marriage_year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastUpdatedAtMeta = const VerificationMeta(
    'lastUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastUpdatedAt =
      GeneratedColumn<DateTime>(
        'last_updated_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _isRetractedMeta = const VerificationMeta(
    'isRetracted',
  );
  @override
  late final GeneratedColumn<bool> isRetracted = GeneratedColumn<bool>(
    'is_retracted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_retracted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    personAId,
    personBId,
    relationshipType,
    claimEventId,
    marriageYearRaw,
    marriageYear,
    lastUpdatedAt,
    isRetracted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'relationships';
  @override
  VerificationContext validateIntegrity(
    Insertable<RelationshipRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('person_a_id')) {
      context.handle(
        _personAIdMeta,
        personAId.isAcceptableOrUnknown(data['person_a_id']!, _personAIdMeta),
      );
    }
    if (data.containsKey('person_b_id')) {
      context.handle(
        _personBIdMeta,
        personBId.isAcceptableOrUnknown(data['person_b_id']!, _personBIdMeta),
      );
    }
    if (data.containsKey('relationship_type')) {
      context.handle(
        _relationshipTypeMeta,
        relationshipType.isAcceptableOrUnknown(
          data['relationship_type']!,
          _relationshipTypeMeta,
        ),
      );
    }
    if (data.containsKey('claim_event_id')) {
      context.handle(
        _claimEventIdMeta,
        claimEventId.isAcceptableOrUnknown(
          data['claim_event_id']!,
          _claimEventIdMeta,
        ),
      );
    }
    if (data.containsKey('marriage_year_raw')) {
      context.handle(
        _marriageYearRawMeta,
        marriageYearRaw.isAcceptableOrUnknown(
          data['marriage_year_raw']!,
          _marriageYearRawMeta,
        ),
      );
    }
    if (data.containsKey('marriage_year')) {
      context.handle(
        _marriageYearMeta,
        marriageYear.isAcceptableOrUnknown(
          data['marriage_year']!,
          _marriageYearMeta,
        ),
      );
    }
    if (data.containsKey('last_updated_at')) {
      context.handle(
        _lastUpdatedAtMeta,
        lastUpdatedAt.isAcceptableOrUnknown(
          data['last_updated_at']!,
          _lastUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('is_retracted')) {
      context.handle(
        _isRetractedMeta,
        isRetracted.isAcceptableOrUnknown(
          data['is_retracted']!,
          _isRetractedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RelationshipRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RelationshipRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      personAId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}person_a_id'],
      ),
      personBId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}person_b_id'],
      ),
      relationshipType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relationship_type'],
      ),
      claimEventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}claim_event_id'],
      ),
      marriageYearRaw: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}marriage_year_raw'],
      ),
      marriageYear: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}marriage_year'],
      ),
      lastUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_updated_at'],
      ),
      isRetracted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_retracted'],
      )!,
    );
  }

  @override
  $RelationshipsTable createAlias(String alias) {
    return $RelationshipsTable(attachedDatabase, alias);
  }
}

class RelationshipRow extends DataClass implements Insertable<RelationshipRow> {
  final String id;
  final String? personAId;
  final String? personBId;

  /// `parent_of` | `spouse_of` | `sibling_of`.
  final String? relationshipType;

  /// Provenance link to the claim event that established the current type.
  final String? claimEventId;

  /// Optional, spouse relationships only. Free text like birth years.
  final String? marriageYearRaw;
  final int? marriageYear;
  final DateTime? lastUpdatedAt;
  final bool isRetracted;
  const RelationshipRow({
    required this.id,
    this.personAId,
    this.personBId,
    this.relationshipType,
    this.claimEventId,
    this.marriageYearRaw,
    this.marriageYear,
    this.lastUpdatedAt,
    required this.isRetracted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || personAId != null) {
      map['person_a_id'] = Variable<String>(personAId);
    }
    if (!nullToAbsent || personBId != null) {
      map['person_b_id'] = Variable<String>(personBId);
    }
    if (!nullToAbsent || relationshipType != null) {
      map['relationship_type'] = Variable<String>(relationshipType);
    }
    if (!nullToAbsent || claimEventId != null) {
      map['claim_event_id'] = Variable<String>(claimEventId);
    }
    if (!nullToAbsent || marriageYearRaw != null) {
      map['marriage_year_raw'] = Variable<String>(marriageYearRaw);
    }
    if (!nullToAbsent || marriageYear != null) {
      map['marriage_year'] = Variable<int>(marriageYear);
    }
    if (!nullToAbsent || lastUpdatedAt != null) {
      map['last_updated_at'] = Variable<DateTime>(lastUpdatedAt);
    }
    map['is_retracted'] = Variable<bool>(isRetracted);
    return map;
  }

  RelationshipsCompanion toCompanion(bool nullToAbsent) {
    return RelationshipsCompanion(
      id: Value(id),
      personAId: personAId == null && nullToAbsent
          ? const Value.absent()
          : Value(personAId),
      personBId: personBId == null && nullToAbsent
          ? const Value.absent()
          : Value(personBId),
      relationshipType: relationshipType == null && nullToAbsent
          ? const Value.absent()
          : Value(relationshipType),
      claimEventId: claimEventId == null && nullToAbsent
          ? const Value.absent()
          : Value(claimEventId),
      marriageYearRaw: marriageYearRaw == null && nullToAbsent
          ? const Value.absent()
          : Value(marriageYearRaw),
      marriageYear: marriageYear == null && nullToAbsent
          ? const Value.absent()
          : Value(marriageYear),
      lastUpdatedAt: lastUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastUpdatedAt),
      isRetracted: Value(isRetracted),
    );
  }

  factory RelationshipRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RelationshipRow(
      id: serializer.fromJson<String>(json['id']),
      personAId: serializer.fromJson<String?>(json['personAId']),
      personBId: serializer.fromJson<String?>(json['personBId']),
      relationshipType: serializer.fromJson<String?>(json['relationshipType']),
      claimEventId: serializer.fromJson<String?>(json['claimEventId']),
      marriageYearRaw: serializer.fromJson<String?>(json['marriageYearRaw']),
      marriageYear: serializer.fromJson<int?>(json['marriageYear']),
      lastUpdatedAt: serializer.fromJson<DateTime?>(json['lastUpdatedAt']),
      isRetracted: serializer.fromJson<bool>(json['isRetracted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'personAId': serializer.toJson<String?>(personAId),
      'personBId': serializer.toJson<String?>(personBId),
      'relationshipType': serializer.toJson<String?>(relationshipType),
      'claimEventId': serializer.toJson<String?>(claimEventId),
      'marriageYearRaw': serializer.toJson<String?>(marriageYearRaw),
      'marriageYear': serializer.toJson<int?>(marriageYear),
      'lastUpdatedAt': serializer.toJson<DateTime?>(lastUpdatedAt),
      'isRetracted': serializer.toJson<bool>(isRetracted),
    };
  }

  RelationshipRow copyWith({
    String? id,
    Value<String?> personAId = const Value.absent(),
    Value<String?> personBId = const Value.absent(),
    Value<String?> relationshipType = const Value.absent(),
    Value<String?> claimEventId = const Value.absent(),
    Value<String?> marriageYearRaw = const Value.absent(),
    Value<int?> marriageYear = const Value.absent(),
    Value<DateTime?> lastUpdatedAt = const Value.absent(),
    bool? isRetracted,
  }) => RelationshipRow(
    id: id ?? this.id,
    personAId: personAId.present ? personAId.value : this.personAId,
    personBId: personBId.present ? personBId.value : this.personBId,
    relationshipType: relationshipType.present
        ? relationshipType.value
        : this.relationshipType,
    claimEventId: claimEventId.present ? claimEventId.value : this.claimEventId,
    marriageYearRaw: marriageYearRaw.present
        ? marriageYearRaw.value
        : this.marriageYearRaw,
    marriageYear: marriageYear.present ? marriageYear.value : this.marriageYear,
    lastUpdatedAt: lastUpdatedAt.present
        ? lastUpdatedAt.value
        : this.lastUpdatedAt,
    isRetracted: isRetracted ?? this.isRetracted,
  );
  RelationshipRow copyWithCompanion(RelationshipsCompanion data) {
    return RelationshipRow(
      id: data.id.present ? data.id.value : this.id,
      personAId: data.personAId.present ? data.personAId.value : this.personAId,
      personBId: data.personBId.present ? data.personBId.value : this.personBId,
      relationshipType: data.relationshipType.present
          ? data.relationshipType.value
          : this.relationshipType,
      claimEventId: data.claimEventId.present
          ? data.claimEventId.value
          : this.claimEventId,
      marriageYearRaw: data.marriageYearRaw.present
          ? data.marriageYearRaw.value
          : this.marriageYearRaw,
      marriageYear: data.marriageYear.present
          ? data.marriageYear.value
          : this.marriageYear,
      lastUpdatedAt: data.lastUpdatedAt.present
          ? data.lastUpdatedAt.value
          : this.lastUpdatedAt,
      isRetracted: data.isRetracted.present
          ? data.isRetracted.value
          : this.isRetracted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RelationshipRow(')
          ..write('id: $id, ')
          ..write('personAId: $personAId, ')
          ..write('personBId: $personBId, ')
          ..write('relationshipType: $relationshipType, ')
          ..write('claimEventId: $claimEventId, ')
          ..write('marriageYearRaw: $marriageYearRaw, ')
          ..write('marriageYear: $marriageYear, ')
          ..write('lastUpdatedAt: $lastUpdatedAt, ')
          ..write('isRetracted: $isRetracted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    personAId,
    personBId,
    relationshipType,
    claimEventId,
    marriageYearRaw,
    marriageYear,
    lastUpdatedAt,
    isRetracted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RelationshipRow &&
          other.id == this.id &&
          other.personAId == this.personAId &&
          other.personBId == this.personBId &&
          other.relationshipType == this.relationshipType &&
          other.claimEventId == this.claimEventId &&
          other.marriageYearRaw == this.marriageYearRaw &&
          other.marriageYear == this.marriageYear &&
          other.lastUpdatedAt == this.lastUpdatedAt &&
          other.isRetracted == this.isRetracted);
}

class RelationshipsCompanion extends UpdateCompanion<RelationshipRow> {
  final Value<String> id;
  final Value<String?> personAId;
  final Value<String?> personBId;
  final Value<String?> relationshipType;
  final Value<String?> claimEventId;
  final Value<String?> marriageYearRaw;
  final Value<int?> marriageYear;
  final Value<DateTime?> lastUpdatedAt;
  final Value<bool> isRetracted;
  final Value<int> rowid;
  const RelationshipsCompanion({
    this.id = const Value.absent(),
    this.personAId = const Value.absent(),
    this.personBId = const Value.absent(),
    this.relationshipType = const Value.absent(),
    this.claimEventId = const Value.absent(),
    this.marriageYearRaw = const Value.absent(),
    this.marriageYear = const Value.absent(),
    this.lastUpdatedAt = const Value.absent(),
    this.isRetracted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RelationshipsCompanion.insert({
    required String id,
    this.personAId = const Value.absent(),
    this.personBId = const Value.absent(),
    this.relationshipType = const Value.absent(),
    this.claimEventId = const Value.absent(),
    this.marriageYearRaw = const Value.absent(),
    this.marriageYear = const Value.absent(),
    this.lastUpdatedAt = const Value.absent(),
    this.isRetracted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<RelationshipRow> custom({
    Expression<String>? id,
    Expression<String>? personAId,
    Expression<String>? personBId,
    Expression<String>? relationshipType,
    Expression<String>? claimEventId,
    Expression<String>? marriageYearRaw,
    Expression<int>? marriageYear,
    Expression<DateTime>? lastUpdatedAt,
    Expression<bool>? isRetracted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (personAId != null) 'person_a_id': personAId,
      if (personBId != null) 'person_b_id': personBId,
      if (relationshipType != null) 'relationship_type': relationshipType,
      if (claimEventId != null) 'claim_event_id': claimEventId,
      if (marriageYearRaw != null) 'marriage_year_raw': marriageYearRaw,
      if (marriageYear != null) 'marriage_year': marriageYear,
      if (lastUpdatedAt != null) 'last_updated_at': lastUpdatedAt,
      if (isRetracted != null) 'is_retracted': isRetracted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RelationshipsCompanion copyWith({
    Value<String>? id,
    Value<String?>? personAId,
    Value<String?>? personBId,
    Value<String?>? relationshipType,
    Value<String?>? claimEventId,
    Value<String?>? marriageYearRaw,
    Value<int?>? marriageYear,
    Value<DateTime?>? lastUpdatedAt,
    Value<bool>? isRetracted,
    Value<int>? rowid,
  }) {
    return RelationshipsCompanion(
      id: id ?? this.id,
      personAId: personAId ?? this.personAId,
      personBId: personBId ?? this.personBId,
      relationshipType: relationshipType ?? this.relationshipType,
      claimEventId: claimEventId ?? this.claimEventId,
      marriageYearRaw: marriageYearRaw ?? this.marriageYearRaw,
      marriageYear: marriageYear ?? this.marriageYear,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      isRetracted: isRetracted ?? this.isRetracted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (personAId.present) {
      map['person_a_id'] = Variable<String>(personAId.value);
    }
    if (personBId.present) {
      map['person_b_id'] = Variable<String>(personBId.value);
    }
    if (relationshipType.present) {
      map['relationship_type'] = Variable<String>(relationshipType.value);
    }
    if (claimEventId.present) {
      map['claim_event_id'] = Variable<String>(claimEventId.value);
    }
    if (marriageYearRaw.present) {
      map['marriage_year_raw'] = Variable<String>(marriageYearRaw.value);
    }
    if (marriageYear.present) {
      map['marriage_year'] = Variable<int>(marriageYear.value);
    }
    if (lastUpdatedAt.present) {
      map['last_updated_at'] = Variable<DateTime>(lastUpdatedAt.value);
    }
    if (isRetracted.present) {
      map['is_retracted'] = Variable<bool>(isRetracted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RelationshipsCompanion(')
          ..write('id: $id, ')
          ..write('personAId: $personAId, ')
          ..write('personBId: $personBId, ')
          ..write('relationshipType: $relationshipType, ')
          ..write('claimEventId: $claimEventId, ')
          ..write('marriageYearRaw: $marriageYearRaw, ')
          ..write('marriageYear: $marriageYear, ')
          ..write('lastUpdatedAt: $lastUpdatedAt, ')
          ..write('isRetracted: $isRetracted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MediaItemsTable extends MediaItems
    with TableInfo<$MediaItemsTable, MediaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MediaItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentHashMeta = const VerificationMeta(
    'contentHash',
  );
  @override
  late final GeneratedColumn<String> contentHash = GeneratedColumn<String>(
    'content_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _linkedEntityIdMeta = const VerificationMeta(
    'linkedEntityId',
  );
  @override
  late final GeneratedColumn<String> linkedEntityId = GeneratedColumn<String>(
    'linked_entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mediaTypeMeta = const VerificationMeta(
    'mediaType',
  );
  @override
  late final GeneratedColumn<String> mediaType = GeneratedColumn<String>(
    'media_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _captionMeta = const VerificationMeta(
    'caption',
  );
  @override
  late final GeneratedColumn<String> caption = GeneratedColumn<String>(
    'caption',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    contentHash,
    localPath,
    linkedEntityId,
    mediaType,
    caption,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'media';
  @override
  VerificationContext validateIntegrity(
    Insertable<MediaRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('content_hash')) {
      context.handle(
        _contentHashMeta,
        contentHash.isAcceptableOrUnknown(
          data['content_hash']!,
          _contentHashMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentHashMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    } else if (isInserting) {
      context.missing(_localPathMeta);
    }
    if (data.containsKey('linked_entity_id')) {
      context.handle(
        _linkedEntityIdMeta,
        linkedEntityId.isAcceptableOrUnknown(
          data['linked_entity_id']!,
          _linkedEntityIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_linkedEntityIdMeta);
    }
    if (data.containsKey('media_type')) {
      context.handle(
        _mediaTypeMeta,
        mediaType.isAcceptableOrUnknown(data['media_type']!, _mediaTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mediaTypeMeta);
    }
    if (data.containsKey('caption')) {
      context.handle(
        _captionMeta,
        caption.isAcceptableOrUnknown(data['caption']!, _captionMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {contentHash, linkedEntityId},
  ];
  @override
  MediaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MediaRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      contentHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_hash'],
      )!,
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      )!,
      linkedEntityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}linked_entity_id'],
      )!,
      mediaType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_type'],
      )!,
      caption: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}caption'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $MediaItemsTable createAlias(String alias) {
    return $MediaItemsTable(attachedDatabase, alias);
  }
}

class MediaRow extends DataClass implements Insertable<MediaRow> {
  final String id;

  /// SHA-256 of the file bytes.
  final String contentHash;

  /// Resolved lazily; not assumed stable.
  final String localPath;

  /// The person or claim event this file is attached to.
  final String linkedEntityId;

  /// `'photo'` | `'audio'` | `'document'`.
  final String mediaType;
  final String? caption;
  final DateTime createdAt;
  const MediaRow({
    required this.id,
    required this.contentHash,
    required this.localPath,
    required this.linkedEntityId,
    required this.mediaType,
    this.caption,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['content_hash'] = Variable<String>(contentHash);
    map['local_path'] = Variable<String>(localPath);
    map['linked_entity_id'] = Variable<String>(linkedEntityId);
    map['media_type'] = Variable<String>(mediaType);
    if (!nullToAbsent || caption != null) {
      map['caption'] = Variable<String>(caption);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MediaItemsCompanion toCompanion(bool nullToAbsent) {
    return MediaItemsCompanion(
      id: Value(id),
      contentHash: Value(contentHash),
      localPath: Value(localPath),
      linkedEntityId: Value(linkedEntityId),
      mediaType: Value(mediaType),
      caption: caption == null && nullToAbsent
          ? const Value.absent()
          : Value(caption),
      createdAt: Value(createdAt),
    );
  }

  factory MediaRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MediaRow(
      id: serializer.fromJson<String>(json['id']),
      contentHash: serializer.fromJson<String>(json['contentHash']),
      localPath: serializer.fromJson<String>(json['localPath']),
      linkedEntityId: serializer.fromJson<String>(json['linkedEntityId']),
      mediaType: serializer.fromJson<String>(json['mediaType']),
      caption: serializer.fromJson<String?>(json['caption']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'contentHash': serializer.toJson<String>(contentHash),
      'localPath': serializer.toJson<String>(localPath),
      'linkedEntityId': serializer.toJson<String>(linkedEntityId),
      'mediaType': serializer.toJson<String>(mediaType),
      'caption': serializer.toJson<String?>(caption),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  MediaRow copyWith({
    String? id,
    String? contentHash,
    String? localPath,
    String? linkedEntityId,
    String? mediaType,
    Value<String?> caption = const Value.absent(),
    DateTime? createdAt,
  }) => MediaRow(
    id: id ?? this.id,
    contentHash: contentHash ?? this.contentHash,
    localPath: localPath ?? this.localPath,
    linkedEntityId: linkedEntityId ?? this.linkedEntityId,
    mediaType: mediaType ?? this.mediaType,
    caption: caption.present ? caption.value : this.caption,
    createdAt: createdAt ?? this.createdAt,
  );
  MediaRow copyWithCompanion(MediaItemsCompanion data) {
    return MediaRow(
      id: data.id.present ? data.id.value : this.id,
      contentHash: data.contentHash.present
          ? data.contentHash.value
          : this.contentHash,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      linkedEntityId: data.linkedEntityId.present
          ? data.linkedEntityId.value
          : this.linkedEntityId,
      mediaType: data.mediaType.present ? data.mediaType.value : this.mediaType,
      caption: data.caption.present ? data.caption.value : this.caption,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MediaRow(')
          ..write('id: $id, ')
          ..write('contentHash: $contentHash, ')
          ..write('localPath: $localPath, ')
          ..write('linkedEntityId: $linkedEntityId, ')
          ..write('mediaType: $mediaType, ')
          ..write('caption: $caption, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    contentHash,
    localPath,
    linkedEntityId,
    mediaType,
    caption,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MediaRow &&
          other.id == this.id &&
          other.contentHash == this.contentHash &&
          other.localPath == this.localPath &&
          other.linkedEntityId == this.linkedEntityId &&
          other.mediaType == this.mediaType &&
          other.caption == this.caption &&
          other.createdAt == this.createdAt);
}

class MediaItemsCompanion extends UpdateCompanion<MediaRow> {
  final Value<String> id;
  final Value<String> contentHash;
  final Value<String> localPath;
  final Value<String> linkedEntityId;
  final Value<String> mediaType;
  final Value<String?> caption;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const MediaItemsCompanion({
    this.id = const Value.absent(),
    this.contentHash = const Value.absent(),
    this.localPath = const Value.absent(),
    this.linkedEntityId = const Value.absent(),
    this.mediaType = const Value.absent(),
    this.caption = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MediaItemsCompanion.insert({
    required String id,
    required String contentHash,
    required String localPath,
    required String linkedEntityId,
    required String mediaType,
    this.caption = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       contentHash = Value(contentHash),
       localPath = Value(localPath),
       linkedEntityId = Value(linkedEntityId),
       mediaType = Value(mediaType),
       createdAt = Value(createdAt);
  static Insertable<MediaRow> custom({
    Expression<String>? id,
    Expression<String>? contentHash,
    Expression<String>? localPath,
    Expression<String>? linkedEntityId,
    Expression<String>? mediaType,
    Expression<String>? caption,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (contentHash != null) 'content_hash': contentHash,
      if (localPath != null) 'local_path': localPath,
      if (linkedEntityId != null) 'linked_entity_id': linkedEntityId,
      if (mediaType != null) 'media_type': mediaType,
      if (caption != null) 'caption': caption,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MediaItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? contentHash,
    Value<String>? localPath,
    Value<String>? linkedEntityId,
    Value<String>? mediaType,
    Value<String?>? caption,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return MediaItemsCompanion(
      id: id ?? this.id,
      contentHash: contentHash ?? this.contentHash,
      localPath: localPath ?? this.localPath,
      linkedEntityId: linkedEntityId ?? this.linkedEntityId,
      mediaType: mediaType ?? this.mediaType,
      caption: caption ?? this.caption,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (contentHash.present) {
      map['content_hash'] = Variable<String>(contentHash.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (linkedEntityId.present) {
      map['linked_entity_id'] = Variable<String>(linkedEntityId.value);
    }
    if (mediaType.present) {
      map['media_type'] = Variable<String>(mediaType.value);
    }
    if (caption.present) {
      map['caption'] = Variable<String>(caption.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MediaItemsCompanion(')
          ..write('id: $id, ')
          ..write('contentHash: $contentHash, ')
          ..write('localPath: $localPath, ')
          ..write('linkedEntityId: $linkedEntityId, ')
          ..write('mediaType: $mediaType, ')
          ..write('caption: $caption, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FamilyTreesTable extends FamilyTrees
    with TableInfo<$FamilyTreesTable, FamilyTreeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FamilyTreesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'family_trees';
  @override
  VerificationContext validateIntegrity(
    Insertable<FamilyTreeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FamilyTreeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FamilyTreeRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $FamilyTreesTable createAlias(String alias) {
    return $FamilyTreesTable(attachedDatabase, alias);
  }
}

class FamilyTreeRow extends DataClass implements Insertable<FamilyTreeRow> {
  final String id;
  final String name;
  final DateTime createdAt;
  const FamilyTreeRow({
    required this.id,
    required this.name,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  FamilyTreesCompanion toCompanion(bool nullToAbsent) {
    return FamilyTreesCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
    );
  }

  factory FamilyTreeRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FamilyTreeRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  FamilyTreeRow copyWith({String? id, String? name, DateTime? createdAt}) =>
      FamilyTreeRow(
        id: id ?? this.id,
        name: name ?? this.name,
        createdAt: createdAt ?? this.createdAt,
      );
  FamilyTreeRow copyWithCompanion(FamilyTreesCompanion data) {
    return FamilyTreeRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FamilyTreeRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FamilyTreeRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt);
}

class FamilyTreesCompanion extends UpdateCompanion<FamilyTreeRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const FamilyTreesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FamilyTreesCompanion.insert({
    required String id,
    required String name,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<FamilyTreeRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FamilyTreesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return FamilyTreesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FamilyTreesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ClaimEventsTable claimEvents = $ClaimEventsTable(this);
  late final $PersonsTable persons = $PersonsTable(this);
  late final $RelationshipsTable relationships = $RelationshipsTable(this);
  late final $MediaItemsTable mediaItems = $MediaItemsTable(this);
  late final $FamilyTreesTable familyTrees = $FamilyTreesTable(this);
  late final ClaimEventDao claimEventDao = ClaimEventDao(this as AppDatabase);
  late final ProjectionDao projectionDao = ProjectionDao(this as AppDatabase);
  late final MediaDao mediaDao = MediaDao(this as AppDatabase);
  late final FamilyTreeDao familyTreeDao = FamilyTreeDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    claimEvents,
    persons,
    relationships,
    mediaItems,
    familyTrees,
  ];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$ClaimEventsTableCreateCompanionBuilder =
    ClaimEventsCompanion Function({
      required String id,
      required String entityId,
      required String entityType,
      required String field,
      required String value,
      required String authorId,
      required String source,
      Value<double?> confidence,
      required DateTime createdAt,
      Value<bool> synced,
      Value<int> rowid,
    });
typedef $$ClaimEventsTableUpdateCompanionBuilder =
    ClaimEventsCompanion Function({
      Value<String> id,
      Value<String> entityId,
      Value<String> entityType,
      Value<String> field,
      Value<String> value,
      Value<String> authorId,
      Value<String> source,
      Value<double?> confidence,
      Value<DateTime> createdAt,
      Value<bool> synced,
      Value<int> rowid,
    });

class $$ClaimEventsTableFilterComposer
    extends Composer<_$AppDatabase, $ClaimEventsTable> {
  $$ClaimEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get field => $composableBuilder(
    column: $table.field,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authorId => $composableBuilder(
    column: $table.authorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ClaimEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $ClaimEventsTable> {
  $$ClaimEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get field => $composableBuilder(
    column: $table.field,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authorId => $composableBuilder(
    column: $table.authorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ClaimEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClaimEventsTable> {
  $$ClaimEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get field =>
      $composableBuilder(column: $table.field, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<String> get authorId =>
      $composableBuilder(column: $table.authorId, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$ClaimEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ClaimEventsTable,
          ClaimEventRow,
          $$ClaimEventsTableFilterComposer,
          $$ClaimEventsTableOrderingComposer,
          $$ClaimEventsTableAnnotationComposer,
          $$ClaimEventsTableCreateCompanionBuilder,
          $$ClaimEventsTableUpdateCompanionBuilder,
          (
            ClaimEventRow,
            BaseReferences<_$AppDatabase, $ClaimEventsTable, ClaimEventRow>,
          ),
          ClaimEventRow,
          PrefetchHooks Function()
        > {
  $$ClaimEventsTableTableManager(_$AppDatabase db, $ClaimEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClaimEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClaimEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClaimEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> field = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<String> authorId = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<double?> confidence = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClaimEventsCompanion(
                id: id,
                entityId: entityId,
                entityType: entityType,
                field: field,
                value: value,
                authorId: authorId,
                source: source,
                confidence: confidence,
                createdAt: createdAt,
                synced: synced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String entityId,
                required String entityType,
                required String field,
                required String value,
                required String authorId,
                required String source,
                Value<double?> confidence = const Value.absent(),
                required DateTime createdAt,
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClaimEventsCompanion.insert(
                id: id,
                entityId: entityId,
                entityType: entityType,
                field: field,
                value: value,
                authorId: authorId,
                source: source,
                confidence: confidence,
                createdAt: createdAt,
                synced: synced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ClaimEventsTable, ClaimEventRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ClaimEventsTable,
                    ClaimEventRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ClaimEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ClaimEventsTable,
      ClaimEventRow,
      $$ClaimEventsTableFilterComposer,
      $$ClaimEventsTableOrderingComposer,
      $$ClaimEventsTableAnnotationComposer,
      $$ClaimEventsTableCreateCompanionBuilder,
      $$ClaimEventsTableUpdateCompanionBuilder,
      (
        ClaimEventRow,
        BaseReferences<_$AppDatabase, $ClaimEventsTable, ClaimEventRow>,
      ),
      ClaimEventRow,
      PrefetchHooks Function()
    >;
typedef $$PersonsTableCreateCompanionBuilder = PersonsCompanion Function({
  required String id,
  Value<String?> fullName,
  Value<String?> birthYearRaw,
  Value<int?> birthYear,
  Value<String?> birthPlace,
  Value<String?> gender,
  Value<bool> isDeceased,
  Value<String?> photoMediaId,
  Value<DateTime?> lastUpdatedAt,
  Value<bool> isRetracted,
  Value<int> rowid,
});
typedef $$PersonsTableUpdateCompanionBuilder = PersonsCompanion Function({
  Value<String> id,
  Value<String?> fullName,
  Value<String?> birthYearRaw,
  Value<int?> birthYear,
  Value<String?> birthPlace,
  Value<String?> gender,
  Value<bool> isDeceased,
  Value<String?> photoMediaId,
  Value<DateTime?> lastUpdatedAt,
  Value<bool> isRetracted,
  Value<int> rowid,
});

class $$PersonsTableFilterComposer
    extends Composer<_$AppDatabase, $PersonsTable> {
  $$PersonsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get birthYearRaw => $composableBuilder(
    column: $table.birthYearRaw,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get birthYear => $composableBuilder(
    column: $table.birthYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get birthPlace => $composableBuilder(
    column: $table.birthPlace,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeceased => $composableBuilder(
    column: $table.isDeceased,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoMediaId => $composableBuilder(
    column: $table.photoMediaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUpdatedAt => $composableBuilder(
    column: $table.lastUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRetracted => $composableBuilder(
    column: $table.isRetracted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PersonsTableOrderingComposer
    extends Composer<_$AppDatabase, $PersonsTable> {
  $$PersonsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get birthYearRaw => $composableBuilder(
    column: $table.birthYearRaw,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get birthYear => $composableBuilder(
    column: $table.birthYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get birthPlace => $composableBuilder(
    column: $table.birthPlace,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeceased => $composableBuilder(
    column: $table.isDeceased,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoMediaId => $composableBuilder(
    column: $table.photoMediaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUpdatedAt => $composableBuilder(
    column: $table.lastUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRetracted => $composableBuilder(
    column: $table.isRetracted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PersonsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PersonsTable> {
  $$PersonsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<String> get birthYearRaw => $composableBuilder(
    column: $table.birthYearRaw,
    builder: (column) => column,
  );

  GeneratedColumn<int> get birthYear =>
      $composableBuilder(column: $table.birthYear, builder: (column) => column);

  GeneratedColumn<String> get birthPlace => $composableBuilder(
    column: $table.birthPlace,
    builder: (column) => column,
  );

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<bool> get isDeceased => $composableBuilder(
    column: $table.isDeceased,
    builder: (column) => column,
  );

  GeneratedColumn<String> get photoMediaId => $composableBuilder(
    column: $table.photoMediaId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastUpdatedAt => $composableBuilder(
    column: $table.lastUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isRetracted => $composableBuilder(
    column: $table.isRetracted,
    builder: (column) => column,
  );
}

class $$PersonsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PersonsTable,
          PersonRow,
          $$PersonsTableFilterComposer,
          $$PersonsTableOrderingComposer,
          $$PersonsTableAnnotationComposer,
          $$PersonsTableCreateCompanionBuilder,
          $$PersonsTableUpdateCompanionBuilder,
          (PersonRow, BaseReferences<_$AppDatabase, $PersonsTable, PersonRow>),
          PersonRow,
          PrefetchHooks Function()
        > {
  $$PersonsTableTableManager(_$AppDatabase db, $PersonsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PersonsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PersonsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PersonsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> fullName = const Value.absent(),
                Value<String?> birthYearRaw = const Value.absent(),
                Value<int?> birthYear = const Value.absent(),
                Value<String?> birthPlace = const Value.absent(),
                Value<String?> gender = const Value.absent(),
                Value<bool> isDeceased = const Value.absent(),
                Value<String?> photoMediaId = const Value.absent(),
                Value<DateTime?> lastUpdatedAt = const Value.absent(),
                Value<bool> isRetracted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PersonsCompanion(
                id: id,
                fullName: fullName,
                birthYearRaw: birthYearRaw,
                birthYear: birthYear,
                birthPlace: birthPlace,
                gender: gender,
                isDeceased: isDeceased,
                photoMediaId: photoMediaId,
                lastUpdatedAt: lastUpdatedAt,
                isRetracted: isRetracted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> fullName = const Value.absent(),
                Value<String?> birthYearRaw = const Value.absent(),
                Value<int?> birthYear = const Value.absent(),
                Value<String?> birthPlace = const Value.absent(),
                Value<String?> gender = const Value.absent(),
                Value<bool> isDeceased = const Value.absent(),
                Value<String?> photoMediaId = const Value.absent(),
                Value<DateTime?> lastUpdatedAt = const Value.absent(),
                Value<bool> isRetracted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PersonsCompanion.insert(
                id: id,
                fullName: fullName,
                birthYearRaw: birthYearRaw,
                birthYear: birthYear,
                birthPlace: birthPlace,
                gender: gender,
                isDeceased: isDeceased,
                photoMediaId: photoMediaId,
                lastUpdatedAt: lastUpdatedAt,
                isRetracted: isRetracted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PersonsTable, PersonRow>(table),
                  BaseReferences<_$AppDatabase, $PersonsTable, PersonRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PersonsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PersonsTable,
      PersonRow,
      $$PersonsTableFilterComposer,
      $$PersonsTableOrderingComposer,
      $$PersonsTableAnnotationComposer,
      $$PersonsTableCreateCompanionBuilder,
      $$PersonsTableUpdateCompanionBuilder,
      (PersonRow, BaseReferences<_$AppDatabase, $PersonsTable, PersonRow>),
      PersonRow,
      PrefetchHooks Function()
    >;
typedef $$RelationshipsTableCreateCompanionBuilder =
    RelationshipsCompanion Function({
      required String id,
      Value<String?> personAId,
      Value<String?> personBId,
      Value<String?> relationshipType,
      Value<String?> claimEventId,
      Value<String?> marriageYearRaw,
      Value<int?> marriageYear,
      Value<DateTime?> lastUpdatedAt,
      Value<bool> isRetracted,
      Value<int> rowid,
    });
typedef $$RelationshipsTableUpdateCompanionBuilder =
    RelationshipsCompanion Function({
      Value<String> id,
      Value<String?> personAId,
      Value<String?> personBId,
      Value<String?> relationshipType,
      Value<String?> claimEventId,
      Value<String?> marriageYearRaw,
      Value<int?> marriageYear,
      Value<DateTime?> lastUpdatedAt,
      Value<bool> isRetracted,
      Value<int> rowid,
    });

class $$RelationshipsTableFilterComposer
    extends Composer<_$AppDatabase, $RelationshipsTable> {
  $$RelationshipsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get personAId => $composableBuilder(
    column: $table.personAId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get personBId => $composableBuilder(
    column: $table.personBId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relationshipType => $composableBuilder(
    column: $table.relationshipType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get claimEventId => $composableBuilder(
    column: $table.claimEventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get marriageYearRaw => $composableBuilder(
    column: $table.marriageYearRaw,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get marriageYear => $composableBuilder(
    column: $table.marriageYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUpdatedAt => $composableBuilder(
    column: $table.lastUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRetracted => $composableBuilder(
    column: $table.isRetracted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RelationshipsTableOrderingComposer
    extends Composer<_$AppDatabase, $RelationshipsTable> {
  $$RelationshipsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get personAId => $composableBuilder(
    column: $table.personAId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get personBId => $composableBuilder(
    column: $table.personBId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relationshipType => $composableBuilder(
    column: $table.relationshipType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get claimEventId => $composableBuilder(
    column: $table.claimEventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get marriageYearRaw => $composableBuilder(
    column: $table.marriageYearRaw,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get marriageYear => $composableBuilder(
    column: $table.marriageYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUpdatedAt => $composableBuilder(
    column: $table.lastUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRetracted => $composableBuilder(
    column: $table.isRetracted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RelationshipsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RelationshipsTable> {
  $$RelationshipsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get personAId =>
      $composableBuilder(column: $table.personAId, builder: (column) => column);

  GeneratedColumn<String> get personBId =>
      $composableBuilder(column: $table.personBId, builder: (column) => column);

  GeneratedColumn<String> get relationshipType => $composableBuilder(
    column: $table.relationshipType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get claimEventId => $composableBuilder(
    column: $table.claimEventId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get marriageYearRaw => $composableBuilder(
    column: $table.marriageYearRaw,
    builder: (column) => column,
  );

  GeneratedColumn<int> get marriageYear => $composableBuilder(
    column: $table.marriageYear,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastUpdatedAt => $composableBuilder(
    column: $table.lastUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isRetracted => $composableBuilder(
    column: $table.isRetracted,
    builder: (column) => column,
  );
}

class $$RelationshipsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RelationshipsTable,
          RelationshipRow,
          $$RelationshipsTableFilterComposer,
          $$RelationshipsTableOrderingComposer,
          $$RelationshipsTableAnnotationComposer,
          $$RelationshipsTableCreateCompanionBuilder,
          $$RelationshipsTableUpdateCompanionBuilder,
          (
            RelationshipRow,
            BaseReferences<_$AppDatabase, $RelationshipsTable, RelationshipRow>,
          ),
          RelationshipRow,
          PrefetchHooks Function()
        > {
  $$RelationshipsTableTableManager(_$AppDatabase db, $RelationshipsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RelationshipsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RelationshipsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RelationshipsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> personAId = const Value.absent(),
                Value<String?> personBId = const Value.absent(),
                Value<String?> relationshipType = const Value.absent(),
                Value<String?> claimEventId = const Value.absent(),
                Value<String?> marriageYearRaw = const Value.absent(),
                Value<int?> marriageYear = const Value.absent(),
                Value<DateTime?> lastUpdatedAt = const Value.absent(),
                Value<bool> isRetracted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RelationshipsCompanion(
                id: id,
                personAId: personAId,
                personBId: personBId,
                relationshipType: relationshipType,
                claimEventId: claimEventId,
                marriageYearRaw: marriageYearRaw,
                marriageYear: marriageYear,
                lastUpdatedAt: lastUpdatedAt,
                isRetracted: isRetracted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> personAId = const Value.absent(),
                Value<String?> personBId = const Value.absent(),
                Value<String?> relationshipType = const Value.absent(),
                Value<String?> claimEventId = const Value.absent(),
                Value<String?> marriageYearRaw = const Value.absent(),
                Value<int?> marriageYear = const Value.absent(),
                Value<DateTime?> lastUpdatedAt = const Value.absent(),
                Value<bool> isRetracted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RelationshipsCompanion.insert(
                id: id,
                personAId: personAId,
                personBId: personBId,
                relationshipType: relationshipType,
                claimEventId: claimEventId,
                marriageYearRaw: marriageYearRaw,
                marriageYear: marriageYear,
                lastUpdatedAt: lastUpdatedAt,
                isRetracted: isRetracted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RelationshipsTable, RelationshipRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $RelationshipsTable,
                    RelationshipRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RelationshipsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RelationshipsTable,
      RelationshipRow,
      $$RelationshipsTableFilterComposer,
      $$RelationshipsTableOrderingComposer,
      $$RelationshipsTableAnnotationComposer,
      $$RelationshipsTableCreateCompanionBuilder,
      $$RelationshipsTableUpdateCompanionBuilder,
      (
        RelationshipRow,
        BaseReferences<_$AppDatabase, $RelationshipsTable, RelationshipRow>,
      ),
      RelationshipRow,
      PrefetchHooks Function()
    >;
typedef $$MediaItemsTableCreateCompanionBuilder = MediaItemsCompanion Function({
  required String id,
  required String contentHash,
  required String localPath,
  required String linkedEntityId,
  required String mediaType,
  Value<String?> caption,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$MediaItemsTableUpdateCompanionBuilder = MediaItemsCompanion Function({
  Value<String> id,
  Value<String> contentHash,
  Value<String> localPath,
  Value<String> linkedEntityId,
  Value<String> mediaType,
  Value<String?> caption,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$MediaItemsTableFilterComposer
    extends Composer<_$AppDatabase, $MediaItemsTable> {
  $$MediaItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get linkedEntityId => $composableBuilder(
    column: $table.linkedEntityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mediaType => $composableBuilder(
    column: $table.mediaType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get caption => $composableBuilder(
    column: $table.caption,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MediaItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $MediaItemsTable> {
  $$MediaItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get linkedEntityId => $composableBuilder(
    column: $table.linkedEntityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mediaType => $composableBuilder(
    column: $table.mediaType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get caption => $composableBuilder(
    column: $table.caption,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MediaItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MediaItemsTable> {
  $$MediaItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get linkedEntityId => $composableBuilder(
    column: $table.linkedEntityId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mediaType =>
      $composableBuilder(column: $table.mediaType, builder: (column) => column);

  GeneratedColumn<String> get caption =>
      $composableBuilder(column: $table.caption, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$MediaItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MediaItemsTable,
          MediaRow,
          $$MediaItemsTableFilterComposer,
          $$MediaItemsTableOrderingComposer,
          $$MediaItemsTableAnnotationComposer,
          $$MediaItemsTableCreateCompanionBuilder,
          $$MediaItemsTableUpdateCompanionBuilder,
          (MediaRow, BaseReferences<_$AppDatabase, $MediaItemsTable, MediaRow>),
          MediaRow,
          PrefetchHooks Function()
        > {
  $$MediaItemsTableTableManager(_$AppDatabase db, $MediaItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MediaItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MediaItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MediaItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> contentHash = const Value.absent(),
                Value<String> localPath = const Value.absent(),
                Value<String> linkedEntityId = const Value.absent(),
                Value<String> mediaType = const Value.absent(),
                Value<String?> caption = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MediaItemsCompanion(
                id: id,
                contentHash: contentHash,
                localPath: localPath,
                linkedEntityId: linkedEntityId,
                mediaType: mediaType,
                caption: caption,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String contentHash,
                required String localPath,
                required String linkedEntityId,
                required String mediaType,
                Value<String?> caption = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => MediaItemsCompanion.insert(
                id: id,
                contentHash: contentHash,
                localPath: localPath,
                linkedEntityId: linkedEntityId,
                mediaType: mediaType,
                caption: caption,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MediaItemsTable, MediaRow>(table),
                  BaseReferences<_$AppDatabase, $MediaItemsTable, MediaRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MediaItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MediaItemsTable,
      MediaRow,
      $$MediaItemsTableFilterComposer,
      $$MediaItemsTableOrderingComposer,
      $$MediaItemsTableAnnotationComposer,
      $$MediaItemsTableCreateCompanionBuilder,
      $$MediaItemsTableUpdateCompanionBuilder,
      (MediaRow, BaseReferences<_$AppDatabase, $MediaItemsTable, MediaRow>),
      MediaRow,
      PrefetchHooks Function()
    >;
typedef $$FamilyTreesTableCreateCompanionBuilder =
    FamilyTreesCompanion Function({
      required String id,
      required String name,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$FamilyTreesTableUpdateCompanionBuilder =
    FamilyTreesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$FamilyTreesTableFilterComposer
    extends Composer<_$AppDatabase, $FamilyTreesTable> {
  $$FamilyTreesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FamilyTreesTableOrderingComposer
    extends Composer<_$AppDatabase, $FamilyTreesTable> {
  $$FamilyTreesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FamilyTreesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FamilyTreesTable> {
  $$FamilyTreesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$FamilyTreesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FamilyTreesTable,
          FamilyTreeRow,
          $$FamilyTreesTableFilterComposer,
          $$FamilyTreesTableOrderingComposer,
          $$FamilyTreesTableAnnotationComposer,
          $$FamilyTreesTableCreateCompanionBuilder,
          $$FamilyTreesTableUpdateCompanionBuilder,
          (
            FamilyTreeRow,
            BaseReferences<_$AppDatabase, $FamilyTreesTable, FamilyTreeRow>,
          ),
          FamilyTreeRow,
          PrefetchHooks Function()
        > {
  $$FamilyTreesTableTableManager(_$AppDatabase db, $FamilyTreesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FamilyTreesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FamilyTreesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FamilyTreesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FamilyTreesCompanion(
                id: id,
                name: name,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => FamilyTreesCompanion.insert(
                id: id,
                name: name,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FamilyTreesTable, FamilyTreeRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $FamilyTreesTable,
                    FamilyTreeRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FamilyTreesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FamilyTreesTable,
      FamilyTreeRow,
      $$FamilyTreesTableFilterComposer,
      $$FamilyTreesTableOrderingComposer,
      $$FamilyTreesTableAnnotationComposer,
      $$FamilyTreesTableCreateCompanionBuilder,
      $$FamilyTreesTableUpdateCompanionBuilder,
      (
        FamilyTreeRow,
        BaseReferences<_$AppDatabase, $FamilyTreesTable, FamilyTreeRow>,
      ),
      FamilyTreeRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ClaimEventsTableTableManager get claimEvents =>
      $$ClaimEventsTableTableManager(_db, _db.claimEvents);
  $$PersonsTableTableManager get persons =>
      $$PersonsTableTableManager(_db, _db.persons);
  $$RelationshipsTableTableManager get relationships =>
      $$RelationshipsTableTableManager(_db, _db.relationships);
  $$MediaItemsTableTableManager get mediaItems =>
      $$MediaItemsTableTableManager(_db, _db.mediaItems);
  $$FamilyTreesTableTableManager get familyTrees =>
      $$FamilyTreesTableTableManager(_db, _db.familyTrees);
}

mixin _$ClaimEventDaoMixin on DatabaseAccessor<AppDatabase> {
  $ClaimEventsTable get claimEvents => attachedDatabase.claimEvents;
  ClaimEventDaoManager get managers => ClaimEventDaoManager(this);
}

class ClaimEventDaoManager {
  final _$ClaimEventDaoMixin _db;
  ClaimEventDaoManager(this._db);
  $$ClaimEventsTableTableManager get claimEvents =>
      $$ClaimEventsTableTableManager(_db.attachedDatabase, _db.claimEvents);
}

mixin _$ProjectionDaoMixin on DatabaseAccessor<AppDatabase> {
  $PersonsTable get persons => attachedDatabase.persons;
  $RelationshipsTable get relationships => attachedDatabase.relationships;
  ProjectionDaoManager get managers => ProjectionDaoManager(this);
}

class ProjectionDaoManager {
  final _$ProjectionDaoMixin _db;
  ProjectionDaoManager(this._db);
  $$PersonsTableTableManager get persons =>
      $$PersonsTableTableManager(_db.attachedDatabase, _db.persons);
  $$RelationshipsTableTableManager get relationships =>
      $$RelationshipsTableTableManager(_db.attachedDatabase, _db.relationships);
}

mixin _$MediaDaoMixin on DatabaseAccessor<AppDatabase> {
  $MediaItemsTable get mediaItems => attachedDatabase.mediaItems;
  MediaDaoManager get managers => MediaDaoManager(this);
}

class MediaDaoManager {
  final _$MediaDaoMixin _db;
  MediaDaoManager(this._db);
  $$MediaItemsTableTableManager get mediaItems =>
      $$MediaItemsTableTableManager(_db.attachedDatabase, _db.mediaItems);
}

mixin _$FamilyTreeDaoMixin on DatabaseAccessor<AppDatabase> {
  $FamilyTreesTable get familyTrees => attachedDatabase.familyTrees;
  FamilyTreeDaoManager get managers => FamilyTreeDaoManager(this);
}

class FamilyTreeDaoManager {
  final _$FamilyTreeDaoMixin _db;
  FamilyTreeDaoManager(this._db);
  $$FamilyTreesTableTableManager get familyTrees =>
      $$FamilyTreesTableTableManager(_db.attachedDatabase, _db.familyTrees);
}
