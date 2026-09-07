// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $HeritageItemsTable extends HeritageItems
    with TableInfo<$HeritageItemsTable, HeritageItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HeritageItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleEnMeta = const VerificationMeta(
    'titleEn',
  );
  @override
  late final GeneratedColumn<String> titleEn = GeneratedColumn<String>(
    'title_en',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleIdMeta = const VerificationMeta(
    'titleId',
  );
  @override
  late final GeneratedColumn<String> titleId = GeneratedColumn<String>(
    'title_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleNiaMeta = const VerificationMeta(
    'titleNia',
  );
  @override
  late final GeneratedColumn<String> titleNia = GeneratedColumn<String>(
    'title_nia',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionEnMeta = const VerificationMeta(
    'descriptionEn',
  );
  @override
  late final GeneratedColumn<String> descriptionEn = GeneratedColumn<String>(
    'description_en',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionIdMeta = const VerificationMeta(
    'descriptionId',
  );
  @override
  late final GeneratedColumn<String> descriptionId = GeneratedColumn<String>(
    'description_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionNiaMeta = const VerificationMeta(
    'descriptionNia',
  );
  @override
  late final GeneratedColumn<String> descriptionNia = GeneratedColumn<String>(
    'description_nia',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
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
  List<GeneratedColumn> get $columns => [
    id,
    titleEn,
    titleId,
    titleNia,
    descriptionEn,
    descriptionId,
    descriptionNia,
    category,
    imageUrl,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'heritage_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<HeritageItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title_en')) {
      context.handle(
        _titleEnMeta,
        titleEn.isAcceptableOrUnknown(data['title_en']!, _titleEnMeta),
      );
    } else if (isInserting) {
      context.missing(_titleEnMeta);
    }
    if (data.containsKey('title_id')) {
      context.handle(
        _titleIdMeta,
        titleId.isAcceptableOrUnknown(data['title_id']!, _titleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_titleIdMeta);
    }
    if (data.containsKey('title_nia')) {
      context.handle(
        _titleNiaMeta,
        titleNia.isAcceptableOrUnknown(data['title_nia']!, _titleNiaMeta),
      );
    } else if (isInserting) {
      context.missing(_titleNiaMeta);
    }
    if (data.containsKey('description_en')) {
      context.handle(
        _descriptionEnMeta,
        descriptionEn.isAcceptableOrUnknown(
          data['description_en']!,
          _descriptionEnMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionEnMeta);
    }
    if (data.containsKey('description_id')) {
      context.handle(
        _descriptionIdMeta,
        descriptionId.isAcceptableOrUnknown(
          data['description_id']!,
          _descriptionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionIdMeta);
    }
    if (data.containsKey('description_nia')) {
      context.handle(
        _descriptionNiaMeta,
        descriptionNia.isAcceptableOrUnknown(
          data['description_nia']!,
          _descriptionNiaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionNiaMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_imageUrlMeta);
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
  HeritageItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HeritageItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      titleEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title_en'],
      )!,
      titleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title_id'],
      )!,
      titleNia: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title_nia'],
      )!,
      descriptionEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description_en'],
      )!,
      descriptionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description_id'],
      )!,
      descriptionNia: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description_nia'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $HeritageItemsTable createAlias(String alias) {
    return $HeritageItemsTable(attachedDatabase, alias);
  }
}

class HeritageItem extends DataClass implements Insertable<HeritageItem> {
  final String id;
  final String titleEn;
  final String titleId;
  final String titleNia;
  final String descriptionEn;
  final String descriptionId;
  final String descriptionNia;
  final String category;
  final String imageUrl;
  final DateTime createdAt;
  const HeritageItem({
    required this.id,
    required this.titleEn,
    required this.titleId,
    required this.titleNia,
    required this.descriptionEn,
    required this.descriptionId,
    required this.descriptionNia,
    required this.category,
    required this.imageUrl,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title_en'] = Variable<String>(titleEn);
    map['title_id'] = Variable<String>(titleId);
    map['title_nia'] = Variable<String>(titleNia);
    map['description_en'] = Variable<String>(descriptionEn);
    map['description_id'] = Variable<String>(descriptionId);
    map['description_nia'] = Variable<String>(descriptionNia);
    map['category'] = Variable<String>(category);
    map['image_url'] = Variable<String>(imageUrl);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  HeritageItemsCompanion toCompanion(bool nullToAbsent) {
    return HeritageItemsCompanion(
      id: Value(id),
      titleEn: Value(titleEn),
      titleId: Value(titleId),
      titleNia: Value(titleNia),
      descriptionEn: Value(descriptionEn),
      descriptionId: Value(descriptionId),
      descriptionNia: Value(descriptionNia),
      category: Value(category),
      imageUrl: Value(imageUrl),
      createdAt: Value(createdAt),
    );
  }

  factory HeritageItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HeritageItem(
      id: serializer.fromJson<String>(json['id']),
      titleEn: serializer.fromJson<String>(json['titleEn']),
      titleId: serializer.fromJson<String>(json['titleId']),
      titleNia: serializer.fromJson<String>(json['titleNia']),
      descriptionEn: serializer.fromJson<String>(json['descriptionEn']),
      descriptionId: serializer.fromJson<String>(json['descriptionId']),
      descriptionNia: serializer.fromJson<String>(json['descriptionNia']),
      category: serializer.fromJson<String>(json['category']),
      imageUrl: serializer.fromJson<String>(json['imageUrl']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'titleEn': serializer.toJson<String>(titleEn),
      'titleId': serializer.toJson<String>(titleId),
      'titleNia': serializer.toJson<String>(titleNia),
      'descriptionEn': serializer.toJson<String>(descriptionEn),
      'descriptionId': serializer.toJson<String>(descriptionId),
      'descriptionNia': serializer.toJson<String>(descriptionNia),
      'category': serializer.toJson<String>(category),
      'imageUrl': serializer.toJson<String>(imageUrl),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  HeritageItem copyWith({
    String? id,
    String? titleEn,
    String? titleId,
    String? titleNia,
    String? descriptionEn,
    String? descriptionId,
    String? descriptionNia,
    String? category,
    String? imageUrl,
    DateTime? createdAt,
  }) => HeritageItem(
    id: id ?? this.id,
    titleEn: titleEn ?? this.titleEn,
    titleId: titleId ?? this.titleId,
    titleNia: titleNia ?? this.titleNia,
    descriptionEn: descriptionEn ?? this.descriptionEn,
    descriptionId: descriptionId ?? this.descriptionId,
    descriptionNia: descriptionNia ?? this.descriptionNia,
    category: category ?? this.category,
    imageUrl: imageUrl ?? this.imageUrl,
    createdAt: createdAt ?? this.createdAt,
  );
  HeritageItem copyWithCompanion(HeritageItemsCompanion data) {
    return HeritageItem(
      id: data.id.present ? data.id.value : this.id,
      titleEn: data.titleEn.present ? data.titleEn.value : this.titleEn,
      titleId: data.titleId.present ? data.titleId.value : this.titleId,
      titleNia: data.titleNia.present ? data.titleNia.value : this.titleNia,
      descriptionEn: data.descriptionEn.present
          ? data.descriptionEn.value
          : this.descriptionEn,
      descriptionId: data.descriptionId.present
          ? data.descriptionId.value
          : this.descriptionId,
      descriptionNia: data.descriptionNia.present
          ? data.descriptionNia.value
          : this.descriptionNia,
      category: data.category.present ? data.category.value : this.category,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HeritageItem(')
          ..write('id: $id, ')
          ..write('titleEn: $titleEn, ')
          ..write('titleId: $titleId, ')
          ..write('titleNia: $titleNia, ')
          ..write('descriptionEn: $descriptionEn, ')
          ..write('descriptionId: $descriptionId, ')
          ..write('descriptionNia: $descriptionNia, ')
          ..write('category: $category, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    titleEn,
    titleId,
    titleNia,
    descriptionEn,
    descriptionId,
    descriptionNia,
    category,
    imageUrl,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HeritageItem &&
          other.id == this.id &&
          other.titleEn == this.titleEn &&
          other.titleId == this.titleId &&
          other.titleNia == this.titleNia &&
          other.descriptionEn == this.descriptionEn &&
          other.descriptionId == this.descriptionId &&
          other.descriptionNia == this.descriptionNia &&
          other.category == this.category &&
          other.imageUrl == this.imageUrl &&
          other.createdAt == this.createdAt);
}

class HeritageItemsCompanion extends UpdateCompanion<HeritageItem> {
  final Value<String> id;
  final Value<String> titleEn;
  final Value<String> titleId;
  final Value<String> titleNia;
  final Value<String> descriptionEn;
  final Value<String> descriptionId;
  final Value<String> descriptionNia;
  final Value<String> category;
  final Value<String> imageUrl;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const HeritageItemsCompanion({
    this.id = const Value.absent(),
    this.titleEn = const Value.absent(),
    this.titleId = const Value.absent(),
    this.titleNia = const Value.absent(),
    this.descriptionEn = const Value.absent(),
    this.descriptionId = const Value.absent(),
    this.descriptionNia = const Value.absent(),
    this.category = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HeritageItemsCompanion.insert({
    required String id,
    required String titleEn,
    required String titleId,
    required String titleNia,
    required String descriptionEn,
    required String descriptionId,
    required String descriptionNia,
    required String category,
    required String imageUrl,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       titleEn = Value(titleEn),
       titleId = Value(titleId),
       titleNia = Value(titleNia),
       descriptionEn = Value(descriptionEn),
       descriptionId = Value(descriptionId),
       descriptionNia = Value(descriptionNia),
       category = Value(category),
       imageUrl = Value(imageUrl),
       createdAt = Value(createdAt);
  static Insertable<HeritageItem> custom({
    Expression<String>? id,
    Expression<String>? titleEn,
    Expression<String>? titleId,
    Expression<String>? titleNia,
    Expression<String>? descriptionEn,
    Expression<String>? descriptionId,
    Expression<String>? descriptionNia,
    Expression<String>? category,
    Expression<String>? imageUrl,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (titleEn != null) 'title_en': titleEn,
      if (titleId != null) 'title_id': titleId,
      if (titleNia != null) 'title_nia': titleNia,
      if (descriptionEn != null) 'description_en': descriptionEn,
      if (descriptionId != null) 'description_id': descriptionId,
      if (descriptionNia != null) 'description_nia': descriptionNia,
      if (category != null) 'category': category,
      if (imageUrl != null) 'image_url': imageUrl,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HeritageItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? titleEn,
    Value<String>? titleId,
    Value<String>? titleNia,
    Value<String>? descriptionEn,
    Value<String>? descriptionId,
    Value<String>? descriptionNia,
    Value<String>? category,
    Value<String>? imageUrl,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return HeritageItemsCompanion(
      id: id ?? this.id,
      titleEn: titleEn ?? this.titleEn,
      titleId: titleId ?? this.titleId,
      titleNia: titleNia ?? this.titleNia,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      descriptionId: descriptionId ?? this.descriptionId,
      descriptionNia: descriptionNia ?? this.descriptionNia,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
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
    if (titleEn.present) {
      map['title_en'] = Variable<String>(titleEn.value);
    }
    if (titleId.present) {
      map['title_id'] = Variable<String>(titleId.value);
    }
    if (titleNia.present) {
      map['title_nia'] = Variable<String>(titleNia.value);
    }
    if (descriptionEn.present) {
      map['description_en'] = Variable<String>(descriptionEn.value);
    }
    if (descriptionId.present) {
      map['description_id'] = Variable<String>(descriptionId.value);
    }
    if (descriptionNia.present) {
      map['description_nia'] = Variable<String>(descriptionNia.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
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
    return (StringBuffer('HeritageItemsCompanion(')
          ..write('id: $id, ')
          ..write('titleEn: $titleEn, ')
          ..write('titleId: $titleId, ')
          ..write('titleNia: $titleNia, ')
          ..write('descriptionEn: $descriptionEn, ')
          ..write('descriptionId: $descriptionId, ')
          ..write('descriptionNia: $descriptionNia, ')
          ..write('category: $category, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TimelineEventsTable extends TimelineEvents
    with TableInfo<$TimelineEventsTable, TimelineEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TimelineEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<String> year = GeneratedColumn<String>(
    'year',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleEnMeta = const VerificationMeta(
    'titleEn',
  );
  @override
  late final GeneratedColumn<String> titleEn = GeneratedColumn<String>(
    'title_en',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleIdMeta = const VerificationMeta(
    'titleId',
  );
  @override
  late final GeneratedColumn<String> titleId = GeneratedColumn<String>(
    'title_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleNiaMeta = const VerificationMeta(
    'titleNia',
  );
  @override
  late final GeneratedColumn<String> titleNia = GeneratedColumn<String>(
    'title_nia',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionEnMeta = const VerificationMeta(
    'descriptionEn',
  );
  @override
  late final GeneratedColumn<String> descriptionEn = GeneratedColumn<String>(
    'description_en',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionIdMeta = const VerificationMeta(
    'descriptionId',
  );
  @override
  late final GeneratedColumn<String> descriptionId = GeneratedColumn<String>(
    'description_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionNiaMeta = const VerificationMeta(
    'descriptionNia',
  );
  @override
  late final GeneratedColumn<String> descriptionNia = GeneratedColumn<String>(
    'description_nia',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    year,
    titleEn,
    titleId,
    titleNia,
    descriptionEn,
    descriptionId,
    descriptionNia,
    imageUrl,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'timeline_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<TimelineEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    } else if (isInserting) {
      context.missing(_yearMeta);
    }
    if (data.containsKey('title_en')) {
      context.handle(
        _titleEnMeta,
        titleEn.isAcceptableOrUnknown(data['title_en']!, _titleEnMeta),
      );
    } else if (isInserting) {
      context.missing(_titleEnMeta);
    }
    if (data.containsKey('title_id')) {
      context.handle(
        _titleIdMeta,
        titleId.isAcceptableOrUnknown(data['title_id']!, _titleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_titleIdMeta);
    }
    if (data.containsKey('title_nia')) {
      context.handle(
        _titleNiaMeta,
        titleNia.isAcceptableOrUnknown(data['title_nia']!, _titleNiaMeta),
      );
    } else if (isInserting) {
      context.missing(_titleNiaMeta);
    }
    if (data.containsKey('description_en')) {
      context.handle(
        _descriptionEnMeta,
        descriptionEn.isAcceptableOrUnknown(
          data['description_en']!,
          _descriptionEnMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionEnMeta);
    }
    if (data.containsKey('description_id')) {
      context.handle(
        _descriptionIdMeta,
        descriptionId.isAcceptableOrUnknown(
          data['description_id']!,
          _descriptionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionIdMeta);
    }
    if (data.containsKey('description_nia')) {
      context.handle(
        _descriptionNiaMeta,
        descriptionNia.isAcceptableOrUnknown(
          data['description_nia']!,
          _descriptionNiaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionNiaMeta);
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TimelineEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TimelineEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}year'],
      )!,
      titleEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title_en'],
      )!,
      titleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title_id'],
      )!,
      titleNia: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title_nia'],
      )!,
      descriptionEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description_en'],
      )!,
      descriptionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description_id'],
      )!,
      descriptionNia: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description_nia'],
      )!,
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      ),
    );
  }

  @override
  $TimelineEventsTable createAlias(String alias) {
    return $TimelineEventsTable(attachedDatabase, alias);
  }
}

class TimelineEvent extends DataClass implements Insertable<TimelineEvent> {
  final String id;
  final String year;
  final String titleEn;
  final String titleId;
  final String titleNia;
  final String descriptionEn;
  final String descriptionId;
  final String descriptionNia;
  final String? imageUrl;
  const TimelineEvent({
    required this.id,
    required this.year,
    required this.titleEn,
    required this.titleId,
    required this.titleNia,
    required this.descriptionEn,
    required this.descriptionId,
    required this.descriptionNia,
    this.imageUrl,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['year'] = Variable<String>(year);
    map['title_en'] = Variable<String>(titleEn);
    map['title_id'] = Variable<String>(titleId);
    map['title_nia'] = Variable<String>(titleNia);
    map['description_en'] = Variable<String>(descriptionEn);
    map['description_id'] = Variable<String>(descriptionId);
    map['description_nia'] = Variable<String>(descriptionNia);
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    return map;
  }

  TimelineEventsCompanion toCompanion(bool nullToAbsent) {
    return TimelineEventsCompanion(
      id: Value(id),
      year: Value(year),
      titleEn: Value(titleEn),
      titleId: Value(titleId),
      titleNia: Value(titleNia),
      descriptionEn: Value(descriptionEn),
      descriptionId: Value(descriptionId),
      descriptionNia: Value(descriptionNia),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
    );
  }

  factory TimelineEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TimelineEvent(
      id: serializer.fromJson<String>(json['id']),
      year: serializer.fromJson<String>(json['year']),
      titleEn: serializer.fromJson<String>(json['titleEn']),
      titleId: serializer.fromJson<String>(json['titleId']),
      titleNia: serializer.fromJson<String>(json['titleNia']),
      descriptionEn: serializer.fromJson<String>(json['descriptionEn']),
      descriptionId: serializer.fromJson<String>(json['descriptionId']),
      descriptionNia: serializer.fromJson<String>(json['descriptionNia']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'year': serializer.toJson<String>(year),
      'titleEn': serializer.toJson<String>(titleEn),
      'titleId': serializer.toJson<String>(titleId),
      'titleNia': serializer.toJson<String>(titleNia),
      'descriptionEn': serializer.toJson<String>(descriptionEn),
      'descriptionId': serializer.toJson<String>(descriptionId),
      'descriptionNia': serializer.toJson<String>(descriptionNia),
      'imageUrl': serializer.toJson<String?>(imageUrl),
    };
  }

  TimelineEvent copyWith({
    String? id,
    String? year,
    String? titleEn,
    String? titleId,
    String? titleNia,
    String? descriptionEn,
    String? descriptionId,
    String? descriptionNia,
    Value<String?> imageUrl = const Value.absent(),
  }) => TimelineEvent(
    id: id ?? this.id,
    year: year ?? this.year,
    titleEn: titleEn ?? this.titleEn,
    titleId: titleId ?? this.titleId,
    titleNia: titleNia ?? this.titleNia,
    descriptionEn: descriptionEn ?? this.descriptionEn,
    descriptionId: descriptionId ?? this.descriptionId,
    descriptionNia: descriptionNia ?? this.descriptionNia,
    imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
  );
  TimelineEvent copyWithCompanion(TimelineEventsCompanion data) {
    return TimelineEvent(
      id: data.id.present ? data.id.value : this.id,
      year: data.year.present ? data.year.value : this.year,
      titleEn: data.titleEn.present ? data.titleEn.value : this.titleEn,
      titleId: data.titleId.present ? data.titleId.value : this.titleId,
      titleNia: data.titleNia.present ? data.titleNia.value : this.titleNia,
      descriptionEn: data.descriptionEn.present
          ? data.descriptionEn.value
          : this.descriptionEn,
      descriptionId: data.descriptionId.present
          ? data.descriptionId.value
          : this.descriptionId,
      descriptionNia: data.descriptionNia.present
          ? data.descriptionNia.value
          : this.descriptionNia,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TimelineEvent(')
          ..write('id: $id, ')
          ..write('year: $year, ')
          ..write('titleEn: $titleEn, ')
          ..write('titleId: $titleId, ')
          ..write('titleNia: $titleNia, ')
          ..write('descriptionEn: $descriptionEn, ')
          ..write('descriptionId: $descriptionId, ')
          ..write('descriptionNia: $descriptionNia, ')
          ..write('imageUrl: $imageUrl')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    year,
    titleEn,
    titleId,
    titleNia,
    descriptionEn,
    descriptionId,
    descriptionNia,
    imageUrl,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimelineEvent &&
          other.id == this.id &&
          other.year == this.year &&
          other.titleEn == this.titleEn &&
          other.titleId == this.titleId &&
          other.titleNia == this.titleNia &&
          other.descriptionEn == this.descriptionEn &&
          other.descriptionId == this.descriptionId &&
          other.descriptionNia == this.descriptionNia &&
          other.imageUrl == this.imageUrl);
}

class TimelineEventsCompanion extends UpdateCompanion<TimelineEvent> {
  final Value<String> id;
  final Value<String> year;
  final Value<String> titleEn;
  final Value<String> titleId;
  final Value<String> titleNia;
  final Value<String> descriptionEn;
  final Value<String> descriptionId;
  final Value<String> descriptionNia;
  final Value<String?> imageUrl;
  final Value<int> rowid;
  const TimelineEventsCompanion({
    this.id = const Value.absent(),
    this.year = const Value.absent(),
    this.titleEn = const Value.absent(),
    this.titleId = const Value.absent(),
    this.titleNia = const Value.absent(),
    this.descriptionEn = const Value.absent(),
    this.descriptionId = const Value.absent(),
    this.descriptionNia = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TimelineEventsCompanion.insert({
    required String id,
    required String year,
    required String titleEn,
    required String titleId,
    required String titleNia,
    required String descriptionEn,
    required String descriptionId,
    required String descriptionNia,
    this.imageUrl = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       year = Value(year),
       titleEn = Value(titleEn),
       titleId = Value(titleId),
       titleNia = Value(titleNia),
       descriptionEn = Value(descriptionEn),
       descriptionId = Value(descriptionId),
       descriptionNia = Value(descriptionNia);
  static Insertable<TimelineEvent> custom({
    Expression<String>? id,
    Expression<String>? year,
    Expression<String>? titleEn,
    Expression<String>? titleId,
    Expression<String>? titleNia,
    Expression<String>? descriptionEn,
    Expression<String>? descriptionId,
    Expression<String>? descriptionNia,
    Expression<String>? imageUrl,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (year != null) 'year': year,
      if (titleEn != null) 'title_en': titleEn,
      if (titleId != null) 'title_id': titleId,
      if (titleNia != null) 'title_nia': titleNia,
      if (descriptionEn != null) 'description_en': descriptionEn,
      if (descriptionId != null) 'description_id': descriptionId,
      if (descriptionNia != null) 'description_nia': descriptionNia,
      if (imageUrl != null) 'image_url': imageUrl,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TimelineEventsCompanion copyWith({
    Value<String>? id,
    Value<String>? year,
    Value<String>? titleEn,
    Value<String>? titleId,
    Value<String>? titleNia,
    Value<String>? descriptionEn,
    Value<String>? descriptionId,
    Value<String>? descriptionNia,
    Value<String?>? imageUrl,
    Value<int>? rowid,
  }) {
    return TimelineEventsCompanion(
      id: id ?? this.id,
      year: year ?? this.year,
      titleEn: titleEn ?? this.titleEn,
      titleId: titleId ?? this.titleId,
      titleNia: titleNia ?? this.titleNia,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      descriptionId: descriptionId ?? this.descriptionId,
      descriptionNia: descriptionNia ?? this.descriptionNia,
      imageUrl: imageUrl ?? this.imageUrl,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (year.present) {
      map['year'] = Variable<String>(year.value);
    }
    if (titleEn.present) {
      map['title_en'] = Variable<String>(titleEn.value);
    }
    if (titleId.present) {
      map['title_id'] = Variable<String>(titleId.value);
    }
    if (titleNia.present) {
      map['title_nia'] = Variable<String>(titleNia.value);
    }
    if (descriptionEn.present) {
      map['description_en'] = Variable<String>(descriptionEn.value);
    }
    if (descriptionId.present) {
      map['description_id'] = Variable<String>(descriptionId.value);
    }
    if (descriptionNia.present) {
      map['description_nia'] = Variable<String>(descriptionNia.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TimelineEventsCompanion(')
          ..write('id: $id, ')
          ..write('year: $year, ')
          ..write('titleEn: $titleEn, ')
          ..write('titleId: $titleId, ')
          ..write('titleNia: $titleNia, ')
          ..write('descriptionEn: $descriptionEn, ')
          ..write('descriptionId: $descriptionId, ')
          ..write('descriptionNia: $descriptionNia, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AmaedolasTable extends Amaedolas
    with TableInfo<$AmaedolasTable, Amaedola> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AmaedolasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _pageIdMeta = const VerificationMeta('pageId');
  @override
  late final GeneratedColumn<int> pageId = GeneratedColumn<int>(
    'page_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _textContentMeta = const VerificationMeta(
    'textContent',
  );
  @override
  late final GeneratedColumn<String> textContent = GeneratedColumn<String>(
    'text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _meaningMeta = const VerificationMeta(
    'meaning',
  );
  @override
  late final GeneratedColumn<String> meaning = GeneratedColumn<String>(
    'meaning',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _meaningIdMeta = const VerificationMeta(
    'meaningId',
  );
  @override
  late final GeneratedColumn<String> meaningId = GeneratedColumn<String>(
    'meaning_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _meaningEnMeta = const VerificationMeta(
    'meaningEn',
  );
  @override
  late final GeneratedColumn<String> meaningEn = GeneratedColumn<String>(
    'meaning_en',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    pageId,
    textContent,
    meaning,
    meaningId,
    meaningEn,
    label,
    url,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'amaedola';
  @override
  VerificationContext validateIntegrity(
    Insertable<Amaedola> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('page_id')) {
      context.handle(
        _pageIdMeta,
        pageId.isAcceptableOrUnknown(data['page_id']!, _pageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_pageIdMeta);
    }
    if (data.containsKey('text')) {
      context.handle(
        _textContentMeta,
        textContent.isAcceptableOrUnknown(data['text']!, _textContentMeta),
      );
    } else if (isInserting) {
      context.missing(_textContentMeta);
    }
    if (data.containsKey('meaning')) {
      context.handle(
        _meaningMeta,
        meaning.isAcceptableOrUnknown(data['meaning']!, _meaningMeta),
      );
    } else if (isInserting) {
      context.missing(_meaningMeta);
    }
    if (data.containsKey('meaning_id')) {
      context.handle(
        _meaningIdMeta,
        meaningId.isAcceptableOrUnknown(data['meaning_id']!, _meaningIdMeta),
      );
    }
    if (data.containsKey('meaning_en')) {
      context.handle(
        _meaningEnMeta,
        meaningEn.isAcceptableOrUnknown(data['meaning_en']!, _meaningEnMeta),
      );
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Amaedola map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Amaedola(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      pageId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_id'],
      )!,
      textContent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text'],
      )!,
      meaning: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meaning'],
      )!,
      meaningId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meaning_id'],
      ),
      meaningEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meaning_en'],
      ),
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $AmaedolasTable createAlias(String alias) {
    return $AmaedolasTable(attachedDatabase, alias);
  }
}

class Amaedola extends DataClass implements Insertable<Amaedola> {
  final int id;
  final int pageId;
  final String textContent;
  final String meaning;
  final String? meaningId;
  final String? meaningEn;
  final String label;
  final String? url;
  final String? note;
  const Amaedola({
    required this.id,
    required this.pageId,
    required this.textContent,
    required this.meaning,
    this.meaningId,
    this.meaningEn,
    required this.label,
    this.url,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['page_id'] = Variable<int>(pageId);
    map['text'] = Variable<String>(textContent);
    map['meaning'] = Variable<String>(meaning);
    if (!nullToAbsent || meaningId != null) {
      map['meaning_id'] = Variable<String>(meaningId);
    }
    if (!nullToAbsent || meaningEn != null) {
      map['meaning_en'] = Variable<String>(meaningEn);
    }
    map['label'] = Variable<String>(label);
    if (!nullToAbsent || url != null) {
      map['url'] = Variable<String>(url);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  AmaedolasCompanion toCompanion(bool nullToAbsent) {
    return AmaedolasCompanion(
      id: Value(id),
      pageId: Value(pageId),
      textContent: Value(textContent),
      meaning: Value(meaning),
      meaningId: meaningId == null && nullToAbsent
          ? const Value.absent()
          : Value(meaningId),
      meaningEn: meaningEn == null && nullToAbsent
          ? const Value.absent()
          : Value(meaningEn),
      label: Value(label),
      url: url == null && nullToAbsent ? const Value.absent() : Value(url),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory Amaedola.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Amaedola(
      id: serializer.fromJson<int>(json['id']),
      pageId: serializer.fromJson<int>(json['pageId']),
      textContent: serializer.fromJson<String>(json['textContent']),
      meaning: serializer.fromJson<String>(json['meaning']),
      meaningId: serializer.fromJson<String?>(json['meaningId']),
      meaningEn: serializer.fromJson<String?>(json['meaningEn']),
      label: serializer.fromJson<String>(json['label']),
      url: serializer.fromJson<String?>(json['url']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'pageId': serializer.toJson<int>(pageId),
      'textContent': serializer.toJson<String>(textContent),
      'meaning': serializer.toJson<String>(meaning),
      'meaningId': serializer.toJson<String?>(meaningId),
      'meaningEn': serializer.toJson<String?>(meaningEn),
      'label': serializer.toJson<String>(label),
      'url': serializer.toJson<String?>(url),
      'note': serializer.toJson<String?>(note),
    };
  }

  Amaedola copyWith({
    int? id,
    int? pageId,
    String? textContent,
    String? meaning,
    Value<String?> meaningId = const Value.absent(),
    Value<String?> meaningEn = const Value.absent(),
    String? label,
    Value<String?> url = const Value.absent(),
    Value<String?> note = const Value.absent(),
  }) => Amaedola(
    id: id ?? this.id,
    pageId: pageId ?? this.pageId,
    textContent: textContent ?? this.textContent,
    meaning: meaning ?? this.meaning,
    meaningId: meaningId.present ? meaningId.value : this.meaningId,
    meaningEn: meaningEn.present ? meaningEn.value : this.meaningEn,
    label: label ?? this.label,
    url: url.present ? url.value : this.url,
    note: note.present ? note.value : this.note,
  );
  Amaedola copyWithCompanion(AmaedolasCompanion data) {
    return Amaedola(
      id: data.id.present ? data.id.value : this.id,
      pageId: data.pageId.present ? data.pageId.value : this.pageId,
      textContent: data.textContent.present
          ? data.textContent.value
          : this.textContent,
      meaning: data.meaning.present ? data.meaning.value : this.meaning,
      meaningId: data.meaningId.present ? data.meaningId.value : this.meaningId,
      meaningEn: data.meaningEn.present ? data.meaningEn.value : this.meaningEn,
      label: data.label.present ? data.label.value : this.label,
      url: data.url.present ? data.url.value : this.url,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Amaedola(')
          ..write('id: $id, ')
          ..write('pageId: $pageId, ')
          ..write('textContent: $textContent, ')
          ..write('meaning: $meaning, ')
          ..write('meaningId: $meaningId, ')
          ..write('meaningEn: $meaningEn, ')
          ..write('label: $label, ')
          ..write('url: $url, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    pageId,
    textContent,
    meaning,
    meaningId,
    meaningEn,
    label,
    url,
    note,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Amaedola &&
          other.id == this.id &&
          other.pageId == this.pageId &&
          other.textContent == this.textContent &&
          other.meaning == this.meaning &&
          other.meaningId == this.meaningId &&
          other.meaningEn == this.meaningEn &&
          other.label == this.label &&
          other.url == this.url &&
          other.note == this.note);
}

class AmaedolasCompanion extends UpdateCompanion<Amaedola> {
  final Value<int> id;
  final Value<int> pageId;
  final Value<String> textContent;
  final Value<String> meaning;
  final Value<String?> meaningId;
  final Value<String?> meaningEn;
  final Value<String> label;
  final Value<String?> url;
  final Value<String?> note;
  const AmaedolasCompanion({
    this.id = const Value.absent(),
    this.pageId = const Value.absent(),
    this.textContent = const Value.absent(),
    this.meaning = const Value.absent(),
    this.meaningId = const Value.absent(),
    this.meaningEn = const Value.absent(),
    this.label = const Value.absent(),
    this.url = const Value.absent(),
    this.note = const Value.absent(),
  });
  AmaedolasCompanion.insert({
    this.id = const Value.absent(),
    required int pageId,
    required String textContent,
    required String meaning,
    this.meaningId = const Value.absent(),
    this.meaningEn = const Value.absent(),
    required String label,
    this.url = const Value.absent(),
    this.note = const Value.absent(),
  }) : pageId = Value(pageId),
       textContent = Value(textContent),
       meaning = Value(meaning),
       label = Value(label);
  static Insertable<Amaedola> custom({
    Expression<int>? id,
    Expression<int>? pageId,
    Expression<String>? textContent,
    Expression<String>? meaning,
    Expression<String>? meaningId,
    Expression<String>? meaningEn,
    Expression<String>? label,
    Expression<String>? url,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pageId != null) 'page_id': pageId,
      if (textContent != null) 'text': textContent,
      if (meaning != null) 'meaning': meaning,
      if (meaningId != null) 'meaning_id': meaningId,
      if (meaningEn != null) 'meaning_en': meaningEn,
      if (label != null) 'label': label,
      if (url != null) 'url': url,
      if (note != null) 'note': note,
    });
  }

  AmaedolasCompanion copyWith({
    Value<int>? id,
    Value<int>? pageId,
    Value<String>? textContent,
    Value<String>? meaning,
    Value<String?>? meaningId,
    Value<String?>? meaningEn,
    Value<String>? label,
    Value<String?>? url,
    Value<String?>? note,
  }) {
    return AmaedolasCompanion(
      id: id ?? this.id,
      pageId: pageId ?? this.pageId,
      textContent: textContent ?? this.textContent,
      meaning: meaning ?? this.meaning,
      meaningId: meaningId ?? this.meaningId,
      meaningEn: meaningEn ?? this.meaningEn,
      label: label ?? this.label,
      url: url ?? this.url,
      note: note ?? this.note,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (pageId.present) {
      map['page_id'] = Variable<int>(pageId.value);
    }
    if (textContent.present) {
      map['text'] = Variable<String>(textContent.value);
    }
    if (meaning.present) {
      map['meaning'] = Variable<String>(meaning.value);
    }
    if (meaningId.present) {
      map['meaning_id'] = Variable<String>(meaningId.value);
    }
    if (meaningEn.present) {
      map['meaning_en'] = Variable<String>(meaningEn.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AmaedolasCompanion(')
          ..write('id: $id, ')
          ..write('pageId: $pageId, ')
          ..write('textContent: $textContent, ')
          ..write('meaning: $meaning, ')
          ..write('meaningId: $meaningId, ')
          ..write('meaningEn: $meaningEn, ')
          ..write('label: $label, ')
          ..write('url: $url, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }
}

class $BiblesTable extends Bibles with TableInfo<$BiblesTable, Bible> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BiblesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _pageIdMeta = const VerificationMeta('pageId');
  @override
  late final GeneratedColumn<int> pageId = GeneratedColumn<int>(
    'page_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bookMeta = const VerificationMeta('book');
  @override
  late final GeneratedColumn<String> book = GeneratedColumn<String>(
    'book',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chapterMeta = const VerificationMeta(
    'chapter',
  );
  @override
  late final GeneratedColumn<int> chapter = GeneratedColumn<int>(
    'chapter',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _verseMeta = const VerificationMeta('verse');
  @override
  late final GeneratedColumn<int> verse = GeneratedColumn<int>(
    'verse',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _textContentMeta = const VerificationMeta(
    'textContent',
  );
  @override
  late final GeneratedColumn<String> textContent = GeneratedColumn<String>(
    'text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>?, String> reference =
      GeneratedColumn<String>(
        'reference',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<List<String>?>($BiblesTable.$converterreferencen);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    pageId,
    category,
    book,
    chapter,
    verse,
    textContent,
    reference,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bible';
  @override
  VerificationContext validateIntegrity(
    Insertable<Bible> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('page_id')) {
      context.handle(
        _pageIdMeta,
        pageId.isAcceptableOrUnknown(data['page_id']!, _pageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_pageIdMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('book')) {
      context.handle(
        _bookMeta,
        book.isAcceptableOrUnknown(data['book']!, _bookMeta),
      );
    } else if (isInserting) {
      context.missing(_bookMeta);
    }
    if (data.containsKey('chapter')) {
      context.handle(
        _chapterMeta,
        chapter.isAcceptableOrUnknown(data['chapter']!, _chapterMeta),
      );
    } else if (isInserting) {
      context.missing(_chapterMeta);
    }
    if (data.containsKey('verse')) {
      context.handle(
        _verseMeta,
        verse.isAcceptableOrUnknown(data['verse']!, _verseMeta),
      );
    } else if (isInserting) {
      context.missing(_verseMeta);
    }
    if (data.containsKey('text')) {
      context.handle(
        _textContentMeta,
        textContent.isAcceptableOrUnknown(data['text']!, _textContentMeta),
      );
    } else if (isInserting) {
      context.missing(_textContentMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Bible map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Bible(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      pageId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_id'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      book: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book'],
      )!,
      chapter: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chapter'],
      )!,
      verse: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}verse'],
      )!,
      textContent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text'],
      )!,
      reference: $BiblesTable.$converterreferencen.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}reference'],
        ),
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $BiblesTable createAlias(String alias) {
    return $BiblesTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $converterreference =
      const StringListConverter();
  static TypeConverter<List<String>?, String?> $converterreferencen =
      NullAwareTypeConverter.wrap($converterreference);
}

class Bible extends DataClass implements Insertable<Bible> {
  final int id;
  final int pageId;
  final String category;
  final String book;
  final int chapter;
  final int verse;
  final String textContent;
  final List<String>? reference;
  final String? note;
  const Bible({
    required this.id,
    required this.pageId,
    required this.category,
    required this.book,
    required this.chapter,
    required this.verse,
    required this.textContent,
    this.reference,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['page_id'] = Variable<int>(pageId);
    map['category'] = Variable<String>(category);
    map['book'] = Variable<String>(book);
    map['chapter'] = Variable<int>(chapter);
    map['verse'] = Variable<int>(verse);
    map['text'] = Variable<String>(textContent);
    if (!nullToAbsent || reference != null) {
      map['reference'] = Variable<String>(
        $BiblesTable.$converterreferencen.toSql(reference),
      );
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  BiblesCompanion toCompanion(bool nullToAbsent) {
    return BiblesCompanion(
      id: Value(id),
      pageId: Value(pageId),
      category: Value(category),
      book: Value(book),
      chapter: Value(chapter),
      verse: Value(verse),
      textContent: Value(textContent),
      reference: reference == null && nullToAbsent
          ? const Value.absent()
          : Value(reference),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory Bible.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Bible(
      id: serializer.fromJson<int>(json['id']),
      pageId: serializer.fromJson<int>(json['pageId']),
      category: serializer.fromJson<String>(json['category']),
      book: serializer.fromJson<String>(json['book']),
      chapter: serializer.fromJson<int>(json['chapter']),
      verse: serializer.fromJson<int>(json['verse']),
      textContent: serializer.fromJson<String>(json['textContent']),
      reference: serializer.fromJson<List<String>?>(json['reference']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'pageId': serializer.toJson<int>(pageId),
      'category': serializer.toJson<String>(category),
      'book': serializer.toJson<String>(book),
      'chapter': serializer.toJson<int>(chapter),
      'verse': serializer.toJson<int>(verse),
      'textContent': serializer.toJson<String>(textContent),
      'reference': serializer.toJson<List<String>?>(reference),
      'note': serializer.toJson<String?>(note),
    };
  }

  Bible copyWith({
    int? id,
    int? pageId,
    String? category,
    String? book,
    int? chapter,
    int? verse,
    String? textContent,
    Value<List<String>?> reference = const Value.absent(),
    Value<String?> note = const Value.absent(),
  }) => Bible(
    id: id ?? this.id,
    pageId: pageId ?? this.pageId,
    category: category ?? this.category,
    book: book ?? this.book,
    chapter: chapter ?? this.chapter,
    verse: verse ?? this.verse,
    textContent: textContent ?? this.textContent,
    reference: reference.present ? reference.value : this.reference,
    note: note.present ? note.value : this.note,
  );
  Bible copyWithCompanion(BiblesCompanion data) {
    return Bible(
      id: data.id.present ? data.id.value : this.id,
      pageId: data.pageId.present ? data.pageId.value : this.pageId,
      category: data.category.present ? data.category.value : this.category,
      book: data.book.present ? data.book.value : this.book,
      chapter: data.chapter.present ? data.chapter.value : this.chapter,
      verse: data.verse.present ? data.verse.value : this.verse,
      textContent: data.textContent.present
          ? data.textContent.value
          : this.textContent,
      reference: data.reference.present ? data.reference.value : this.reference,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Bible(')
          ..write('id: $id, ')
          ..write('pageId: $pageId, ')
          ..write('category: $category, ')
          ..write('book: $book, ')
          ..write('chapter: $chapter, ')
          ..write('verse: $verse, ')
          ..write('textContent: $textContent, ')
          ..write('reference: $reference, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    pageId,
    category,
    book,
    chapter,
    verse,
    textContent,
    reference,
    note,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Bible &&
          other.id == this.id &&
          other.pageId == this.pageId &&
          other.category == this.category &&
          other.book == this.book &&
          other.chapter == this.chapter &&
          other.verse == this.verse &&
          other.textContent == this.textContent &&
          other.reference == this.reference &&
          other.note == this.note);
}

class BiblesCompanion extends UpdateCompanion<Bible> {
  final Value<int> id;
  final Value<int> pageId;
  final Value<String> category;
  final Value<String> book;
  final Value<int> chapter;
  final Value<int> verse;
  final Value<String> textContent;
  final Value<List<String>?> reference;
  final Value<String?> note;
  const BiblesCompanion({
    this.id = const Value.absent(),
    this.pageId = const Value.absent(),
    this.category = const Value.absent(),
    this.book = const Value.absent(),
    this.chapter = const Value.absent(),
    this.verse = const Value.absent(),
    this.textContent = const Value.absent(),
    this.reference = const Value.absent(),
    this.note = const Value.absent(),
  });
  BiblesCompanion.insert({
    this.id = const Value.absent(),
    required int pageId,
    required String category,
    required String book,
    required int chapter,
    required int verse,
    required String textContent,
    this.reference = const Value.absent(),
    this.note = const Value.absent(),
  }) : pageId = Value(pageId),
       category = Value(category),
       book = Value(book),
       chapter = Value(chapter),
       verse = Value(verse),
       textContent = Value(textContent);
  static Insertable<Bible> custom({
    Expression<int>? id,
    Expression<int>? pageId,
    Expression<String>? category,
    Expression<String>? book,
    Expression<int>? chapter,
    Expression<int>? verse,
    Expression<String>? textContent,
    Expression<String>? reference,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pageId != null) 'page_id': pageId,
      if (category != null) 'category': category,
      if (book != null) 'book': book,
      if (chapter != null) 'chapter': chapter,
      if (verse != null) 'verse': verse,
      if (textContent != null) 'text': textContent,
      if (reference != null) 'reference': reference,
      if (note != null) 'note': note,
    });
  }

  BiblesCompanion copyWith({
    Value<int>? id,
    Value<int>? pageId,
    Value<String>? category,
    Value<String>? book,
    Value<int>? chapter,
    Value<int>? verse,
    Value<String>? textContent,
    Value<List<String>?>? reference,
    Value<String?>? note,
  }) {
    return BiblesCompanion(
      id: id ?? this.id,
      pageId: pageId ?? this.pageId,
      category: category ?? this.category,
      book: book ?? this.book,
      chapter: chapter ?? this.chapter,
      verse: verse ?? this.verse,
      textContent: textContent ?? this.textContent,
      reference: reference ?? this.reference,
      note: note ?? this.note,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (pageId.present) {
      map['page_id'] = Variable<int>(pageId.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (book.present) {
      map['book'] = Variable<String>(book.value);
    }
    if (chapter.present) {
      map['chapter'] = Variable<int>(chapter.value);
    }
    if (verse.present) {
      map['verse'] = Variable<int>(verse.value);
    }
    if (textContent.present) {
      map['text'] = Variable<String>(textContent.value);
    }
    if (reference.present) {
      map['reference'] = Variable<String>(
        $BiblesTable.$converterreferencen.toSql(reference.value),
      );
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BiblesCompanion(')
          ..write('id: $id, ')
          ..write('pageId: $pageId, ')
          ..write('category: $category, ')
          ..write('book: $book, ')
          ..write('chapter: $chapter, ')
          ..write('verse: $verse, ')
          ..write('textContent: $textContent, ')
          ..write('reference: $reference, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }
}

class $WikiPageRevisionsTable extends WikiPageRevisions
    with TableInfo<$WikiPageRevisionsTable, WikiPageRevision> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WikiPageRevisionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _pageIdMeta = const VerificationMeta('pageId');
  @override
  late final GeneratedColumn<int> pageId = GeneratedColumn<int>(
    'page_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastRevidMeta = const VerificationMeta(
    'lastRevid',
  );
  @override
  late final GeneratedColumn<int> lastRevid = GeneratedColumn<int>(
    'last_revid',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pageTitleMeta = const VerificationMeta(
    'pageTitle',
  );
  @override
  late final GeneratedColumn<String> pageTitle = GeneratedColumn<String>(
    'page_title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pageTypeMeta = const VerificationMeta(
    'pageType',
  );
  @override
  late final GeneratedColumn<String> pageType = GeneratedColumn<String>(
    'page_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastUpdatedMeta = const VerificationMeta(
    'lastUpdated',
  );
  @override
  late final GeneratedColumn<DateTime> lastUpdated = GeneratedColumn<DateTime>(
    'last_updated',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    pageId,
    lastRevid,
    pageTitle,
    pageType,
    lastUpdated,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wiki_page_revisions';
  @override
  VerificationContext validateIntegrity(
    Insertable<WikiPageRevision> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('page_id')) {
      context.handle(
        _pageIdMeta,
        pageId.isAcceptableOrUnknown(data['page_id']!, _pageIdMeta),
      );
    }
    if (data.containsKey('last_revid')) {
      context.handle(
        _lastRevidMeta,
        lastRevid.isAcceptableOrUnknown(data['last_revid']!, _lastRevidMeta),
      );
    } else if (isInserting) {
      context.missing(_lastRevidMeta);
    }
    if (data.containsKey('page_title')) {
      context.handle(
        _pageTitleMeta,
        pageTitle.isAcceptableOrUnknown(data['page_title']!, _pageTitleMeta),
      );
    } else if (isInserting) {
      context.missing(_pageTitleMeta);
    }
    if (data.containsKey('page_type')) {
      context.handle(
        _pageTypeMeta,
        pageType.isAcceptableOrUnknown(data['page_type']!, _pageTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_pageTypeMeta);
    }
    if (data.containsKey('last_updated')) {
      context.handle(
        _lastUpdatedMeta,
        lastUpdated.isAcceptableOrUnknown(
          data['last_updated']!,
          _lastUpdatedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastUpdatedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {pageId};
  @override
  WikiPageRevision map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WikiPageRevision(
      pageId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_id'],
      )!,
      lastRevid: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_revid'],
      )!,
      pageTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}page_title'],
      )!,
      pageType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}page_type'],
      )!,
      lastUpdated: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_updated'],
      )!,
    );
  }

  @override
  $WikiPageRevisionsTable createAlias(String alias) {
    return $WikiPageRevisionsTable(attachedDatabase, alias);
  }
}

class WikiPageRevision extends DataClass
    implements Insertable<WikiPageRevision> {
  final int pageId;
  final int lastRevid;
  final String pageTitle;
  final String pageType;
  final DateTime lastUpdated;
  const WikiPageRevision({
    required this.pageId,
    required this.lastRevid,
    required this.pageTitle,
    required this.pageType,
    required this.lastUpdated,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['page_id'] = Variable<int>(pageId);
    map['last_revid'] = Variable<int>(lastRevid);
    map['page_title'] = Variable<String>(pageTitle);
    map['page_type'] = Variable<String>(pageType);
    map['last_updated'] = Variable<DateTime>(lastUpdated);
    return map;
  }

  WikiPageRevisionsCompanion toCompanion(bool nullToAbsent) {
    return WikiPageRevisionsCompanion(
      pageId: Value(pageId),
      lastRevid: Value(lastRevid),
      pageTitle: Value(pageTitle),
      pageType: Value(pageType),
      lastUpdated: Value(lastUpdated),
    );
  }

  factory WikiPageRevision.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WikiPageRevision(
      pageId: serializer.fromJson<int>(json['pageId']),
      lastRevid: serializer.fromJson<int>(json['lastRevid']),
      pageTitle: serializer.fromJson<String>(json['pageTitle']),
      pageType: serializer.fromJson<String>(json['pageType']),
      lastUpdated: serializer.fromJson<DateTime>(json['lastUpdated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'pageId': serializer.toJson<int>(pageId),
      'lastRevid': serializer.toJson<int>(lastRevid),
      'pageTitle': serializer.toJson<String>(pageTitle),
      'pageType': serializer.toJson<String>(pageType),
      'lastUpdated': serializer.toJson<DateTime>(lastUpdated),
    };
  }

  WikiPageRevision copyWith({
    int? pageId,
    int? lastRevid,
    String? pageTitle,
    String? pageType,
    DateTime? lastUpdated,
  }) => WikiPageRevision(
    pageId: pageId ?? this.pageId,
    lastRevid: lastRevid ?? this.lastRevid,
    pageTitle: pageTitle ?? this.pageTitle,
    pageType: pageType ?? this.pageType,
    lastUpdated: lastUpdated ?? this.lastUpdated,
  );
  WikiPageRevision copyWithCompanion(WikiPageRevisionsCompanion data) {
    return WikiPageRevision(
      pageId: data.pageId.present ? data.pageId.value : this.pageId,
      lastRevid: data.lastRevid.present ? data.lastRevid.value : this.lastRevid,
      pageTitle: data.pageTitle.present ? data.pageTitle.value : this.pageTitle,
      pageType: data.pageType.present ? data.pageType.value : this.pageType,
      lastUpdated: data.lastUpdated.present
          ? data.lastUpdated.value
          : this.lastUpdated,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WikiPageRevision(')
          ..write('pageId: $pageId, ')
          ..write('lastRevid: $lastRevid, ')
          ..write('pageTitle: $pageTitle, ')
          ..write('pageType: $pageType, ')
          ..write('lastUpdated: $lastUpdated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(pageId, lastRevid, pageTitle, pageType, lastUpdated);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WikiPageRevision &&
          other.pageId == this.pageId &&
          other.lastRevid == this.lastRevid &&
          other.pageTitle == this.pageTitle &&
          other.pageType == this.pageType &&
          other.lastUpdated == this.lastUpdated);
}

class WikiPageRevisionsCompanion extends UpdateCompanion<WikiPageRevision> {
  final Value<int> pageId;
  final Value<int> lastRevid;
  final Value<String> pageTitle;
  final Value<String> pageType;
  final Value<DateTime> lastUpdated;
  const WikiPageRevisionsCompanion({
    this.pageId = const Value.absent(),
    this.lastRevid = const Value.absent(),
    this.pageTitle = const Value.absent(),
    this.pageType = const Value.absent(),
    this.lastUpdated = const Value.absent(),
  });
  WikiPageRevisionsCompanion.insert({
    this.pageId = const Value.absent(),
    required int lastRevid,
    required String pageTitle,
    required String pageType,
    required DateTime lastUpdated,
  }) : lastRevid = Value(lastRevid),
       pageTitle = Value(pageTitle),
       pageType = Value(pageType),
       lastUpdated = Value(lastUpdated);
  static Insertable<WikiPageRevision> custom({
    Expression<int>? pageId,
    Expression<int>? lastRevid,
    Expression<String>? pageTitle,
    Expression<String>? pageType,
    Expression<DateTime>? lastUpdated,
  }) {
    return RawValuesInsertable({
      if (pageId != null) 'page_id': pageId,
      if (lastRevid != null) 'last_revid': lastRevid,
      if (pageTitle != null) 'page_title': pageTitle,
      if (pageType != null) 'page_type': pageType,
      if (lastUpdated != null) 'last_updated': lastUpdated,
    });
  }

  WikiPageRevisionsCompanion copyWith({
    Value<int>? pageId,
    Value<int>? lastRevid,
    Value<String>? pageTitle,
    Value<String>? pageType,
    Value<DateTime>? lastUpdated,
  }) {
    return WikiPageRevisionsCompanion(
      pageId: pageId ?? this.pageId,
      lastRevid: lastRevid ?? this.lastRevid,
      pageTitle: pageTitle ?? this.pageTitle,
      pageType: pageType ?? this.pageType,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (pageId.present) {
      map['page_id'] = Variable<int>(pageId.value);
    }
    if (lastRevid.present) {
      map['last_revid'] = Variable<int>(lastRevid.value);
    }
    if (pageTitle.present) {
      map['page_title'] = Variable<String>(pageTitle.value);
    }
    if (pageType.present) {
      map['page_type'] = Variable<String>(pageType.value);
    }
    if (lastUpdated.present) {
      map['last_updated'] = Variable<DateTime>(lastUpdated.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WikiPageRevisionsCompanion(')
          ..write('pageId: $pageId, ')
          ..write('lastRevid: $lastRevid, ')
          ..write('pageTitle: $pageTitle, ')
          ..write('pageType: $pageType, ')
          ..write('lastUpdated: $lastUpdated')
          ..write(')'))
        .toString();
  }
}

class $SongsTable extends Songs with TableInfo<$SongsTable, Song> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SongsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _pageIdMeta = const VerificationMeta('pageId');
  @override
  late final GeneratedColumn<int> pageId = GeneratedColumn<int>(
    'page_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _textContentMeta = const VerificationMeta(
    'textContent',
  );
  @override
  late final GeneratedColumn<String> textContent = GeneratedColumn<String>(
    'text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>?, String> artist =
      GeneratedColumn<String>(
        'artist',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<List<String>?>($SongsTable.$converterartistn);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>?, String> writer =
      GeneratedColumn<String>(
        'writer',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<List<String>?>($SongsTable.$converterwritern);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>?, String> producer =
      GeneratedColumn<String>(
        'producer',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<List<String>?>($SongsTable.$converterproducern);
  static const VerificationMeta _albumMeta = const VerificationMeta('album');
  @override
  late final GeneratedColumn<String> album = GeneratedColumn<String>(
    'album',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _genreMeta = const VerificationMeta('genre');
  @override
  late final GeneratedColumn<String> genre = GeneratedColumn<String>(
    'genre',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _releasedMeta = const VerificationMeta(
    'released',
  );
  @override
  late final GeneratedColumn<String> released = GeneratedColumn<String>(
    'released',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recordedMeta = const VerificationMeta(
    'recorded',
  );
  @override
  late final GeneratedColumn<String> recorded = GeneratedColumn<String>(
    'recorded',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _studioMeta = const VerificationMeta('studio');
  @override
  late final GeneratedColumn<String> studio = GeneratedColumn<String>(
    'studio',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _youtubeMeta = const VerificationMeta(
    'youtube',
  );
  @override
  late final GeneratedColumn<String> youtube = GeneratedColumn<String>(
    'youtube',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    pageId,
    title,
    textContent,
    category,
    type,
    artist,
    writer,
    producer,
    album,
    genre,
    released,
    recorded,
    studio,
    label,
    url,
    youtube,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'songs';
  @override
  VerificationContext validateIntegrity(
    Insertable<Song> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('page_id')) {
      context.handle(
        _pageIdMeta,
        pageId.isAcceptableOrUnknown(data['page_id']!, _pageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_pageIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('text')) {
      context.handle(
        _textContentMeta,
        textContent.isAcceptableOrUnknown(data['text']!, _textContentMeta),
      );
    } else if (isInserting) {
      context.missing(_textContentMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('album')) {
      context.handle(
        _albumMeta,
        album.isAcceptableOrUnknown(data['album']!, _albumMeta),
      );
    }
    if (data.containsKey('genre')) {
      context.handle(
        _genreMeta,
        genre.isAcceptableOrUnknown(data['genre']!, _genreMeta),
      );
    }
    if (data.containsKey('released')) {
      context.handle(
        _releasedMeta,
        released.isAcceptableOrUnknown(data['released']!, _releasedMeta),
      );
    }
    if (data.containsKey('recorded')) {
      context.handle(
        _recordedMeta,
        recorded.isAcceptableOrUnknown(data['recorded']!, _recordedMeta),
      );
    }
    if (data.containsKey('studio')) {
      context.handle(
        _studioMeta,
        studio.isAcceptableOrUnknown(data['studio']!, _studioMeta),
      );
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    }
    if (data.containsKey('youtube')) {
      context.handle(
        _youtubeMeta,
        youtube.isAcceptableOrUnknown(data['youtube']!, _youtubeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Song map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Song(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      pageId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      textContent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      ),
      artist: $SongsTable.$converterartistn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}artist'],
        ),
      ),
      writer: $SongsTable.$converterwritern.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}writer'],
        ),
      ),
      producer: $SongsTable.$converterproducern.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}producer'],
        ),
      ),
      album: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}album'],
      ),
      genre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}genre'],
      ),
      released: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}released'],
      ),
      recorded: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recorded'],
      ),
      studio: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}studio'],
      ),
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      ),
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      ),
      youtube: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}youtube'],
      ),
    );
  }

  @override
  $SongsTable createAlias(String alias) {
    return $SongsTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $converterartist =
      const StringListConverter();
  static TypeConverter<List<String>?, String?> $converterartistn =
      NullAwareTypeConverter.wrap($converterartist);
  static TypeConverter<List<String>, String> $converterwriter =
      const StringListConverter();
  static TypeConverter<List<String>?, String?> $converterwritern =
      NullAwareTypeConverter.wrap($converterwriter);
  static TypeConverter<List<String>, String> $converterproducer =
      const StringListConverter();
  static TypeConverter<List<String>?, String?> $converterproducern =
      NullAwareTypeConverter.wrap($converterproducer);
}

class Song extends DataClass implements Insertable<Song> {
  final int id;
  final int pageId;
  final String title;
  final String textContent;
  final String category;
  final String? type;
  final List<String>? artist;
  final List<String>? writer;
  final List<String>? producer;
  final String? album;
  final String? genre;
  final String? released;
  final String? recorded;
  final String? studio;
  final String? label;
  final String? url;
  final String? youtube;
  const Song({
    required this.id,
    required this.pageId,
    required this.title,
    required this.textContent,
    required this.category,
    this.type,
    this.artist,
    this.writer,
    this.producer,
    this.album,
    this.genre,
    this.released,
    this.recorded,
    this.studio,
    this.label,
    this.url,
    this.youtube,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['page_id'] = Variable<int>(pageId);
    map['title'] = Variable<String>(title);
    map['text'] = Variable<String>(textContent);
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || type != null) {
      map['type'] = Variable<String>(type);
    }
    if (!nullToAbsent || artist != null) {
      map['artist'] = Variable<String>(
        $SongsTable.$converterartistn.toSql(artist),
      );
    }
    if (!nullToAbsent || writer != null) {
      map['writer'] = Variable<String>(
        $SongsTable.$converterwritern.toSql(writer),
      );
    }
    if (!nullToAbsent || producer != null) {
      map['producer'] = Variable<String>(
        $SongsTable.$converterproducern.toSql(producer),
      );
    }
    if (!nullToAbsent || album != null) {
      map['album'] = Variable<String>(album);
    }
    if (!nullToAbsent || genre != null) {
      map['genre'] = Variable<String>(genre);
    }
    if (!nullToAbsent || released != null) {
      map['released'] = Variable<String>(released);
    }
    if (!nullToAbsent || recorded != null) {
      map['recorded'] = Variable<String>(recorded);
    }
    if (!nullToAbsent || studio != null) {
      map['studio'] = Variable<String>(studio);
    }
    if (!nullToAbsent || label != null) {
      map['label'] = Variable<String>(label);
    }
    if (!nullToAbsent || url != null) {
      map['url'] = Variable<String>(url);
    }
    if (!nullToAbsent || youtube != null) {
      map['youtube'] = Variable<String>(youtube);
    }
    return map;
  }

  SongsCompanion toCompanion(bool nullToAbsent) {
    return SongsCompanion(
      id: Value(id),
      pageId: Value(pageId),
      title: Value(title),
      textContent: Value(textContent),
      category: Value(category),
      type: type == null && nullToAbsent ? const Value.absent() : Value(type),
      artist: artist == null && nullToAbsent
          ? const Value.absent()
          : Value(artist),
      writer: writer == null && nullToAbsent
          ? const Value.absent()
          : Value(writer),
      producer: producer == null && nullToAbsent
          ? const Value.absent()
          : Value(producer),
      album: album == null && nullToAbsent
          ? const Value.absent()
          : Value(album),
      genre: genre == null && nullToAbsent
          ? const Value.absent()
          : Value(genre),
      released: released == null && nullToAbsent
          ? const Value.absent()
          : Value(released),
      recorded: recorded == null && nullToAbsent
          ? const Value.absent()
          : Value(recorded),
      studio: studio == null && nullToAbsent
          ? const Value.absent()
          : Value(studio),
      label: label == null && nullToAbsent
          ? const Value.absent()
          : Value(label),
      url: url == null && nullToAbsent ? const Value.absent() : Value(url),
      youtube: youtube == null && nullToAbsent
          ? const Value.absent()
          : Value(youtube),
    );
  }

  factory Song.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Song(
      id: serializer.fromJson<int>(json['id']),
      pageId: serializer.fromJson<int>(json['pageId']),
      title: serializer.fromJson<String>(json['title']),
      textContent: serializer.fromJson<String>(json['textContent']),
      category: serializer.fromJson<String>(json['category']),
      type: serializer.fromJson<String?>(json['type']),
      artist: serializer.fromJson<List<String>?>(json['artist']),
      writer: serializer.fromJson<List<String>?>(json['writer']),
      producer: serializer.fromJson<List<String>?>(json['producer']),
      album: serializer.fromJson<String?>(json['album']),
      genre: serializer.fromJson<String?>(json['genre']),
      released: serializer.fromJson<String?>(json['released']),
      recorded: serializer.fromJson<String?>(json['recorded']),
      studio: serializer.fromJson<String?>(json['studio']),
      label: serializer.fromJson<String?>(json['label']),
      url: serializer.fromJson<String?>(json['url']),
      youtube: serializer.fromJson<String?>(json['youtube']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'pageId': serializer.toJson<int>(pageId),
      'title': serializer.toJson<String>(title),
      'textContent': serializer.toJson<String>(textContent),
      'category': serializer.toJson<String>(category),
      'type': serializer.toJson<String?>(type),
      'artist': serializer.toJson<List<String>?>(artist),
      'writer': serializer.toJson<List<String>?>(writer),
      'producer': serializer.toJson<List<String>?>(producer),
      'album': serializer.toJson<String?>(album),
      'genre': serializer.toJson<String?>(genre),
      'released': serializer.toJson<String?>(released),
      'recorded': serializer.toJson<String?>(recorded),
      'studio': serializer.toJson<String?>(studio),
      'label': serializer.toJson<String?>(label),
      'url': serializer.toJson<String?>(url),
      'youtube': serializer.toJson<String?>(youtube),
    };
  }

  Song copyWith({
    int? id,
    int? pageId,
    String? title,
    String? textContent,
    String? category,
    Value<String?> type = const Value.absent(),
    Value<List<String>?> artist = const Value.absent(),
    Value<List<String>?> writer = const Value.absent(),
    Value<List<String>?> producer = const Value.absent(),
    Value<String?> album = const Value.absent(),
    Value<String?> genre = const Value.absent(),
    Value<String?> released = const Value.absent(),
    Value<String?> recorded = const Value.absent(),
    Value<String?> studio = const Value.absent(),
    Value<String?> label = const Value.absent(),
    Value<String?> url = const Value.absent(),
    Value<String?> youtube = const Value.absent(),
  }) => Song(
    id: id ?? this.id,
    pageId: pageId ?? this.pageId,
    title: title ?? this.title,
    textContent: textContent ?? this.textContent,
    category: category ?? this.category,
    type: type.present ? type.value : this.type,
    artist: artist.present ? artist.value : this.artist,
    writer: writer.present ? writer.value : this.writer,
    producer: producer.present ? producer.value : this.producer,
    album: album.present ? album.value : this.album,
    genre: genre.present ? genre.value : this.genre,
    released: released.present ? released.value : this.released,
    recorded: recorded.present ? recorded.value : this.recorded,
    studio: studio.present ? studio.value : this.studio,
    label: label.present ? label.value : this.label,
    url: url.present ? url.value : this.url,
    youtube: youtube.present ? youtube.value : this.youtube,
  );
  Song copyWithCompanion(SongsCompanion data) {
    return Song(
      id: data.id.present ? data.id.value : this.id,
      pageId: data.pageId.present ? data.pageId.value : this.pageId,
      title: data.title.present ? data.title.value : this.title,
      textContent: data.textContent.present
          ? data.textContent.value
          : this.textContent,
      category: data.category.present ? data.category.value : this.category,
      type: data.type.present ? data.type.value : this.type,
      artist: data.artist.present ? data.artist.value : this.artist,
      writer: data.writer.present ? data.writer.value : this.writer,
      producer: data.producer.present ? data.producer.value : this.producer,
      album: data.album.present ? data.album.value : this.album,
      genre: data.genre.present ? data.genre.value : this.genre,
      released: data.released.present ? data.released.value : this.released,
      recorded: data.recorded.present ? data.recorded.value : this.recorded,
      studio: data.studio.present ? data.studio.value : this.studio,
      label: data.label.present ? data.label.value : this.label,
      url: data.url.present ? data.url.value : this.url,
      youtube: data.youtube.present ? data.youtube.value : this.youtube,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Song(')
          ..write('id: $id, ')
          ..write('pageId: $pageId, ')
          ..write('title: $title, ')
          ..write('textContent: $textContent, ')
          ..write('category: $category, ')
          ..write('type: $type, ')
          ..write('artist: $artist, ')
          ..write('writer: $writer, ')
          ..write('producer: $producer, ')
          ..write('album: $album, ')
          ..write('genre: $genre, ')
          ..write('released: $released, ')
          ..write('recorded: $recorded, ')
          ..write('studio: $studio, ')
          ..write('label: $label, ')
          ..write('url: $url, ')
          ..write('youtube: $youtube')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    pageId,
    title,
    textContent,
    category,
    type,
    artist,
    writer,
    producer,
    album,
    genre,
    released,
    recorded,
    studio,
    label,
    url,
    youtube,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Song &&
          other.id == this.id &&
          other.pageId == this.pageId &&
          other.title == this.title &&
          other.textContent == this.textContent &&
          other.category == this.category &&
          other.type == this.type &&
          other.artist == this.artist &&
          other.writer == this.writer &&
          other.producer == this.producer &&
          other.album == this.album &&
          other.genre == this.genre &&
          other.released == this.released &&
          other.recorded == this.recorded &&
          other.studio == this.studio &&
          other.label == this.label &&
          other.url == this.url &&
          other.youtube == this.youtube);
}

class SongsCompanion extends UpdateCompanion<Song> {
  final Value<int> id;
  final Value<int> pageId;
  final Value<String> title;
  final Value<String> textContent;
  final Value<String> category;
  final Value<String?> type;
  final Value<List<String>?> artist;
  final Value<List<String>?> writer;
  final Value<List<String>?> producer;
  final Value<String?> album;
  final Value<String?> genre;
  final Value<String?> released;
  final Value<String?> recorded;
  final Value<String?> studio;
  final Value<String?> label;
  final Value<String?> url;
  final Value<String?> youtube;
  const SongsCompanion({
    this.id = const Value.absent(),
    this.pageId = const Value.absent(),
    this.title = const Value.absent(),
    this.textContent = const Value.absent(),
    this.category = const Value.absent(),
    this.type = const Value.absent(),
    this.artist = const Value.absent(),
    this.writer = const Value.absent(),
    this.producer = const Value.absent(),
    this.album = const Value.absent(),
    this.genre = const Value.absent(),
    this.released = const Value.absent(),
    this.recorded = const Value.absent(),
    this.studio = const Value.absent(),
    this.label = const Value.absent(),
    this.url = const Value.absent(),
    this.youtube = const Value.absent(),
  });
  SongsCompanion.insert({
    this.id = const Value.absent(),
    required int pageId,
    required String title,
    required String textContent,
    required String category,
    this.type = const Value.absent(),
    this.artist = const Value.absent(),
    this.writer = const Value.absent(),
    this.producer = const Value.absent(),
    this.album = const Value.absent(),
    this.genre = const Value.absent(),
    this.released = const Value.absent(),
    this.recorded = const Value.absent(),
    this.studio = const Value.absent(),
    this.label = const Value.absent(),
    this.url = const Value.absent(),
    this.youtube = const Value.absent(),
  }) : pageId = Value(pageId),
       title = Value(title),
       textContent = Value(textContent),
       category = Value(category);
  static Insertable<Song> custom({
    Expression<int>? id,
    Expression<int>? pageId,
    Expression<String>? title,
    Expression<String>? textContent,
    Expression<String>? category,
    Expression<String>? type,
    Expression<String>? artist,
    Expression<String>? writer,
    Expression<String>? producer,
    Expression<String>? album,
    Expression<String>? genre,
    Expression<String>? released,
    Expression<String>? recorded,
    Expression<String>? studio,
    Expression<String>? label,
    Expression<String>? url,
    Expression<String>? youtube,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pageId != null) 'page_id': pageId,
      if (title != null) 'title': title,
      if (textContent != null) 'text': textContent,
      if (category != null) 'category': category,
      if (type != null) 'type': type,
      if (artist != null) 'artist': artist,
      if (writer != null) 'writer': writer,
      if (producer != null) 'producer': producer,
      if (album != null) 'album': album,
      if (genre != null) 'genre': genre,
      if (released != null) 'released': released,
      if (recorded != null) 'recorded': recorded,
      if (studio != null) 'studio': studio,
      if (label != null) 'label': label,
      if (url != null) 'url': url,
      if (youtube != null) 'youtube': youtube,
    });
  }

  SongsCompanion copyWith({
    Value<int>? id,
    Value<int>? pageId,
    Value<String>? title,
    Value<String>? textContent,
    Value<String>? category,
    Value<String?>? type,
    Value<List<String>?>? artist,
    Value<List<String>?>? writer,
    Value<List<String>?>? producer,
    Value<String?>? album,
    Value<String?>? genre,
    Value<String?>? released,
    Value<String?>? recorded,
    Value<String?>? studio,
    Value<String?>? label,
    Value<String?>? url,
    Value<String?>? youtube,
  }) {
    return SongsCompanion(
      id: id ?? this.id,
      pageId: pageId ?? this.pageId,
      title: title ?? this.title,
      textContent: textContent ?? this.textContent,
      category: category ?? this.category,
      type: type ?? this.type,
      artist: artist ?? this.artist,
      writer: writer ?? this.writer,
      producer: producer ?? this.producer,
      album: album ?? this.album,
      genre: genre ?? this.genre,
      released: released ?? this.released,
      recorded: recorded ?? this.recorded,
      studio: studio ?? this.studio,
      label: label ?? this.label,
      url: url ?? this.url,
      youtube: youtube ?? this.youtube,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (pageId.present) {
      map['page_id'] = Variable<int>(pageId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (textContent.present) {
      map['text'] = Variable<String>(textContent.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (artist.present) {
      map['artist'] = Variable<String>(
        $SongsTable.$converterartistn.toSql(artist.value),
      );
    }
    if (writer.present) {
      map['writer'] = Variable<String>(
        $SongsTable.$converterwritern.toSql(writer.value),
      );
    }
    if (producer.present) {
      map['producer'] = Variable<String>(
        $SongsTable.$converterproducern.toSql(producer.value),
      );
    }
    if (album.present) {
      map['album'] = Variable<String>(album.value);
    }
    if (genre.present) {
      map['genre'] = Variable<String>(genre.value);
    }
    if (released.present) {
      map['released'] = Variable<String>(released.value);
    }
    if (recorded.present) {
      map['recorded'] = Variable<String>(recorded.value);
    }
    if (studio.present) {
      map['studio'] = Variable<String>(studio.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (youtube.present) {
      map['youtube'] = Variable<String>(youtube.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SongsCompanion(')
          ..write('id: $id, ')
          ..write('pageId: $pageId, ')
          ..write('title: $title, ')
          ..write('textContent: $textContent, ')
          ..write('category: $category, ')
          ..write('type: $type, ')
          ..write('artist: $artist, ')
          ..write('writer: $writer, ')
          ..write('producer: $producer, ')
          ..write('album: $album, ')
          ..write('genre: $genre, ')
          ..write('released: $released, ')
          ..write('recorded: $recorded, ')
          ..write('studio: $studio, ')
          ..write('label: $label, ')
          ..write('url: $url, ')
          ..write('youtube: $youtube')
          ..write(')'))
        .toString();
  }
}

class $ManoManosTable extends ManoManos
    with TableInfo<$ManoManosTable, ManoMano> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ManoManosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _pageIdMeta = const VerificationMeta('pageId');
  @override
  late final GeneratedColumn<int> pageId = GeneratedColumn<int>(
    'page_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _textContentMeta = const VerificationMeta(
    'textContent',
  );
  @override
  late final GeneratedColumn<String> textContent = GeneratedColumn<String>(
    'text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>?, String> editor =
      GeneratedColumn<String>(
        'editor',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<List<String>?>($ManoManosTable.$convertereditorn);
  static const VerificationMeta _originMeta = const VerificationMeta('origin');
  @override
  late final GeneratedColumn<String> origin = GeneratedColumn<String>(
    'origin',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    pageId,
    title,
    textContent,
    description,
    editor,
    origin,
    source,
    url,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mano_mano';
  @override
  VerificationContext validateIntegrity(
    Insertable<ManoMano> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('page_id')) {
      context.handle(
        _pageIdMeta,
        pageId.isAcceptableOrUnknown(data['page_id']!, _pageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_pageIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('text')) {
      context.handle(
        _textContentMeta,
        textContent.isAcceptableOrUnknown(data['text']!, _textContentMeta),
      );
    } else if (isInserting) {
      context.missing(_textContentMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('origin')) {
      context.handle(
        _originMeta,
        origin.isAcceptableOrUnknown(data['origin']!, _originMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ManoMano map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ManoMano(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      pageId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      textContent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      editor: $ManoManosTable.$convertereditorn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}editor'],
        ),
      ),
      origin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      ),
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      ),
    );
  }

  @override
  $ManoManosTable createAlias(String alias) {
    return $ManoManosTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $convertereditor =
      const StringListConverter();
  static TypeConverter<List<String>?, String?> $convertereditorn =
      NullAwareTypeConverter.wrap($convertereditor);
}

class ManoMano extends DataClass implements Insertable<ManoMano> {
  final int id;
  final int pageId;
  final String title;
  final String textContent;
  final String? description;
  final List<String>? editor;
  final String? origin;
  final String? source;
  final String? url;
  const ManoMano({
    required this.id,
    required this.pageId,
    required this.title,
    required this.textContent,
    this.description,
    this.editor,
    this.origin,
    this.source,
    this.url,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['page_id'] = Variable<int>(pageId);
    map['title'] = Variable<String>(title);
    map['text'] = Variable<String>(textContent);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || editor != null) {
      map['editor'] = Variable<String>(
        $ManoManosTable.$convertereditorn.toSql(editor),
      );
    }
    if (!nullToAbsent || origin != null) {
      map['origin'] = Variable<String>(origin);
    }
    if (!nullToAbsent || source != null) {
      map['source'] = Variable<String>(source);
    }
    if (!nullToAbsent || url != null) {
      map['url'] = Variable<String>(url);
    }
    return map;
  }

  ManoManosCompanion toCompanion(bool nullToAbsent) {
    return ManoManosCompanion(
      id: Value(id),
      pageId: Value(pageId),
      title: Value(title),
      textContent: Value(textContent),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      editor: editor == null && nullToAbsent
          ? const Value.absent()
          : Value(editor),
      origin: origin == null && nullToAbsent
          ? const Value.absent()
          : Value(origin),
      source: source == null && nullToAbsent
          ? const Value.absent()
          : Value(source),
      url: url == null && nullToAbsent ? const Value.absent() : Value(url),
    );
  }

  factory ManoMano.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ManoMano(
      id: serializer.fromJson<int>(json['id']),
      pageId: serializer.fromJson<int>(json['pageId']),
      title: serializer.fromJson<String>(json['title']),
      textContent: serializer.fromJson<String>(json['textContent']),
      description: serializer.fromJson<String?>(json['description']),
      editor: serializer.fromJson<List<String>?>(json['editor']),
      origin: serializer.fromJson<String?>(json['origin']),
      source: serializer.fromJson<String?>(json['source']),
      url: serializer.fromJson<String?>(json['url']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'pageId': serializer.toJson<int>(pageId),
      'title': serializer.toJson<String>(title),
      'textContent': serializer.toJson<String>(textContent),
      'description': serializer.toJson<String?>(description),
      'editor': serializer.toJson<List<String>?>(editor),
      'origin': serializer.toJson<String?>(origin),
      'source': serializer.toJson<String?>(source),
      'url': serializer.toJson<String?>(url),
    };
  }

  ManoMano copyWith({
    int? id,
    int? pageId,
    String? title,
    String? textContent,
    Value<String?> description = const Value.absent(),
    Value<List<String>?> editor = const Value.absent(),
    Value<String?> origin = const Value.absent(),
    Value<String?> source = const Value.absent(),
    Value<String?> url = const Value.absent(),
  }) => ManoMano(
    id: id ?? this.id,
    pageId: pageId ?? this.pageId,
    title: title ?? this.title,
    textContent: textContent ?? this.textContent,
    description: description.present ? description.value : this.description,
    editor: editor.present ? editor.value : this.editor,
    origin: origin.present ? origin.value : this.origin,
    source: source.present ? source.value : this.source,
    url: url.present ? url.value : this.url,
  );
  ManoMano copyWithCompanion(ManoManosCompanion data) {
    return ManoMano(
      id: data.id.present ? data.id.value : this.id,
      pageId: data.pageId.present ? data.pageId.value : this.pageId,
      title: data.title.present ? data.title.value : this.title,
      textContent: data.textContent.present
          ? data.textContent.value
          : this.textContent,
      description: data.description.present
          ? data.description.value
          : this.description,
      editor: data.editor.present ? data.editor.value : this.editor,
      origin: data.origin.present ? data.origin.value : this.origin,
      source: data.source.present ? data.source.value : this.source,
      url: data.url.present ? data.url.value : this.url,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ManoMano(')
          ..write('id: $id, ')
          ..write('pageId: $pageId, ')
          ..write('title: $title, ')
          ..write('textContent: $textContent, ')
          ..write('description: $description, ')
          ..write('editor: $editor, ')
          ..write('origin: $origin, ')
          ..write('source: $source, ')
          ..write('url: $url')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    pageId,
    title,
    textContent,
    description,
    editor,
    origin,
    source,
    url,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ManoMano &&
          other.id == this.id &&
          other.pageId == this.pageId &&
          other.title == this.title &&
          other.textContent == this.textContent &&
          other.description == this.description &&
          other.editor == this.editor &&
          other.origin == this.origin &&
          other.source == this.source &&
          other.url == this.url);
}

class ManoManosCompanion extends UpdateCompanion<ManoMano> {
  final Value<int> id;
  final Value<int> pageId;
  final Value<String> title;
  final Value<String> textContent;
  final Value<String?> description;
  final Value<List<String>?> editor;
  final Value<String?> origin;
  final Value<String?> source;
  final Value<String?> url;
  const ManoManosCompanion({
    this.id = const Value.absent(),
    this.pageId = const Value.absent(),
    this.title = const Value.absent(),
    this.textContent = const Value.absent(),
    this.description = const Value.absent(),
    this.editor = const Value.absent(),
    this.origin = const Value.absent(),
    this.source = const Value.absent(),
    this.url = const Value.absent(),
  });
  ManoManosCompanion.insert({
    this.id = const Value.absent(),
    required int pageId,
    required String title,
    required String textContent,
    this.description = const Value.absent(),
    this.editor = const Value.absent(),
    this.origin = const Value.absent(),
    this.source = const Value.absent(),
    this.url = const Value.absent(),
  }) : pageId = Value(pageId),
       title = Value(title),
       textContent = Value(textContent);
  static Insertable<ManoMano> custom({
    Expression<int>? id,
    Expression<int>? pageId,
    Expression<String>? title,
    Expression<String>? textContent,
    Expression<String>? description,
    Expression<String>? editor,
    Expression<String>? origin,
    Expression<String>? source,
    Expression<String>? url,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pageId != null) 'page_id': pageId,
      if (title != null) 'title': title,
      if (textContent != null) 'text': textContent,
      if (description != null) 'description': description,
      if (editor != null) 'editor': editor,
      if (origin != null) 'origin': origin,
      if (source != null) 'source': source,
      if (url != null) 'url': url,
    });
  }

  ManoManosCompanion copyWith({
    Value<int>? id,
    Value<int>? pageId,
    Value<String>? title,
    Value<String>? textContent,
    Value<String?>? description,
    Value<List<String>?>? editor,
    Value<String?>? origin,
    Value<String?>? source,
    Value<String?>? url,
  }) {
    return ManoManosCompanion(
      id: id ?? this.id,
      pageId: pageId ?? this.pageId,
      title: title ?? this.title,
      textContent: textContent ?? this.textContent,
      description: description ?? this.description,
      editor: editor ?? this.editor,
      origin: origin ?? this.origin,
      source: source ?? this.source,
      url: url ?? this.url,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (pageId.present) {
      map['page_id'] = Variable<int>(pageId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (textContent.present) {
      map['text'] = Variable<String>(textContent.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (editor.present) {
      map['editor'] = Variable<String>(
        $ManoManosTable.$convertereditorn.toSql(editor.value),
      );
    }
    if (origin.present) {
      map['origin'] = Variable<String>(origin.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ManoManosCompanion(')
          ..write('id: $id, ')
          ..write('pageId: $pageId, ')
          ..write('title: $title, ')
          ..write('textContent: $textContent, ')
          ..write('description: $description, ')
          ..write('editor: $editor, ')
          ..write('origin: $origin, ')
          ..write('source: $source, ')
          ..write('url: $url')
          ..write(')'))
        .toString();
  }
}

class $ArticlesTable extends Articles with TableInfo<$ArticlesTable, Article> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ArticlesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _pageIdMeta = const VerificationMeta('pageId');
  @override
  late final GeneratedColumn<int> pageId = GeneratedColumn<int>(
    'page_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _textContentMeta = const VerificationMeta(
    'textContent',
  );
  @override
  late final GeneratedColumn<String> textContent = GeneratedColumn<String>(
    'text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>?, String> editor =
      GeneratedColumn<String>(
        'editor',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<List<String>?>($ArticlesTable.$convertereditorn);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    pageId,
    category,
    title,
    textContent,
    description,
    editor,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'articles';
  @override
  VerificationContext validateIntegrity(
    Insertable<Article> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('page_id')) {
      context.handle(
        _pageIdMeta,
        pageId.isAcceptableOrUnknown(data['page_id']!, _pageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_pageIdMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('text')) {
      context.handle(
        _textContentMeta,
        textContent.isAcceptableOrUnknown(data['text']!, _textContentMeta),
      );
    } else if (isInserting) {
      context.missing(_textContentMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Article map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Article(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      pageId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_id'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      textContent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      editor: $ArticlesTable.$convertereditorn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}editor'],
        ),
      ),
    );
  }

  @override
  $ArticlesTable createAlias(String alias) {
    return $ArticlesTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $convertereditor =
      const StringListConverter();
  static TypeConverter<List<String>?, String?> $convertereditorn =
      NullAwareTypeConverter.wrap($convertereditor);
}

class Article extends DataClass implements Insertable<Article> {
  final int id;
  final int pageId;
  final String category;
  final String title;
  final String textContent;
  final String? description;
  final List<String>? editor;
  const Article({
    required this.id,
    required this.pageId,
    required this.category,
    required this.title,
    required this.textContent,
    this.description,
    this.editor,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['page_id'] = Variable<int>(pageId);
    map['category'] = Variable<String>(category);
    map['title'] = Variable<String>(title);
    map['text'] = Variable<String>(textContent);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || editor != null) {
      map['editor'] = Variable<String>(
        $ArticlesTable.$convertereditorn.toSql(editor),
      );
    }
    return map;
  }

  ArticlesCompanion toCompanion(bool nullToAbsent) {
    return ArticlesCompanion(
      id: Value(id),
      pageId: Value(pageId),
      category: Value(category),
      title: Value(title),
      textContent: Value(textContent),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      editor: editor == null && nullToAbsent
          ? const Value.absent()
          : Value(editor),
    );
  }

  factory Article.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Article(
      id: serializer.fromJson<int>(json['id']),
      pageId: serializer.fromJson<int>(json['pageId']),
      category: serializer.fromJson<String>(json['category']),
      title: serializer.fromJson<String>(json['title']),
      textContent: serializer.fromJson<String>(json['textContent']),
      description: serializer.fromJson<String?>(json['description']),
      editor: serializer.fromJson<List<String>?>(json['editor']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'pageId': serializer.toJson<int>(pageId),
      'category': serializer.toJson<String>(category),
      'title': serializer.toJson<String>(title),
      'textContent': serializer.toJson<String>(textContent),
      'description': serializer.toJson<String?>(description),
      'editor': serializer.toJson<List<String>?>(editor),
    };
  }

  Article copyWith({
    int? id,
    int? pageId,
    String? category,
    String? title,
    String? textContent,
    Value<String?> description = const Value.absent(),
    Value<List<String>?> editor = const Value.absent(),
  }) => Article(
    id: id ?? this.id,
    pageId: pageId ?? this.pageId,
    category: category ?? this.category,
    title: title ?? this.title,
    textContent: textContent ?? this.textContent,
    description: description.present ? description.value : this.description,
    editor: editor.present ? editor.value : this.editor,
  );
  Article copyWithCompanion(ArticlesCompanion data) {
    return Article(
      id: data.id.present ? data.id.value : this.id,
      pageId: data.pageId.present ? data.pageId.value : this.pageId,
      category: data.category.present ? data.category.value : this.category,
      title: data.title.present ? data.title.value : this.title,
      textContent: data.textContent.present
          ? data.textContent.value
          : this.textContent,
      description: data.description.present
          ? data.description.value
          : this.description,
      editor: data.editor.present ? data.editor.value : this.editor,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Article(')
          ..write('id: $id, ')
          ..write('pageId: $pageId, ')
          ..write('category: $category, ')
          ..write('title: $title, ')
          ..write('textContent: $textContent, ')
          ..write('description: $description, ')
          ..write('editor: $editor')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    pageId,
    category,
    title,
    textContent,
    description,
    editor,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Article &&
          other.id == this.id &&
          other.pageId == this.pageId &&
          other.category == this.category &&
          other.title == this.title &&
          other.textContent == this.textContent &&
          other.description == this.description &&
          other.editor == this.editor);
}

class ArticlesCompanion extends UpdateCompanion<Article> {
  final Value<int> id;
  final Value<int> pageId;
  final Value<String> category;
  final Value<String> title;
  final Value<String> textContent;
  final Value<String?> description;
  final Value<List<String>?> editor;
  const ArticlesCompanion({
    this.id = const Value.absent(),
    this.pageId = const Value.absent(),
    this.category = const Value.absent(),
    this.title = const Value.absent(),
    this.textContent = const Value.absent(),
    this.description = const Value.absent(),
    this.editor = const Value.absent(),
  });
  ArticlesCompanion.insert({
    this.id = const Value.absent(),
    required int pageId,
    required String category,
    required String title,
    required String textContent,
    this.description = const Value.absent(),
    this.editor = const Value.absent(),
  }) : pageId = Value(pageId),
       category = Value(category),
       title = Value(title),
       textContent = Value(textContent);
  static Insertable<Article> custom({
    Expression<int>? id,
    Expression<int>? pageId,
    Expression<String>? category,
    Expression<String>? title,
    Expression<String>? textContent,
    Expression<String>? description,
    Expression<String>? editor,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pageId != null) 'page_id': pageId,
      if (category != null) 'category': category,
      if (title != null) 'title': title,
      if (textContent != null) 'text': textContent,
      if (description != null) 'description': description,
      if (editor != null) 'editor': editor,
    });
  }

  ArticlesCompanion copyWith({
    Value<int>? id,
    Value<int>? pageId,
    Value<String>? category,
    Value<String>? title,
    Value<String>? textContent,
    Value<String?>? description,
    Value<List<String>?>? editor,
  }) {
    return ArticlesCompanion(
      id: id ?? this.id,
      pageId: pageId ?? this.pageId,
      category: category ?? this.category,
      title: title ?? this.title,
      textContent: textContent ?? this.textContent,
      description: description ?? this.description,
      editor: editor ?? this.editor,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (pageId.present) {
      map['page_id'] = Variable<int>(pageId.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (textContent.present) {
      map['text'] = Variable<String>(textContent.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (editor.present) {
      map['editor'] = Variable<String>(
        $ArticlesTable.$convertereditorn.toSql(editor.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ArticlesCompanion(')
          ..write('id: $id, ')
          ..write('pageId: $pageId, ')
          ..write('category: $category, ')
          ..write('title: $title, ')
          ..write('textContent: $textContent, ')
          ..write('description: $description, ')
          ..write('editor: $editor')
          ..write(')'))
        .toString();
  }
}

class $HohosTable extends Hohos with TableInfo<$HohosTable, Hoho> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HohosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _pageIdMeta = const VerificationMeta('pageId');
  @override
  late final GeneratedColumn<int> pageId = GeneratedColumn<int>(
    'page_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _textContentMeta = const VerificationMeta(
    'textContent',
  );
  @override
  late final GeneratedColumn<String> textContent = GeneratedColumn<String>(
    'text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descIdMeta = const VerificationMeta('descId');
  @override
  late final GeneratedColumn<String> descId = GeneratedColumn<String>(
    'desc_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descEnMeta = const VerificationMeta('descEn');
  @override
  late final GeneratedColumn<String> descEn = GeneratedColumn<String>(
    'desc_en',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>?, String> editor =
      GeneratedColumn<String>(
        'editor',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<List<String>?>($HohosTable.$convertereditorn);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    pageId,
    title,
    textContent,
    description,
    descId,
    descEn,
    editor,
    source,
    url,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hoho';
  @override
  VerificationContext validateIntegrity(
    Insertable<Hoho> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('page_id')) {
      context.handle(
        _pageIdMeta,
        pageId.isAcceptableOrUnknown(data['page_id']!, _pageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_pageIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('text')) {
      context.handle(
        _textContentMeta,
        textContent.isAcceptableOrUnknown(data['text']!, _textContentMeta),
      );
    } else if (isInserting) {
      context.missing(_textContentMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('desc_id')) {
      context.handle(
        _descIdMeta,
        descId.isAcceptableOrUnknown(data['desc_id']!, _descIdMeta),
      );
    }
    if (data.containsKey('desc_en')) {
      context.handle(
        _descEnMeta,
        descEn.isAcceptableOrUnknown(data['desc_en']!, _descEnMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Hoho map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Hoho(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      pageId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      textContent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      descId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}desc_id'],
      ),
      descEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}desc_en'],
      ),
      editor: $HohosTable.$convertereditorn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}editor'],
        ),
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      ),
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      ),
    );
  }

  @override
  $HohosTable createAlias(String alias) {
    return $HohosTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $convertereditor =
      const StringListConverter();
  static TypeConverter<List<String>?, String?> $convertereditorn =
      NullAwareTypeConverter.wrap($convertereditor);
}

class Hoho extends DataClass implements Insertable<Hoho> {
  final int id;
  final int pageId;
  final String title;
  final String textContent;
  final String? description;
  final String? descId;
  final String? descEn;
  final List<String>? editor;
  final String? source;
  final String? url;
  const Hoho({
    required this.id,
    required this.pageId,
    required this.title,
    required this.textContent,
    this.description,
    this.descId,
    this.descEn,
    this.editor,
    this.source,
    this.url,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['page_id'] = Variable<int>(pageId);
    map['title'] = Variable<String>(title);
    map['text'] = Variable<String>(textContent);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || descId != null) {
      map['desc_id'] = Variable<String>(descId);
    }
    if (!nullToAbsent || descEn != null) {
      map['desc_en'] = Variable<String>(descEn);
    }
    if (!nullToAbsent || editor != null) {
      map['editor'] = Variable<String>(
        $HohosTable.$convertereditorn.toSql(editor),
      );
    }
    if (!nullToAbsent || source != null) {
      map['source'] = Variable<String>(source);
    }
    if (!nullToAbsent || url != null) {
      map['url'] = Variable<String>(url);
    }
    return map;
  }

  HohosCompanion toCompanion(bool nullToAbsent) {
    return HohosCompanion(
      id: Value(id),
      pageId: Value(pageId),
      title: Value(title),
      textContent: Value(textContent),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      descId: descId == null && nullToAbsent
          ? const Value.absent()
          : Value(descId),
      descEn: descEn == null && nullToAbsent
          ? const Value.absent()
          : Value(descEn),
      editor: editor == null && nullToAbsent
          ? const Value.absent()
          : Value(editor),
      source: source == null && nullToAbsent
          ? const Value.absent()
          : Value(source),
      url: url == null && nullToAbsent ? const Value.absent() : Value(url),
    );
  }

  factory Hoho.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Hoho(
      id: serializer.fromJson<int>(json['id']),
      pageId: serializer.fromJson<int>(json['pageId']),
      title: serializer.fromJson<String>(json['title']),
      textContent: serializer.fromJson<String>(json['textContent']),
      description: serializer.fromJson<String?>(json['description']),
      descId: serializer.fromJson<String?>(json['descId']),
      descEn: serializer.fromJson<String?>(json['descEn']),
      editor: serializer.fromJson<List<String>?>(json['editor']),
      source: serializer.fromJson<String?>(json['source']),
      url: serializer.fromJson<String?>(json['url']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'pageId': serializer.toJson<int>(pageId),
      'title': serializer.toJson<String>(title),
      'textContent': serializer.toJson<String>(textContent),
      'description': serializer.toJson<String?>(description),
      'descId': serializer.toJson<String?>(descId),
      'descEn': serializer.toJson<String?>(descEn),
      'editor': serializer.toJson<List<String>?>(editor),
      'source': serializer.toJson<String?>(source),
      'url': serializer.toJson<String?>(url),
    };
  }

  Hoho copyWith({
    int? id,
    int? pageId,
    String? title,
    String? textContent,
    Value<String?> description = const Value.absent(),
    Value<String?> descId = const Value.absent(),
    Value<String?> descEn = const Value.absent(),
    Value<List<String>?> editor = const Value.absent(),
    Value<String?> source = const Value.absent(),
    Value<String?> url = const Value.absent(),
  }) => Hoho(
    id: id ?? this.id,
    pageId: pageId ?? this.pageId,
    title: title ?? this.title,
    textContent: textContent ?? this.textContent,
    description: description.present ? description.value : this.description,
    descId: descId.present ? descId.value : this.descId,
    descEn: descEn.present ? descEn.value : this.descEn,
    editor: editor.present ? editor.value : this.editor,
    source: source.present ? source.value : this.source,
    url: url.present ? url.value : this.url,
  );
  Hoho copyWithCompanion(HohosCompanion data) {
    return Hoho(
      id: data.id.present ? data.id.value : this.id,
      pageId: data.pageId.present ? data.pageId.value : this.pageId,
      title: data.title.present ? data.title.value : this.title,
      textContent: data.textContent.present
          ? data.textContent.value
          : this.textContent,
      description: data.description.present
          ? data.description.value
          : this.description,
      descId: data.descId.present ? data.descId.value : this.descId,
      descEn: data.descEn.present ? data.descEn.value : this.descEn,
      editor: data.editor.present ? data.editor.value : this.editor,
      source: data.source.present ? data.source.value : this.source,
      url: data.url.present ? data.url.value : this.url,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Hoho(')
          ..write('id: $id, ')
          ..write('pageId: $pageId, ')
          ..write('title: $title, ')
          ..write('textContent: $textContent, ')
          ..write('description: $description, ')
          ..write('descId: $descId, ')
          ..write('descEn: $descEn, ')
          ..write('editor: $editor, ')
          ..write('source: $source, ')
          ..write('url: $url')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    pageId,
    title,
    textContent,
    description,
    descId,
    descEn,
    editor,
    source,
    url,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Hoho &&
          other.id == this.id &&
          other.pageId == this.pageId &&
          other.title == this.title &&
          other.textContent == this.textContent &&
          other.description == this.description &&
          other.descId == this.descId &&
          other.descEn == this.descEn &&
          other.editor == this.editor &&
          other.source == this.source &&
          other.url == this.url);
}

class HohosCompanion extends UpdateCompanion<Hoho> {
  final Value<int> id;
  final Value<int> pageId;
  final Value<String> title;
  final Value<String> textContent;
  final Value<String?> description;
  final Value<String?> descId;
  final Value<String?> descEn;
  final Value<List<String>?> editor;
  final Value<String?> source;
  final Value<String?> url;
  const HohosCompanion({
    this.id = const Value.absent(),
    this.pageId = const Value.absent(),
    this.title = const Value.absent(),
    this.textContent = const Value.absent(),
    this.description = const Value.absent(),
    this.descId = const Value.absent(),
    this.descEn = const Value.absent(),
    this.editor = const Value.absent(),
    this.source = const Value.absent(),
    this.url = const Value.absent(),
  });
  HohosCompanion.insert({
    this.id = const Value.absent(),
    required int pageId,
    required String title,
    required String textContent,
    this.description = const Value.absent(),
    this.descId = const Value.absent(),
    this.descEn = const Value.absent(),
    this.editor = const Value.absent(),
    this.source = const Value.absent(),
    this.url = const Value.absent(),
  }) : pageId = Value(pageId),
       title = Value(title),
       textContent = Value(textContent);
  static Insertable<Hoho> custom({
    Expression<int>? id,
    Expression<int>? pageId,
    Expression<String>? title,
    Expression<String>? textContent,
    Expression<String>? description,
    Expression<String>? descId,
    Expression<String>? descEn,
    Expression<String>? editor,
    Expression<String>? source,
    Expression<String>? url,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pageId != null) 'page_id': pageId,
      if (title != null) 'title': title,
      if (textContent != null) 'text': textContent,
      if (description != null) 'description': description,
      if (descId != null) 'desc_id': descId,
      if (descEn != null) 'desc_en': descEn,
      if (editor != null) 'editor': editor,
      if (source != null) 'source': source,
      if (url != null) 'url': url,
    });
  }

  HohosCompanion copyWith({
    Value<int>? id,
    Value<int>? pageId,
    Value<String>? title,
    Value<String>? textContent,
    Value<String?>? description,
    Value<String?>? descId,
    Value<String?>? descEn,
    Value<List<String>?>? editor,
    Value<String?>? source,
    Value<String?>? url,
  }) {
    return HohosCompanion(
      id: id ?? this.id,
      pageId: pageId ?? this.pageId,
      title: title ?? this.title,
      textContent: textContent ?? this.textContent,
      description: description ?? this.description,
      descId: descId ?? this.descId,
      descEn: descEn ?? this.descEn,
      editor: editor ?? this.editor,
      source: source ?? this.source,
      url: url ?? this.url,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (pageId.present) {
      map['page_id'] = Variable<int>(pageId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (textContent.present) {
      map['text'] = Variable<String>(textContent.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (descId.present) {
      map['desc_id'] = Variable<String>(descId.value);
    }
    if (descEn.present) {
      map['desc_en'] = Variable<String>(descEn.value);
    }
    if (editor.present) {
      map['editor'] = Variable<String>(
        $HohosTable.$convertereditorn.toSql(editor.value),
      );
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HohosCompanion(')
          ..write('id: $id, ')
          ..write('pageId: $pageId, ')
          ..write('title: $title, ')
          ..write('textContent: $textContent, ')
          ..write('description: $description, ')
          ..write('descId: $descId, ')
          ..write('descEn: $descEn, ')
          ..write('editor: $editor, ')
          ..write('source: $source, ')
          ..write('url: $url')
          ..write(')'))
        .toString();
  }
}

class $HeritageArticlesTable extends HeritageArticles
    with TableInfo<$HeritageArticlesTable, HeritageArticle> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HeritageArticlesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _pageIdMeta = const VerificationMeta('pageId');
  @override
  late final GeneratedColumn<int> pageId = GeneratedColumn<int>(
    'page_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wikiHostMeta = const VerificationMeta(
    'wikiHost',
  );
  @override
  late final GeneratedColumn<String> wikiHost = GeneratedColumn<String>(
    'wiki_host',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('nia.wikipedia.org'),
  );
  static const VerificationMeta _pageTitleMeta = const VerificationMeta(
    'pageTitle',
  );
  @override
  late final GeneratedColumn<String> pageTitle = GeneratedColumn<String>(
    'page_title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _textContentMeta = const VerificationMeta(
    'textContent',
  );
  @override
  late final GeneratedColumn<String> textContent = GeneratedColumn<String>(
    'text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _htmlContentMeta = const VerificationMeta(
    'htmlContent',
  );
  @override
  late final GeneratedColumn<String> htmlContent = GeneratedColumn<String>(
    'html',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _footnotesMeta = const VerificationMeta(
    'footnotes',
  );
  @override
  late final GeneratedColumn<String> footnotes = GeneratedColumn<String>(
    'footnotes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastRevidMeta = const VerificationMeta(
    'lastRevid',
  );
  @override
  late final GeneratedColumn<int> lastRevid = GeneratedColumn<int>(
    'last_revid',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastUpdatedMeta = const VerificationMeta(
    'lastUpdated',
  );
  @override
  late final GeneratedColumn<DateTime> lastUpdated = GeneratedColumn<DateTime>(
    'last_updated',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    pageId,
    category,
    wikiHost,
    pageTitle,
    title,
    textContent,
    htmlContent,
    footnotes,
    imageUrl,
    lastRevid,
    lastUpdated,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'heritage_articles';
  @override
  VerificationContext validateIntegrity(
    Insertable<HeritageArticle> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('page_id')) {
      context.handle(
        _pageIdMeta,
        pageId.isAcceptableOrUnknown(data['page_id']!, _pageIdMeta),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('wiki_host')) {
      context.handle(
        _wikiHostMeta,
        wikiHost.isAcceptableOrUnknown(data['wiki_host']!, _wikiHostMeta),
      );
    }
    if (data.containsKey('page_title')) {
      context.handle(
        _pageTitleMeta,
        pageTitle.isAcceptableOrUnknown(data['page_title']!, _pageTitleMeta),
      );
    } else if (isInserting) {
      context.missing(_pageTitleMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('text')) {
      context.handle(
        _textContentMeta,
        textContent.isAcceptableOrUnknown(data['text']!, _textContentMeta),
      );
    } else if (isInserting) {
      context.missing(_textContentMeta);
    }
    if (data.containsKey('html')) {
      context.handle(
        _htmlContentMeta,
        htmlContent.isAcceptableOrUnknown(data['html']!, _htmlContentMeta),
      );
    }
    if (data.containsKey('footnotes')) {
      context.handle(
        _footnotesMeta,
        footnotes.isAcceptableOrUnknown(data['footnotes']!, _footnotesMeta),
      );
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    if (data.containsKey('last_revid')) {
      context.handle(
        _lastRevidMeta,
        lastRevid.isAcceptableOrUnknown(data['last_revid']!, _lastRevidMeta),
      );
    }
    if (data.containsKey('last_updated')) {
      context.handle(
        _lastUpdatedMeta,
        lastUpdated.isAcceptableOrUnknown(
          data['last_updated']!,
          _lastUpdatedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {pageId};
  @override
  HeritageArticle map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HeritageArticle(
      pageId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_id'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      wikiHost: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}wiki_host'],
      )!,
      pageTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}page_title'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      textContent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text'],
      )!,
      htmlContent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}html'],
      ),
      footnotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}footnotes'],
      ),
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      ),
      lastRevid: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_revid'],
      )!,
      lastUpdated: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_updated'],
      ),
    );
  }

  @override
  $HeritageArticlesTable createAlias(String alias) {
    return $HeritageArticlesTable(attachedDatabase, alias);
  }
}

class HeritageArticle extends DataClass implements Insertable<HeritageArticle> {
  final int pageId;
  final String category;
  final String wikiHost;
  final String pageTitle;
  final String title;
  final String textContent;
  final String? htmlContent;
  final String? footnotes;
  final String? imageUrl;
  final int lastRevid;
  final DateTime? lastUpdated;
  const HeritageArticle({
    required this.pageId,
    required this.category,
    required this.wikiHost,
    required this.pageTitle,
    required this.title,
    required this.textContent,
    this.htmlContent,
    this.footnotes,
    this.imageUrl,
    required this.lastRevid,
    this.lastUpdated,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['page_id'] = Variable<int>(pageId);
    map['category'] = Variable<String>(category);
    map['wiki_host'] = Variable<String>(wikiHost);
    map['page_title'] = Variable<String>(pageTitle);
    map['title'] = Variable<String>(title);
    map['text'] = Variable<String>(textContent);
    if (!nullToAbsent || htmlContent != null) {
      map['html'] = Variable<String>(htmlContent);
    }
    if (!nullToAbsent || footnotes != null) {
      map['footnotes'] = Variable<String>(footnotes);
    }
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    map['last_revid'] = Variable<int>(lastRevid);
    if (!nullToAbsent || lastUpdated != null) {
      map['last_updated'] = Variable<DateTime>(lastUpdated);
    }
    return map;
  }

  HeritageArticlesCompanion toCompanion(bool nullToAbsent) {
    return HeritageArticlesCompanion(
      pageId: Value(pageId),
      category: Value(category),
      wikiHost: Value(wikiHost),
      pageTitle: Value(pageTitle),
      title: Value(title),
      textContent: Value(textContent),
      htmlContent: htmlContent == null && nullToAbsent
          ? const Value.absent()
          : Value(htmlContent),
      footnotes: footnotes == null && nullToAbsent
          ? const Value.absent()
          : Value(footnotes),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      lastRevid: Value(lastRevid),
      lastUpdated: lastUpdated == null && nullToAbsent
          ? const Value.absent()
          : Value(lastUpdated),
    );
  }

  factory HeritageArticle.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HeritageArticle(
      pageId: serializer.fromJson<int>(json['pageId']),
      category: serializer.fromJson<String>(json['category']),
      wikiHost: serializer.fromJson<String>(json['wikiHost']),
      pageTitle: serializer.fromJson<String>(json['pageTitle']),
      title: serializer.fromJson<String>(json['title']),
      textContent: serializer.fromJson<String>(json['textContent']),
      htmlContent: serializer.fromJson<String?>(json['htmlContent']),
      footnotes: serializer.fromJson<String?>(json['footnotes']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      lastRevid: serializer.fromJson<int>(json['lastRevid']),
      lastUpdated: serializer.fromJson<DateTime?>(json['lastUpdated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'pageId': serializer.toJson<int>(pageId),
      'category': serializer.toJson<String>(category),
      'wikiHost': serializer.toJson<String>(wikiHost),
      'pageTitle': serializer.toJson<String>(pageTitle),
      'title': serializer.toJson<String>(title),
      'textContent': serializer.toJson<String>(textContent),
      'htmlContent': serializer.toJson<String?>(htmlContent),
      'footnotes': serializer.toJson<String?>(footnotes),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'lastRevid': serializer.toJson<int>(lastRevid),
      'lastUpdated': serializer.toJson<DateTime?>(lastUpdated),
    };
  }

  HeritageArticle copyWith({
    int? pageId,
    String? category,
    String? wikiHost,
    String? pageTitle,
    String? title,
    String? textContent,
    Value<String?> htmlContent = const Value.absent(),
    Value<String?> footnotes = const Value.absent(),
    Value<String?> imageUrl = const Value.absent(),
    int? lastRevid,
    Value<DateTime?> lastUpdated = const Value.absent(),
  }) => HeritageArticle(
    pageId: pageId ?? this.pageId,
    category: category ?? this.category,
    wikiHost: wikiHost ?? this.wikiHost,
    pageTitle: pageTitle ?? this.pageTitle,
    title: title ?? this.title,
    textContent: textContent ?? this.textContent,
    htmlContent: htmlContent.present ? htmlContent.value : this.htmlContent,
    footnotes: footnotes.present ? footnotes.value : this.footnotes,
    imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
    lastRevid: lastRevid ?? this.lastRevid,
    lastUpdated: lastUpdated.present ? lastUpdated.value : this.lastUpdated,
  );
  HeritageArticle copyWithCompanion(HeritageArticlesCompanion data) {
    return HeritageArticle(
      pageId: data.pageId.present ? data.pageId.value : this.pageId,
      category: data.category.present ? data.category.value : this.category,
      wikiHost: data.wikiHost.present ? data.wikiHost.value : this.wikiHost,
      pageTitle: data.pageTitle.present ? data.pageTitle.value : this.pageTitle,
      title: data.title.present ? data.title.value : this.title,
      textContent: data.textContent.present
          ? data.textContent.value
          : this.textContent,
      htmlContent: data.htmlContent.present
          ? data.htmlContent.value
          : this.htmlContent,
      footnotes: data.footnotes.present ? data.footnotes.value : this.footnotes,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      lastRevid: data.lastRevid.present ? data.lastRevid.value : this.lastRevid,
      lastUpdated: data.lastUpdated.present
          ? data.lastUpdated.value
          : this.lastUpdated,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HeritageArticle(')
          ..write('pageId: $pageId, ')
          ..write('category: $category, ')
          ..write('wikiHost: $wikiHost, ')
          ..write('pageTitle: $pageTitle, ')
          ..write('title: $title, ')
          ..write('textContent: $textContent, ')
          ..write('htmlContent: $htmlContent, ')
          ..write('footnotes: $footnotes, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('lastRevid: $lastRevid, ')
          ..write('lastUpdated: $lastUpdated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    pageId,
    category,
    wikiHost,
    pageTitle,
    title,
    textContent,
    htmlContent,
    footnotes,
    imageUrl,
    lastRevid,
    lastUpdated,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HeritageArticle &&
          other.pageId == this.pageId &&
          other.category == this.category &&
          other.wikiHost == this.wikiHost &&
          other.pageTitle == this.pageTitle &&
          other.title == this.title &&
          other.textContent == this.textContent &&
          other.htmlContent == this.htmlContent &&
          other.footnotes == this.footnotes &&
          other.imageUrl == this.imageUrl &&
          other.lastRevid == this.lastRevid &&
          other.lastUpdated == this.lastUpdated);
}

class HeritageArticlesCompanion extends UpdateCompanion<HeritageArticle> {
  final Value<int> pageId;
  final Value<String> category;
  final Value<String> wikiHost;
  final Value<String> pageTitle;
  final Value<String> title;
  final Value<String> textContent;
  final Value<String?> htmlContent;
  final Value<String?> footnotes;
  final Value<String?> imageUrl;
  final Value<int> lastRevid;
  final Value<DateTime?> lastUpdated;
  const HeritageArticlesCompanion({
    this.pageId = const Value.absent(),
    this.category = const Value.absent(),
    this.wikiHost = const Value.absent(),
    this.pageTitle = const Value.absent(),
    this.title = const Value.absent(),
    this.textContent = const Value.absent(),
    this.htmlContent = const Value.absent(),
    this.footnotes = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.lastRevid = const Value.absent(),
    this.lastUpdated = const Value.absent(),
  });
  HeritageArticlesCompanion.insert({
    this.pageId = const Value.absent(),
    required String category,
    this.wikiHost = const Value.absent(),
    required String pageTitle,
    required String title,
    required String textContent,
    this.htmlContent = const Value.absent(),
    this.footnotes = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.lastRevid = const Value.absent(),
    this.lastUpdated = const Value.absent(),
  }) : category = Value(category),
       pageTitle = Value(pageTitle),
       title = Value(title),
       textContent = Value(textContent);
  static Insertable<HeritageArticle> custom({
    Expression<int>? pageId,
    Expression<String>? category,
    Expression<String>? wikiHost,
    Expression<String>? pageTitle,
    Expression<String>? title,
    Expression<String>? textContent,
    Expression<String>? htmlContent,
    Expression<String>? footnotes,
    Expression<String>? imageUrl,
    Expression<int>? lastRevid,
    Expression<DateTime>? lastUpdated,
  }) {
    return RawValuesInsertable({
      if (pageId != null) 'page_id': pageId,
      if (category != null) 'category': category,
      if (wikiHost != null) 'wiki_host': wikiHost,
      if (pageTitle != null) 'page_title': pageTitle,
      if (title != null) 'title': title,
      if (textContent != null) 'text': textContent,
      if (htmlContent != null) 'html': htmlContent,
      if (footnotes != null) 'footnotes': footnotes,
      if (imageUrl != null) 'image_url': imageUrl,
      if (lastRevid != null) 'last_revid': lastRevid,
      if (lastUpdated != null) 'last_updated': lastUpdated,
    });
  }

  HeritageArticlesCompanion copyWith({
    Value<int>? pageId,
    Value<String>? category,
    Value<String>? wikiHost,
    Value<String>? pageTitle,
    Value<String>? title,
    Value<String>? textContent,
    Value<String?>? htmlContent,
    Value<String?>? footnotes,
    Value<String?>? imageUrl,
    Value<int>? lastRevid,
    Value<DateTime?>? lastUpdated,
  }) {
    return HeritageArticlesCompanion(
      pageId: pageId ?? this.pageId,
      category: category ?? this.category,
      wikiHost: wikiHost ?? this.wikiHost,
      pageTitle: pageTitle ?? this.pageTitle,
      title: title ?? this.title,
      textContent: textContent ?? this.textContent,
      htmlContent: htmlContent ?? this.htmlContent,
      footnotes: footnotes ?? this.footnotes,
      imageUrl: imageUrl ?? this.imageUrl,
      lastRevid: lastRevid ?? this.lastRevid,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (pageId.present) {
      map['page_id'] = Variable<int>(pageId.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (wikiHost.present) {
      map['wiki_host'] = Variable<String>(wikiHost.value);
    }
    if (pageTitle.present) {
      map['page_title'] = Variable<String>(pageTitle.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (textContent.present) {
      map['text'] = Variable<String>(textContent.value);
    }
    if (htmlContent.present) {
      map['html'] = Variable<String>(htmlContent.value);
    }
    if (footnotes.present) {
      map['footnotes'] = Variable<String>(footnotes.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (lastRevid.present) {
      map['last_revid'] = Variable<int>(lastRevid.value);
    }
    if (lastUpdated.present) {
      map['last_updated'] = Variable<DateTime>(lastUpdated.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HeritageArticlesCompanion(')
          ..write('pageId: $pageId, ')
          ..write('category: $category, ')
          ..write('wikiHost: $wikiHost, ')
          ..write('pageTitle: $pageTitle, ')
          ..write('title: $title, ')
          ..write('textContent: $textContent, ')
          ..write('htmlContent: $htmlContent, ')
          ..write('footnotes: $footnotes, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('lastRevid: $lastRevid, ')
          ..write('lastUpdated: $lastUpdated')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $HeritageItemsTable heritageItems = $HeritageItemsTable(this);
  late final $TimelineEventsTable timelineEvents = $TimelineEventsTable(this);
  late final $AmaedolasTable amaedolas = $AmaedolasTable(this);
  late final $BiblesTable bibles = $BiblesTable(this);
  late final $WikiPageRevisionsTable wikiPageRevisions =
      $WikiPageRevisionsTable(this);
  late final $SongsTable songs = $SongsTable(this);
  late final $ManoManosTable manoManos = $ManoManosTable(this);
  late final $ArticlesTable articles = $ArticlesTable(this);
  late final $HohosTable hohos = $HohosTable(this);
  late final $HeritageArticlesTable heritageArticles = $HeritageArticlesTable(
    this,
  );
  late final Index biblePageVerseIdx = Index(
    'bible_page_verse_idx',
    'CREATE UNIQUE INDEX bible_page_verse_idx ON bible (page_id, verse)',
  );
  late final Index songsPageIdIdx = Index(
    'songs_page_id_idx',
    'CREATE UNIQUE INDEX songs_page_id_idx ON songs (page_id)',
  );
  late final Index manoManoPageIdIdx = Index(
    'mano_mano_page_id_idx',
    'CREATE UNIQUE INDEX mano_mano_page_id_idx ON mano_mano (page_id)',
  );
  late final Index articlesPageIdIdx = Index(
    'articles_page_id_idx',
    'CREATE UNIQUE INDEX articles_page_id_idx ON articles (page_id)',
  );
  late final Index hohosPageIdIdx = Index(
    'hohos_page_id_idx',
    'CREATE UNIQUE INDEX hohos_page_id_idx ON hoho (page_id)',
  );
  late final Index heritageArticlesPageIdIdx = Index(
    'heritage_articles_page_id_idx',
    'CREATE UNIQUE INDEX heritage_articles_page_id_idx ON heritage_articles (page_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    heritageItems,
    timelineEvents,
    amaedolas,
    bibles,
    wikiPageRevisions,
    songs,
    manoManos,
    articles,
    hohos,
    heritageArticles,
    biblePageVerseIdx,
    songsPageIdIdx,
    manoManoPageIdIdx,
    articlesPageIdIdx,
    hohosPageIdIdx,
    heritageArticlesPageIdIdx,
  ];
}

typedef $$HeritageItemsTableCreateCompanionBuilder =
    HeritageItemsCompanion Function({
      required String id,
      required String titleEn,
      required String titleId,
      required String titleNia,
      required String descriptionEn,
      required String descriptionId,
      required String descriptionNia,
      required String category,
      required String imageUrl,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$HeritageItemsTableUpdateCompanionBuilder =
    HeritageItemsCompanion Function({
      Value<String> id,
      Value<String> titleEn,
      Value<String> titleId,
      Value<String> titleNia,
      Value<String> descriptionEn,
      Value<String> descriptionId,
      Value<String> descriptionNia,
      Value<String> category,
      Value<String> imageUrl,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$HeritageItemsTableFilterComposer
    extends Composer<_$AppDatabase, $HeritageItemsTable> {
  $$HeritageItemsTableFilterComposer({
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

  ColumnFilters<String> get titleEn => $composableBuilder(
    column: $table.titleEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get titleId => $composableBuilder(
    column: $table.titleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get titleNia => $composableBuilder(
    column: $table.titleNia,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descriptionEn => $composableBuilder(
    column: $table.descriptionEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descriptionId => $composableBuilder(
    column: $table.descriptionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descriptionNia => $composableBuilder(
    column: $table.descriptionNia,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HeritageItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $HeritageItemsTable> {
  $$HeritageItemsTableOrderingComposer({
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

  ColumnOrderings<String> get titleEn => $composableBuilder(
    column: $table.titleEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get titleId => $composableBuilder(
    column: $table.titleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get titleNia => $composableBuilder(
    column: $table.titleNia,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descriptionEn => $composableBuilder(
    column: $table.descriptionEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descriptionId => $composableBuilder(
    column: $table.descriptionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descriptionNia => $composableBuilder(
    column: $table.descriptionNia,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HeritageItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HeritageItemsTable> {
  $$HeritageItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get titleEn =>
      $composableBuilder(column: $table.titleEn, builder: (column) => column);

  GeneratedColumn<String> get titleId =>
      $composableBuilder(column: $table.titleId, builder: (column) => column);

  GeneratedColumn<String> get titleNia =>
      $composableBuilder(column: $table.titleNia, builder: (column) => column);

  GeneratedColumn<String> get descriptionEn => $composableBuilder(
    column: $table.descriptionEn,
    builder: (column) => column,
  );

  GeneratedColumn<String> get descriptionId => $composableBuilder(
    column: $table.descriptionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get descriptionNia => $composableBuilder(
    column: $table.descriptionNia,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$HeritageItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HeritageItemsTable,
          HeritageItem,
          $$HeritageItemsTableFilterComposer,
          $$HeritageItemsTableOrderingComposer,
          $$HeritageItemsTableAnnotationComposer,
          $$HeritageItemsTableCreateCompanionBuilder,
          $$HeritageItemsTableUpdateCompanionBuilder,
          (
            HeritageItem,
            BaseReferences<_$AppDatabase, $HeritageItemsTable, HeritageItem>,
          ),
          HeritageItem,
          PrefetchHooks Function()
        > {
  $$HeritageItemsTableTableManager(_$AppDatabase db, $HeritageItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HeritageItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HeritageItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HeritageItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> titleEn = const Value.absent(),
                Value<String> titleId = const Value.absent(),
                Value<String> titleNia = const Value.absent(),
                Value<String> descriptionEn = const Value.absent(),
                Value<String> descriptionId = const Value.absent(),
                Value<String> descriptionNia = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> imageUrl = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HeritageItemsCompanion(
                id: id,
                titleEn: titleEn,
                titleId: titleId,
                titleNia: titleNia,
                descriptionEn: descriptionEn,
                descriptionId: descriptionId,
                descriptionNia: descriptionNia,
                category: category,
                imageUrl: imageUrl,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String titleEn,
                required String titleId,
                required String titleNia,
                required String descriptionEn,
                required String descriptionId,
                required String descriptionNia,
                required String category,
                required String imageUrl,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => HeritageItemsCompanion.insert(
                id: id,
                titleEn: titleEn,
                titleId: titleId,
                titleNia: titleNia,
                descriptionEn: descriptionEn,
                descriptionId: descriptionId,
                descriptionNia: descriptionNia,
                category: category,
                imageUrl: imageUrl,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HeritageItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HeritageItemsTable,
      HeritageItem,
      $$HeritageItemsTableFilterComposer,
      $$HeritageItemsTableOrderingComposer,
      $$HeritageItemsTableAnnotationComposer,
      $$HeritageItemsTableCreateCompanionBuilder,
      $$HeritageItemsTableUpdateCompanionBuilder,
      (
        HeritageItem,
        BaseReferences<_$AppDatabase, $HeritageItemsTable, HeritageItem>,
      ),
      HeritageItem,
      PrefetchHooks Function()
    >;
typedef $$TimelineEventsTableCreateCompanionBuilder =
    TimelineEventsCompanion Function({
      required String id,
      required String year,
      required String titleEn,
      required String titleId,
      required String titleNia,
      required String descriptionEn,
      required String descriptionId,
      required String descriptionNia,
      Value<String?> imageUrl,
      Value<int> rowid,
    });
typedef $$TimelineEventsTableUpdateCompanionBuilder =
    TimelineEventsCompanion Function({
      Value<String> id,
      Value<String> year,
      Value<String> titleEn,
      Value<String> titleId,
      Value<String> titleNia,
      Value<String> descriptionEn,
      Value<String> descriptionId,
      Value<String> descriptionNia,
      Value<String?> imageUrl,
      Value<int> rowid,
    });

class $$TimelineEventsTableFilterComposer
    extends Composer<_$AppDatabase, $TimelineEventsTable> {
  $$TimelineEventsTableFilterComposer({
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

  ColumnFilters<String> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get titleEn => $composableBuilder(
    column: $table.titleEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get titleId => $composableBuilder(
    column: $table.titleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get titleNia => $composableBuilder(
    column: $table.titleNia,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descriptionEn => $composableBuilder(
    column: $table.descriptionEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descriptionId => $composableBuilder(
    column: $table.descriptionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descriptionNia => $composableBuilder(
    column: $table.descriptionNia,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TimelineEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $TimelineEventsTable> {
  $$TimelineEventsTableOrderingComposer({
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

  ColumnOrderings<String> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get titleEn => $composableBuilder(
    column: $table.titleEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get titleId => $composableBuilder(
    column: $table.titleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get titleNia => $composableBuilder(
    column: $table.titleNia,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descriptionEn => $composableBuilder(
    column: $table.descriptionEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descriptionId => $composableBuilder(
    column: $table.descriptionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descriptionNia => $composableBuilder(
    column: $table.descriptionNia,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TimelineEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TimelineEventsTable> {
  $$TimelineEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<String> get titleEn =>
      $composableBuilder(column: $table.titleEn, builder: (column) => column);

  GeneratedColumn<String> get titleId =>
      $composableBuilder(column: $table.titleId, builder: (column) => column);

  GeneratedColumn<String> get titleNia =>
      $composableBuilder(column: $table.titleNia, builder: (column) => column);

  GeneratedColumn<String> get descriptionEn => $composableBuilder(
    column: $table.descriptionEn,
    builder: (column) => column,
  );

  GeneratedColumn<String> get descriptionId => $composableBuilder(
    column: $table.descriptionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get descriptionNia => $composableBuilder(
    column: $table.descriptionNia,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);
}

class $$TimelineEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TimelineEventsTable,
          TimelineEvent,
          $$TimelineEventsTableFilterComposer,
          $$TimelineEventsTableOrderingComposer,
          $$TimelineEventsTableAnnotationComposer,
          $$TimelineEventsTableCreateCompanionBuilder,
          $$TimelineEventsTableUpdateCompanionBuilder,
          (
            TimelineEvent,
            BaseReferences<_$AppDatabase, $TimelineEventsTable, TimelineEvent>,
          ),
          TimelineEvent,
          PrefetchHooks Function()
        > {
  $$TimelineEventsTableTableManager(
    _$AppDatabase db,
    $TimelineEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TimelineEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TimelineEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TimelineEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> year = const Value.absent(),
                Value<String> titleEn = const Value.absent(),
                Value<String> titleId = const Value.absent(),
                Value<String> titleNia = const Value.absent(),
                Value<String> descriptionEn = const Value.absent(),
                Value<String> descriptionId = const Value.absent(),
                Value<String> descriptionNia = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TimelineEventsCompanion(
                id: id,
                year: year,
                titleEn: titleEn,
                titleId: titleId,
                titleNia: titleNia,
                descriptionEn: descriptionEn,
                descriptionId: descriptionId,
                descriptionNia: descriptionNia,
                imageUrl: imageUrl,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String year,
                required String titleEn,
                required String titleId,
                required String titleNia,
                required String descriptionEn,
                required String descriptionId,
                required String descriptionNia,
                Value<String?> imageUrl = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TimelineEventsCompanion.insert(
                id: id,
                year: year,
                titleEn: titleEn,
                titleId: titleId,
                titleNia: titleNia,
                descriptionEn: descriptionEn,
                descriptionId: descriptionId,
                descriptionNia: descriptionNia,
                imageUrl: imageUrl,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TimelineEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TimelineEventsTable,
      TimelineEvent,
      $$TimelineEventsTableFilterComposer,
      $$TimelineEventsTableOrderingComposer,
      $$TimelineEventsTableAnnotationComposer,
      $$TimelineEventsTableCreateCompanionBuilder,
      $$TimelineEventsTableUpdateCompanionBuilder,
      (
        TimelineEvent,
        BaseReferences<_$AppDatabase, $TimelineEventsTable, TimelineEvent>,
      ),
      TimelineEvent,
      PrefetchHooks Function()
    >;
typedef $$AmaedolasTableCreateCompanionBuilder = AmaedolasCompanion Function({
  Value<int> id,
  required int pageId,
  required String textContent,
  required String meaning,
  Value<String?> meaningId,
  Value<String?> meaningEn,
  required String label,
  Value<String?> url,
  Value<String?> note,
});
typedef $$AmaedolasTableUpdateCompanionBuilder = AmaedolasCompanion Function({
  Value<int> id,
  Value<int> pageId,
  Value<String> textContent,
  Value<String> meaning,
  Value<String?> meaningId,
  Value<String?> meaningEn,
  Value<String> label,
  Value<String?> url,
  Value<String?> note,
});

class $$AmaedolasTableFilterComposer
    extends Composer<_$AppDatabase, $AmaedolasTable> {
  $$AmaedolasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pageId => $composableBuilder(
    column: $table.pageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meaning => $composableBuilder(
    column: $table.meaning,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meaningId => $composableBuilder(
    column: $table.meaningId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meaningEn => $composableBuilder(
    column: $table.meaningEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AmaedolasTableOrderingComposer
    extends Composer<_$AppDatabase, $AmaedolasTable> {
  $$AmaedolasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pageId => $composableBuilder(
    column: $table.pageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meaning => $composableBuilder(
    column: $table.meaning,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meaningId => $composableBuilder(
    column: $table.meaningId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meaningEn => $composableBuilder(
    column: $table.meaningEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AmaedolasTableAnnotationComposer
    extends Composer<_$AppDatabase, $AmaedolasTable> {
  $$AmaedolasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get pageId =>
      $composableBuilder(column: $table.pageId, builder: (column) => column);

  GeneratedColumn<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => column,
  );

  GeneratedColumn<String> get meaning =>
      $composableBuilder(column: $table.meaning, builder: (column) => column);

  GeneratedColumn<String> get meaningId =>
      $composableBuilder(column: $table.meaningId, builder: (column) => column);

  GeneratedColumn<String> get meaningEn =>
      $composableBuilder(column: $table.meaningEn, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$AmaedolasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AmaedolasTable,
          Amaedola,
          $$AmaedolasTableFilterComposer,
          $$AmaedolasTableOrderingComposer,
          $$AmaedolasTableAnnotationComposer,
          $$AmaedolasTableCreateCompanionBuilder,
          $$AmaedolasTableUpdateCompanionBuilder,
          (Amaedola, BaseReferences<_$AppDatabase, $AmaedolasTable, Amaedola>),
          Amaedola,
          PrefetchHooks Function()
        > {
  $$AmaedolasTableTableManager(_$AppDatabase db, $AmaedolasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AmaedolasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AmaedolasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AmaedolasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> pageId = const Value.absent(),
                Value<String> textContent = const Value.absent(),
                Value<String> meaning = const Value.absent(),
                Value<String?> meaningId = const Value.absent(),
                Value<String?> meaningEn = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String?> url = const Value.absent(),
                Value<String?> note = const Value.absent(),
              }) => AmaedolasCompanion(
                id: id,
                pageId: pageId,
                textContent: textContent,
                meaning: meaning,
                meaningId: meaningId,
                meaningEn: meaningEn,
                label: label,
                url: url,
                note: note,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int pageId,
                required String textContent,
                required String meaning,
                Value<String?> meaningId = const Value.absent(),
                Value<String?> meaningEn = const Value.absent(),
                required String label,
                Value<String?> url = const Value.absent(),
                Value<String?> note = const Value.absent(),
              }) => AmaedolasCompanion.insert(
                id: id,
                pageId: pageId,
                textContent: textContent,
                meaning: meaning,
                meaningId: meaningId,
                meaningEn: meaningEn,
                label: label,
                url: url,
                note: note,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AmaedolasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AmaedolasTable,
      Amaedola,
      $$AmaedolasTableFilterComposer,
      $$AmaedolasTableOrderingComposer,
      $$AmaedolasTableAnnotationComposer,
      $$AmaedolasTableCreateCompanionBuilder,
      $$AmaedolasTableUpdateCompanionBuilder,
      (Amaedola, BaseReferences<_$AppDatabase, $AmaedolasTable, Amaedola>),
      Amaedola,
      PrefetchHooks Function()
    >;
typedef $$BiblesTableCreateCompanionBuilder = BiblesCompanion Function({
  Value<int> id,
  required int pageId,
  required String category,
  required String book,
  required int chapter,
  required int verse,
  required String textContent,
  Value<List<String>?> reference,
  Value<String?> note,
});
typedef $$BiblesTableUpdateCompanionBuilder = BiblesCompanion Function({
  Value<int> id,
  Value<int> pageId,
  Value<String> category,
  Value<String> book,
  Value<int> chapter,
  Value<int> verse,
  Value<String> textContent,
  Value<List<String>?> reference,
  Value<String?> note,
});

class $$BiblesTableFilterComposer
    extends Composer<_$AppDatabase, $BiblesTable> {
  $$BiblesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pageId => $composableBuilder(
    column: $table.pageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get book => $composableBuilder(
    column: $table.book,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chapter => $composableBuilder(
    column: $table.chapter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get verse => $composableBuilder(
    column: $table.verse,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>?, List<String>, String>
  get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BiblesTableOrderingComposer
    extends Composer<_$AppDatabase, $BiblesTable> {
  $$BiblesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pageId => $composableBuilder(
    column: $table.pageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get book => $composableBuilder(
    column: $table.book,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chapter => $composableBuilder(
    column: $table.chapter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get verse => $composableBuilder(
    column: $table.verse,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BiblesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BiblesTable> {
  $$BiblesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get pageId =>
      $composableBuilder(column: $table.pageId, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get book =>
      $composableBuilder(column: $table.book, builder: (column) => column);

  GeneratedColumn<int> get chapter =>
      $composableBuilder(column: $table.chapter, builder: (column) => column);

  GeneratedColumn<int> get verse =>
      $composableBuilder(column: $table.verse, builder: (column) => column);

  GeneratedColumn<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<List<String>?, String> get reference =>
      $composableBuilder(column: $table.reference, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$BiblesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BiblesTable,
          Bible,
          $$BiblesTableFilterComposer,
          $$BiblesTableOrderingComposer,
          $$BiblesTableAnnotationComposer,
          $$BiblesTableCreateCompanionBuilder,
          $$BiblesTableUpdateCompanionBuilder,
          (Bible, BaseReferences<_$AppDatabase, $BiblesTable, Bible>),
          Bible,
          PrefetchHooks Function()
        > {
  $$BiblesTableTableManager(_$AppDatabase db, $BiblesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BiblesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BiblesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BiblesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> pageId = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> book = const Value.absent(),
                Value<int> chapter = const Value.absent(),
                Value<int> verse = const Value.absent(),
                Value<String> textContent = const Value.absent(),
                Value<List<String>?> reference = const Value.absent(),
                Value<String?> note = const Value.absent(),
              }) => BiblesCompanion(
                id: id,
                pageId: pageId,
                category: category,
                book: book,
                chapter: chapter,
                verse: verse,
                textContent: textContent,
                reference: reference,
                note: note,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int pageId,
                required String category,
                required String book,
                required int chapter,
                required int verse,
                required String textContent,
                Value<List<String>?> reference = const Value.absent(),
                Value<String?> note = const Value.absent(),
              }) => BiblesCompanion.insert(
                id: id,
                pageId: pageId,
                category: category,
                book: book,
                chapter: chapter,
                verse: verse,
                textContent: textContent,
                reference: reference,
                note: note,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BiblesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BiblesTable,
      Bible,
      $$BiblesTableFilterComposer,
      $$BiblesTableOrderingComposer,
      $$BiblesTableAnnotationComposer,
      $$BiblesTableCreateCompanionBuilder,
      $$BiblesTableUpdateCompanionBuilder,
      (Bible, BaseReferences<_$AppDatabase, $BiblesTable, Bible>),
      Bible,
      PrefetchHooks Function()
    >;
typedef $$WikiPageRevisionsTableCreateCompanionBuilder =
    WikiPageRevisionsCompanion Function({
      Value<int> pageId,
      required int lastRevid,
      required String pageTitle,
      required String pageType,
      required DateTime lastUpdated,
    });
typedef $$WikiPageRevisionsTableUpdateCompanionBuilder =
    WikiPageRevisionsCompanion Function({
      Value<int> pageId,
      Value<int> lastRevid,
      Value<String> pageTitle,
      Value<String> pageType,
      Value<DateTime> lastUpdated,
    });

class $$WikiPageRevisionsTableFilterComposer
    extends Composer<_$AppDatabase, $WikiPageRevisionsTable> {
  $$WikiPageRevisionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get pageId => $composableBuilder(
    column: $table.pageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastRevid => $composableBuilder(
    column: $table.lastRevid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pageTitle => $composableBuilder(
    column: $table.pageTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pageType => $composableBuilder(
    column: $table.pageType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WikiPageRevisionsTableOrderingComposer
    extends Composer<_$AppDatabase, $WikiPageRevisionsTable> {
  $$WikiPageRevisionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get pageId => $composableBuilder(
    column: $table.pageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastRevid => $composableBuilder(
    column: $table.lastRevid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pageTitle => $composableBuilder(
    column: $table.pageTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pageType => $composableBuilder(
    column: $table.pageType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WikiPageRevisionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WikiPageRevisionsTable> {
  $$WikiPageRevisionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get pageId =>
      $composableBuilder(column: $table.pageId, builder: (column) => column);

  GeneratedColumn<int> get lastRevid =>
      $composableBuilder(column: $table.lastRevid, builder: (column) => column);

  GeneratedColumn<String> get pageTitle =>
      $composableBuilder(column: $table.pageTitle, builder: (column) => column);

  GeneratedColumn<String> get pageType =>
      $composableBuilder(column: $table.pageType, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => column,
  );
}

class $$WikiPageRevisionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WikiPageRevisionsTable,
          WikiPageRevision,
          $$WikiPageRevisionsTableFilterComposer,
          $$WikiPageRevisionsTableOrderingComposer,
          $$WikiPageRevisionsTableAnnotationComposer,
          $$WikiPageRevisionsTableCreateCompanionBuilder,
          $$WikiPageRevisionsTableUpdateCompanionBuilder,
          (
            WikiPageRevision,
            BaseReferences<
              _$AppDatabase,
              $WikiPageRevisionsTable,
              WikiPageRevision
            >,
          ),
          WikiPageRevision,
          PrefetchHooks Function()
        > {
  $$WikiPageRevisionsTableTableManager(
    _$AppDatabase db,
    $WikiPageRevisionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WikiPageRevisionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WikiPageRevisionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WikiPageRevisionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> pageId = const Value.absent(),
                Value<int> lastRevid = const Value.absent(),
                Value<String> pageTitle = const Value.absent(),
                Value<String> pageType = const Value.absent(),
                Value<DateTime> lastUpdated = const Value.absent(),
              }) => WikiPageRevisionsCompanion(
                pageId: pageId,
                lastRevid: lastRevid,
                pageTitle: pageTitle,
                pageType: pageType,
                lastUpdated: lastUpdated,
              ),
          createCompanionCallback:
              ({
                Value<int> pageId = const Value.absent(),
                required int lastRevid,
                required String pageTitle,
                required String pageType,
                required DateTime lastUpdated,
              }) => WikiPageRevisionsCompanion.insert(
                pageId: pageId,
                lastRevid: lastRevid,
                pageTitle: pageTitle,
                pageType: pageType,
                lastUpdated: lastUpdated,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WikiPageRevisionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WikiPageRevisionsTable,
      WikiPageRevision,
      $$WikiPageRevisionsTableFilterComposer,
      $$WikiPageRevisionsTableOrderingComposer,
      $$WikiPageRevisionsTableAnnotationComposer,
      $$WikiPageRevisionsTableCreateCompanionBuilder,
      $$WikiPageRevisionsTableUpdateCompanionBuilder,
      (
        WikiPageRevision,
        BaseReferences<
          _$AppDatabase,
          $WikiPageRevisionsTable,
          WikiPageRevision
        >,
      ),
      WikiPageRevision,
      PrefetchHooks Function()
    >;
typedef $$SongsTableCreateCompanionBuilder = SongsCompanion Function({
  Value<int> id,
  required int pageId,
  required String title,
  required String textContent,
  required String category,
  Value<String?> type,
  Value<List<String>?> artist,
  Value<List<String>?> writer,
  Value<List<String>?> producer,
  Value<String?> album,
  Value<String?> genre,
  Value<String?> released,
  Value<String?> recorded,
  Value<String?> studio,
  Value<String?> label,
  Value<String?> url,
  Value<String?> youtube,
});
typedef $$SongsTableUpdateCompanionBuilder = SongsCompanion Function({
  Value<int> id,
  Value<int> pageId,
  Value<String> title,
  Value<String> textContent,
  Value<String> category,
  Value<String?> type,
  Value<List<String>?> artist,
  Value<List<String>?> writer,
  Value<List<String>?> producer,
  Value<String?> album,
  Value<String?> genre,
  Value<String?> released,
  Value<String?> recorded,
  Value<String?> studio,
  Value<String?> label,
  Value<String?> url,
  Value<String?> youtube,
});

class $$SongsTableFilterComposer extends Composer<_$AppDatabase, $SongsTable> {
  $$SongsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pageId => $composableBuilder(
    column: $table.pageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>?, List<String>, String>
  get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>?, List<String>, String>
  get writer => $composableBuilder(
    column: $table.writer,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>?, List<String>, String>
  get producer => $composableBuilder(
    column: $table.producer,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get album => $composableBuilder(
    column: $table.album,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get genre => $composableBuilder(
    column: $table.genre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get released => $composableBuilder(
    column: $table.released,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recorded => $composableBuilder(
    column: $table.recorded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get studio => $composableBuilder(
    column: $table.studio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get youtube => $composableBuilder(
    column: $table.youtube,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SongsTableOrderingComposer
    extends Composer<_$AppDatabase, $SongsTable> {
  $$SongsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pageId => $composableBuilder(
    column: $table.pageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get writer => $composableBuilder(
    column: $table.writer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get producer => $composableBuilder(
    column: $table.producer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get album => $composableBuilder(
    column: $table.album,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get genre => $composableBuilder(
    column: $table.genre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get released => $composableBuilder(
    column: $table.released,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recorded => $composableBuilder(
    column: $table.recorded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get studio => $composableBuilder(
    column: $table.studio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get youtube => $composableBuilder(
    column: $table.youtube,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SongsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SongsTable> {
  $$SongsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get pageId =>
      $composableBuilder(column: $table.pageId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>?, String> get artist =>
      $composableBuilder(column: $table.artist, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>?, String> get writer =>
      $composableBuilder(column: $table.writer, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>?, String> get producer =>
      $composableBuilder(column: $table.producer, builder: (column) => column);

  GeneratedColumn<String> get album =>
      $composableBuilder(column: $table.album, builder: (column) => column);

  GeneratedColumn<String> get genre =>
      $composableBuilder(column: $table.genre, builder: (column) => column);

  GeneratedColumn<String> get released =>
      $composableBuilder(column: $table.released, builder: (column) => column);

  GeneratedColumn<String> get recorded =>
      $composableBuilder(column: $table.recorded, builder: (column) => column);

  GeneratedColumn<String> get studio =>
      $composableBuilder(column: $table.studio, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get youtube =>
      $composableBuilder(column: $table.youtube, builder: (column) => column);
}

class $$SongsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SongsTable,
          Song,
          $$SongsTableFilterComposer,
          $$SongsTableOrderingComposer,
          $$SongsTableAnnotationComposer,
          $$SongsTableCreateCompanionBuilder,
          $$SongsTableUpdateCompanionBuilder,
          (Song, BaseReferences<_$AppDatabase, $SongsTable, Song>),
          Song,
          PrefetchHooks Function()
        > {
  $$SongsTableTableManager(_$AppDatabase db, $SongsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SongsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SongsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SongsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> pageId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> textContent = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String?> type = const Value.absent(),
                Value<List<String>?> artist = const Value.absent(),
                Value<List<String>?> writer = const Value.absent(),
                Value<List<String>?> producer = const Value.absent(),
                Value<String?> album = const Value.absent(),
                Value<String?> genre = const Value.absent(),
                Value<String?> released = const Value.absent(),
                Value<String?> recorded = const Value.absent(),
                Value<String?> studio = const Value.absent(),
                Value<String?> label = const Value.absent(),
                Value<String?> url = const Value.absent(),
                Value<String?> youtube = const Value.absent(),
              }) => SongsCompanion(
                id: id,
                pageId: pageId,
                title: title,
                textContent: textContent,
                category: category,
                type: type,
                artist: artist,
                writer: writer,
                producer: producer,
                album: album,
                genre: genre,
                released: released,
                recorded: recorded,
                studio: studio,
                label: label,
                url: url,
                youtube: youtube,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int pageId,
                required String title,
                required String textContent,
                required String category,
                Value<String?> type = const Value.absent(),
                Value<List<String>?> artist = const Value.absent(),
                Value<List<String>?> writer = const Value.absent(),
                Value<List<String>?> producer = const Value.absent(),
                Value<String?> album = const Value.absent(),
                Value<String?> genre = const Value.absent(),
                Value<String?> released = const Value.absent(),
                Value<String?> recorded = const Value.absent(),
                Value<String?> studio = const Value.absent(),
                Value<String?> label = const Value.absent(),
                Value<String?> url = const Value.absent(),
                Value<String?> youtube = const Value.absent(),
              }) => SongsCompanion.insert(
                id: id,
                pageId: pageId,
                title: title,
                textContent: textContent,
                category: category,
                type: type,
                artist: artist,
                writer: writer,
                producer: producer,
                album: album,
                genre: genre,
                released: released,
                recorded: recorded,
                studio: studio,
                label: label,
                url: url,
                youtube: youtube,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SongsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SongsTable,
      Song,
      $$SongsTableFilterComposer,
      $$SongsTableOrderingComposer,
      $$SongsTableAnnotationComposer,
      $$SongsTableCreateCompanionBuilder,
      $$SongsTableUpdateCompanionBuilder,
      (Song, BaseReferences<_$AppDatabase, $SongsTable, Song>),
      Song,
      PrefetchHooks Function()
    >;
typedef $$ManoManosTableCreateCompanionBuilder = ManoManosCompanion Function({
  Value<int> id,
  required int pageId,
  required String title,
  required String textContent,
  Value<String?> description,
  Value<List<String>?> editor,
  Value<String?> origin,
  Value<String?> source,
  Value<String?> url,
});
typedef $$ManoManosTableUpdateCompanionBuilder = ManoManosCompanion Function({
  Value<int> id,
  Value<int> pageId,
  Value<String> title,
  Value<String> textContent,
  Value<String?> description,
  Value<List<String>?> editor,
  Value<String?> origin,
  Value<String?> source,
  Value<String?> url,
});

class $$ManoManosTableFilterComposer
    extends Composer<_$AppDatabase, $ManoManosTable> {
  $$ManoManosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pageId => $composableBuilder(
    column: $table.pageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>?, List<String>, String>
  get editor => $composableBuilder(
    column: $table.editor,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ManoManosTableOrderingComposer
    extends Composer<_$AppDatabase, $ManoManosTable> {
  $$ManoManosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pageId => $composableBuilder(
    column: $table.pageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get editor => $composableBuilder(
    column: $table.editor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ManoManosTableAnnotationComposer
    extends Composer<_$AppDatabase, $ManoManosTable> {
  $$ManoManosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get pageId =>
      $composableBuilder(column: $table.pageId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<List<String>?, String> get editor =>
      $composableBuilder(column: $table.editor, builder: (column) => column);

  GeneratedColumn<String> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);
}

class $$ManoManosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ManoManosTable,
          ManoMano,
          $$ManoManosTableFilterComposer,
          $$ManoManosTableOrderingComposer,
          $$ManoManosTableAnnotationComposer,
          $$ManoManosTableCreateCompanionBuilder,
          $$ManoManosTableUpdateCompanionBuilder,
          (ManoMano, BaseReferences<_$AppDatabase, $ManoManosTable, ManoMano>),
          ManoMano,
          PrefetchHooks Function()
        > {
  $$ManoManosTableTableManager(_$AppDatabase db, $ManoManosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ManoManosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ManoManosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ManoManosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> pageId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> textContent = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<List<String>?> editor = const Value.absent(),
                Value<String?> origin = const Value.absent(),
                Value<String?> source = const Value.absent(),
                Value<String?> url = const Value.absent(),
              }) => ManoManosCompanion(
                id: id,
                pageId: pageId,
                title: title,
                textContent: textContent,
                description: description,
                editor: editor,
                origin: origin,
                source: source,
                url: url,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int pageId,
                required String title,
                required String textContent,
                Value<String?> description = const Value.absent(),
                Value<List<String>?> editor = const Value.absent(),
                Value<String?> origin = const Value.absent(),
                Value<String?> source = const Value.absent(),
                Value<String?> url = const Value.absent(),
              }) => ManoManosCompanion.insert(
                id: id,
                pageId: pageId,
                title: title,
                textContent: textContent,
                description: description,
                editor: editor,
                origin: origin,
                source: source,
                url: url,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ManoManosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ManoManosTable,
      ManoMano,
      $$ManoManosTableFilterComposer,
      $$ManoManosTableOrderingComposer,
      $$ManoManosTableAnnotationComposer,
      $$ManoManosTableCreateCompanionBuilder,
      $$ManoManosTableUpdateCompanionBuilder,
      (ManoMano, BaseReferences<_$AppDatabase, $ManoManosTable, ManoMano>),
      ManoMano,
      PrefetchHooks Function()
    >;
typedef $$ArticlesTableCreateCompanionBuilder = ArticlesCompanion Function({
  Value<int> id,
  required int pageId,
  required String category,
  required String title,
  required String textContent,
  Value<String?> description,
  Value<List<String>?> editor,
});
typedef $$ArticlesTableUpdateCompanionBuilder = ArticlesCompanion Function({
  Value<int> id,
  Value<int> pageId,
  Value<String> category,
  Value<String> title,
  Value<String> textContent,
  Value<String?> description,
  Value<List<String>?> editor,
});

class $$ArticlesTableFilterComposer
    extends Composer<_$AppDatabase, $ArticlesTable> {
  $$ArticlesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pageId => $composableBuilder(
    column: $table.pageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>?, List<String>, String>
  get editor => $composableBuilder(
    column: $table.editor,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );
}

class $$ArticlesTableOrderingComposer
    extends Composer<_$AppDatabase, $ArticlesTable> {
  $$ArticlesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pageId => $composableBuilder(
    column: $table.pageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get editor => $composableBuilder(
    column: $table.editor,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ArticlesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ArticlesTable> {
  $$ArticlesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get pageId =>
      $composableBuilder(column: $table.pageId, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<List<String>?, String> get editor =>
      $composableBuilder(column: $table.editor, builder: (column) => column);
}

class $$ArticlesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ArticlesTable,
          Article,
          $$ArticlesTableFilterComposer,
          $$ArticlesTableOrderingComposer,
          $$ArticlesTableAnnotationComposer,
          $$ArticlesTableCreateCompanionBuilder,
          $$ArticlesTableUpdateCompanionBuilder,
          (Article, BaseReferences<_$AppDatabase, $ArticlesTable, Article>),
          Article,
          PrefetchHooks Function()
        > {
  $$ArticlesTableTableManager(_$AppDatabase db, $ArticlesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ArticlesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ArticlesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ArticlesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> pageId = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> textContent = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<List<String>?> editor = const Value.absent(),
              }) => ArticlesCompanion(
                id: id,
                pageId: pageId,
                category: category,
                title: title,
                textContent: textContent,
                description: description,
                editor: editor,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int pageId,
                required String category,
                required String title,
                required String textContent,
                Value<String?> description = const Value.absent(),
                Value<List<String>?> editor = const Value.absent(),
              }) => ArticlesCompanion.insert(
                id: id,
                pageId: pageId,
                category: category,
                title: title,
                textContent: textContent,
                description: description,
                editor: editor,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ArticlesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ArticlesTable,
      Article,
      $$ArticlesTableFilterComposer,
      $$ArticlesTableOrderingComposer,
      $$ArticlesTableAnnotationComposer,
      $$ArticlesTableCreateCompanionBuilder,
      $$ArticlesTableUpdateCompanionBuilder,
      (Article, BaseReferences<_$AppDatabase, $ArticlesTable, Article>),
      Article,
      PrefetchHooks Function()
    >;
typedef $$HohosTableCreateCompanionBuilder = HohosCompanion Function({
  Value<int> id,
  required int pageId,
  required String title,
  required String textContent,
  Value<String?> description,
  Value<String?> descId,
  Value<String?> descEn,
  Value<List<String>?> editor,
  Value<String?> source,
  Value<String?> url,
});
typedef $$HohosTableUpdateCompanionBuilder = HohosCompanion Function({
  Value<int> id,
  Value<int> pageId,
  Value<String> title,
  Value<String> textContent,
  Value<String?> description,
  Value<String?> descId,
  Value<String?> descEn,
  Value<List<String>?> editor,
  Value<String?> source,
  Value<String?> url,
});

class $$HohosTableFilterComposer extends Composer<_$AppDatabase, $HohosTable> {
  $$HohosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pageId => $composableBuilder(
    column: $table.pageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descId => $composableBuilder(
    column: $table.descId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descEn => $composableBuilder(
    column: $table.descEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>?, List<String>, String>
  get editor => $composableBuilder(
    column: $table.editor,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HohosTableOrderingComposer
    extends Composer<_$AppDatabase, $HohosTable> {
  $$HohosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pageId => $composableBuilder(
    column: $table.pageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descId => $composableBuilder(
    column: $table.descId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descEn => $composableBuilder(
    column: $table.descEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get editor => $composableBuilder(
    column: $table.editor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HohosTableAnnotationComposer
    extends Composer<_$AppDatabase, $HohosTable> {
  $$HohosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get pageId =>
      $composableBuilder(column: $table.pageId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get descId =>
      $composableBuilder(column: $table.descId, builder: (column) => column);

  GeneratedColumn<String> get descEn =>
      $composableBuilder(column: $table.descEn, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>?, String> get editor =>
      $composableBuilder(column: $table.editor, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);
}

class $$HohosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HohosTable,
          Hoho,
          $$HohosTableFilterComposer,
          $$HohosTableOrderingComposer,
          $$HohosTableAnnotationComposer,
          $$HohosTableCreateCompanionBuilder,
          $$HohosTableUpdateCompanionBuilder,
          (Hoho, BaseReferences<_$AppDatabase, $HohosTable, Hoho>),
          Hoho,
          PrefetchHooks Function()
        > {
  $$HohosTableTableManager(_$AppDatabase db, $HohosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HohosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HohosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HohosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> pageId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> textContent = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> descId = const Value.absent(),
                Value<String?> descEn = const Value.absent(),
                Value<List<String>?> editor = const Value.absent(),
                Value<String?> source = const Value.absent(),
                Value<String?> url = const Value.absent(),
              }) => HohosCompanion(
                id: id,
                pageId: pageId,
                title: title,
                textContent: textContent,
                description: description,
                descId: descId,
                descEn: descEn,
                editor: editor,
                source: source,
                url: url,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int pageId,
                required String title,
                required String textContent,
                Value<String?> description = const Value.absent(),
                Value<String?> descId = const Value.absent(),
                Value<String?> descEn = const Value.absent(),
                Value<List<String>?> editor = const Value.absent(),
                Value<String?> source = const Value.absent(),
                Value<String?> url = const Value.absent(),
              }) => HohosCompanion.insert(
                id: id,
                pageId: pageId,
                title: title,
                textContent: textContent,
                description: description,
                descId: descId,
                descEn: descEn,
                editor: editor,
                source: source,
                url: url,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HohosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HohosTable,
      Hoho,
      $$HohosTableFilterComposer,
      $$HohosTableOrderingComposer,
      $$HohosTableAnnotationComposer,
      $$HohosTableCreateCompanionBuilder,
      $$HohosTableUpdateCompanionBuilder,
      (Hoho, BaseReferences<_$AppDatabase, $HohosTable, Hoho>),
      Hoho,
      PrefetchHooks Function()
    >;
typedef $$HeritageArticlesTableCreateCompanionBuilder =
    HeritageArticlesCompanion Function({
      Value<int> pageId,
      required String category,
      Value<String> wikiHost,
      required String pageTitle,
      required String title,
      required String textContent,
      Value<String?> htmlContent,
      Value<String?> footnotes,
      Value<String?> imageUrl,
      Value<int> lastRevid,
      Value<DateTime?> lastUpdated,
    });
typedef $$HeritageArticlesTableUpdateCompanionBuilder =
    HeritageArticlesCompanion Function({
      Value<int> pageId,
      Value<String> category,
      Value<String> wikiHost,
      Value<String> pageTitle,
      Value<String> title,
      Value<String> textContent,
      Value<String?> htmlContent,
      Value<String?> footnotes,
      Value<String?> imageUrl,
      Value<int> lastRevid,
      Value<DateTime?> lastUpdated,
    });

class $$HeritageArticlesTableFilterComposer
    extends Composer<_$AppDatabase, $HeritageArticlesTable> {
  $$HeritageArticlesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get pageId => $composableBuilder(
    column: $table.pageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get wikiHost => $composableBuilder(
    column: $table.wikiHost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pageTitle => $composableBuilder(
    column: $table.pageTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get htmlContent => $composableBuilder(
    column: $table.htmlContent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get footnotes => $composableBuilder(
    column: $table.footnotes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastRevid => $composableBuilder(
    column: $table.lastRevid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HeritageArticlesTableOrderingComposer
    extends Composer<_$AppDatabase, $HeritageArticlesTable> {
  $$HeritageArticlesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get pageId => $composableBuilder(
    column: $table.pageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get wikiHost => $composableBuilder(
    column: $table.wikiHost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pageTitle => $composableBuilder(
    column: $table.pageTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get htmlContent => $composableBuilder(
    column: $table.htmlContent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get footnotes => $composableBuilder(
    column: $table.footnotes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastRevid => $composableBuilder(
    column: $table.lastRevid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HeritageArticlesTableAnnotationComposer
    extends Composer<_$AppDatabase, $HeritageArticlesTable> {
  $$HeritageArticlesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get pageId =>
      $composableBuilder(column: $table.pageId, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get wikiHost =>
      $composableBuilder(column: $table.wikiHost, builder: (column) => column);

  GeneratedColumn<String> get pageTitle =>
      $composableBuilder(column: $table.pageTitle, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => column,
  );

  GeneratedColumn<String> get htmlContent => $composableBuilder(
    column: $table.htmlContent,
    builder: (column) => column,
  );

  GeneratedColumn<String> get footnotes =>
      $composableBuilder(column: $table.footnotes, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<int> get lastRevid =>
      $composableBuilder(column: $table.lastRevid, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => column,
  );
}

class $$HeritageArticlesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HeritageArticlesTable,
          HeritageArticle,
          $$HeritageArticlesTableFilterComposer,
          $$HeritageArticlesTableOrderingComposer,
          $$HeritageArticlesTableAnnotationComposer,
          $$HeritageArticlesTableCreateCompanionBuilder,
          $$HeritageArticlesTableUpdateCompanionBuilder,
          (
            HeritageArticle,
            BaseReferences<
              _$AppDatabase,
              $HeritageArticlesTable,
              HeritageArticle
            >,
          ),
          HeritageArticle,
          PrefetchHooks Function()
        > {
  $$HeritageArticlesTableTableManager(
    _$AppDatabase db,
    $HeritageArticlesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HeritageArticlesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HeritageArticlesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HeritageArticlesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> pageId = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> wikiHost = const Value.absent(),
                Value<String> pageTitle = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> textContent = const Value.absent(),
                Value<String?> htmlContent = const Value.absent(),
                Value<String?> footnotes = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<int> lastRevid = const Value.absent(),
                Value<DateTime?> lastUpdated = const Value.absent(),
              }) => HeritageArticlesCompanion(
                pageId: pageId,
                category: category,
                wikiHost: wikiHost,
                pageTitle: pageTitle,
                title: title,
                textContent: textContent,
                htmlContent: htmlContent,
                footnotes: footnotes,
                imageUrl: imageUrl,
                lastRevid: lastRevid,
                lastUpdated: lastUpdated,
              ),
          createCompanionCallback:
              ({
                Value<int> pageId = const Value.absent(),
                required String category,
                Value<String> wikiHost = const Value.absent(),
                required String pageTitle,
                required String title,
                required String textContent,
                Value<String?> htmlContent = const Value.absent(),
                Value<String?> footnotes = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<int> lastRevid = const Value.absent(),
                Value<DateTime?> lastUpdated = const Value.absent(),
              }) => HeritageArticlesCompanion.insert(
                pageId: pageId,
                category: category,
                wikiHost: wikiHost,
                pageTitle: pageTitle,
                title: title,
                textContent: textContent,
                htmlContent: htmlContent,
                footnotes: footnotes,
                imageUrl: imageUrl,
                lastRevid: lastRevid,
                lastUpdated: lastUpdated,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HeritageArticlesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HeritageArticlesTable,
      HeritageArticle,
      $$HeritageArticlesTableFilterComposer,
      $$HeritageArticlesTableOrderingComposer,
      $$HeritageArticlesTableAnnotationComposer,
      $$HeritageArticlesTableCreateCompanionBuilder,
      $$HeritageArticlesTableUpdateCompanionBuilder,
      (
        HeritageArticle,
        BaseReferences<_$AppDatabase, $HeritageArticlesTable, HeritageArticle>,
      ),
      HeritageArticle,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$HeritageItemsTableTableManager get heritageItems =>
      $$HeritageItemsTableTableManager(_db, _db.heritageItems);
  $$TimelineEventsTableTableManager get timelineEvents =>
      $$TimelineEventsTableTableManager(_db, _db.timelineEvents);
  $$AmaedolasTableTableManager get amaedolas =>
      $$AmaedolasTableTableManager(_db, _db.amaedolas);
  $$BiblesTableTableManager get bibles =>
      $$BiblesTableTableManager(_db, _db.bibles);
  $$WikiPageRevisionsTableTableManager get wikiPageRevisions =>
      $$WikiPageRevisionsTableTableManager(_db, _db.wikiPageRevisions);
  $$SongsTableTableManager get songs =>
      $$SongsTableTableManager(_db, _db.songs);
  $$ManoManosTableTableManager get manoManos =>
      $$ManoManosTableTableManager(_db, _db.manoManos);
  $$ArticlesTableTableManager get articles =>
      $$ArticlesTableTableManager(_db, _db.articles);
  $$HohosTableTableManager get hohos =>
      $$HohosTableTableManager(_db, _db.hohos);
  $$HeritageArticlesTableTableManager get heritageArticles =>
      $$HeritageArticlesTableTableManager(_db, _db.heritageArticles);
}
