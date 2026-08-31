// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $VibeCategoriesTable extends VibeCategories
    with TableInfo<$VibeCategoriesTable, VibeCategoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VibeCategoriesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _colorHexMeta = const VerificationMeta(
    'colorHex',
  );
  @override
  late final GeneratedColumn<String> colorHex = GeneratedColumn<String>(
    'color_hex',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, colorHex, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vibe_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<VibeCategoryRow> instance, {
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
    if (data.containsKey('color_hex')) {
      context.handle(
        _colorHexMeta,
        colorHex.isAcceptableOrUnknown(data['color_hex']!, _colorHexMeta),
      );
    } else if (isInserting) {
      context.missing(_colorHexMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VibeCategoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VibeCategoryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      colorHex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color_hex'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $VibeCategoriesTable createAlias(String alias) {
    return $VibeCategoriesTable(attachedDatabase, alias);
  }
}

class VibeCategoryRow extends DataClass implements Insertable<VibeCategoryRow> {
  final String id;
  final String name;
  final String colorHex;
  final int sortOrder;
  const VibeCategoryRow({
    required this.id,
    required this.name,
    required this.colorHex,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['color_hex'] = Variable<String>(colorHex);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  VibeCategoriesCompanion toCompanion(bool nullToAbsent) {
    return VibeCategoriesCompanion(
      id: Value(id),
      name: Value(name),
      colorHex: Value(colorHex),
      sortOrder: Value(sortOrder),
    );
  }

  factory VibeCategoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VibeCategoryRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      colorHex: serializer.fromJson<String>(json['colorHex']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'colorHex': serializer.toJson<String>(colorHex),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  VibeCategoryRow copyWith({
    String? id,
    String? name,
    String? colorHex,
    int? sortOrder,
  }) => VibeCategoryRow(
    id: id ?? this.id,
    name: name ?? this.name,
    colorHex: colorHex ?? this.colorHex,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  VibeCategoryRow copyWithCompanion(VibeCategoriesCompanion data) {
    return VibeCategoryRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      colorHex: data.colorHex.present ? data.colorHex.value : this.colorHex,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VibeCategoryRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('colorHex: $colorHex, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, colorHex, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VibeCategoryRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.colorHex == this.colorHex &&
          other.sortOrder == this.sortOrder);
}

class VibeCategoriesCompanion extends UpdateCompanion<VibeCategoryRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> colorHex;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const VibeCategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VibeCategoriesCompanion.insert({
    required String id,
    required String name,
    required String colorHex,
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       colorHex = Value(colorHex);
  static Insertable<VibeCategoryRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? colorHex,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (colorHex != null) 'color_hex': colorHex,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VibeCategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? colorHex,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return VibeCategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      colorHex: colorHex ?? this.colorHex,
      sortOrder: sortOrder ?? this.sortOrder,
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
    if (colorHex.present) {
      map['color_hex'] = Variable<String>(colorHex.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VibeCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('colorHex: $colorHex, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VibeTagsTable extends VibeTags
    with TableInfo<$VibeTagsTable, VibeTagRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VibeTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _colorHexMeta = const VerificationMeta(
    'colorHex',
  );
  @override
  late final GeneratedColumn<String> colorHex = GeneratedColumn<String>(
    'color_hex',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    label,
    colorHex,
    sortOrder,
    categoryId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vibe_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<VibeTagRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('color_hex')) {
      context.handle(
        _colorHexMeta,
        colorHex.isAcceptableOrUnknown(data['color_hex']!, _colorHexMeta),
      );
    } else if (isInserting) {
      context.missing(_colorHexMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VibeTagRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VibeTagRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      colorHex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color_hex'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      ),
    );
  }

  @override
  $VibeTagsTable createAlias(String alias) {
    return $VibeTagsTable(attachedDatabase, alias);
  }
}

class VibeTagRow extends DataClass implements Insertable<VibeTagRow> {
  final String id;
  final String label;
  final String colorHex;
  final int sortOrder;

  /// The folder this vibe sits in, or null for "Uncategorised". A vibe
  /// belongs to at most one folder.
  ///
  /// `VibeTagRepository.deleteVibeCategory` clears this itself rather than
  /// trusting the constraint below: it only exists on databases created after
  /// the category feature landed, and `ALTER TABLE ... ADD COLUMN` can't
  /// retrofit it onto older installs.
  final String? categoryId;
  const VibeTagRow({
    required this.id,
    required this.label,
    required this.colorHex,
    required this.sortOrder,
    this.categoryId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['label'] = Variable<String>(label);
    map['color_hex'] = Variable<String>(colorHex);
    map['sort_order'] = Variable<int>(sortOrder);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    return map;
  }

  VibeTagsCompanion toCompanion(bool nullToAbsent) {
    return VibeTagsCompanion(
      id: Value(id),
      label: Value(label),
      colorHex: Value(colorHex),
      sortOrder: Value(sortOrder),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
    );
  }

  factory VibeTagRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VibeTagRow(
      id: serializer.fromJson<String>(json['id']),
      label: serializer.fromJson<String>(json['label']),
      colorHex: serializer.fromJson<String>(json['colorHex']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'label': serializer.toJson<String>(label),
      'colorHex': serializer.toJson<String>(colorHex),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'categoryId': serializer.toJson<String?>(categoryId),
    };
  }

  VibeTagRow copyWith({
    String? id,
    String? label,
    String? colorHex,
    int? sortOrder,
    Value<String?> categoryId = const Value.absent(),
  }) => VibeTagRow(
    id: id ?? this.id,
    label: label ?? this.label,
    colorHex: colorHex ?? this.colorHex,
    sortOrder: sortOrder ?? this.sortOrder,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
  );
  VibeTagRow copyWithCompanion(VibeTagsCompanion data) {
    return VibeTagRow(
      id: data.id.present ? data.id.value : this.id,
      label: data.label.present ? data.label.value : this.label,
      colorHex: data.colorHex.present ? data.colorHex.value : this.colorHex,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VibeTagRow(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('colorHex: $colorHex, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('categoryId: $categoryId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, label, colorHex, sortOrder, categoryId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VibeTagRow &&
          other.id == this.id &&
          other.label == this.label &&
          other.colorHex == this.colorHex &&
          other.sortOrder == this.sortOrder &&
          other.categoryId == this.categoryId);
}

class VibeTagsCompanion extends UpdateCompanion<VibeTagRow> {
  final Value<String> id;
  final Value<String> label;
  final Value<String> colorHex;
  final Value<int> sortOrder;
  final Value<String?> categoryId;
  final Value<int> rowid;
  const VibeTagsCompanion({
    this.id = const Value.absent(),
    this.label = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VibeTagsCompanion.insert({
    required String id,
    required String label,
    required String colorHex,
    this.sortOrder = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       label = Value(label),
       colorHex = Value(colorHex);
  static Insertable<VibeTagRow> custom({
    Expression<String>? id,
    Expression<String>? label,
    Expression<String>? colorHex,
    Expression<int>? sortOrder,
    Expression<String>? categoryId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (label != null) 'label': label,
      if (colorHex != null) 'color_hex': colorHex,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (categoryId != null) 'category_id': categoryId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VibeTagsCompanion copyWith({
    Value<String>? id,
    Value<String>? label,
    Value<String>? colorHex,
    Value<int>? sortOrder,
    Value<String?>? categoryId,
    Value<int>? rowid,
  }) {
    return VibeTagsCompanion(
      id: id ?? this.id,
      label: label ?? this.label,
      colorHex: colorHex ?? this.colorHex,
      sortOrder: sortOrder ?? this.sortOrder,
      categoryId: categoryId ?? this.categoryId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (colorHex.present) {
      map['color_hex'] = Variable<String>(colorHex.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VibeTagsCompanion(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('colorHex: $colorHex, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('categoryId: $categoryId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SongsTable extends Songs with TableInfo<$SongsTable, SongRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SongsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
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
  static const VerificationMeta _artistMeta = const VerificationMeta('artist');
  @override
  late final GeneratedColumn<String> artist = GeneratedColumn<String>(
    'artist',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _albumMeta = const VerificationMeta('album');
  @override
  late final GeneratedColumn<String> album = GeneratedColumn<String>(
    'album',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isVideoMeta = const VerificationMeta(
    'isVideo',
  );
  @override
  late final GeneratedColumn<bool> isVideo = GeneratedColumn<bool>(
    'is_video',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_video" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isLikedMeta = const VerificationMeta(
    'isLiked',
  );
  @override
  late final GeneratedColumn<bool> isLiked = GeneratedColumn<bool>(
    'is_liked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_liked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isMissingMeta = const VerificationMeta(
    'isMissing',
  );
  @override
  late final GeneratedColumn<bool> isMissing = GeneratedColumn<bool>(
    'is_missing',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_missing" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _playCountMeta = const VerificationMeta(
    'playCount',
  );
  @override
  late final GeneratedColumn<int> playCount = GeneratedColumn<int>(
    'play_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastPlayedAtMeta = const VerificationMeta(
    'lastPlayedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastPlayedAt = GeneratedColumn<DateTime>(
    'last_played_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateAddedMeta = const VerificationMeta(
    'dateAdded',
  );
  @override
  late final GeneratedColumn<DateTime> dateAdded = GeneratedColumn<DateTime>(
    'date_added',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    filePath,
    title,
    artist,
    album,
    durationMs,
    isVideo,
    isLiked,
    isMissing,
    playCount,
    lastPlayedAt,
    dateAdded,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'songs';
  @override
  VerificationContext validateIntegrity(
    Insertable<SongRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('artist')) {
      context.handle(
        _artistMeta,
        artist.isAcceptableOrUnknown(data['artist']!, _artistMeta),
      );
    } else if (isInserting) {
      context.missing(_artistMeta);
    }
    if (data.containsKey('album')) {
      context.handle(
        _albumMeta,
        album.isAcceptableOrUnknown(data['album']!, _albumMeta),
      );
    } else if (isInserting) {
      context.missing(_albumMeta);
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    } else if (isInserting) {
      context.missing(_durationMsMeta);
    }
    if (data.containsKey('is_video')) {
      context.handle(
        _isVideoMeta,
        isVideo.isAcceptableOrUnknown(data['is_video']!, _isVideoMeta),
      );
    }
    if (data.containsKey('is_liked')) {
      context.handle(
        _isLikedMeta,
        isLiked.isAcceptableOrUnknown(data['is_liked']!, _isLikedMeta),
      );
    }
    if (data.containsKey('is_missing')) {
      context.handle(
        _isMissingMeta,
        isMissing.isAcceptableOrUnknown(data['is_missing']!, _isMissingMeta),
      );
    }
    if (data.containsKey('play_count')) {
      context.handle(
        _playCountMeta,
        playCount.isAcceptableOrUnknown(data['play_count']!, _playCountMeta),
      );
    }
    if (data.containsKey('last_played_at')) {
      context.handle(
        _lastPlayedAtMeta,
        lastPlayedAt.isAcceptableOrUnknown(
          data['last_played_at']!,
          _lastPlayedAtMeta,
        ),
      );
    }
    if (data.containsKey('date_added')) {
      context.handle(
        _dateAddedMeta,
        dateAdded.isAcceptableOrUnknown(data['date_added']!, _dateAddedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SongRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SongRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      artist: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist'],
      )!,
      album: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}album'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      )!,
      isVideo: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_video'],
      )!,
      isLiked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_liked'],
      )!,
      isMissing: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_missing'],
      )!,
      playCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}play_count'],
      )!,
      lastPlayedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_played_at'],
      ),
      dateAdded: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_added'],
      ),
    );
  }

  @override
  $SongsTable createAlias(String alias) {
    return $SongsTable(attachedDatabase, alias);
  }
}

class SongRow extends DataClass implements Insertable<SongRow> {
  final String id;
  final String filePath;
  final String title;
  final String artist;
  final String album;
  final int durationMs;

  /// Whether this entry is a video file played as music (SRS: audio-only
  /// video playback). Video ids are namespaced — see `MediaScannerService` —
  /// since MediaStore numbers audio and video rows independently.
  final bool isVideo;
  final bool isLiked;
  final bool isMissing;
  final int playCount;
  final DateTime? lastPlayedAt;

  /// When the device's media store first saw this file, which is what the
  /// "Newest added" sort orders by.
  ///
  /// Nullable, and treated as "unknown" rather than "very old" everywhere it
  /// is read: it only arrives with a device scan, so rows cached before this
  /// column existed carry null until the next refresh, and MediaStore itself
  /// leaves the column empty on some devices.
  final DateTime? dateAdded;
  const SongRow({
    required this.id,
    required this.filePath,
    required this.title,
    required this.artist,
    required this.album,
    required this.durationMs,
    required this.isVideo,
    required this.isLiked,
    required this.isMissing,
    required this.playCount,
    this.lastPlayedAt,
    this.dateAdded,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['file_path'] = Variable<String>(filePath);
    map['title'] = Variable<String>(title);
    map['artist'] = Variable<String>(artist);
    map['album'] = Variable<String>(album);
    map['duration_ms'] = Variable<int>(durationMs);
    map['is_video'] = Variable<bool>(isVideo);
    map['is_liked'] = Variable<bool>(isLiked);
    map['is_missing'] = Variable<bool>(isMissing);
    map['play_count'] = Variable<int>(playCount);
    if (!nullToAbsent || lastPlayedAt != null) {
      map['last_played_at'] = Variable<DateTime>(lastPlayedAt);
    }
    if (!nullToAbsent || dateAdded != null) {
      map['date_added'] = Variable<DateTime>(dateAdded);
    }
    return map;
  }

  SongsCompanion toCompanion(bool nullToAbsent) {
    return SongsCompanion(
      id: Value(id),
      filePath: Value(filePath),
      title: Value(title),
      artist: Value(artist),
      album: Value(album),
      durationMs: Value(durationMs),
      isVideo: Value(isVideo),
      isLiked: Value(isLiked),
      isMissing: Value(isMissing),
      playCount: Value(playCount),
      lastPlayedAt: lastPlayedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPlayedAt),
      dateAdded: dateAdded == null && nullToAbsent
          ? const Value.absent()
          : Value(dateAdded),
    );
  }

  factory SongRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SongRow(
      id: serializer.fromJson<String>(json['id']),
      filePath: serializer.fromJson<String>(json['filePath']),
      title: serializer.fromJson<String>(json['title']),
      artist: serializer.fromJson<String>(json['artist']),
      album: serializer.fromJson<String>(json['album']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      isVideo: serializer.fromJson<bool>(json['isVideo']),
      isLiked: serializer.fromJson<bool>(json['isLiked']),
      isMissing: serializer.fromJson<bool>(json['isMissing']),
      playCount: serializer.fromJson<int>(json['playCount']),
      lastPlayedAt: serializer.fromJson<DateTime?>(json['lastPlayedAt']),
      dateAdded: serializer.fromJson<DateTime?>(json['dateAdded']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'filePath': serializer.toJson<String>(filePath),
      'title': serializer.toJson<String>(title),
      'artist': serializer.toJson<String>(artist),
      'album': serializer.toJson<String>(album),
      'durationMs': serializer.toJson<int>(durationMs),
      'isVideo': serializer.toJson<bool>(isVideo),
      'isLiked': serializer.toJson<bool>(isLiked),
      'isMissing': serializer.toJson<bool>(isMissing),
      'playCount': serializer.toJson<int>(playCount),
      'lastPlayedAt': serializer.toJson<DateTime?>(lastPlayedAt),
      'dateAdded': serializer.toJson<DateTime?>(dateAdded),
    };
  }

  SongRow copyWith({
    String? id,
    String? filePath,
    String? title,
    String? artist,
    String? album,
    int? durationMs,
    bool? isVideo,
    bool? isLiked,
    bool? isMissing,
    int? playCount,
    Value<DateTime?> lastPlayedAt = const Value.absent(),
    Value<DateTime?> dateAdded = const Value.absent(),
  }) => SongRow(
    id: id ?? this.id,
    filePath: filePath ?? this.filePath,
    title: title ?? this.title,
    artist: artist ?? this.artist,
    album: album ?? this.album,
    durationMs: durationMs ?? this.durationMs,
    isVideo: isVideo ?? this.isVideo,
    isLiked: isLiked ?? this.isLiked,
    isMissing: isMissing ?? this.isMissing,
    playCount: playCount ?? this.playCount,
    lastPlayedAt: lastPlayedAt.present ? lastPlayedAt.value : this.lastPlayedAt,
    dateAdded: dateAdded.present ? dateAdded.value : this.dateAdded,
  );
  SongRow copyWithCompanion(SongsCompanion data) {
    return SongRow(
      id: data.id.present ? data.id.value : this.id,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      title: data.title.present ? data.title.value : this.title,
      artist: data.artist.present ? data.artist.value : this.artist,
      album: data.album.present ? data.album.value : this.album,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      isVideo: data.isVideo.present ? data.isVideo.value : this.isVideo,
      isLiked: data.isLiked.present ? data.isLiked.value : this.isLiked,
      isMissing: data.isMissing.present ? data.isMissing.value : this.isMissing,
      playCount: data.playCount.present ? data.playCount.value : this.playCount,
      lastPlayedAt: data.lastPlayedAt.present
          ? data.lastPlayedAt.value
          : this.lastPlayedAt,
      dateAdded: data.dateAdded.present ? data.dateAdded.value : this.dateAdded,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SongRow(')
          ..write('id: $id, ')
          ..write('filePath: $filePath, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('album: $album, ')
          ..write('durationMs: $durationMs, ')
          ..write('isVideo: $isVideo, ')
          ..write('isLiked: $isLiked, ')
          ..write('isMissing: $isMissing, ')
          ..write('playCount: $playCount, ')
          ..write('lastPlayedAt: $lastPlayedAt, ')
          ..write('dateAdded: $dateAdded')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    filePath,
    title,
    artist,
    album,
    durationMs,
    isVideo,
    isLiked,
    isMissing,
    playCount,
    lastPlayedAt,
    dateAdded,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SongRow &&
          other.id == this.id &&
          other.filePath == this.filePath &&
          other.title == this.title &&
          other.artist == this.artist &&
          other.album == this.album &&
          other.durationMs == this.durationMs &&
          other.isVideo == this.isVideo &&
          other.isLiked == this.isLiked &&
          other.isMissing == this.isMissing &&
          other.playCount == this.playCount &&
          other.lastPlayedAt == this.lastPlayedAt &&
          other.dateAdded == this.dateAdded);
}

class SongsCompanion extends UpdateCompanion<SongRow> {
  final Value<String> id;
  final Value<String> filePath;
  final Value<String> title;
  final Value<String> artist;
  final Value<String> album;
  final Value<int> durationMs;
  final Value<bool> isVideo;
  final Value<bool> isLiked;
  final Value<bool> isMissing;
  final Value<int> playCount;
  final Value<DateTime?> lastPlayedAt;
  final Value<DateTime?> dateAdded;
  final Value<int> rowid;
  const SongsCompanion({
    this.id = const Value.absent(),
    this.filePath = const Value.absent(),
    this.title = const Value.absent(),
    this.artist = const Value.absent(),
    this.album = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.isVideo = const Value.absent(),
    this.isLiked = const Value.absent(),
    this.isMissing = const Value.absent(),
    this.playCount = const Value.absent(),
    this.lastPlayedAt = const Value.absent(),
    this.dateAdded = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SongsCompanion.insert({
    required String id,
    required String filePath,
    required String title,
    required String artist,
    required String album,
    required int durationMs,
    this.isVideo = const Value.absent(),
    this.isLiked = const Value.absent(),
    this.isMissing = const Value.absent(),
    this.playCount = const Value.absent(),
    this.lastPlayedAt = const Value.absent(),
    this.dateAdded = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       filePath = Value(filePath),
       title = Value(title),
       artist = Value(artist),
       album = Value(album),
       durationMs = Value(durationMs);
  static Insertable<SongRow> custom({
    Expression<String>? id,
    Expression<String>? filePath,
    Expression<String>? title,
    Expression<String>? artist,
    Expression<String>? album,
    Expression<int>? durationMs,
    Expression<bool>? isVideo,
    Expression<bool>? isLiked,
    Expression<bool>? isMissing,
    Expression<int>? playCount,
    Expression<DateTime>? lastPlayedAt,
    Expression<DateTime>? dateAdded,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (filePath != null) 'file_path': filePath,
      if (title != null) 'title': title,
      if (artist != null) 'artist': artist,
      if (album != null) 'album': album,
      if (durationMs != null) 'duration_ms': durationMs,
      if (isVideo != null) 'is_video': isVideo,
      if (isLiked != null) 'is_liked': isLiked,
      if (isMissing != null) 'is_missing': isMissing,
      if (playCount != null) 'play_count': playCount,
      if (lastPlayedAt != null) 'last_played_at': lastPlayedAt,
      if (dateAdded != null) 'date_added': dateAdded,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SongsCompanion copyWith({
    Value<String>? id,
    Value<String>? filePath,
    Value<String>? title,
    Value<String>? artist,
    Value<String>? album,
    Value<int>? durationMs,
    Value<bool>? isVideo,
    Value<bool>? isLiked,
    Value<bool>? isMissing,
    Value<int>? playCount,
    Value<DateTime?>? lastPlayedAt,
    Value<DateTime?>? dateAdded,
    Value<int>? rowid,
  }) {
    return SongsCompanion(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      durationMs: durationMs ?? this.durationMs,
      isVideo: isVideo ?? this.isVideo,
      isLiked: isLiked ?? this.isLiked,
      isMissing: isMissing ?? this.isMissing,
      playCount: playCount ?? this.playCount,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      dateAdded: dateAdded ?? this.dateAdded,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (artist.present) {
      map['artist'] = Variable<String>(artist.value);
    }
    if (album.present) {
      map['album'] = Variable<String>(album.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (isVideo.present) {
      map['is_video'] = Variable<bool>(isVideo.value);
    }
    if (isLiked.present) {
      map['is_liked'] = Variable<bool>(isLiked.value);
    }
    if (isMissing.present) {
      map['is_missing'] = Variable<bool>(isMissing.value);
    }
    if (playCount.present) {
      map['play_count'] = Variable<int>(playCount.value);
    }
    if (lastPlayedAt.present) {
      map['last_played_at'] = Variable<DateTime>(lastPlayedAt.value);
    }
    if (dateAdded.present) {
      map['date_added'] = Variable<DateTime>(dateAdded.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SongsCompanion(')
          ..write('id: $id, ')
          ..write('filePath: $filePath, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('album: $album, ')
          ..write('durationMs: $durationMs, ')
          ..write('isVideo: $isVideo, ')
          ..write('isLiked: $isLiked, ')
          ..write('isMissing: $isMissing, ')
          ..write('playCount: $playCount, ')
          ..write('lastPlayedAt: $lastPlayedAt, ')
          ..write('dateAdded: $dateAdded, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SongVibesTable extends SongVibes
    with TableInfo<$SongVibesTable, SongVibeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SongVibesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _songIdMeta = const VerificationMeta('songId');
  @override
  late final GeneratedColumn<String> songId = GeneratedColumn<String>(
    'song_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vibeTagIdMeta = const VerificationMeta(
    'vibeTagId',
  );
  @override
  late final GeneratedColumn<String> vibeTagId = GeneratedColumn<String>(
    'vibe_tag_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [songId, vibeTagId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'song_vibes';
  @override
  VerificationContext validateIntegrity(
    Insertable<SongVibeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('song_id')) {
      context.handle(
        _songIdMeta,
        songId.isAcceptableOrUnknown(data['song_id']!, _songIdMeta),
      );
    } else if (isInserting) {
      context.missing(_songIdMeta);
    }
    if (data.containsKey('vibe_tag_id')) {
      context.handle(
        _vibeTagIdMeta,
        vibeTagId.isAcceptableOrUnknown(data['vibe_tag_id']!, _vibeTagIdMeta),
      );
    } else if (isInserting) {
      context.missing(_vibeTagIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {songId, vibeTagId};
  @override
  SongVibeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SongVibeRow(
      songId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}song_id'],
      )!,
      vibeTagId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vibe_tag_id'],
      )!,
    );
  }

  @override
  $SongVibesTable createAlias(String alias) {
    return $SongVibesTable(attachedDatabase, alias);
  }
}

class SongVibeRow extends DataClass implements Insertable<SongVibeRow> {
  final String songId;
  final String vibeTagId;
  const SongVibeRow({required this.songId, required this.vibeTagId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['song_id'] = Variable<String>(songId);
    map['vibe_tag_id'] = Variable<String>(vibeTagId);
    return map;
  }

  SongVibesCompanion toCompanion(bool nullToAbsent) {
    return SongVibesCompanion(
      songId: Value(songId),
      vibeTagId: Value(vibeTagId),
    );
  }

  factory SongVibeRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SongVibeRow(
      songId: serializer.fromJson<String>(json['songId']),
      vibeTagId: serializer.fromJson<String>(json['vibeTagId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'songId': serializer.toJson<String>(songId),
      'vibeTagId': serializer.toJson<String>(vibeTagId),
    };
  }

  SongVibeRow copyWith({String? songId, String? vibeTagId}) => SongVibeRow(
    songId: songId ?? this.songId,
    vibeTagId: vibeTagId ?? this.vibeTagId,
  );
  SongVibeRow copyWithCompanion(SongVibesCompanion data) {
    return SongVibeRow(
      songId: data.songId.present ? data.songId.value : this.songId,
      vibeTagId: data.vibeTagId.present ? data.vibeTagId.value : this.vibeTagId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SongVibeRow(')
          ..write('songId: $songId, ')
          ..write('vibeTagId: $vibeTagId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(songId, vibeTagId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SongVibeRow &&
          other.songId == this.songId &&
          other.vibeTagId == this.vibeTagId);
}

class SongVibesCompanion extends UpdateCompanion<SongVibeRow> {
  final Value<String> songId;
  final Value<String> vibeTagId;
  final Value<int> rowid;
  const SongVibesCompanion({
    this.songId = const Value.absent(),
    this.vibeTagId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SongVibesCompanion.insert({
    required String songId,
    required String vibeTagId,
    this.rowid = const Value.absent(),
  }) : songId = Value(songId),
       vibeTagId = Value(vibeTagId);
  static Insertable<SongVibeRow> custom({
    Expression<String>? songId,
    Expression<String>? vibeTagId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (songId != null) 'song_id': songId,
      if (vibeTagId != null) 'vibe_tag_id': vibeTagId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SongVibesCompanion copyWith({
    Value<String>? songId,
    Value<String>? vibeTagId,
    Value<int>? rowid,
  }) {
    return SongVibesCompanion(
      songId: songId ?? this.songId,
      vibeTagId: vibeTagId ?? this.vibeTagId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (songId.present) {
      map['song_id'] = Variable<String>(songId.value);
    }
    if (vibeTagId.present) {
      map['vibe_tag_id'] = Variable<String>(vibeTagId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SongVibesCompanion(')
          ..write('songId: $songId, ')
          ..write('vibeTagId: $vibeTagId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GameScoresTable extends GameScores
    with TableInfo<$GameScoresTable, GameScoreRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GameScoresTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _songIdMeta = const VerificationMeta('songId');
  @override
  late final GeneratedColumn<String> songId = GeneratedColumn<String>(
    'song_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _highScoreMeta = const VerificationMeta(
    'highScore',
  );
  @override
  late final GeneratedColumn<int> highScore = GeneratedColumn<int>(
    'high_score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _maxComboMeta = const VerificationMeta(
    'maxCombo',
  );
  @override
  late final GeneratedColumn<int> maxCombo = GeneratedColumn<int>(
    'max_combo',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _playCountMeta = const VerificationMeta(
    'playCount',
  );
  @override
  late final GeneratedColumn<int> playCount = GeneratedColumn<int>(
    'play_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    songId,
    highScore,
    maxCombo,
    playCount,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'game_scores';
  @override
  VerificationContext validateIntegrity(
    Insertable<GameScoreRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('song_id')) {
      context.handle(
        _songIdMeta,
        songId.isAcceptableOrUnknown(data['song_id']!, _songIdMeta),
      );
    } else if (isInserting) {
      context.missing(_songIdMeta);
    }
    if (data.containsKey('high_score')) {
      context.handle(
        _highScoreMeta,
        highScore.isAcceptableOrUnknown(data['high_score']!, _highScoreMeta),
      );
    }
    if (data.containsKey('max_combo')) {
      context.handle(
        _maxComboMeta,
        maxCombo.isAcceptableOrUnknown(data['max_combo']!, _maxComboMeta),
      );
    }
    if (data.containsKey('play_count')) {
      context.handle(
        _playCountMeta,
        playCount.isAcceptableOrUnknown(data['play_count']!, _playCountMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {songId};
  @override
  GameScoreRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GameScoreRow(
      songId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}song_id'],
      )!,
      highScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}high_score'],
      )!,
      maxCombo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_combo'],
      )!,
      playCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}play_count'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $GameScoresTable createAlias(String alias) {
    return $GameScoresTable(attachedDatabase, alias);
  }
}

class GameScoreRow extends DataClass implements Insertable<GameScoreRow> {
  final String songId;
  final int highScore;
  final int maxCombo;

  /// How many times rhythm mode has been played through on this song.
  final int playCount;
  final DateTime updatedAt;
  const GameScoreRow({
    required this.songId,
    required this.highScore,
    required this.maxCombo,
    required this.playCount,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['song_id'] = Variable<String>(songId);
    map['high_score'] = Variable<int>(highScore);
    map['max_combo'] = Variable<int>(maxCombo);
    map['play_count'] = Variable<int>(playCount);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  GameScoresCompanion toCompanion(bool nullToAbsent) {
    return GameScoresCompanion(
      songId: Value(songId),
      highScore: Value(highScore),
      maxCombo: Value(maxCombo),
      playCount: Value(playCount),
      updatedAt: Value(updatedAt),
    );
  }

  factory GameScoreRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GameScoreRow(
      songId: serializer.fromJson<String>(json['songId']),
      highScore: serializer.fromJson<int>(json['highScore']),
      maxCombo: serializer.fromJson<int>(json['maxCombo']),
      playCount: serializer.fromJson<int>(json['playCount']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'songId': serializer.toJson<String>(songId),
      'highScore': serializer.toJson<int>(highScore),
      'maxCombo': serializer.toJson<int>(maxCombo),
      'playCount': serializer.toJson<int>(playCount),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  GameScoreRow copyWith({
    String? songId,
    int? highScore,
    int? maxCombo,
    int? playCount,
    DateTime? updatedAt,
  }) => GameScoreRow(
    songId: songId ?? this.songId,
    highScore: highScore ?? this.highScore,
    maxCombo: maxCombo ?? this.maxCombo,
    playCount: playCount ?? this.playCount,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  GameScoreRow copyWithCompanion(GameScoresCompanion data) {
    return GameScoreRow(
      songId: data.songId.present ? data.songId.value : this.songId,
      highScore: data.highScore.present ? data.highScore.value : this.highScore,
      maxCombo: data.maxCombo.present ? data.maxCombo.value : this.maxCombo,
      playCount: data.playCount.present ? data.playCount.value : this.playCount,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GameScoreRow(')
          ..write('songId: $songId, ')
          ..write('highScore: $highScore, ')
          ..write('maxCombo: $maxCombo, ')
          ..write('playCount: $playCount, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(songId, highScore, maxCombo, playCount, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GameScoreRow &&
          other.songId == this.songId &&
          other.highScore == this.highScore &&
          other.maxCombo == this.maxCombo &&
          other.playCount == this.playCount &&
          other.updatedAt == this.updatedAt);
}

class GameScoresCompanion extends UpdateCompanion<GameScoreRow> {
  final Value<String> songId;
  final Value<int> highScore;
  final Value<int> maxCombo;
  final Value<int> playCount;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const GameScoresCompanion({
    this.songId = const Value.absent(),
    this.highScore = const Value.absent(),
    this.maxCombo = const Value.absent(),
    this.playCount = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GameScoresCompanion.insert({
    required String songId,
    this.highScore = const Value.absent(),
    this.maxCombo = const Value.absent(),
    this.playCount = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : songId = Value(songId),
       updatedAt = Value(updatedAt);
  static Insertable<GameScoreRow> custom({
    Expression<String>? songId,
    Expression<int>? highScore,
    Expression<int>? maxCombo,
    Expression<int>? playCount,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (songId != null) 'song_id': songId,
      if (highScore != null) 'high_score': highScore,
      if (maxCombo != null) 'max_combo': maxCombo,
      if (playCount != null) 'play_count': playCount,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GameScoresCompanion copyWith({
    Value<String>? songId,
    Value<int>? highScore,
    Value<int>? maxCombo,
    Value<int>? playCount,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return GameScoresCompanion(
      songId: songId ?? this.songId,
      highScore: highScore ?? this.highScore,
      maxCombo: maxCombo ?? this.maxCombo,
      playCount: playCount ?? this.playCount,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (songId.present) {
      map['song_id'] = Variable<String>(songId.value);
    }
    if (highScore.present) {
      map['high_score'] = Variable<int>(highScore.value);
    }
    if (maxCombo.present) {
      map['max_combo'] = Variable<int>(maxCombo.value);
    }
    if (playCount.present) {
      map['play_count'] = Variable<int>(playCount.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GameScoresCompanion(')
          ..write('songId: $songId, ')
          ..write('highScore: $highScore, ')
          ..write('maxCombo: $maxCombo, ')
          ..write('playCount: $playCount, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlaylistsTable extends Playlists
    with TableInfo<$PlaylistsTable, PlaylistRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaylistsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _isAutoGeneratedMeta = const VerificationMeta(
    'isAutoGenerated',
  );
  @override
  late final GeneratedColumn<bool> isAutoGenerated = GeneratedColumn<bool>(
    'is_auto_generated',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_auto_generated" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sourceVibeTagIdMeta = const VerificationMeta(
    'sourceVibeTagId',
  );
  @override
  late final GeneratedColumn<String> sourceVibeTagId = GeneratedColumn<String>(
    'source_vibe_tag_id',
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
  static const VerificationMeta _coverImagePathMeta = const VerificationMeta(
    'coverImagePath',
  );
  @override
  late final GeneratedColumn<String> coverImagePath = GeneratedColumn<String>(
    'cover_image_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    isAutoGenerated,
    sourceVibeTagId,
    createdAt,
    coverImagePath,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playlists';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlaylistRow> instance, {
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
    if (data.containsKey('is_auto_generated')) {
      context.handle(
        _isAutoGeneratedMeta,
        isAutoGenerated.isAcceptableOrUnknown(
          data['is_auto_generated']!,
          _isAutoGeneratedMeta,
        ),
      );
    }
    if (data.containsKey('source_vibe_tag_id')) {
      context.handle(
        _sourceVibeTagIdMeta,
        sourceVibeTagId.isAcceptableOrUnknown(
          data['source_vibe_tag_id']!,
          _sourceVibeTagIdMeta,
        ),
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
    if (data.containsKey('cover_image_path')) {
      context.handle(
        _coverImagePathMeta,
        coverImagePath.isAcceptableOrUnknown(
          data['cover_image_path']!,
          _coverImagePathMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlaylistRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaylistRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      isAutoGenerated: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_auto_generated'],
      )!,
      sourceVibeTagId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_vibe_tag_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      coverImagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_image_path'],
      ),
    );
  }

  @override
  $PlaylistsTable createAlias(String alias) {
    return $PlaylistsTable(attachedDatabase, alias);
  }
}

class PlaylistRow extends DataClass implements Insertable<PlaylistRow> {
  final String id;
  final String name;
  final bool isAutoGenerated;
  final String? sourceVibeTagId;
  final DateTime createdAt;
  final String? coverImagePath;
  const PlaylistRow({
    required this.id,
    required this.name,
    required this.isAutoGenerated,
    this.sourceVibeTagId,
    required this.createdAt,
    this.coverImagePath,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['is_auto_generated'] = Variable<bool>(isAutoGenerated);
    if (!nullToAbsent || sourceVibeTagId != null) {
      map['source_vibe_tag_id'] = Variable<String>(sourceVibeTagId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || coverImagePath != null) {
      map['cover_image_path'] = Variable<String>(coverImagePath);
    }
    return map;
  }

  PlaylistsCompanion toCompanion(bool nullToAbsent) {
    return PlaylistsCompanion(
      id: Value(id),
      name: Value(name),
      isAutoGenerated: Value(isAutoGenerated),
      sourceVibeTagId: sourceVibeTagId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceVibeTagId),
      createdAt: Value(createdAt),
      coverImagePath: coverImagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(coverImagePath),
    );
  }

  factory PlaylistRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaylistRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      isAutoGenerated: serializer.fromJson<bool>(json['isAutoGenerated']),
      sourceVibeTagId: serializer.fromJson<String?>(json['sourceVibeTagId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      coverImagePath: serializer.fromJson<String?>(json['coverImagePath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'isAutoGenerated': serializer.toJson<bool>(isAutoGenerated),
      'sourceVibeTagId': serializer.toJson<String?>(sourceVibeTagId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'coverImagePath': serializer.toJson<String?>(coverImagePath),
    };
  }

  PlaylistRow copyWith({
    String? id,
    String? name,
    bool? isAutoGenerated,
    Value<String?> sourceVibeTagId = const Value.absent(),
    DateTime? createdAt,
    Value<String?> coverImagePath = const Value.absent(),
  }) => PlaylistRow(
    id: id ?? this.id,
    name: name ?? this.name,
    isAutoGenerated: isAutoGenerated ?? this.isAutoGenerated,
    sourceVibeTagId: sourceVibeTagId.present
        ? sourceVibeTagId.value
        : this.sourceVibeTagId,
    createdAt: createdAt ?? this.createdAt,
    coverImagePath: coverImagePath.present
        ? coverImagePath.value
        : this.coverImagePath,
  );
  PlaylistRow copyWithCompanion(PlaylistsCompanion data) {
    return PlaylistRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      isAutoGenerated: data.isAutoGenerated.present
          ? data.isAutoGenerated.value
          : this.isAutoGenerated,
      sourceVibeTagId: data.sourceVibeTagId.present
          ? data.sourceVibeTagId.value
          : this.sourceVibeTagId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      coverImagePath: data.coverImagePath.present
          ? data.coverImagePath.value
          : this.coverImagePath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isAutoGenerated: $isAutoGenerated, ')
          ..write('sourceVibeTagId: $sourceVibeTagId, ')
          ..write('createdAt: $createdAt, ')
          ..write('coverImagePath: $coverImagePath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    isAutoGenerated,
    sourceVibeTagId,
    createdAt,
    coverImagePath,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaylistRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.isAutoGenerated == this.isAutoGenerated &&
          other.sourceVibeTagId == this.sourceVibeTagId &&
          other.createdAt == this.createdAt &&
          other.coverImagePath == this.coverImagePath);
}

class PlaylistsCompanion extends UpdateCompanion<PlaylistRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<bool> isAutoGenerated;
  final Value<String?> sourceVibeTagId;
  final Value<DateTime> createdAt;
  final Value<String?> coverImagePath;
  final Value<int> rowid;
  const PlaylistsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.isAutoGenerated = const Value.absent(),
    this.sourceVibeTagId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.coverImagePath = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlaylistsCompanion.insert({
    required String id,
    required String name,
    this.isAutoGenerated = const Value.absent(),
    this.sourceVibeTagId = const Value.absent(),
    required DateTime createdAt,
    this.coverImagePath = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<PlaylistRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<bool>? isAutoGenerated,
    Expression<String>? sourceVibeTagId,
    Expression<DateTime>? createdAt,
    Expression<String>? coverImagePath,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (isAutoGenerated != null) 'is_auto_generated': isAutoGenerated,
      if (sourceVibeTagId != null) 'source_vibe_tag_id': sourceVibeTagId,
      if (createdAt != null) 'created_at': createdAt,
      if (coverImagePath != null) 'cover_image_path': coverImagePath,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlaylistsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<bool>? isAutoGenerated,
    Value<String?>? sourceVibeTagId,
    Value<DateTime>? createdAt,
    Value<String?>? coverImagePath,
    Value<int>? rowid,
  }) {
    return PlaylistsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      isAutoGenerated: isAutoGenerated ?? this.isAutoGenerated,
      sourceVibeTagId: sourceVibeTagId ?? this.sourceVibeTagId,
      createdAt: createdAt ?? this.createdAt,
      coverImagePath: coverImagePath ?? this.coverImagePath,
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
    if (isAutoGenerated.present) {
      map['is_auto_generated'] = Variable<bool>(isAutoGenerated.value);
    }
    if (sourceVibeTagId.present) {
      map['source_vibe_tag_id'] = Variable<String>(sourceVibeTagId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (coverImagePath.present) {
      map['cover_image_path'] = Variable<String>(coverImagePath.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isAutoGenerated: $isAutoGenerated, ')
          ..write('sourceVibeTagId: $sourceVibeTagId, ')
          ..write('createdAt: $createdAt, ')
          ..write('coverImagePath: $coverImagePath, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlaylistSongsTable extends PlaylistSongs
    with TableInfo<$PlaylistSongsTable, PlaylistSongRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaylistSongsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _playlistIdMeta = const VerificationMeta(
    'playlistId',
  );
  @override
  late final GeneratedColumn<String> playlistId = GeneratedColumn<String>(
    'playlist_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _songIdMeta = const VerificationMeta('songId');
  @override
  late final GeneratedColumn<String> songId = GeneratedColumn<String>(
    'song_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [playlistId, songId, position];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playlist_songs';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlaylistSongRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('playlist_id')) {
      context.handle(
        _playlistIdMeta,
        playlistId.isAcceptableOrUnknown(data['playlist_id']!, _playlistIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playlistIdMeta);
    }
    if (data.containsKey('song_id')) {
      context.handle(
        _songIdMeta,
        songId.isAcceptableOrUnknown(data['song_id']!, _songIdMeta),
      );
    } else if (isInserting) {
      context.missing(_songIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {playlistId, songId};
  @override
  PlaylistSongRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaylistSongRow(
      playlistId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}playlist_id'],
      )!,
      songId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}song_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $PlaylistSongsTable createAlias(String alias) {
    return $PlaylistSongsTable(attachedDatabase, alias);
  }
}

class PlaylistSongRow extends DataClass implements Insertable<PlaylistSongRow> {
  final String playlistId;
  final String songId;
  final int position;
  const PlaylistSongRow({
    required this.playlistId,
    required this.songId,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['playlist_id'] = Variable<String>(playlistId);
    map['song_id'] = Variable<String>(songId);
    map['position'] = Variable<int>(position);
    return map;
  }

  PlaylistSongsCompanion toCompanion(bool nullToAbsent) {
    return PlaylistSongsCompanion(
      playlistId: Value(playlistId),
      songId: Value(songId),
      position: Value(position),
    );
  }

  factory PlaylistSongRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaylistSongRow(
      playlistId: serializer.fromJson<String>(json['playlistId']),
      songId: serializer.fromJson<String>(json['songId']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'playlistId': serializer.toJson<String>(playlistId),
      'songId': serializer.toJson<String>(songId),
      'position': serializer.toJson<int>(position),
    };
  }

  PlaylistSongRow copyWith({
    String? playlistId,
    String? songId,
    int? position,
  }) => PlaylistSongRow(
    playlistId: playlistId ?? this.playlistId,
    songId: songId ?? this.songId,
    position: position ?? this.position,
  );
  PlaylistSongRow copyWithCompanion(PlaylistSongsCompanion data) {
    return PlaylistSongRow(
      playlistId: data.playlistId.present
          ? data.playlistId.value
          : this.playlistId,
      songId: data.songId.present ? data.songId.value : this.songId,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistSongRow(')
          ..write('playlistId: $playlistId, ')
          ..write('songId: $songId, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(playlistId, songId, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaylistSongRow &&
          other.playlistId == this.playlistId &&
          other.songId == this.songId &&
          other.position == this.position);
}

class PlaylistSongsCompanion extends UpdateCompanion<PlaylistSongRow> {
  final Value<String> playlistId;
  final Value<String> songId;
  final Value<int> position;
  final Value<int> rowid;
  const PlaylistSongsCompanion({
    this.playlistId = const Value.absent(),
    this.songId = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlaylistSongsCompanion.insert({
    required String playlistId,
    required String songId,
    required int position,
    this.rowid = const Value.absent(),
  }) : playlistId = Value(playlistId),
       songId = Value(songId),
       position = Value(position);
  static Insertable<PlaylistSongRow> custom({
    Expression<String>? playlistId,
    Expression<String>? songId,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (playlistId != null) 'playlist_id': playlistId,
      if (songId != null) 'song_id': songId,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlaylistSongsCompanion copyWith({
    Value<String>? playlistId,
    Value<String>? songId,
    Value<int>? position,
    Value<int>? rowid,
  }) {
    return PlaylistSongsCompanion(
      playlistId: playlistId ?? this.playlistId,
      songId: songId ?? this.songId,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (playlistId.present) {
      map['playlist_id'] = Variable<String>(playlistId.value);
    }
    if (songId.present) {
      map['song_id'] = Variable<String>(songId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistSongsCompanion(')
          ..write('playlistId: $playlistId, ')
          ..write('songId: $songId, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EqualizerPresetsTable extends EqualizerPresets
    with TableInfo<$EqualizerPresetsTable, EqualizerPresetRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EqualizerPresetsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _bandLevelsJsonMeta = const VerificationMeta(
    'bandLevelsJson',
  );
  @override
  late final GeneratedColumn<String> bandLevelsJson = GeneratedColumn<String>(
    'band_levels_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, bandLevelsJson];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'equalizer_presets';
  @override
  VerificationContext validateIntegrity(
    Insertable<EqualizerPresetRow> instance, {
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
    if (data.containsKey('band_levels_json')) {
      context.handle(
        _bandLevelsJsonMeta,
        bandLevelsJson.isAcceptableOrUnknown(
          data['band_levels_json']!,
          _bandLevelsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_bandLevelsJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EqualizerPresetRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EqualizerPresetRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      bandLevelsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}band_levels_json'],
      )!,
    );
  }

  @override
  $EqualizerPresetsTable createAlias(String alias) {
    return $EqualizerPresetsTable(attachedDatabase, alias);
  }
}

class EqualizerPresetRow extends DataClass
    implements Insertable<EqualizerPresetRow> {
  final String id;
  final String name;

  /// JSON-encoded `List<double>` of gains in decibels, one per band.
  final String bandLevelsJson;
  const EqualizerPresetRow({
    required this.id,
    required this.name,
    required this.bandLevelsJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['band_levels_json'] = Variable<String>(bandLevelsJson);
    return map;
  }

  EqualizerPresetsCompanion toCompanion(bool nullToAbsent) {
    return EqualizerPresetsCompanion(
      id: Value(id),
      name: Value(name),
      bandLevelsJson: Value(bandLevelsJson),
    );
  }

  factory EqualizerPresetRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EqualizerPresetRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      bandLevelsJson: serializer.fromJson<String>(json['bandLevelsJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'bandLevelsJson': serializer.toJson<String>(bandLevelsJson),
    };
  }

  EqualizerPresetRow copyWith({
    String? id,
    String? name,
    String? bandLevelsJson,
  }) => EqualizerPresetRow(
    id: id ?? this.id,
    name: name ?? this.name,
    bandLevelsJson: bandLevelsJson ?? this.bandLevelsJson,
  );
  EqualizerPresetRow copyWithCompanion(EqualizerPresetsCompanion data) {
    return EqualizerPresetRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      bandLevelsJson: data.bandLevelsJson.present
          ? data.bandLevelsJson.value
          : this.bandLevelsJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EqualizerPresetRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('bandLevelsJson: $bandLevelsJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, bandLevelsJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EqualizerPresetRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.bandLevelsJson == this.bandLevelsJson);
}

class EqualizerPresetsCompanion extends UpdateCompanion<EqualizerPresetRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> bandLevelsJson;
  final Value<int> rowid;
  const EqualizerPresetsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.bandLevelsJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EqualizerPresetsCompanion.insert({
    required String id,
    required String name,
    required String bandLevelsJson,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       bandLevelsJson = Value(bandLevelsJson);
  static Insertable<EqualizerPresetRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? bandLevelsJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (bandLevelsJson != null) 'band_levels_json': bandLevelsJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EqualizerPresetsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? bandLevelsJson,
    Value<int>? rowid,
  }) {
    return EqualizerPresetsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      bandLevelsJson: bandLevelsJson ?? this.bandLevelsJson,
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
    if (bandLevelsJson.present) {
      map['band_levels_json'] = Variable<String>(bandLevelsJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EqualizerPresetsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('bandLevelsJson: $bandLevelsJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings
    with TableInfo<$SettingsTable, SettingsRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _adaptiveDarkModeEnabledMeta =
      const VerificationMeta('adaptiveDarkModeEnabled');
  @override
  late final GeneratedColumn<bool> adaptiveDarkModeEnabled =
      GeneratedColumn<bool>(
        'adaptive_dark_mode_enabled',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("adaptive_dark_mode_enabled" IN (0, 1))',
        ),
        defaultValue: const Constant(true),
      );
  static const VerificationMeta _manualThemeOverrideMeta =
      const VerificationMeta('manualThemeOverride');
  @override
  late final GeneratedColumn<String> manualThemeOverride =
      GeneratedColumn<String>(
        'manual_theme_override',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _themeSeedColorHexMeta = const VerificationMeta(
    'themeSeedColorHex',
  );
  @override
  late final GeneratedColumn<String> themeSeedColorHex =
      GeneratedColumn<String>(
        'theme_seed_color_hex',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('#673AB7'),
      );
  static const VerificationMeta _visualizerColorHexMeta =
      const VerificationMeta('visualizerColorHex');
  @override
  late final GeneratedColumn<String> visualizerColorHex =
      GeneratedColumn<String>(
        'visualizer_color_hex',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('#673AB7'),
      );
  static const VerificationMeta _crossfadeEnabledMeta = const VerificationMeta(
    'crossfadeEnabled',
  );
  @override
  late final GeneratedColumn<bool> crossfadeEnabled = GeneratedColumn<bool>(
    'crossfade_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("crossfade_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _crossfadeDurationMsMeta =
      const VerificationMeta('crossfadeDurationMs');
  @override
  late final GeneratedColumn<int> crossfadeDurationMs = GeneratedColumn<int>(
    'crossfade_duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3000),
  );
  static const VerificationMeta _currentEqualizerPresetIdMeta =
      const VerificationMeta('currentEqualizerPresetId');
  @override
  late final GeneratedColumn<String> currentEqualizerPresetId =
      GeneratedColumn<String>(
        'current_equalizer_preset_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _visualizerStyleMeta = const VerificationMeta(
    'visualizerStyle',
  );
  @override
  late final GeneratedColumn<String> visualizerStyle = GeneratedColumn<String>(
    'visualizer_style',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('bars'),
  );
  static const VerificationMeta _showAlbumArtInMiniPlayerMeta =
      const VerificationMeta('showAlbumArtInMiniPlayer');
  @override
  late final GeneratedColumn<bool> showAlbumArtInMiniPlayer =
      GeneratedColumn<bool>(
        'show_album_art_in_mini_player',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("show_album_art_in_mini_player" IN (0, 1))',
        ),
        defaultValue: const Constant(true),
      );
  static const VerificationMeta _showVisualizerInMiniPlayerMeta =
      const VerificationMeta('showVisualizerInMiniPlayer');
  @override
  late final GeneratedColumn<bool> showVisualizerInMiniPlayer =
      GeneratedColumn<bool>(
        'show_visualizer_in_mini_player',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("show_visualizer_in_mini_player" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _showAlbumArtInNowPlayingMeta =
      const VerificationMeta('showAlbumArtInNowPlaying');
  @override
  late final GeneratedColumn<bool> showAlbumArtInNowPlaying =
      GeneratedColumn<bool>(
        'show_album_art_in_now_playing',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("show_album_art_in_now_playing" IN (0, 1))',
        ),
        defaultValue: const Constant(true),
      );
  static const VerificationMeta _visualizerPlacementMeta =
      const VerificationMeta('visualizerPlacement');
  @override
  late final GeneratedColumn<String> visualizerPlacement =
      GeneratedColumn<String>(
        'visualizer_placement',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('belowControls'),
      );
  static const VerificationMeta _visualizerAsArtworkFallbackMeta =
      const VerificationMeta('visualizerAsArtworkFallback');
  @override
  late final GeneratedColumn<bool> visualizerAsArtworkFallback =
      GeneratedColumn<bool>(
        'visualizer_as_artwork_fallback',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("visualizer_as_artwork_fallback" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _visualizerSensitivityMeta =
      const VerificationMeta('visualizerSensitivity');
  @override
  late final GeneratedColumn<double> visualizerSensitivity =
      GeneratedColumn<double>(
        'visualizer_sensitivity',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(1.0),
      );
  static const VerificationMeta _visualizerContrastMeta =
      const VerificationMeta('visualizerContrast');
  @override
  late final GeneratedColumn<double> visualizerContrast =
      GeneratedColumn<double>(
        'visualizer_contrast',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(1.0),
      );
  static const VerificationMeta _visualizerFloorMeta = const VerificationMeta(
    'visualizerFloor',
  );
  @override
  late final GeneratedColumn<double> visualizerFloor = GeneratedColumn<double>(
    'visualizer_floor',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.12),
  );
  static const VerificationMeta _visualizerResponsivenessMeta =
      const VerificationMeta('visualizerResponsiveness');
  @override
  late final GeneratedColumn<double> visualizerResponsiveness =
      GeneratedColumn<double>(
        'visualizer_responsiveness',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0.5),
      );
  static const VerificationMeta _visualizerBarCountMeta =
      const VerificationMeta('visualizerBarCount');
  @override
  late final GeneratedColumn<int> visualizerBarCount = GeneratedColumn<int>(
    'visualizer_bar_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(40),
  );
  static const VerificationMeta _seekStepSecondsMeta = const VerificationMeta(
    'seekStepSeconds',
  );
  @override
  late final GeneratedColumn<int> seekStepSeconds = GeneratedColumn<int>(
    'seek_step_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(10),
  );
  static const VerificationMeta _includeVideosMeta = const VerificationMeta(
    'includeVideos',
  );
  @override
  late final GeneratedColumn<bool> includeVideos = GeneratedColumn<bool>(
    'include_videos',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("include_videos" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _realVisualizerEnabledMeta =
      const VerificationMeta('realVisualizerEnabled');
  @override
  late final GeneratedColumn<bool> realVisualizerEnabled =
      GeneratedColumn<bool>(
        'real_visualizer_enabled',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("real_visualizer_enabled" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _autoExcludeNonMusicFoldersMeta =
      const VerificationMeta('autoExcludeNonMusicFolders');
  @override
  late final GeneratedColumn<bool> autoExcludeNonMusicFolders =
      GeneratedColumn<bool>(
        'auto_exclude_non_music_folders',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("auto_exclude_non_music_folders" IN (0, 1))',
        ),
        defaultValue: const Constant(true),
      );
  static const VerificationMeta _minimumTrackSecondsMeta =
      const VerificationMeta('minimumTrackSeconds');
  @override
  late final GeneratedColumn<int> minimumTrackSeconds = GeneratedColumn<int>(
    'minimum_track_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(30),
  );
  static const VerificationMeta _libraryFolderOverridesJsonMeta =
      const VerificationMeta('libraryFolderOverridesJson');
  @override
  late final GeneratedColumn<String> libraryFolderOverridesJson =
      GeneratedColumn<String>(
        'library_folder_overrides_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('{}'),
      );
  static const VerificationMeta _compactNowPlayingMeta = const VerificationMeta(
    'compactNowPlaying',
  );
  @override
  late final GeneratedColumn<bool> compactNowPlaying = GeneratedColumn<bool>(
    'compact_now_playing',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("compact_now_playing" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    adaptiveDarkModeEnabled,
    manualThemeOverride,
    themeSeedColorHex,
    visualizerColorHex,
    crossfadeEnabled,
    crossfadeDurationMs,
    currentEqualizerPresetId,
    visualizerStyle,
    showAlbumArtInMiniPlayer,
    showVisualizerInMiniPlayer,
    showAlbumArtInNowPlaying,
    visualizerPlacement,
    visualizerAsArtworkFallback,
    visualizerSensitivity,
    visualizerContrast,
    visualizerFloor,
    visualizerResponsiveness,
    visualizerBarCount,
    seekStepSeconds,
    includeVideos,
    realVisualizerEnabled,
    autoExcludeNonMusicFolders,
    minimumTrackSeconds,
    libraryFolderOverridesJson,
    compactNowPlaying,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingsRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('adaptive_dark_mode_enabled')) {
      context.handle(
        _adaptiveDarkModeEnabledMeta,
        adaptiveDarkModeEnabled.isAcceptableOrUnknown(
          data['adaptive_dark_mode_enabled']!,
          _adaptiveDarkModeEnabledMeta,
        ),
      );
    }
    if (data.containsKey('manual_theme_override')) {
      context.handle(
        _manualThemeOverrideMeta,
        manualThemeOverride.isAcceptableOrUnknown(
          data['manual_theme_override']!,
          _manualThemeOverrideMeta,
        ),
      );
    }
    if (data.containsKey('theme_seed_color_hex')) {
      context.handle(
        _themeSeedColorHexMeta,
        themeSeedColorHex.isAcceptableOrUnknown(
          data['theme_seed_color_hex']!,
          _themeSeedColorHexMeta,
        ),
      );
    }
    if (data.containsKey('visualizer_color_hex')) {
      context.handle(
        _visualizerColorHexMeta,
        visualizerColorHex.isAcceptableOrUnknown(
          data['visualizer_color_hex']!,
          _visualizerColorHexMeta,
        ),
      );
    }
    if (data.containsKey('crossfade_enabled')) {
      context.handle(
        _crossfadeEnabledMeta,
        crossfadeEnabled.isAcceptableOrUnknown(
          data['crossfade_enabled']!,
          _crossfadeEnabledMeta,
        ),
      );
    }
    if (data.containsKey('crossfade_duration_ms')) {
      context.handle(
        _crossfadeDurationMsMeta,
        crossfadeDurationMs.isAcceptableOrUnknown(
          data['crossfade_duration_ms']!,
          _crossfadeDurationMsMeta,
        ),
      );
    }
    if (data.containsKey('current_equalizer_preset_id')) {
      context.handle(
        _currentEqualizerPresetIdMeta,
        currentEqualizerPresetId.isAcceptableOrUnknown(
          data['current_equalizer_preset_id']!,
          _currentEqualizerPresetIdMeta,
        ),
      );
    }
    if (data.containsKey('visualizer_style')) {
      context.handle(
        _visualizerStyleMeta,
        visualizerStyle.isAcceptableOrUnknown(
          data['visualizer_style']!,
          _visualizerStyleMeta,
        ),
      );
    }
    if (data.containsKey('show_album_art_in_mini_player')) {
      context.handle(
        _showAlbumArtInMiniPlayerMeta,
        showAlbumArtInMiniPlayer.isAcceptableOrUnknown(
          data['show_album_art_in_mini_player']!,
          _showAlbumArtInMiniPlayerMeta,
        ),
      );
    }
    if (data.containsKey('show_visualizer_in_mini_player')) {
      context.handle(
        _showVisualizerInMiniPlayerMeta,
        showVisualizerInMiniPlayer.isAcceptableOrUnknown(
          data['show_visualizer_in_mini_player']!,
          _showVisualizerInMiniPlayerMeta,
        ),
      );
    }
    if (data.containsKey('show_album_art_in_now_playing')) {
      context.handle(
        _showAlbumArtInNowPlayingMeta,
        showAlbumArtInNowPlaying.isAcceptableOrUnknown(
          data['show_album_art_in_now_playing']!,
          _showAlbumArtInNowPlayingMeta,
        ),
      );
    }
    if (data.containsKey('visualizer_placement')) {
      context.handle(
        _visualizerPlacementMeta,
        visualizerPlacement.isAcceptableOrUnknown(
          data['visualizer_placement']!,
          _visualizerPlacementMeta,
        ),
      );
    }
    if (data.containsKey('visualizer_as_artwork_fallback')) {
      context.handle(
        _visualizerAsArtworkFallbackMeta,
        visualizerAsArtworkFallback.isAcceptableOrUnknown(
          data['visualizer_as_artwork_fallback']!,
          _visualizerAsArtworkFallbackMeta,
        ),
      );
    }
    if (data.containsKey('visualizer_sensitivity')) {
      context.handle(
        _visualizerSensitivityMeta,
        visualizerSensitivity.isAcceptableOrUnknown(
          data['visualizer_sensitivity']!,
          _visualizerSensitivityMeta,
        ),
      );
    }
    if (data.containsKey('visualizer_contrast')) {
      context.handle(
        _visualizerContrastMeta,
        visualizerContrast.isAcceptableOrUnknown(
          data['visualizer_contrast']!,
          _visualizerContrastMeta,
        ),
      );
    }
    if (data.containsKey('visualizer_floor')) {
      context.handle(
        _visualizerFloorMeta,
        visualizerFloor.isAcceptableOrUnknown(
          data['visualizer_floor']!,
          _visualizerFloorMeta,
        ),
      );
    }
    if (data.containsKey('visualizer_responsiveness')) {
      context.handle(
        _visualizerResponsivenessMeta,
        visualizerResponsiveness.isAcceptableOrUnknown(
          data['visualizer_responsiveness']!,
          _visualizerResponsivenessMeta,
        ),
      );
    }
    if (data.containsKey('visualizer_bar_count')) {
      context.handle(
        _visualizerBarCountMeta,
        visualizerBarCount.isAcceptableOrUnknown(
          data['visualizer_bar_count']!,
          _visualizerBarCountMeta,
        ),
      );
    }
    if (data.containsKey('seek_step_seconds')) {
      context.handle(
        _seekStepSecondsMeta,
        seekStepSeconds.isAcceptableOrUnknown(
          data['seek_step_seconds']!,
          _seekStepSecondsMeta,
        ),
      );
    }
    if (data.containsKey('include_videos')) {
      context.handle(
        _includeVideosMeta,
        includeVideos.isAcceptableOrUnknown(
          data['include_videos']!,
          _includeVideosMeta,
        ),
      );
    }
    if (data.containsKey('real_visualizer_enabled')) {
      context.handle(
        _realVisualizerEnabledMeta,
        realVisualizerEnabled.isAcceptableOrUnknown(
          data['real_visualizer_enabled']!,
          _realVisualizerEnabledMeta,
        ),
      );
    }
    if (data.containsKey('auto_exclude_non_music_folders')) {
      context.handle(
        _autoExcludeNonMusicFoldersMeta,
        autoExcludeNonMusicFolders.isAcceptableOrUnknown(
          data['auto_exclude_non_music_folders']!,
          _autoExcludeNonMusicFoldersMeta,
        ),
      );
    }
    if (data.containsKey('minimum_track_seconds')) {
      context.handle(
        _minimumTrackSecondsMeta,
        minimumTrackSeconds.isAcceptableOrUnknown(
          data['minimum_track_seconds']!,
          _minimumTrackSecondsMeta,
        ),
      );
    }
    if (data.containsKey('library_folder_overrides_json')) {
      context.handle(
        _libraryFolderOverridesJsonMeta,
        libraryFolderOverridesJson.isAcceptableOrUnknown(
          data['library_folder_overrides_json']!,
          _libraryFolderOverridesJsonMeta,
        ),
      );
    }
    if (data.containsKey('compact_now_playing')) {
      context.handle(
        _compactNowPlayingMeta,
        compactNowPlaying.isAcceptableOrUnknown(
          data['compact_now_playing']!,
          _compactNowPlayingMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SettingsRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingsRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      adaptiveDarkModeEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}adaptive_dark_mode_enabled'],
      )!,
      manualThemeOverride: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}manual_theme_override'],
      ),
      themeSeedColorHex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theme_seed_color_hex'],
      )!,
      visualizerColorHex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}visualizer_color_hex'],
      )!,
      crossfadeEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}crossfade_enabled'],
      )!,
      crossfadeDurationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}crossfade_duration_ms'],
      )!,
      currentEqualizerPresetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}current_equalizer_preset_id'],
      ),
      visualizerStyle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}visualizer_style'],
      )!,
      showAlbumArtInMiniPlayer: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}show_album_art_in_mini_player'],
      )!,
      showVisualizerInMiniPlayer: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}show_visualizer_in_mini_player'],
      )!,
      showAlbumArtInNowPlaying: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}show_album_art_in_now_playing'],
      )!,
      visualizerPlacement: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}visualizer_placement'],
      )!,
      visualizerAsArtworkFallback: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}visualizer_as_artwork_fallback'],
      )!,
      visualizerSensitivity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}visualizer_sensitivity'],
      )!,
      visualizerContrast: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}visualizer_contrast'],
      )!,
      visualizerFloor: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}visualizer_floor'],
      )!,
      visualizerResponsiveness: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}visualizer_responsiveness'],
      )!,
      visualizerBarCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}visualizer_bar_count'],
      )!,
      seekStepSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seek_step_seconds'],
      )!,
      includeVideos: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}include_videos'],
      )!,
      realVisualizerEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}real_visualizer_enabled'],
      )!,
      autoExcludeNonMusicFolders: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}auto_exclude_non_music_folders'],
      )!,
      minimumTrackSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}minimum_track_seconds'],
      )!,
      libraryFolderOverridesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}library_folder_overrides_json'],
      )!,
      compactNowPlaying: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}compact_now_playing'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class SettingsRow extends DataClass implements Insertable<SettingsRow> {
  final String id;
  final bool adaptiveDarkModeEnabled;
  final String? manualThemeOverride;
  final String themeSeedColorHex;
  final String visualizerColorHex;
  final bool crossfadeEnabled;
  final int crossfadeDurationMs;
  final String? currentEqualizerPresetId;
  final String visualizerStyle;
  final bool showAlbumArtInMiniPlayer;
  final bool showVisualizerInMiniPlayer;
  final bool showAlbumArtInNowPlaying;

  /// Where the visualizer sits on Now Playing — a [VisualizerPlacement] name.
  ///
  /// Supersedes the `show_visualizer_in_now_playing` boolean, which the v13
  /// migration reads once to seed this and then leaves behind: SQLite makes
  /// dropping a column awkward, and nothing reads it any more. Databases
  /// created from v13 on never have it.
  final String visualizerPlacement;

  /// Draw the visualizer where a song's artwork would go when that song has
  /// no artwork, rather than the generic music-note placeholder.
  final bool visualizerAsArtworkFallback;

  /// How the raw levels are shaped before they are drawn — see
  /// `VisualizerTuning`, which owns the meaning and the valid ranges.
  final double visualizerSensitivity;
  final double visualizerContrast;
  final double visualizerFloor;
  final double visualizerResponsiveness;
  final int visualizerBarCount;

  /// How far Now Playing's seek-back/forward buttons jump, in seconds.
  final int seekStepSeconds;

  /// Whether the library scan also picks up video files, played as audio.
  final bool includeVideos;

  /// Opt-in: drive the visualizer from the real audio signal rather than the
  /// simulated waveform. Off by default because it needs RECORD_AUDIO.
  final bool realVisualizerEnabled;

  /// Skip folders whose name says they hold voice notes, recordings, or
  /// ringtones rather than music — see `LibrarySourceFilter`.
  final bool autoExcludeNonMusicFolders;

  /// Audio shorter than this is not a track. 0 keeps everything.
  final int minimumTrackSeconds;

  /// The user's per-folder include/exclude decisions, as the JSON object
  /// `LibrarySourceFilter.overridesToJson` writes. One column rather than two
  /// because the two sets are only ever read and written together.
  final String libraryFolderOverridesJson;

  /// Show the stripped-back Now Playing layout — artwork, title, and the
  /// three transport buttons.
  final bool compactNowPlaying;
  const SettingsRow({
    required this.id,
    required this.adaptiveDarkModeEnabled,
    this.manualThemeOverride,
    required this.themeSeedColorHex,
    required this.visualizerColorHex,
    required this.crossfadeEnabled,
    required this.crossfadeDurationMs,
    this.currentEqualizerPresetId,
    required this.visualizerStyle,
    required this.showAlbumArtInMiniPlayer,
    required this.showVisualizerInMiniPlayer,
    required this.showAlbumArtInNowPlaying,
    required this.visualizerPlacement,
    required this.visualizerAsArtworkFallback,
    required this.visualizerSensitivity,
    required this.visualizerContrast,
    required this.visualizerFloor,
    required this.visualizerResponsiveness,
    required this.visualizerBarCount,
    required this.seekStepSeconds,
    required this.includeVideos,
    required this.realVisualizerEnabled,
    required this.autoExcludeNonMusicFolders,
    required this.minimumTrackSeconds,
    required this.libraryFolderOverridesJson,
    required this.compactNowPlaying,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['adaptive_dark_mode_enabled'] = Variable<bool>(adaptiveDarkModeEnabled);
    if (!nullToAbsent || manualThemeOverride != null) {
      map['manual_theme_override'] = Variable<String>(manualThemeOverride);
    }
    map['theme_seed_color_hex'] = Variable<String>(themeSeedColorHex);
    map['visualizer_color_hex'] = Variable<String>(visualizerColorHex);
    map['crossfade_enabled'] = Variable<bool>(crossfadeEnabled);
    map['crossfade_duration_ms'] = Variable<int>(crossfadeDurationMs);
    if (!nullToAbsent || currentEqualizerPresetId != null) {
      map['current_equalizer_preset_id'] = Variable<String>(
        currentEqualizerPresetId,
      );
    }
    map['visualizer_style'] = Variable<String>(visualizerStyle);
    map['show_album_art_in_mini_player'] = Variable<bool>(
      showAlbumArtInMiniPlayer,
    );
    map['show_visualizer_in_mini_player'] = Variable<bool>(
      showVisualizerInMiniPlayer,
    );
    map['show_album_art_in_now_playing'] = Variable<bool>(
      showAlbumArtInNowPlaying,
    );
    map['visualizer_placement'] = Variable<String>(visualizerPlacement);
    map['visualizer_as_artwork_fallback'] = Variable<bool>(
      visualizerAsArtworkFallback,
    );
    map['visualizer_sensitivity'] = Variable<double>(visualizerSensitivity);
    map['visualizer_contrast'] = Variable<double>(visualizerContrast);
    map['visualizer_floor'] = Variable<double>(visualizerFloor);
    map['visualizer_responsiveness'] = Variable<double>(
      visualizerResponsiveness,
    );
    map['visualizer_bar_count'] = Variable<int>(visualizerBarCount);
    map['seek_step_seconds'] = Variable<int>(seekStepSeconds);
    map['include_videos'] = Variable<bool>(includeVideos);
    map['real_visualizer_enabled'] = Variable<bool>(realVisualizerEnabled);
    map['auto_exclude_non_music_folders'] = Variable<bool>(
      autoExcludeNonMusicFolders,
    );
    map['minimum_track_seconds'] = Variable<int>(minimumTrackSeconds);
    map['library_folder_overrides_json'] = Variable<String>(
      libraryFolderOverridesJson,
    );
    map['compact_now_playing'] = Variable<bool>(compactNowPlaying);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      id: Value(id),
      adaptiveDarkModeEnabled: Value(adaptiveDarkModeEnabled),
      manualThemeOverride: manualThemeOverride == null && nullToAbsent
          ? const Value.absent()
          : Value(manualThemeOverride),
      themeSeedColorHex: Value(themeSeedColorHex),
      visualizerColorHex: Value(visualizerColorHex),
      crossfadeEnabled: Value(crossfadeEnabled),
      crossfadeDurationMs: Value(crossfadeDurationMs),
      currentEqualizerPresetId: currentEqualizerPresetId == null && nullToAbsent
          ? const Value.absent()
          : Value(currentEqualizerPresetId),
      visualizerStyle: Value(visualizerStyle),
      showAlbumArtInMiniPlayer: Value(showAlbumArtInMiniPlayer),
      showVisualizerInMiniPlayer: Value(showVisualizerInMiniPlayer),
      showAlbumArtInNowPlaying: Value(showAlbumArtInNowPlaying),
      visualizerPlacement: Value(visualizerPlacement),
      visualizerAsArtworkFallback: Value(visualizerAsArtworkFallback),
      visualizerSensitivity: Value(visualizerSensitivity),
      visualizerContrast: Value(visualizerContrast),
      visualizerFloor: Value(visualizerFloor),
      visualizerResponsiveness: Value(visualizerResponsiveness),
      visualizerBarCount: Value(visualizerBarCount),
      seekStepSeconds: Value(seekStepSeconds),
      includeVideos: Value(includeVideos),
      realVisualizerEnabled: Value(realVisualizerEnabled),
      autoExcludeNonMusicFolders: Value(autoExcludeNonMusicFolders),
      minimumTrackSeconds: Value(minimumTrackSeconds),
      libraryFolderOverridesJson: Value(libraryFolderOverridesJson),
      compactNowPlaying: Value(compactNowPlaying),
    );
  }

  factory SettingsRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingsRow(
      id: serializer.fromJson<String>(json['id']),
      adaptiveDarkModeEnabled: serializer.fromJson<bool>(
        json['adaptiveDarkModeEnabled'],
      ),
      manualThemeOverride: serializer.fromJson<String?>(
        json['manualThemeOverride'],
      ),
      themeSeedColorHex: serializer.fromJson<String>(json['themeSeedColorHex']),
      visualizerColorHex: serializer.fromJson<String>(
        json['visualizerColorHex'],
      ),
      crossfadeEnabled: serializer.fromJson<bool>(json['crossfadeEnabled']),
      crossfadeDurationMs: serializer.fromJson<int>(
        json['crossfadeDurationMs'],
      ),
      currentEqualizerPresetId: serializer.fromJson<String?>(
        json['currentEqualizerPresetId'],
      ),
      visualizerStyle: serializer.fromJson<String>(json['visualizerStyle']),
      showAlbumArtInMiniPlayer: serializer.fromJson<bool>(
        json['showAlbumArtInMiniPlayer'],
      ),
      showVisualizerInMiniPlayer: serializer.fromJson<bool>(
        json['showVisualizerInMiniPlayer'],
      ),
      showAlbumArtInNowPlaying: serializer.fromJson<bool>(
        json['showAlbumArtInNowPlaying'],
      ),
      visualizerPlacement: serializer.fromJson<String>(
        json['visualizerPlacement'],
      ),
      visualizerAsArtworkFallback: serializer.fromJson<bool>(
        json['visualizerAsArtworkFallback'],
      ),
      visualizerSensitivity: serializer.fromJson<double>(
        json['visualizerSensitivity'],
      ),
      visualizerContrast: serializer.fromJson<double>(
        json['visualizerContrast'],
      ),
      visualizerFloor: serializer.fromJson<double>(json['visualizerFloor']),
      visualizerResponsiveness: serializer.fromJson<double>(
        json['visualizerResponsiveness'],
      ),
      visualizerBarCount: serializer.fromJson<int>(json['visualizerBarCount']),
      seekStepSeconds: serializer.fromJson<int>(json['seekStepSeconds']),
      includeVideos: serializer.fromJson<bool>(json['includeVideos']),
      realVisualizerEnabled: serializer.fromJson<bool>(
        json['realVisualizerEnabled'],
      ),
      autoExcludeNonMusicFolders: serializer.fromJson<bool>(
        json['autoExcludeNonMusicFolders'],
      ),
      minimumTrackSeconds: serializer.fromJson<int>(
        json['minimumTrackSeconds'],
      ),
      libraryFolderOverridesJson: serializer.fromJson<String>(
        json['libraryFolderOverridesJson'],
      ),
      compactNowPlaying: serializer.fromJson<bool>(json['compactNowPlaying']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'adaptiveDarkModeEnabled': serializer.toJson<bool>(
        adaptiveDarkModeEnabled,
      ),
      'manualThemeOverride': serializer.toJson<String?>(manualThemeOverride),
      'themeSeedColorHex': serializer.toJson<String>(themeSeedColorHex),
      'visualizerColorHex': serializer.toJson<String>(visualizerColorHex),
      'crossfadeEnabled': serializer.toJson<bool>(crossfadeEnabled),
      'crossfadeDurationMs': serializer.toJson<int>(crossfadeDurationMs),
      'currentEqualizerPresetId': serializer.toJson<String?>(
        currentEqualizerPresetId,
      ),
      'visualizerStyle': serializer.toJson<String>(visualizerStyle),
      'showAlbumArtInMiniPlayer': serializer.toJson<bool>(
        showAlbumArtInMiniPlayer,
      ),
      'showVisualizerInMiniPlayer': serializer.toJson<bool>(
        showVisualizerInMiniPlayer,
      ),
      'showAlbumArtInNowPlaying': serializer.toJson<bool>(
        showAlbumArtInNowPlaying,
      ),
      'visualizerPlacement': serializer.toJson<String>(visualizerPlacement),
      'visualizerAsArtworkFallback': serializer.toJson<bool>(
        visualizerAsArtworkFallback,
      ),
      'visualizerSensitivity': serializer.toJson<double>(visualizerSensitivity),
      'visualizerContrast': serializer.toJson<double>(visualizerContrast),
      'visualizerFloor': serializer.toJson<double>(visualizerFloor),
      'visualizerResponsiveness': serializer.toJson<double>(
        visualizerResponsiveness,
      ),
      'visualizerBarCount': serializer.toJson<int>(visualizerBarCount),
      'seekStepSeconds': serializer.toJson<int>(seekStepSeconds),
      'includeVideos': serializer.toJson<bool>(includeVideos),
      'realVisualizerEnabled': serializer.toJson<bool>(realVisualizerEnabled),
      'autoExcludeNonMusicFolders': serializer.toJson<bool>(
        autoExcludeNonMusicFolders,
      ),
      'minimumTrackSeconds': serializer.toJson<int>(minimumTrackSeconds),
      'libraryFolderOverridesJson': serializer.toJson<String>(
        libraryFolderOverridesJson,
      ),
      'compactNowPlaying': serializer.toJson<bool>(compactNowPlaying),
    };
  }

  SettingsRow copyWith({
    String? id,
    bool? adaptiveDarkModeEnabled,
    Value<String?> manualThemeOverride = const Value.absent(),
    String? themeSeedColorHex,
    String? visualizerColorHex,
    bool? crossfadeEnabled,
    int? crossfadeDurationMs,
    Value<String?> currentEqualizerPresetId = const Value.absent(),
    String? visualizerStyle,
    bool? showAlbumArtInMiniPlayer,
    bool? showVisualizerInMiniPlayer,
    bool? showAlbumArtInNowPlaying,
    String? visualizerPlacement,
    bool? visualizerAsArtworkFallback,
    double? visualizerSensitivity,
    double? visualizerContrast,
    double? visualizerFloor,
    double? visualizerResponsiveness,
    int? visualizerBarCount,
    int? seekStepSeconds,
    bool? includeVideos,
    bool? realVisualizerEnabled,
    bool? autoExcludeNonMusicFolders,
    int? minimumTrackSeconds,
    String? libraryFolderOverridesJson,
    bool? compactNowPlaying,
  }) => SettingsRow(
    id: id ?? this.id,
    adaptiveDarkModeEnabled:
        adaptiveDarkModeEnabled ?? this.adaptiveDarkModeEnabled,
    manualThemeOverride: manualThemeOverride.present
        ? manualThemeOverride.value
        : this.manualThemeOverride,
    themeSeedColorHex: themeSeedColorHex ?? this.themeSeedColorHex,
    visualizerColorHex: visualizerColorHex ?? this.visualizerColorHex,
    crossfadeEnabled: crossfadeEnabled ?? this.crossfadeEnabled,
    crossfadeDurationMs: crossfadeDurationMs ?? this.crossfadeDurationMs,
    currentEqualizerPresetId: currentEqualizerPresetId.present
        ? currentEqualizerPresetId.value
        : this.currentEqualizerPresetId,
    visualizerStyle: visualizerStyle ?? this.visualizerStyle,
    showAlbumArtInMiniPlayer:
        showAlbumArtInMiniPlayer ?? this.showAlbumArtInMiniPlayer,
    showVisualizerInMiniPlayer:
        showVisualizerInMiniPlayer ?? this.showVisualizerInMiniPlayer,
    showAlbumArtInNowPlaying:
        showAlbumArtInNowPlaying ?? this.showAlbumArtInNowPlaying,
    visualizerPlacement: visualizerPlacement ?? this.visualizerPlacement,
    visualizerAsArtworkFallback:
        visualizerAsArtworkFallback ?? this.visualizerAsArtworkFallback,
    visualizerSensitivity: visualizerSensitivity ?? this.visualizerSensitivity,
    visualizerContrast: visualizerContrast ?? this.visualizerContrast,
    visualizerFloor: visualizerFloor ?? this.visualizerFloor,
    visualizerResponsiveness:
        visualizerResponsiveness ?? this.visualizerResponsiveness,
    visualizerBarCount: visualizerBarCount ?? this.visualizerBarCount,
    seekStepSeconds: seekStepSeconds ?? this.seekStepSeconds,
    includeVideos: includeVideos ?? this.includeVideos,
    realVisualizerEnabled: realVisualizerEnabled ?? this.realVisualizerEnabled,
    autoExcludeNonMusicFolders:
        autoExcludeNonMusicFolders ?? this.autoExcludeNonMusicFolders,
    minimumTrackSeconds: minimumTrackSeconds ?? this.minimumTrackSeconds,
    libraryFolderOverridesJson:
        libraryFolderOverridesJson ?? this.libraryFolderOverridesJson,
    compactNowPlaying: compactNowPlaying ?? this.compactNowPlaying,
  );
  SettingsRow copyWithCompanion(SettingsCompanion data) {
    return SettingsRow(
      id: data.id.present ? data.id.value : this.id,
      adaptiveDarkModeEnabled: data.adaptiveDarkModeEnabled.present
          ? data.adaptiveDarkModeEnabled.value
          : this.adaptiveDarkModeEnabled,
      manualThemeOverride: data.manualThemeOverride.present
          ? data.manualThemeOverride.value
          : this.manualThemeOverride,
      themeSeedColorHex: data.themeSeedColorHex.present
          ? data.themeSeedColorHex.value
          : this.themeSeedColorHex,
      visualizerColorHex: data.visualizerColorHex.present
          ? data.visualizerColorHex.value
          : this.visualizerColorHex,
      crossfadeEnabled: data.crossfadeEnabled.present
          ? data.crossfadeEnabled.value
          : this.crossfadeEnabled,
      crossfadeDurationMs: data.crossfadeDurationMs.present
          ? data.crossfadeDurationMs.value
          : this.crossfadeDurationMs,
      currentEqualizerPresetId: data.currentEqualizerPresetId.present
          ? data.currentEqualizerPresetId.value
          : this.currentEqualizerPresetId,
      visualizerStyle: data.visualizerStyle.present
          ? data.visualizerStyle.value
          : this.visualizerStyle,
      showAlbumArtInMiniPlayer: data.showAlbumArtInMiniPlayer.present
          ? data.showAlbumArtInMiniPlayer.value
          : this.showAlbumArtInMiniPlayer,
      showVisualizerInMiniPlayer: data.showVisualizerInMiniPlayer.present
          ? data.showVisualizerInMiniPlayer.value
          : this.showVisualizerInMiniPlayer,
      showAlbumArtInNowPlaying: data.showAlbumArtInNowPlaying.present
          ? data.showAlbumArtInNowPlaying.value
          : this.showAlbumArtInNowPlaying,
      visualizerPlacement: data.visualizerPlacement.present
          ? data.visualizerPlacement.value
          : this.visualizerPlacement,
      visualizerAsArtworkFallback: data.visualizerAsArtworkFallback.present
          ? data.visualizerAsArtworkFallback.value
          : this.visualizerAsArtworkFallback,
      visualizerSensitivity: data.visualizerSensitivity.present
          ? data.visualizerSensitivity.value
          : this.visualizerSensitivity,
      visualizerContrast: data.visualizerContrast.present
          ? data.visualizerContrast.value
          : this.visualizerContrast,
      visualizerFloor: data.visualizerFloor.present
          ? data.visualizerFloor.value
          : this.visualizerFloor,
      visualizerResponsiveness: data.visualizerResponsiveness.present
          ? data.visualizerResponsiveness.value
          : this.visualizerResponsiveness,
      visualizerBarCount: data.visualizerBarCount.present
          ? data.visualizerBarCount.value
          : this.visualizerBarCount,
      seekStepSeconds: data.seekStepSeconds.present
          ? data.seekStepSeconds.value
          : this.seekStepSeconds,
      includeVideos: data.includeVideos.present
          ? data.includeVideos.value
          : this.includeVideos,
      realVisualizerEnabled: data.realVisualizerEnabled.present
          ? data.realVisualizerEnabled.value
          : this.realVisualizerEnabled,
      autoExcludeNonMusicFolders: data.autoExcludeNonMusicFolders.present
          ? data.autoExcludeNonMusicFolders.value
          : this.autoExcludeNonMusicFolders,
      minimumTrackSeconds: data.minimumTrackSeconds.present
          ? data.minimumTrackSeconds.value
          : this.minimumTrackSeconds,
      libraryFolderOverridesJson: data.libraryFolderOverridesJson.present
          ? data.libraryFolderOverridesJson.value
          : this.libraryFolderOverridesJson,
      compactNowPlaying: data.compactNowPlaying.present
          ? data.compactNowPlaying.value
          : this.compactNowPlaying,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingsRow(')
          ..write('id: $id, ')
          ..write('adaptiveDarkModeEnabled: $adaptiveDarkModeEnabled, ')
          ..write('manualThemeOverride: $manualThemeOverride, ')
          ..write('themeSeedColorHex: $themeSeedColorHex, ')
          ..write('visualizerColorHex: $visualizerColorHex, ')
          ..write('crossfadeEnabled: $crossfadeEnabled, ')
          ..write('crossfadeDurationMs: $crossfadeDurationMs, ')
          ..write('currentEqualizerPresetId: $currentEqualizerPresetId, ')
          ..write('visualizerStyle: $visualizerStyle, ')
          ..write('showAlbumArtInMiniPlayer: $showAlbumArtInMiniPlayer, ')
          ..write('showVisualizerInMiniPlayer: $showVisualizerInMiniPlayer, ')
          ..write('showAlbumArtInNowPlaying: $showAlbumArtInNowPlaying, ')
          ..write('visualizerPlacement: $visualizerPlacement, ')
          ..write('visualizerAsArtworkFallback: $visualizerAsArtworkFallback, ')
          ..write('visualizerSensitivity: $visualizerSensitivity, ')
          ..write('visualizerContrast: $visualizerContrast, ')
          ..write('visualizerFloor: $visualizerFloor, ')
          ..write('visualizerResponsiveness: $visualizerResponsiveness, ')
          ..write('visualizerBarCount: $visualizerBarCount, ')
          ..write('seekStepSeconds: $seekStepSeconds, ')
          ..write('includeVideos: $includeVideos, ')
          ..write('realVisualizerEnabled: $realVisualizerEnabled, ')
          ..write('autoExcludeNonMusicFolders: $autoExcludeNonMusicFolders, ')
          ..write('minimumTrackSeconds: $minimumTrackSeconds, ')
          ..write('libraryFolderOverridesJson: $libraryFolderOverridesJson, ')
          ..write('compactNowPlaying: $compactNowPlaying')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    adaptiveDarkModeEnabled,
    manualThemeOverride,
    themeSeedColorHex,
    visualizerColorHex,
    crossfadeEnabled,
    crossfadeDurationMs,
    currentEqualizerPresetId,
    visualizerStyle,
    showAlbumArtInMiniPlayer,
    showVisualizerInMiniPlayer,
    showAlbumArtInNowPlaying,
    visualizerPlacement,
    visualizerAsArtworkFallback,
    visualizerSensitivity,
    visualizerContrast,
    visualizerFloor,
    visualizerResponsiveness,
    visualizerBarCount,
    seekStepSeconds,
    includeVideos,
    realVisualizerEnabled,
    autoExcludeNonMusicFolders,
    minimumTrackSeconds,
    libraryFolderOverridesJson,
    compactNowPlaying,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingsRow &&
          other.id == this.id &&
          other.adaptiveDarkModeEnabled == this.adaptiveDarkModeEnabled &&
          other.manualThemeOverride == this.manualThemeOverride &&
          other.themeSeedColorHex == this.themeSeedColorHex &&
          other.visualizerColorHex == this.visualizerColorHex &&
          other.crossfadeEnabled == this.crossfadeEnabled &&
          other.crossfadeDurationMs == this.crossfadeDurationMs &&
          other.currentEqualizerPresetId == this.currentEqualizerPresetId &&
          other.visualizerStyle == this.visualizerStyle &&
          other.showAlbumArtInMiniPlayer == this.showAlbumArtInMiniPlayer &&
          other.showVisualizerInMiniPlayer == this.showVisualizerInMiniPlayer &&
          other.showAlbumArtInNowPlaying == this.showAlbumArtInNowPlaying &&
          other.visualizerPlacement == this.visualizerPlacement &&
          other.visualizerAsArtworkFallback ==
              this.visualizerAsArtworkFallback &&
          other.visualizerSensitivity == this.visualizerSensitivity &&
          other.visualizerContrast == this.visualizerContrast &&
          other.visualizerFloor == this.visualizerFloor &&
          other.visualizerResponsiveness == this.visualizerResponsiveness &&
          other.visualizerBarCount == this.visualizerBarCount &&
          other.seekStepSeconds == this.seekStepSeconds &&
          other.includeVideos == this.includeVideos &&
          other.realVisualizerEnabled == this.realVisualizerEnabled &&
          other.autoExcludeNonMusicFolders == this.autoExcludeNonMusicFolders &&
          other.minimumTrackSeconds == this.minimumTrackSeconds &&
          other.libraryFolderOverridesJson == this.libraryFolderOverridesJson &&
          other.compactNowPlaying == this.compactNowPlaying);
}

class SettingsCompanion extends UpdateCompanion<SettingsRow> {
  final Value<String> id;
  final Value<bool> adaptiveDarkModeEnabled;
  final Value<String?> manualThemeOverride;
  final Value<String> themeSeedColorHex;
  final Value<String> visualizerColorHex;
  final Value<bool> crossfadeEnabled;
  final Value<int> crossfadeDurationMs;
  final Value<String?> currentEqualizerPresetId;
  final Value<String> visualizerStyle;
  final Value<bool> showAlbumArtInMiniPlayer;
  final Value<bool> showVisualizerInMiniPlayer;
  final Value<bool> showAlbumArtInNowPlaying;
  final Value<String> visualizerPlacement;
  final Value<bool> visualizerAsArtworkFallback;
  final Value<double> visualizerSensitivity;
  final Value<double> visualizerContrast;
  final Value<double> visualizerFloor;
  final Value<double> visualizerResponsiveness;
  final Value<int> visualizerBarCount;
  final Value<int> seekStepSeconds;
  final Value<bool> includeVideos;
  final Value<bool> realVisualizerEnabled;
  final Value<bool> autoExcludeNonMusicFolders;
  final Value<int> minimumTrackSeconds;
  final Value<String> libraryFolderOverridesJson;
  final Value<bool> compactNowPlaying;
  final Value<int> rowid;
  const SettingsCompanion({
    this.id = const Value.absent(),
    this.adaptiveDarkModeEnabled = const Value.absent(),
    this.manualThemeOverride = const Value.absent(),
    this.themeSeedColorHex = const Value.absent(),
    this.visualizerColorHex = const Value.absent(),
    this.crossfadeEnabled = const Value.absent(),
    this.crossfadeDurationMs = const Value.absent(),
    this.currentEqualizerPresetId = const Value.absent(),
    this.visualizerStyle = const Value.absent(),
    this.showAlbumArtInMiniPlayer = const Value.absent(),
    this.showVisualizerInMiniPlayer = const Value.absent(),
    this.showAlbumArtInNowPlaying = const Value.absent(),
    this.visualizerPlacement = const Value.absent(),
    this.visualizerAsArtworkFallback = const Value.absent(),
    this.visualizerSensitivity = const Value.absent(),
    this.visualizerContrast = const Value.absent(),
    this.visualizerFloor = const Value.absent(),
    this.visualizerResponsiveness = const Value.absent(),
    this.visualizerBarCount = const Value.absent(),
    this.seekStepSeconds = const Value.absent(),
    this.includeVideos = const Value.absent(),
    this.realVisualizerEnabled = const Value.absent(),
    this.autoExcludeNonMusicFolders = const Value.absent(),
    this.minimumTrackSeconds = const Value.absent(),
    this.libraryFolderOverridesJson = const Value.absent(),
    this.compactNowPlaying = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String id,
    this.adaptiveDarkModeEnabled = const Value.absent(),
    this.manualThemeOverride = const Value.absent(),
    this.themeSeedColorHex = const Value.absent(),
    this.visualizerColorHex = const Value.absent(),
    this.crossfadeEnabled = const Value.absent(),
    this.crossfadeDurationMs = const Value.absent(),
    this.currentEqualizerPresetId = const Value.absent(),
    this.visualizerStyle = const Value.absent(),
    this.showAlbumArtInMiniPlayer = const Value.absent(),
    this.showVisualizerInMiniPlayer = const Value.absent(),
    this.showAlbumArtInNowPlaying = const Value.absent(),
    this.visualizerPlacement = const Value.absent(),
    this.visualizerAsArtworkFallback = const Value.absent(),
    this.visualizerSensitivity = const Value.absent(),
    this.visualizerContrast = const Value.absent(),
    this.visualizerFloor = const Value.absent(),
    this.visualizerResponsiveness = const Value.absent(),
    this.visualizerBarCount = const Value.absent(),
    this.seekStepSeconds = const Value.absent(),
    this.includeVideos = const Value.absent(),
    this.realVisualizerEnabled = const Value.absent(),
    this.autoExcludeNonMusicFolders = const Value.absent(),
    this.minimumTrackSeconds = const Value.absent(),
    this.libraryFolderOverridesJson = const Value.absent(),
    this.compactNowPlaying = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<SettingsRow> custom({
    Expression<String>? id,
    Expression<bool>? adaptiveDarkModeEnabled,
    Expression<String>? manualThemeOverride,
    Expression<String>? themeSeedColorHex,
    Expression<String>? visualizerColorHex,
    Expression<bool>? crossfadeEnabled,
    Expression<int>? crossfadeDurationMs,
    Expression<String>? currentEqualizerPresetId,
    Expression<String>? visualizerStyle,
    Expression<bool>? showAlbumArtInMiniPlayer,
    Expression<bool>? showVisualizerInMiniPlayer,
    Expression<bool>? showAlbumArtInNowPlaying,
    Expression<String>? visualizerPlacement,
    Expression<bool>? visualizerAsArtworkFallback,
    Expression<double>? visualizerSensitivity,
    Expression<double>? visualizerContrast,
    Expression<double>? visualizerFloor,
    Expression<double>? visualizerResponsiveness,
    Expression<int>? visualizerBarCount,
    Expression<int>? seekStepSeconds,
    Expression<bool>? includeVideos,
    Expression<bool>? realVisualizerEnabled,
    Expression<bool>? autoExcludeNonMusicFolders,
    Expression<int>? minimumTrackSeconds,
    Expression<String>? libraryFolderOverridesJson,
    Expression<bool>? compactNowPlaying,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (adaptiveDarkModeEnabled != null)
        'adaptive_dark_mode_enabled': adaptiveDarkModeEnabled,
      if (manualThemeOverride != null)
        'manual_theme_override': manualThemeOverride,
      if (themeSeedColorHex != null) 'theme_seed_color_hex': themeSeedColorHex,
      if (visualizerColorHex != null)
        'visualizer_color_hex': visualizerColorHex,
      if (crossfadeEnabled != null) 'crossfade_enabled': crossfadeEnabled,
      if (crossfadeDurationMs != null)
        'crossfade_duration_ms': crossfadeDurationMs,
      if (currentEqualizerPresetId != null)
        'current_equalizer_preset_id': currentEqualizerPresetId,
      if (visualizerStyle != null) 'visualizer_style': visualizerStyle,
      if (showAlbumArtInMiniPlayer != null)
        'show_album_art_in_mini_player': showAlbumArtInMiniPlayer,
      if (showVisualizerInMiniPlayer != null)
        'show_visualizer_in_mini_player': showVisualizerInMiniPlayer,
      if (showAlbumArtInNowPlaying != null)
        'show_album_art_in_now_playing': showAlbumArtInNowPlaying,
      if (visualizerPlacement != null)
        'visualizer_placement': visualizerPlacement,
      if (visualizerAsArtworkFallback != null)
        'visualizer_as_artwork_fallback': visualizerAsArtworkFallback,
      if (visualizerSensitivity != null)
        'visualizer_sensitivity': visualizerSensitivity,
      if (visualizerContrast != null) 'visualizer_contrast': visualizerContrast,
      if (visualizerFloor != null) 'visualizer_floor': visualizerFloor,
      if (visualizerResponsiveness != null)
        'visualizer_responsiveness': visualizerResponsiveness,
      if (visualizerBarCount != null)
        'visualizer_bar_count': visualizerBarCount,
      if (seekStepSeconds != null) 'seek_step_seconds': seekStepSeconds,
      if (includeVideos != null) 'include_videos': includeVideos,
      if (realVisualizerEnabled != null)
        'real_visualizer_enabled': realVisualizerEnabled,
      if (autoExcludeNonMusicFolders != null)
        'auto_exclude_non_music_folders': autoExcludeNonMusicFolders,
      if (minimumTrackSeconds != null)
        'minimum_track_seconds': minimumTrackSeconds,
      if (libraryFolderOverridesJson != null)
        'library_folder_overrides_json': libraryFolderOverridesJson,
      if (compactNowPlaying != null) 'compact_now_playing': compactNowPlaying,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<String>? id,
    Value<bool>? adaptiveDarkModeEnabled,
    Value<String?>? manualThemeOverride,
    Value<String>? themeSeedColorHex,
    Value<String>? visualizerColorHex,
    Value<bool>? crossfadeEnabled,
    Value<int>? crossfadeDurationMs,
    Value<String?>? currentEqualizerPresetId,
    Value<String>? visualizerStyle,
    Value<bool>? showAlbumArtInMiniPlayer,
    Value<bool>? showVisualizerInMiniPlayer,
    Value<bool>? showAlbumArtInNowPlaying,
    Value<String>? visualizerPlacement,
    Value<bool>? visualizerAsArtworkFallback,
    Value<double>? visualizerSensitivity,
    Value<double>? visualizerContrast,
    Value<double>? visualizerFloor,
    Value<double>? visualizerResponsiveness,
    Value<int>? visualizerBarCount,
    Value<int>? seekStepSeconds,
    Value<bool>? includeVideos,
    Value<bool>? realVisualizerEnabled,
    Value<bool>? autoExcludeNonMusicFolders,
    Value<int>? minimumTrackSeconds,
    Value<String>? libraryFolderOverridesJson,
    Value<bool>? compactNowPlaying,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      id: id ?? this.id,
      adaptiveDarkModeEnabled:
          adaptiveDarkModeEnabled ?? this.adaptiveDarkModeEnabled,
      manualThemeOverride: manualThemeOverride ?? this.manualThemeOverride,
      themeSeedColorHex: themeSeedColorHex ?? this.themeSeedColorHex,
      visualizerColorHex: visualizerColorHex ?? this.visualizerColorHex,
      crossfadeEnabled: crossfadeEnabled ?? this.crossfadeEnabled,
      crossfadeDurationMs: crossfadeDurationMs ?? this.crossfadeDurationMs,
      currentEqualizerPresetId:
          currentEqualizerPresetId ?? this.currentEqualizerPresetId,
      visualizerStyle: visualizerStyle ?? this.visualizerStyle,
      showAlbumArtInMiniPlayer:
          showAlbumArtInMiniPlayer ?? this.showAlbumArtInMiniPlayer,
      showVisualizerInMiniPlayer:
          showVisualizerInMiniPlayer ?? this.showVisualizerInMiniPlayer,
      showAlbumArtInNowPlaying:
          showAlbumArtInNowPlaying ?? this.showAlbumArtInNowPlaying,
      visualizerPlacement: visualizerPlacement ?? this.visualizerPlacement,
      visualizerAsArtworkFallback:
          visualizerAsArtworkFallback ?? this.visualizerAsArtworkFallback,
      visualizerSensitivity:
          visualizerSensitivity ?? this.visualizerSensitivity,
      visualizerContrast: visualizerContrast ?? this.visualizerContrast,
      visualizerFloor: visualizerFloor ?? this.visualizerFloor,
      visualizerResponsiveness:
          visualizerResponsiveness ?? this.visualizerResponsiveness,
      visualizerBarCount: visualizerBarCount ?? this.visualizerBarCount,
      seekStepSeconds: seekStepSeconds ?? this.seekStepSeconds,
      includeVideos: includeVideos ?? this.includeVideos,
      realVisualizerEnabled:
          realVisualizerEnabled ?? this.realVisualizerEnabled,
      autoExcludeNonMusicFolders:
          autoExcludeNonMusicFolders ?? this.autoExcludeNonMusicFolders,
      minimumTrackSeconds: minimumTrackSeconds ?? this.minimumTrackSeconds,
      libraryFolderOverridesJson:
          libraryFolderOverridesJson ?? this.libraryFolderOverridesJson,
      compactNowPlaying: compactNowPlaying ?? this.compactNowPlaying,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (adaptiveDarkModeEnabled.present) {
      map['adaptive_dark_mode_enabled'] = Variable<bool>(
        adaptiveDarkModeEnabled.value,
      );
    }
    if (manualThemeOverride.present) {
      map['manual_theme_override'] = Variable<String>(
        manualThemeOverride.value,
      );
    }
    if (themeSeedColorHex.present) {
      map['theme_seed_color_hex'] = Variable<String>(themeSeedColorHex.value);
    }
    if (visualizerColorHex.present) {
      map['visualizer_color_hex'] = Variable<String>(visualizerColorHex.value);
    }
    if (crossfadeEnabled.present) {
      map['crossfade_enabled'] = Variable<bool>(crossfadeEnabled.value);
    }
    if (crossfadeDurationMs.present) {
      map['crossfade_duration_ms'] = Variable<int>(crossfadeDurationMs.value);
    }
    if (currentEqualizerPresetId.present) {
      map['current_equalizer_preset_id'] = Variable<String>(
        currentEqualizerPresetId.value,
      );
    }
    if (visualizerStyle.present) {
      map['visualizer_style'] = Variable<String>(visualizerStyle.value);
    }
    if (showAlbumArtInMiniPlayer.present) {
      map['show_album_art_in_mini_player'] = Variable<bool>(
        showAlbumArtInMiniPlayer.value,
      );
    }
    if (showVisualizerInMiniPlayer.present) {
      map['show_visualizer_in_mini_player'] = Variable<bool>(
        showVisualizerInMiniPlayer.value,
      );
    }
    if (showAlbumArtInNowPlaying.present) {
      map['show_album_art_in_now_playing'] = Variable<bool>(
        showAlbumArtInNowPlaying.value,
      );
    }
    if (visualizerPlacement.present) {
      map['visualizer_placement'] = Variable<String>(visualizerPlacement.value);
    }
    if (visualizerAsArtworkFallback.present) {
      map['visualizer_as_artwork_fallback'] = Variable<bool>(
        visualizerAsArtworkFallback.value,
      );
    }
    if (visualizerSensitivity.present) {
      map['visualizer_sensitivity'] = Variable<double>(
        visualizerSensitivity.value,
      );
    }
    if (visualizerContrast.present) {
      map['visualizer_contrast'] = Variable<double>(visualizerContrast.value);
    }
    if (visualizerFloor.present) {
      map['visualizer_floor'] = Variable<double>(visualizerFloor.value);
    }
    if (visualizerResponsiveness.present) {
      map['visualizer_responsiveness'] = Variable<double>(
        visualizerResponsiveness.value,
      );
    }
    if (visualizerBarCount.present) {
      map['visualizer_bar_count'] = Variable<int>(visualizerBarCount.value);
    }
    if (seekStepSeconds.present) {
      map['seek_step_seconds'] = Variable<int>(seekStepSeconds.value);
    }
    if (includeVideos.present) {
      map['include_videos'] = Variable<bool>(includeVideos.value);
    }
    if (realVisualizerEnabled.present) {
      map['real_visualizer_enabled'] = Variable<bool>(
        realVisualizerEnabled.value,
      );
    }
    if (autoExcludeNonMusicFolders.present) {
      map['auto_exclude_non_music_folders'] = Variable<bool>(
        autoExcludeNonMusicFolders.value,
      );
    }
    if (minimumTrackSeconds.present) {
      map['minimum_track_seconds'] = Variable<int>(minimumTrackSeconds.value);
    }
    if (libraryFolderOverridesJson.present) {
      map['library_folder_overrides_json'] = Variable<String>(
        libraryFolderOverridesJson.value,
      );
    }
    if (compactNowPlaying.present) {
      map['compact_now_playing'] = Variable<bool>(compactNowPlaying.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('id: $id, ')
          ..write('adaptiveDarkModeEnabled: $adaptiveDarkModeEnabled, ')
          ..write('manualThemeOverride: $manualThemeOverride, ')
          ..write('themeSeedColorHex: $themeSeedColorHex, ')
          ..write('visualizerColorHex: $visualizerColorHex, ')
          ..write('crossfadeEnabled: $crossfadeEnabled, ')
          ..write('crossfadeDurationMs: $crossfadeDurationMs, ')
          ..write('currentEqualizerPresetId: $currentEqualizerPresetId, ')
          ..write('visualizerStyle: $visualizerStyle, ')
          ..write('showAlbumArtInMiniPlayer: $showAlbumArtInMiniPlayer, ')
          ..write('showVisualizerInMiniPlayer: $showVisualizerInMiniPlayer, ')
          ..write('showAlbumArtInNowPlaying: $showAlbumArtInNowPlaying, ')
          ..write('visualizerPlacement: $visualizerPlacement, ')
          ..write('visualizerAsArtworkFallback: $visualizerAsArtworkFallback, ')
          ..write('visualizerSensitivity: $visualizerSensitivity, ')
          ..write('visualizerContrast: $visualizerContrast, ')
          ..write('visualizerFloor: $visualizerFloor, ')
          ..write('visualizerResponsiveness: $visualizerResponsiveness, ')
          ..write('visualizerBarCount: $visualizerBarCount, ')
          ..write('seekStepSeconds: $seekStepSeconds, ')
          ..write('includeVideos: $includeVideos, ')
          ..write('realVisualizerEnabled: $realVisualizerEnabled, ')
          ..write('autoExcludeNonMusicFolders: $autoExcludeNonMusicFolders, ')
          ..write('minimumTrackSeconds: $minimumTrackSeconds, ')
          ..write('libraryFolderOverridesJson: $libraryFolderOverridesJson, ')
          ..write('compactNowPlaying: $compactNowPlaying, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BackupsTable extends Backups with TableInfo<$BackupsTable, BackupRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BackupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, createdAt, filePath];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'backups';
  @override
  VerificationContext validateIntegrity(
    Insertable<BackupRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BackupRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BackupRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
    );
  }

  @override
  $BackupsTable createAlias(String alias) {
    return $BackupsTable(attachedDatabase, alias);
  }
}

class BackupRow extends DataClass implements Insertable<BackupRow> {
  final String id;
  final DateTime createdAt;
  final String filePath;
  const BackupRow({
    required this.id,
    required this.createdAt,
    required this.filePath,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['file_path'] = Variable<String>(filePath);
    return map;
  }

  BackupsCompanion toCompanion(bool nullToAbsent) {
    return BackupsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      filePath: Value(filePath),
    );
  }

  factory BackupRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BackupRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      filePath: serializer.fromJson<String>(json['filePath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'filePath': serializer.toJson<String>(filePath),
    };
  }

  BackupRow copyWith({String? id, DateTime? createdAt, String? filePath}) =>
      BackupRow(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        filePath: filePath ?? this.filePath,
      );
  BackupRow copyWithCompanion(BackupsCompanion data) {
    return BackupRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BackupRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('filePath: $filePath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, createdAt, filePath);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BackupRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.filePath == this.filePath);
}

class BackupsCompanion extends UpdateCompanion<BackupRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<String> filePath;
  final Value<int> rowid;
  const BackupsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.filePath = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BackupsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required String filePath,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       filePath = Value(filePath);
  static Insertable<BackupRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<String>? filePath,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (filePath != null) 'file_path': filePath,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BackupsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<String>? filePath,
    Value<int>? rowid,
  }) {
    return BackupsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      filePath: filePath ?? this.filePath,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BackupsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('filePath: $filePath, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlaybackSessionsTable extends PlaybackSessions
    with TableInfo<$PlaybackSessionsTable, PlaybackSessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaybackSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _songIdsJsonMeta = const VerificationMeta(
    'songIdsJson',
  );
  @override
  late final GeneratedColumn<String> songIdsJson = GeneratedColumn<String>(
    'song_ids_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _currentIndexMeta = const VerificationMeta(
    'currentIndex',
  );
  @override
  late final GeneratedColumn<int> currentIndex = GeneratedColumn<int>(
    'current_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _positionMsMeta = const VerificationMeta(
    'positionMs',
  );
  @override
  late final GeneratedColumn<int> positionMs = GeneratedColumn<int>(
    'position_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _shuffleEnabledMeta = const VerificationMeta(
    'shuffleEnabled',
  );
  @override
  late final GeneratedColumn<bool> shuffleEnabled = GeneratedColumn<bool>(
    'shuffle_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("shuffle_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _repeatModeMeta = const VerificationMeta(
    'repeatMode',
  );
  @override
  late final GeneratedColumn<String> repeatMode = GeneratedColumn<String>(
    'repeat_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('off'),
  );
  static const VerificationMeta _speedMeta = const VerificationMeta('speed');
  @override
  late final GeneratedColumn<double> speed = GeneratedColumn<double>(
    'speed',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  static const VerificationMeta _sourcePlaylistIdMeta = const VerificationMeta(
    'sourcePlaylistId',
  );
  @override
  late final GeneratedColumn<String> sourcePlaylistId = GeneratedColumn<String>(
    'source_playlist_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    songIdsJson,
    currentIndex,
    positionMs,
    shuffleEnabled,
    repeatMode,
    speed,
    sourcePlaylistId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playback_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlaybackSessionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('song_ids_json')) {
      context.handle(
        _songIdsJsonMeta,
        songIdsJson.isAcceptableOrUnknown(
          data['song_ids_json']!,
          _songIdsJsonMeta,
        ),
      );
    }
    if (data.containsKey('current_index')) {
      context.handle(
        _currentIndexMeta,
        currentIndex.isAcceptableOrUnknown(
          data['current_index']!,
          _currentIndexMeta,
        ),
      );
    }
    if (data.containsKey('position_ms')) {
      context.handle(
        _positionMsMeta,
        positionMs.isAcceptableOrUnknown(data['position_ms']!, _positionMsMeta),
      );
    }
    if (data.containsKey('shuffle_enabled')) {
      context.handle(
        _shuffleEnabledMeta,
        shuffleEnabled.isAcceptableOrUnknown(
          data['shuffle_enabled']!,
          _shuffleEnabledMeta,
        ),
      );
    }
    if (data.containsKey('repeat_mode')) {
      context.handle(
        _repeatModeMeta,
        repeatMode.isAcceptableOrUnknown(data['repeat_mode']!, _repeatModeMeta),
      );
    }
    if (data.containsKey('speed')) {
      context.handle(
        _speedMeta,
        speed.isAcceptableOrUnknown(data['speed']!, _speedMeta),
      );
    }
    if (data.containsKey('source_playlist_id')) {
      context.handle(
        _sourcePlaylistIdMeta,
        sourcePlaylistId.isAcceptableOrUnknown(
          data['source_playlist_id']!,
          _sourcePlaylistIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlaybackSessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaybackSessionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      songIdsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}song_ids_json'],
      )!,
      currentIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_index'],
      )!,
      positionMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position_ms'],
      )!,
      shuffleEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}shuffle_enabled'],
      )!,
      repeatMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}repeat_mode'],
      )!,
      speed: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}speed'],
      )!,
      sourcePlaylistId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_playlist_id'],
      ),
    );
  }

  @override
  $PlaybackSessionsTable createAlias(String alias) {
    return $PlaybackSessionsTable(attachedDatabase, alias);
  }
}

class PlaybackSessionRow extends DataClass
    implements Insertable<PlaybackSessionRow> {
  final String id;

  /// JSON-encoded `List<String>` of song IDs, in queue order.
  final String songIdsJson;
  final int currentIndex;
  final int positionMs;
  final bool shuffleEnabled;
  final String repeatMode;
  final double speed;
  final String? sourcePlaylistId;
  const PlaybackSessionRow({
    required this.id,
    required this.songIdsJson,
    required this.currentIndex,
    required this.positionMs,
    required this.shuffleEnabled,
    required this.repeatMode,
    required this.speed,
    this.sourcePlaylistId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['song_ids_json'] = Variable<String>(songIdsJson);
    map['current_index'] = Variable<int>(currentIndex);
    map['position_ms'] = Variable<int>(positionMs);
    map['shuffle_enabled'] = Variable<bool>(shuffleEnabled);
    map['repeat_mode'] = Variable<String>(repeatMode);
    map['speed'] = Variable<double>(speed);
    if (!nullToAbsent || sourcePlaylistId != null) {
      map['source_playlist_id'] = Variable<String>(sourcePlaylistId);
    }
    return map;
  }

  PlaybackSessionsCompanion toCompanion(bool nullToAbsent) {
    return PlaybackSessionsCompanion(
      id: Value(id),
      songIdsJson: Value(songIdsJson),
      currentIndex: Value(currentIndex),
      positionMs: Value(positionMs),
      shuffleEnabled: Value(shuffleEnabled),
      repeatMode: Value(repeatMode),
      speed: Value(speed),
      sourcePlaylistId: sourcePlaylistId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourcePlaylistId),
    );
  }

  factory PlaybackSessionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaybackSessionRow(
      id: serializer.fromJson<String>(json['id']),
      songIdsJson: serializer.fromJson<String>(json['songIdsJson']),
      currentIndex: serializer.fromJson<int>(json['currentIndex']),
      positionMs: serializer.fromJson<int>(json['positionMs']),
      shuffleEnabled: serializer.fromJson<bool>(json['shuffleEnabled']),
      repeatMode: serializer.fromJson<String>(json['repeatMode']),
      speed: serializer.fromJson<double>(json['speed']),
      sourcePlaylistId: serializer.fromJson<String?>(json['sourcePlaylistId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'songIdsJson': serializer.toJson<String>(songIdsJson),
      'currentIndex': serializer.toJson<int>(currentIndex),
      'positionMs': serializer.toJson<int>(positionMs),
      'shuffleEnabled': serializer.toJson<bool>(shuffleEnabled),
      'repeatMode': serializer.toJson<String>(repeatMode),
      'speed': serializer.toJson<double>(speed),
      'sourcePlaylistId': serializer.toJson<String?>(sourcePlaylistId),
    };
  }

  PlaybackSessionRow copyWith({
    String? id,
    String? songIdsJson,
    int? currentIndex,
    int? positionMs,
    bool? shuffleEnabled,
    String? repeatMode,
    double? speed,
    Value<String?> sourcePlaylistId = const Value.absent(),
  }) => PlaybackSessionRow(
    id: id ?? this.id,
    songIdsJson: songIdsJson ?? this.songIdsJson,
    currentIndex: currentIndex ?? this.currentIndex,
    positionMs: positionMs ?? this.positionMs,
    shuffleEnabled: shuffleEnabled ?? this.shuffleEnabled,
    repeatMode: repeatMode ?? this.repeatMode,
    speed: speed ?? this.speed,
    sourcePlaylistId: sourcePlaylistId.present
        ? sourcePlaylistId.value
        : this.sourcePlaylistId,
  );
  PlaybackSessionRow copyWithCompanion(PlaybackSessionsCompanion data) {
    return PlaybackSessionRow(
      id: data.id.present ? data.id.value : this.id,
      songIdsJson: data.songIdsJson.present
          ? data.songIdsJson.value
          : this.songIdsJson,
      currentIndex: data.currentIndex.present
          ? data.currentIndex.value
          : this.currentIndex,
      positionMs: data.positionMs.present
          ? data.positionMs.value
          : this.positionMs,
      shuffleEnabled: data.shuffleEnabled.present
          ? data.shuffleEnabled.value
          : this.shuffleEnabled,
      repeatMode: data.repeatMode.present
          ? data.repeatMode.value
          : this.repeatMode,
      speed: data.speed.present ? data.speed.value : this.speed,
      sourcePlaylistId: data.sourcePlaylistId.present
          ? data.sourcePlaylistId.value
          : this.sourcePlaylistId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaybackSessionRow(')
          ..write('id: $id, ')
          ..write('songIdsJson: $songIdsJson, ')
          ..write('currentIndex: $currentIndex, ')
          ..write('positionMs: $positionMs, ')
          ..write('shuffleEnabled: $shuffleEnabled, ')
          ..write('repeatMode: $repeatMode, ')
          ..write('speed: $speed, ')
          ..write('sourcePlaylistId: $sourcePlaylistId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    songIdsJson,
    currentIndex,
    positionMs,
    shuffleEnabled,
    repeatMode,
    speed,
    sourcePlaylistId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaybackSessionRow &&
          other.id == this.id &&
          other.songIdsJson == this.songIdsJson &&
          other.currentIndex == this.currentIndex &&
          other.positionMs == this.positionMs &&
          other.shuffleEnabled == this.shuffleEnabled &&
          other.repeatMode == this.repeatMode &&
          other.speed == this.speed &&
          other.sourcePlaylistId == this.sourcePlaylistId);
}

class PlaybackSessionsCompanion extends UpdateCompanion<PlaybackSessionRow> {
  final Value<String> id;
  final Value<String> songIdsJson;
  final Value<int> currentIndex;
  final Value<int> positionMs;
  final Value<bool> shuffleEnabled;
  final Value<String> repeatMode;
  final Value<double> speed;
  final Value<String?> sourcePlaylistId;
  final Value<int> rowid;
  const PlaybackSessionsCompanion({
    this.id = const Value.absent(),
    this.songIdsJson = const Value.absent(),
    this.currentIndex = const Value.absent(),
    this.positionMs = const Value.absent(),
    this.shuffleEnabled = const Value.absent(),
    this.repeatMode = const Value.absent(),
    this.speed = const Value.absent(),
    this.sourcePlaylistId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlaybackSessionsCompanion.insert({
    required String id,
    this.songIdsJson = const Value.absent(),
    this.currentIndex = const Value.absent(),
    this.positionMs = const Value.absent(),
    this.shuffleEnabled = const Value.absent(),
    this.repeatMode = const Value.absent(),
    this.speed = const Value.absent(),
    this.sourcePlaylistId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<PlaybackSessionRow> custom({
    Expression<String>? id,
    Expression<String>? songIdsJson,
    Expression<int>? currentIndex,
    Expression<int>? positionMs,
    Expression<bool>? shuffleEnabled,
    Expression<String>? repeatMode,
    Expression<double>? speed,
    Expression<String>? sourcePlaylistId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (songIdsJson != null) 'song_ids_json': songIdsJson,
      if (currentIndex != null) 'current_index': currentIndex,
      if (positionMs != null) 'position_ms': positionMs,
      if (shuffleEnabled != null) 'shuffle_enabled': shuffleEnabled,
      if (repeatMode != null) 'repeat_mode': repeatMode,
      if (speed != null) 'speed': speed,
      if (sourcePlaylistId != null) 'source_playlist_id': sourcePlaylistId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlaybackSessionsCompanion copyWith({
    Value<String>? id,
    Value<String>? songIdsJson,
    Value<int>? currentIndex,
    Value<int>? positionMs,
    Value<bool>? shuffleEnabled,
    Value<String>? repeatMode,
    Value<double>? speed,
    Value<String?>? sourcePlaylistId,
    Value<int>? rowid,
  }) {
    return PlaybackSessionsCompanion(
      id: id ?? this.id,
      songIdsJson: songIdsJson ?? this.songIdsJson,
      currentIndex: currentIndex ?? this.currentIndex,
      positionMs: positionMs ?? this.positionMs,
      shuffleEnabled: shuffleEnabled ?? this.shuffleEnabled,
      repeatMode: repeatMode ?? this.repeatMode,
      speed: speed ?? this.speed,
      sourcePlaylistId: sourcePlaylistId ?? this.sourcePlaylistId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (songIdsJson.present) {
      map['song_ids_json'] = Variable<String>(songIdsJson.value);
    }
    if (currentIndex.present) {
      map['current_index'] = Variable<int>(currentIndex.value);
    }
    if (positionMs.present) {
      map['position_ms'] = Variable<int>(positionMs.value);
    }
    if (shuffleEnabled.present) {
      map['shuffle_enabled'] = Variable<bool>(shuffleEnabled.value);
    }
    if (repeatMode.present) {
      map['repeat_mode'] = Variable<String>(repeatMode.value);
    }
    if (speed.present) {
      map['speed'] = Variable<double>(speed.value);
    }
    if (sourcePlaylistId.present) {
      map['source_playlist_id'] = Variable<String>(sourcePlaylistId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaybackSessionsCompanion(')
          ..write('id: $id, ')
          ..write('songIdsJson: $songIdsJson, ')
          ..write('currentIndex: $currentIndex, ')
          ..write('positionMs: $positionMs, ')
          ..write('shuffleEnabled: $shuffleEnabled, ')
          ..write('repeatMode: $repeatMode, ')
          ..write('speed: $speed, ')
          ..write('sourcePlaylistId: $sourcePlaylistId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $VibeCategoriesTable vibeCategories = $VibeCategoriesTable(this);
  late final $VibeTagsTable vibeTags = $VibeTagsTable(this);
  late final $SongsTable songs = $SongsTable(this);
  late final $SongVibesTable songVibes = $SongVibesTable(this);
  late final $GameScoresTable gameScores = $GameScoresTable(this);
  late final $PlaylistsTable playlists = $PlaylistsTable(this);
  late final $PlaylistSongsTable playlistSongs = $PlaylistSongsTable(this);
  late final $EqualizerPresetsTable equalizerPresets = $EqualizerPresetsTable(
    this,
  );
  late final $SettingsTable settings = $SettingsTable(this);
  late final $BackupsTable backups = $BackupsTable(this);
  late final $PlaybackSessionsTable playbackSessions = $PlaybackSessionsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    vibeCategories,
    vibeTags,
    songs,
    songVibes,
    gameScores,
    playlists,
    playlistSongs,
    equalizerPresets,
    settings,
    backups,
    playbackSessions,
  ];
}

typedef $$VibeCategoriesTableCreateCompanionBuilder =
    VibeCategoriesCompanion Function({
      required String id,
      required String name,
      required String colorHex,
      Value<int> sortOrder,
      Value<int> rowid,
    });
typedef $$VibeCategoriesTableUpdateCompanionBuilder =
    VibeCategoriesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> colorHex,
      Value<int> sortOrder,
      Value<int> rowid,
    });

class $$VibeCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $VibeCategoriesTable> {
  $$VibeCategoriesTableFilterComposer({
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

  ColumnFilters<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VibeCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $VibeCategoriesTable> {
  $$VibeCategoriesTableOrderingComposer({
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

  ColumnOrderings<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VibeCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VibeCategoriesTable> {
  $$VibeCategoriesTableAnnotationComposer({
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

  GeneratedColumn<String> get colorHex =>
      $composableBuilder(column: $table.colorHex, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$VibeCategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VibeCategoriesTable,
          VibeCategoryRow,
          $$VibeCategoriesTableFilterComposer,
          $$VibeCategoriesTableOrderingComposer,
          $$VibeCategoriesTableAnnotationComposer,
          $$VibeCategoriesTableCreateCompanionBuilder,
          $$VibeCategoriesTableUpdateCompanionBuilder,
          (
            VibeCategoryRow,
            BaseReferences<
              _$AppDatabase,
              $VibeCategoriesTable,
              VibeCategoryRow
            >,
          ),
          VibeCategoryRow,
          PrefetchHooks Function()
        > {
  $$VibeCategoriesTableTableManager(
    _$AppDatabase db,
    $VibeCategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VibeCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VibeCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VibeCategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> colorHex = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VibeCategoriesCompanion(
                id: id,
                name: name,
                colorHex: colorHex,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String colorHex,
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VibeCategoriesCompanion.insert(
                id: id,
                name: name,
                colorHex: colorHex,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VibeCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VibeCategoriesTable,
      VibeCategoryRow,
      $$VibeCategoriesTableFilterComposer,
      $$VibeCategoriesTableOrderingComposer,
      $$VibeCategoriesTableAnnotationComposer,
      $$VibeCategoriesTableCreateCompanionBuilder,
      $$VibeCategoriesTableUpdateCompanionBuilder,
      (
        VibeCategoryRow,
        BaseReferences<_$AppDatabase, $VibeCategoriesTable, VibeCategoryRow>,
      ),
      VibeCategoryRow,
      PrefetchHooks Function()
    >;
typedef $$VibeTagsTableCreateCompanionBuilder =
    VibeTagsCompanion Function({
      required String id,
      required String label,
      required String colorHex,
      Value<int> sortOrder,
      Value<String?> categoryId,
      Value<int> rowid,
    });
typedef $$VibeTagsTableUpdateCompanionBuilder =
    VibeTagsCompanion Function({
      Value<String> id,
      Value<String> label,
      Value<String> colorHex,
      Value<int> sortOrder,
      Value<String?> categoryId,
      Value<int> rowid,
    });

class $$VibeTagsTableFilterComposer
    extends Composer<_$AppDatabase, $VibeTagsTable> {
  $$VibeTagsTableFilterComposer({
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

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VibeTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $VibeTagsTable> {
  $$VibeTagsTableOrderingComposer({
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

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VibeTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VibeTagsTable> {
  $$VibeTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get colorHex =>
      $composableBuilder(column: $table.colorHex, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );
}

class $$VibeTagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VibeTagsTable,
          VibeTagRow,
          $$VibeTagsTableFilterComposer,
          $$VibeTagsTableOrderingComposer,
          $$VibeTagsTableAnnotationComposer,
          $$VibeTagsTableCreateCompanionBuilder,
          $$VibeTagsTableUpdateCompanionBuilder,
          (
            VibeTagRow,
            BaseReferences<_$AppDatabase, $VibeTagsTable, VibeTagRow>,
          ),
          VibeTagRow,
          PrefetchHooks Function()
        > {
  $$VibeTagsTableTableManager(_$AppDatabase db, $VibeTagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VibeTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VibeTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VibeTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String> colorHex = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VibeTagsCompanion(
                id: id,
                label: label,
                colorHex: colorHex,
                sortOrder: sortOrder,
                categoryId: categoryId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String label,
                required String colorHex,
                Value<int> sortOrder = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VibeTagsCompanion.insert(
                id: id,
                label: label,
                colorHex: colorHex,
                sortOrder: sortOrder,
                categoryId: categoryId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VibeTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VibeTagsTable,
      VibeTagRow,
      $$VibeTagsTableFilterComposer,
      $$VibeTagsTableOrderingComposer,
      $$VibeTagsTableAnnotationComposer,
      $$VibeTagsTableCreateCompanionBuilder,
      $$VibeTagsTableUpdateCompanionBuilder,
      (VibeTagRow, BaseReferences<_$AppDatabase, $VibeTagsTable, VibeTagRow>),
      VibeTagRow,
      PrefetchHooks Function()
    >;
typedef $$SongsTableCreateCompanionBuilder =
    SongsCompanion Function({
      required String id,
      required String filePath,
      required String title,
      required String artist,
      required String album,
      required int durationMs,
      Value<bool> isVideo,
      Value<bool> isLiked,
      Value<bool> isMissing,
      Value<int> playCount,
      Value<DateTime?> lastPlayedAt,
      Value<DateTime?> dateAdded,
      Value<int> rowid,
    });
typedef $$SongsTableUpdateCompanionBuilder =
    SongsCompanion Function({
      Value<String> id,
      Value<String> filePath,
      Value<String> title,
      Value<String> artist,
      Value<String> album,
      Value<int> durationMs,
      Value<bool> isVideo,
      Value<bool> isLiked,
      Value<bool> isMissing,
      Value<int> playCount,
      Value<DateTime?> lastPlayedAt,
      Value<DateTime?> dateAdded,
      Value<int> rowid,
    });

class $$SongsTableFilterComposer extends Composer<_$AppDatabase, $SongsTable> {
  $$SongsTableFilterComposer({
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

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get album => $composableBuilder(
    column: $table.album,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isVideo => $composableBuilder(
    column: $table.isVideo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isLiked => $composableBuilder(
    column: $table.isLiked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isMissing => $composableBuilder(
    column: $table.isMissing,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get playCount => $composableBuilder(
    column: $table.playCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastPlayedAt => $composableBuilder(
    column: $table.lastPlayedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateAdded => $composableBuilder(
    column: $table.dateAdded,
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
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get album => $composableBuilder(
    column: $table.album,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isVideo => $composableBuilder(
    column: $table.isVideo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isLiked => $composableBuilder(
    column: $table.isLiked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isMissing => $composableBuilder(
    column: $table.isMissing,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get playCount => $composableBuilder(
    column: $table.playCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastPlayedAt => $composableBuilder(
    column: $table.lastPlayedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateAdded => $composableBuilder(
    column: $table.dateAdded,
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
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get artist =>
      $composableBuilder(column: $table.artist, builder: (column) => column);

  GeneratedColumn<String> get album =>
      $composableBuilder(column: $table.album, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isVideo =>
      $composableBuilder(column: $table.isVideo, builder: (column) => column);

  GeneratedColumn<bool> get isLiked =>
      $composableBuilder(column: $table.isLiked, builder: (column) => column);

  GeneratedColumn<bool> get isMissing =>
      $composableBuilder(column: $table.isMissing, builder: (column) => column);

  GeneratedColumn<int> get playCount =>
      $composableBuilder(column: $table.playCount, builder: (column) => column);

  GeneratedColumn<DateTime> get lastPlayedAt => $composableBuilder(
    column: $table.lastPlayedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dateAdded =>
      $composableBuilder(column: $table.dateAdded, builder: (column) => column);
}

class $$SongsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SongsTable,
          SongRow,
          $$SongsTableFilterComposer,
          $$SongsTableOrderingComposer,
          $$SongsTableAnnotationComposer,
          $$SongsTableCreateCompanionBuilder,
          $$SongsTableUpdateCompanionBuilder,
          (SongRow, BaseReferences<_$AppDatabase, $SongsTable, SongRow>),
          SongRow,
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
                Value<String> id = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> artist = const Value.absent(),
                Value<String> album = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<bool> isVideo = const Value.absent(),
                Value<bool> isLiked = const Value.absent(),
                Value<bool> isMissing = const Value.absent(),
                Value<int> playCount = const Value.absent(),
                Value<DateTime?> lastPlayedAt = const Value.absent(),
                Value<DateTime?> dateAdded = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SongsCompanion(
                id: id,
                filePath: filePath,
                title: title,
                artist: artist,
                album: album,
                durationMs: durationMs,
                isVideo: isVideo,
                isLiked: isLiked,
                isMissing: isMissing,
                playCount: playCount,
                lastPlayedAt: lastPlayedAt,
                dateAdded: dateAdded,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String filePath,
                required String title,
                required String artist,
                required String album,
                required int durationMs,
                Value<bool> isVideo = const Value.absent(),
                Value<bool> isLiked = const Value.absent(),
                Value<bool> isMissing = const Value.absent(),
                Value<int> playCount = const Value.absent(),
                Value<DateTime?> lastPlayedAt = const Value.absent(),
                Value<DateTime?> dateAdded = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SongsCompanion.insert(
                id: id,
                filePath: filePath,
                title: title,
                artist: artist,
                album: album,
                durationMs: durationMs,
                isVideo: isVideo,
                isLiked: isLiked,
                isMissing: isMissing,
                playCount: playCount,
                lastPlayedAt: lastPlayedAt,
                dateAdded: dateAdded,
                rowid: rowid,
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
      SongRow,
      $$SongsTableFilterComposer,
      $$SongsTableOrderingComposer,
      $$SongsTableAnnotationComposer,
      $$SongsTableCreateCompanionBuilder,
      $$SongsTableUpdateCompanionBuilder,
      (SongRow, BaseReferences<_$AppDatabase, $SongsTable, SongRow>),
      SongRow,
      PrefetchHooks Function()
    >;
typedef $$SongVibesTableCreateCompanionBuilder =
    SongVibesCompanion Function({
      required String songId,
      required String vibeTagId,
      Value<int> rowid,
    });
typedef $$SongVibesTableUpdateCompanionBuilder =
    SongVibesCompanion Function({
      Value<String> songId,
      Value<String> vibeTagId,
      Value<int> rowid,
    });

class $$SongVibesTableFilterComposer
    extends Composer<_$AppDatabase, $SongVibesTable> {
  $$SongVibesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get songId => $composableBuilder(
    column: $table.songId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vibeTagId => $composableBuilder(
    column: $table.vibeTagId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SongVibesTableOrderingComposer
    extends Composer<_$AppDatabase, $SongVibesTable> {
  $$SongVibesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get songId => $composableBuilder(
    column: $table.songId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vibeTagId => $composableBuilder(
    column: $table.vibeTagId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SongVibesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SongVibesTable> {
  $$SongVibesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get songId =>
      $composableBuilder(column: $table.songId, builder: (column) => column);

  GeneratedColumn<String> get vibeTagId =>
      $composableBuilder(column: $table.vibeTagId, builder: (column) => column);
}

class $$SongVibesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SongVibesTable,
          SongVibeRow,
          $$SongVibesTableFilterComposer,
          $$SongVibesTableOrderingComposer,
          $$SongVibesTableAnnotationComposer,
          $$SongVibesTableCreateCompanionBuilder,
          $$SongVibesTableUpdateCompanionBuilder,
          (
            SongVibeRow,
            BaseReferences<_$AppDatabase, $SongVibesTable, SongVibeRow>,
          ),
          SongVibeRow,
          PrefetchHooks Function()
        > {
  $$SongVibesTableTableManager(_$AppDatabase db, $SongVibesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SongVibesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SongVibesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SongVibesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> songId = const Value.absent(),
                Value<String> vibeTagId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SongVibesCompanion(
                songId: songId,
                vibeTagId: vibeTagId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String songId,
                required String vibeTagId,
                Value<int> rowid = const Value.absent(),
              }) => SongVibesCompanion.insert(
                songId: songId,
                vibeTagId: vibeTagId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SongVibesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SongVibesTable,
      SongVibeRow,
      $$SongVibesTableFilterComposer,
      $$SongVibesTableOrderingComposer,
      $$SongVibesTableAnnotationComposer,
      $$SongVibesTableCreateCompanionBuilder,
      $$SongVibesTableUpdateCompanionBuilder,
      (
        SongVibeRow,
        BaseReferences<_$AppDatabase, $SongVibesTable, SongVibeRow>,
      ),
      SongVibeRow,
      PrefetchHooks Function()
    >;
typedef $$GameScoresTableCreateCompanionBuilder =
    GameScoresCompanion Function({
      required String songId,
      Value<int> highScore,
      Value<int> maxCombo,
      Value<int> playCount,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$GameScoresTableUpdateCompanionBuilder =
    GameScoresCompanion Function({
      Value<String> songId,
      Value<int> highScore,
      Value<int> maxCombo,
      Value<int> playCount,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$GameScoresTableFilterComposer
    extends Composer<_$AppDatabase, $GameScoresTable> {
  $$GameScoresTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get songId => $composableBuilder(
    column: $table.songId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get highScore => $composableBuilder(
    column: $table.highScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxCombo => $composableBuilder(
    column: $table.maxCombo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get playCount => $composableBuilder(
    column: $table.playCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GameScoresTableOrderingComposer
    extends Composer<_$AppDatabase, $GameScoresTable> {
  $$GameScoresTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get songId => $composableBuilder(
    column: $table.songId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get highScore => $composableBuilder(
    column: $table.highScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxCombo => $composableBuilder(
    column: $table.maxCombo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get playCount => $composableBuilder(
    column: $table.playCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GameScoresTableAnnotationComposer
    extends Composer<_$AppDatabase, $GameScoresTable> {
  $$GameScoresTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get songId =>
      $composableBuilder(column: $table.songId, builder: (column) => column);

  GeneratedColumn<int> get highScore =>
      $composableBuilder(column: $table.highScore, builder: (column) => column);

  GeneratedColumn<int> get maxCombo =>
      $composableBuilder(column: $table.maxCombo, builder: (column) => column);

  GeneratedColumn<int> get playCount =>
      $composableBuilder(column: $table.playCount, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$GameScoresTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GameScoresTable,
          GameScoreRow,
          $$GameScoresTableFilterComposer,
          $$GameScoresTableOrderingComposer,
          $$GameScoresTableAnnotationComposer,
          $$GameScoresTableCreateCompanionBuilder,
          $$GameScoresTableUpdateCompanionBuilder,
          (
            GameScoreRow,
            BaseReferences<_$AppDatabase, $GameScoresTable, GameScoreRow>,
          ),
          GameScoreRow,
          PrefetchHooks Function()
        > {
  $$GameScoresTableTableManager(_$AppDatabase db, $GameScoresTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GameScoresTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GameScoresTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GameScoresTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> songId = const Value.absent(),
                Value<int> highScore = const Value.absent(),
                Value<int> maxCombo = const Value.absent(),
                Value<int> playCount = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GameScoresCompanion(
                songId: songId,
                highScore: highScore,
                maxCombo: maxCombo,
                playCount: playCount,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String songId,
                Value<int> highScore = const Value.absent(),
                Value<int> maxCombo = const Value.absent(),
                Value<int> playCount = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => GameScoresCompanion.insert(
                songId: songId,
                highScore: highScore,
                maxCombo: maxCombo,
                playCount: playCount,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GameScoresTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GameScoresTable,
      GameScoreRow,
      $$GameScoresTableFilterComposer,
      $$GameScoresTableOrderingComposer,
      $$GameScoresTableAnnotationComposer,
      $$GameScoresTableCreateCompanionBuilder,
      $$GameScoresTableUpdateCompanionBuilder,
      (
        GameScoreRow,
        BaseReferences<_$AppDatabase, $GameScoresTable, GameScoreRow>,
      ),
      GameScoreRow,
      PrefetchHooks Function()
    >;
typedef $$PlaylistsTableCreateCompanionBuilder =
    PlaylistsCompanion Function({
      required String id,
      required String name,
      Value<bool> isAutoGenerated,
      Value<String?> sourceVibeTagId,
      required DateTime createdAt,
      Value<String?> coverImagePath,
      Value<int> rowid,
    });
typedef $$PlaylistsTableUpdateCompanionBuilder =
    PlaylistsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<bool> isAutoGenerated,
      Value<String?> sourceVibeTagId,
      Value<DateTime> createdAt,
      Value<String?> coverImagePath,
      Value<int> rowid,
    });

class $$PlaylistsTableFilterComposer
    extends Composer<_$AppDatabase, $PlaylistsTable> {
  $$PlaylistsTableFilterComposer({
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

  ColumnFilters<bool> get isAutoGenerated => $composableBuilder(
    column: $table.isAutoGenerated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceVibeTagId => $composableBuilder(
    column: $table.sourceVibeTagId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverImagePath => $composableBuilder(
    column: $table.coverImagePath,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlaylistsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaylistsTable> {
  $$PlaylistsTableOrderingComposer({
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

  ColumnOrderings<bool> get isAutoGenerated => $composableBuilder(
    column: $table.isAutoGenerated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceVibeTagId => $composableBuilder(
    column: $table.sourceVibeTagId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverImagePath => $composableBuilder(
    column: $table.coverImagePath,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlaylistsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaylistsTable> {
  $$PlaylistsTableAnnotationComposer({
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

  GeneratedColumn<bool> get isAutoGenerated => $composableBuilder(
    column: $table.isAutoGenerated,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceVibeTagId => $composableBuilder(
    column: $table.sourceVibeTagId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get coverImagePath => $composableBuilder(
    column: $table.coverImagePath,
    builder: (column) => column,
  );
}

class $$PlaylistsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlaylistsTable,
          PlaylistRow,
          $$PlaylistsTableFilterComposer,
          $$PlaylistsTableOrderingComposer,
          $$PlaylistsTableAnnotationComposer,
          $$PlaylistsTableCreateCompanionBuilder,
          $$PlaylistsTableUpdateCompanionBuilder,
          (
            PlaylistRow,
            BaseReferences<_$AppDatabase, $PlaylistsTable, PlaylistRow>,
          ),
          PlaylistRow,
          PrefetchHooks Function()
        > {
  $$PlaylistsTableTableManager(_$AppDatabase db, $PlaylistsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaylistsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaylistsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaylistsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<bool> isAutoGenerated = const Value.absent(),
                Value<String?> sourceVibeTagId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> coverImagePath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlaylistsCompanion(
                id: id,
                name: name,
                isAutoGenerated: isAutoGenerated,
                sourceVibeTagId: sourceVibeTagId,
                createdAt: createdAt,
                coverImagePath: coverImagePath,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<bool> isAutoGenerated = const Value.absent(),
                Value<String?> sourceVibeTagId = const Value.absent(),
                required DateTime createdAt,
                Value<String?> coverImagePath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlaylistsCompanion.insert(
                id: id,
                name: name,
                isAutoGenerated: isAutoGenerated,
                sourceVibeTagId: sourceVibeTagId,
                createdAt: createdAt,
                coverImagePath: coverImagePath,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlaylistsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlaylistsTable,
      PlaylistRow,
      $$PlaylistsTableFilterComposer,
      $$PlaylistsTableOrderingComposer,
      $$PlaylistsTableAnnotationComposer,
      $$PlaylistsTableCreateCompanionBuilder,
      $$PlaylistsTableUpdateCompanionBuilder,
      (
        PlaylistRow,
        BaseReferences<_$AppDatabase, $PlaylistsTable, PlaylistRow>,
      ),
      PlaylistRow,
      PrefetchHooks Function()
    >;
typedef $$PlaylistSongsTableCreateCompanionBuilder =
    PlaylistSongsCompanion Function({
      required String playlistId,
      required String songId,
      required int position,
      Value<int> rowid,
    });
typedef $$PlaylistSongsTableUpdateCompanionBuilder =
    PlaylistSongsCompanion Function({
      Value<String> playlistId,
      Value<String> songId,
      Value<int> position,
      Value<int> rowid,
    });

class $$PlaylistSongsTableFilterComposer
    extends Composer<_$AppDatabase, $PlaylistSongsTable> {
  $$PlaylistSongsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get playlistId => $composableBuilder(
    column: $table.playlistId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get songId => $composableBuilder(
    column: $table.songId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlaylistSongsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaylistSongsTable> {
  $$PlaylistSongsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get playlistId => $composableBuilder(
    column: $table.playlistId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get songId => $composableBuilder(
    column: $table.songId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlaylistSongsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaylistSongsTable> {
  $$PlaylistSongsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get playlistId => $composableBuilder(
    column: $table.playlistId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get songId =>
      $composableBuilder(column: $table.songId, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);
}

class $$PlaylistSongsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlaylistSongsTable,
          PlaylistSongRow,
          $$PlaylistSongsTableFilterComposer,
          $$PlaylistSongsTableOrderingComposer,
          $$PlaylistSongsTableAnnotationComposer,
          $$PlaylistSongsTableCreateCompanionBuilder,
          $$PlaylistSongsTableUpdateCompanionBuilder,
          (
            PlaylistSongRow,
            BaseReferences<_$AppDatabase, $PlaylistSongsTable, PlaylistSongRow>,
          ),
          PlaylistSongRow,
          PrefetchHooks Function()
        > {
  $$PlaylistSongsTableTableManager(_$AppDatabase db, $PlaylistSongsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaylistSongsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaylistSongsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaylistSongsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> playlistId = const Value.absent(),
                Value<String> songId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlaylistSongsCompanion(
                playlistId: playlistId,
                songId: songId,
                position: position,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String playlistId,
                required String songId,
                required int position,
                Value<int> rowid = const Value.absent(),
              }) => PlaylistSongsCompanion.insert(
                playlistId: playlistId,
                songId: songId,
                position: position,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlaylistSongsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlaylistSongsTable,
      PlaylistSongRow,
      $$PlaylistSongsTableFilterComposer,
      $$PlaylistSongsTableOrderingComposer,
      $$PlaylistSongsTableAnnotationComposer,
      $$PlaylistSongsTableCreateCompanionBuilder,
      $$PlaylistSongsTableUpdateCompanionBuilder,
      (
        PlaylistSongRow,
        BaseReferences<_$AppDatabase, $PlaylistSongsTable, PlaylistSongRow>,
      ),
      PlaylistSongRow,
      PrefetchHooks Function()
    >;
typedef $$EqualizerPresetsTableCreateCompanionBuilder =
    EqualizerPresetsCompanion Function({
      required String id,
      required String name,
      required String bandLevelsJson,
      Value<int> rowid,
    });
typedef $$EqualizerPresetsTableUpdateCompanionBuilder =
    EqualizerPresetsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> bandLevelsJson,
      Value<int> rowid,
    });

class $$EqualizerPresetsTableFilterComposer
    extends Composer<_$AppDatabase, $EqualizerPresetsTable> {
  $$EqualizerPresetsTableFilterComposer({
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

  ColumnFilters<String> get bandLevelsJson => $composableBuilder(
    column: $table.bandLevelsJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EqualizerPresetsTableOrderingComposer
    extends Composer<_$AppDatabase, $EqualizerPresetsTable> {
  $$EqualizerPresetsTableOrderingComposer({
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

  ColumnOrderings<String> get bandLevelsJson => $composableBuilder(
    column: $table.bandLevelsJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EqualizerPresetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EqualizerPresetsTable> {
  $$EqualizerPresetsTableAnnotationComposer({
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

  GeneratedColumn<String> get bandLevelsJson => $composableBuilder(
    column: $table.bandLevelsJson,
    builder: (column) => column,
  );
}

class $$EqualizerPresetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EqualizerPresetsTable,
          EqualizerPresetRow,
          $$EqualizerPresetsTableFilterComposer,
          $$EqualizerPresetsTableOrderingComposer,
          $$EqualizerPresetsTableAnnotationComposer,
          $$EqualizerPresetsTableCreateCompanionBuilder,
          $$EqualizerPresetsTableUpdateCompanionBuilder,
          (
            EqualizerPresetRow,
            BaseReferences<
              _$AppDatabase,
              $EqualizerPresetsTable,
              EqualizerPresetRow
            >,
          ),
          EqualizerPresetRow,
          PrefetchHooks Function()
        > {
  $$EqualizerPresetsTableTableManager(
    _$AppDatabase db,
    $EqualizerPresetsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EqualizerPresetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EqualizerPresetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EqualizerPresetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> bandLevelsJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EqualizerPresetsCompanion(
                id: id,
                name: name,
                bandLevelsJson: bandLevelsJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String bandLevelsJson,
                Value<int> rowid = const Value.absent(),
              }) => EqualizerPresetsCompanion.insert(
                id: id,
                name: name,
                bandLevelsJson: bandLevelsJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EqualizerPresetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EqualizerPresetsTable,
      EqualizerPresetRow,
      $$EqualizerPresetsTableFilterComposer,
      $$EqualizerPresetsTableOrderingComposer,
      $$EqualizerPresetsTableAnnotationComposer,
      $$EqualizerPresetsTableCreateCompanionBuilder,
      $$EqualizerPresetsTableUpdateCompanionBuilder,
      (
        EqualizerPresetRow,
        BaseReferences<
          _$AppDatabase,
          $EqualizerPresetsTable,
          EqualizerPresetRow
        >,
      ),
      EqualizerPresetRow,
      PrefetchHooks Function()
    >;
typedef $$SettingsTableCreateCompanionBuilder =
    SettingsCompanion Function({
      required String id,
      Value<bool> adaptiveDarkModeEnabled,
      Value<String?> manualThemeOverride,
      Value<String> themeSeedColorHex,
      Value<String> visualizerColorHex,
      Value<bool> crossfadeEnabled,
      Value<int> crossfadeDurationMs,
      Value<String?> currentEqualizerPresetId,
      Value<String> visualizerStyle,
      Value<bool> showAlbumArtInMiniPlayer,
      Value<bool> showVisualizerInMiniPlayer,
      Value<bool> showAlbumArtInNowPlaying,
      Value<String> visualizerPlacement,
      Value<bool> visualizerAsArtworkFallback,
      Value<double> visualizerSensitivity,
      Value<double> visualizerContrast,
      Value<double> visualizerFloor,
      Value<double> visualizerResponsiveness,
      Value<int> visualizerBarCount,
      Value<int> seekStepSeconds,
      Value<bool> includeVideos,
      Value<bool> realVisualizerEnabled,
      Value<bool> autoExcludeNonMusicFolders,
      Value<int> minimumTrackSeconds,
      Value<String> libraryFolderOverridesJson,
      Value<bool> compactNowPlaying,
      Value<int> rowid,
    });
typedef $$SettingsTableUpdateCompanionBuilder =
    SettingsCompanion Function({
      Value<String> id,
      Value<bool> adaptiveDarkModeEnabled,
      Value<String?> manualThemeOverride,
      Value<String> themeSeedColorHex,
      Value<String> visualizerColorHex,
      Value<bool> crossfadeEnabled,
      Value<int> crossfadeDurationMs,
      Value<String?> currentEqualizerPresetId,
      Value<String> visualizerStyle,
      Value<bool> showAlbumArtInMiniPlayer,
      Value<bool> showVisualizerInMiniPlayer,
      Value<bool> showAlbumArtInNowPlaying,
      Value<String> visualizerPlacement,
      Value<bool> visualizerAsArtworkFallback,
      Value<double> visualizerSensitivity,
      Value<double> visualizerContrast,
      Value<double> visualizerFloor,
      Value<double> visualizerResponsiveness,
      Value<int> visualizerBarCount,
      Value<int> seekStepSeconds,
      Value<bool> includeVideos,
      Value<bool> realVisualizerEnabled,
      Value<bool> autoExcludeNonMusicFolders,
      Value<int> minimumTrackSeconds,
      Value<String> libraryFolderOverridesJson,
      Value<bool> compactNowPlaying,
      Value<int> rowid,
    });

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
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

  ColumnFilters<bool> get adaptiveDarkModeEnabled => $composableBuilder(
    column: $table.adaptiveDarkModeEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get manualThemeOverride => $composableBuilder(
    column: $table.manualThemeOverride,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get themeSeedColorHex => $composableBuilder(
    column: $table.themeSeedColorHex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get visualizerColorHex => $composableBuilder(
    column: $table.visualizerColorHex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get crossfadeEnabled => $composableBuilder(
    column: $table.crossfadeEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get crossfadeDurationMs => $composableBuilder(
    column: $table.crossfadeDurationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currentEqualizerPresetId => $composableBuilder(
    column: $table.currentEqualizerPresetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get visualizerStyle => $composableBuilder(
    column: $table.visualizerStyle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get showAlbumArtInMiniPlayer => $composableBuilder(
    column: $table.showAlbumArtInMiniPlayer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get showVisualizerInMiniPlayer => $composableBuilder(
    column: $table.showVisualizerInMiniPlayer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get showAlbumArtInNowPlaying => $composableBuilder(
    column: $table.showAlbumArtInNowPlaying,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get visualizerPlacement => $composableBuilder(
    column: $table.visualizerPlacement,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get visualizerAsArtworkFallback => $composableBuilder(
    column: $table.visualizerAsArtworkFallback,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get visualizerSensitivity => $composableBuilder(
    column: $table.visualizerSensitivity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get visualizerContrast => $composableBuilder(
    column: $table.visualizerContrast,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get visualizerFloor => $composableBuilder(
    column: $table.visualizerFloor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get visualizerResponsiveness => $composableBuilder(
    column: $table.visualizerResponsiveness,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get visualizerBarCount => $composableBuilder(
    column: $table.visualizerBarCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seekStepSeconds => $composableBuilder(
    column: $table.seekStepSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get includeVideos => $composableBuilder(
    column: $table.includeVideos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get realVisualizerEnabled => $composableBuilder(
    column: $table.realVisualizerEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get autoExcludeNonMusicFolders => $composableBuilder(
    column: $table.autoExcludeNonMusicFolders,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minimumTrackSeconds => $composableBuilder(
    column: $table.minimumTrackSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get libraryFolderOverridesJson => $composableBuilder(
    column: $table.libraryFolderOverridesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get compactNowPlaying => $composableBuilder(
    column: $table.compactNowPlaying,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
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

  ColumnOrderings<bool> get adaptiveDarkModeEnabled => $composableBuilder(
    column: $table.adaptiveDarkModeEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get manualThemeOverride => $composableBuilder(
    column: $table.manualThemeOverride,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get themeSeedColorHex => $composableBuilder(
    column: $table.themeSeedColorHex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get visualizerColorHex => $composableBuilder(
    column: $table.visualizerColorHex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get crossfadeEnabled => $composableBuilder(
    column: $table.crossfadeEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get crossfadeDurationMs => $composableBuilder(
    column: $table.crossfadeDurationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currentEqualizerPresetId => $composableBuilder(
    column: $table.currentEqualizerPresetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get visualizerStyle => $composableBuilder(
    column: $table.visualizerStyle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get showAlbumArtInMiniPlayer => $composableBuilder(
    column: $table.showAlbumArtInMiniPlayer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get showVisualizerInMiniPlayer => $composableBuilder(
    column: $table.showVisualizerInMiniPlayer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get showAlbumArtInNowPlaying => $composableBuilder(
    column: $table.showAlbumArtInNowPlaying,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get visualizerPlacement => $composableBuilder(
    column: $table.visualizerPlacement,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get visualizerAsArtworkFallback => $composableBuilder(
    column: $table.visualizerAsArtworkFallback,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get visualizerSensitivity => $composableBuilder(
    column: $table.visualizerSensitivity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get visualizerContrast => $composableBuilder(
    column: $table.visualizerContrast,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get visualizerFloor => $composableBuilder(
    column: $table.visualizerFloor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get visualizerResponsiveness => $composableBuilder(
    column: $table.visualizerResponsiveness,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get visualizerBarCount => $composableBuilder(
    column: $table.visualizerBarCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seekStepSeconds => $composableBuilder(
    column: $table.seekStepSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get includeVideos => $composableBuilder(
    column: $table.includeVideos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get realVisualizerEnabled => $composableBuilder(
    column: $table.realVisualizerEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get autoExcludeNonMusicFolders => $composableBuilder(
    column: $table.autoExcludeNonMusicFolders,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minimumTrackSeconds => $composableBuilder(
    column: $table.minimumTrackSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get libraryFolderOverridesJson => $composableBuilder(
    column: $table.libraryFolderOverridesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get compactNowPlaying => $composableBuilder(
    column: $table.compactNowPlaying,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get adaptiveDarkModeEnabled => $composableBuilder(
    column: $table.adaptiveDarkModeEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<String> get manualThemeOverride => $composableBuilder(
    column: $table.manualThemeOverride,
    builder: (column) => column,
  );

  GeneratedColumn<String> get themeSeedColorHex => $composableBuilder(
    column: $table.themeSeedColorHex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get visualizerColorHex => $composableBuilder(
    column: $table.visualizerColorHex,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get crossfadeEnabled => $composableBuilder(
    column: $table.crossfadeEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<int> get crossfadeDurationMs => $composableBuilder(
    column: $table.crossfadeDurationMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currentEqualizerPresetId => $composableBuilder(
    column: $table.currentEqualizerPresetId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get visualizerStyle => $composableBuilder(
    column: $table.visualizerStyle,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get showAlbumArtInMiniPlayer => $composableBuilder(
    column: $table.showAlbumArtInMiniPlayer,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get showVisualizerInMiniPlayer => $composableBuilder(
    column: $table.showVisualizerInMiniPlayer,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get showAlbumArtInNowPlaying => $composableBuilder(
    column: $table.showAlbumArtInNowPlaying,
    builder: (column) => column,
  );

  GeneratedColumn<String> get visualizerPlacement => $composableBuilder(
    column: $table.visualizerPlacement,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get visualizerAsArtworkFallback => $composableBuilder(
    column: $table.visualizerAsArtworkFallback,
    builder: (column) => column,
  );

  GeneratedColumn<double> get visualizerSensitivity => $composableBuilder(
    column: $table.visualizerSensitivity,
    builder: (column) => column,
  );

  GeneratedColumn<double> get visualizerContrast => $composableBuilder(
    column: $table.visualizerContrast,
    builder: (column) => column,
  );

  GeneratedColumn<double> get visualizerFloor => $composableBuilder(
    column: $table.visualizerFloor,
    builder: (column) => column,
  );

  GeneratedColumn<double> get visualizerResponsiveness => $composableBuilder(
    column: $table.visualizerResponsiveness,
    builder: (column) => column,
  );

  GeneratedColumn<int> get visualizerBarCount => $composableBuilder(
    column: $table.visualizerBarCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get seekStepSeconds => $composableBuilder(
    column: $table.seekStepSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get includeVideos => $composableBuilder(
    column: $table.includeVideos,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get realVisualizerEnabled => $composableBuilder(
    column: $table.realVisualizerEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get autoExcludeNonMusicFolders => $composableBuilder(
    column: $table.autoExcludeNonMusicFolders,
    builder: (column) => column,
  );

  GeneratedColumn<int> get minimumTrackSeconds => $composableBuilder(
    column: $table.minimumTrackSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get libraryFolderOverridesJson => $composableBuilder(
    column: $table.libraryFolderOverridesJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get compactNowPlaying => $composableBuilder(
    column: $table.compactNowPlaying,
    builder: (column) => column,
  );
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          SettingsRow,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (
            SettingsRow,
            BaseReferences<_$AppDatabase, $SettingsTable, SettingsRow>,
          ),
          SettingsRow,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<bool> adaptiveDarkModeEnabled = const Value.absent(),
                Value<String?> manualThemeOverride = const Value.absent(),
                Value<String> themeSeedColorHex = const Value.absent(),
                Value<String> visualizerColorHex = const Value.absent(),
                Value<bool> crossfadeEnabled = const Value.absent(),
                Value<int> crossfadeDurationMs = const Value.absent(),
                Value<String?> currentEqualizerPresetId = const Value.absent(),
                Value<String> visualizerStyle = const Value.absent(),
                Value<bool> showAlbumArtInMiniPlayer = const Value.absent(),
                Value<bool> showVisualizerInMiniPlayer = const Value.absent(),
                Value<bool> showAlbumArtInNowPlaying = const Value.absent(),
                Value<String> visualizerPlacement = const Value.absent(),
                Value<bool> visualizerAsArtworkFallback = const Value.absent(),
                Value<double> visualizerSensitivity = const Value.absent(),
                Value<double> visualizerContrast = const Value.absent(),
                Value<double> visualizerFloor = const Value.absent(),
                Value<double> visualizerResponsiveness = const Value.absent(),
                Value<int> visualizerBarCount = const Value.absent(),
                Value<int> seekStepSeconds = const Value.absent(),
                Value<bool> includeVideos = const Value.absent(),
                Value<bool> realVisualizerEnabled = const Value.absent(),
                Value<bool> autoExcludeNonMusicFolders = const Value.absent(),
                Value<int> minimumTrackSeconds = const Value.absent(),
                Value<String> libraryFolderOverridesJson = const Value.absent(),
                Value<bool> compactNowPlaying = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion(
                id: id,
                adaptiveDarkModeEnabled: adaptiveDarkModeEnabled,
                manualThemeOverride: manualThemeOverride,
                themeSeedColorHex: themeSeedColorHex,
                visualizerColorHex: visualizerColorHex,
                crossfadeEnabled: crossfadeEnabled,
                crossfadeDurationMs: crossfadeDurationMs,
                currentEqualizerPresetId: currentEqualizerPresetId,
                visualizerStyle: visualizerStyle,
                showAlbumArtInMiniPlayer: showAlbumArtInMiniPlayer,
                showVisualizerInMiniPlayer: showVisualizerInMiniPlayer,
                showAlbumArtInNowPlaying: showAlbumArtInNowPlaying,
                visualizerPlacement: visualizerPlacement,
                visualizerAsArtworkFallback: visualizerAsArtworkFallback,
                visualizerSensitivity: visualizerSensitivity,
                visualizerContrast: visualizerContrast,
                visualizerFloor: visualizerFloor,
                visualizerResponsiveness: visualizerResponsiveness,
                visualizerBarCount: visualizerBarCount,
                seekStepSeconds: seekStepSeconds,
                includeVideos: includeVideos,
                realVisualizerEnabled: realVisualizerEnabled,
                autoExcludeNonMusicFolders: autoExcludeNonMusicFolders,
                minimumTrackSeconds: minimumTrackSeconds,
                libraryFolderOverridesJson: libraryFolderOverridesJson,
                compactNowPlaying: compactNowPlaying,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<bool> adaptiveDarkModeEnabled = const Value.absent(),
                Value<String?> manualThemeOverride = const Value.absent(),
                Value<String> themeSeedColorHex = const Value.absent(),
                Value<String> visualizerColorHex = const Value.absent(),
                Value<bool> crossfadeEnabled = const Value.absent(),
                Value<int> crossfadeDurationMs = const Value.absent(),
                Value<String?> currentEqualizerPresetId = const Value.absent(),
                Value<String> visualizerStyle = const Value.absent(),
                Value<bool> showAlbumArtInMiniPlayer = const Value.absent(),
                Value<bool> showVisualizerInMiniPlayer = const Value.absent(),
                Value<bool> showAlbumArtInNowPlaying = const Value.absent(),
                Value<String> visualizerPlacement = const Value.absent(),
                Value<bool> visualizerAsArtworkFallback = const Value.absent(),
                Value<double> visualizerSensitivity = const Value.absent(),
                Value<double> visualizerContrast = const Value.absent(),
                Value<double> visualizerFloor = const Value.absent(),
                Value<double> visualizerResponsiveness = const Value.absent(),
                Value<int> visualizerBarCount = const Value.absent(),
                Value<int> seekStepSeconds = const Value.absent(),
                Value<bool> includeVideos = const Value.absent(),
                Value<bool> realVisualizerEnabled = const Value.absent(),
                Value<bool> autoExcludeNonMusicFolders = const Value.absent(),
                Value<int> minimumTrackSeconds = const Value.absent(),
                Value<String> libraryFolderOverridesJson = const Value.absent(),
                Value<bool> compactNowPlaying = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion.insert(
                id: id,
                adaptiveDarkModeEnabled: adaptiveDarkModeEnabled,
                manualThemeOverride: manualThemeOverride,
                themeSeedColorHex: themeSeedColorHex,
                visualizerColorHex: visualizerColorHex,
                crossfadeEnabled: crossfadeEnabled,
                crossfadeDurationMs: crossfadeDurationMs,
                currentEqualizerPresetId: currentEqualizerPresetId,
                visualizerStyle: visualizerStyle,
                showAlbumArtInMiniPlayer: showAlbumArtInMiniPlayer,
                showVisualizerInMiniPlayer: showVisualizerInMiniPlayer,
                showAlbumArtInNowPlaying: showAlbumArtInNowPlaying,
                visualizerPlacement: visualizerPlacement,
                visualizerAsArtworkFallback: visualizerAsArtworkFallback,
                visualizerSensitivity: visualizerSensitivity,
                visualizerContrast: visualizerContrast,
                visualizerFloor: visualizerFloor,
                visualizerResponsiveness: visualizerResponsiveness,
                visualizerBarCount: visualizerBarCount,
                seekStepSeconds: seekStepSeconds,
                includeVideos: includeVideos,
                realVisualizerEnabled: realVisualizerEnabled,
                autoExcludeNonMusicFolders: autoExcludeNonMusicFolders,
                minimumTrackSeconds: minimumTrackSeconds,
                libraryFolderOverridesJson: libraryFolderOverridesJson,
                compactNowPlaying: compactNowPlaying,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      SettingsRow,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (SettingsRow, BaseReferences<_$AppDatabase, $SettingsTable, SettingsRow>),
      SettingsRow,
      PrefetchHooks Function()
    >;
typedef $$BackupsTableCreateCompanionBuilder =
    BackupsCompanion Function({
      required String id,
      required DateTime createdAt,
      required String filePath,
      Value<int> rowid,
    });
typedef $$BackupsTableUpdateCompanionBuilder =
    BackupsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<String> filePath,
      Value<int> rowid,
    });

class $$BackupsTableFilterComposer
    extends Composer<_$AppDatabase, $BackupsTable> {
  $$BackupsTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BackupsTableOrderingComposer
    extends Composer<_$AppDatabase, $BackupsTable> {
  $$BackupsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BackupsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BackupsTable> {
  $$BackupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);
}

class $$BackupsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BackupsTable,
          BackupRow,
          $$BackupsTableFilterComposer,
          $$BackupsTableOrderingComposer,
          $$BackupsTableAnnotationComposer,
          $$BackupsTableCreateCompanionBuilder,
          $$BackupsTableUpdateCompanionBuilder,
          (BackupRow, BaseReferences<_$AppDatabase, $BackupsTable, BackupRow>),
          BackupRow,
          PrefetchHooks Function()
        > {
  $$BackupsTableTableManager(_$AppDatabase db, $BackupsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BackupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BackupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BackupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BackupsCompanion(
                id: id,
                createdAt: createdAt,
                filePath: filePath,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required String filePath,
                Value<int> rowid = const Value.absent(),
              }) => BackupsCompanion.insert(
                id: id,
                createdAt: createdAt,
                filePath: filePath,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BackupsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BackupsTable,
      BackupRow,
      $$BackupsTableFilterComposer,
      $$BackupsTableOrderingComposer,
      $$BackupsTableAnnotationComposer,
      $$BackupsTableCreateCompanionBuilder,
      $$BackupsTableUpdateCompanionBuilder,
      (BackupRow, BaseReferences<_$AppDatabase, $BackupsTable, BackupRow>),
      BackupRow,
      PrefetchHooks Function()
    >;
typedef $$PlaybackSessionsTableCreateCompanionBuilder =
    PlaybackSessionsCompanion Function({
      required String id,
      Value<String> songIdsJson,
      Value<int> currentIndex,
      Value<int> positionMs,
      Value<bool> shuffleEnabled,
      Value<String> repeatMode,
      Value<double> speed,
      Value<String?> sourcePlaylistId,
      Value<int> rowid,
    });
typedef $$PlaybackSessionsTableUpdateCompanionBuilder =
    PlaybackSessionsCompanion Function({
      Value<String> id,
      Value<String> songIdsJson,
      Value<int> currentIndex,
      Value<int> positionMs,
      Value<bool> shuffleEnabled,
      Value<String> repeatMode,
      Value<double> speed,
      Value<String?> sourcePlaylistId,
      Value<int> rowid,
    });

class $$PlaybackSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $PlaybackSessionsTable> {
  $$PlaybackSessionsTableFilterComposer({
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

  ColumnFilters<String> get songIdsJson => $composableBuilder(
    column: $table.songIdsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentIndex => $composableBuilder(
    column: $table.currentIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get shuffleEnabled => $composableBuilder(
    column: $table.shuffleEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get repeatMode => $composableBuilder(
    column: $table.repeatMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get speed => $composableBuilder(
    column: $table.speed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourcePlaylistId => $composableBuilder(
    column: $table.sourcePlaylistId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlaybackSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaybackSessionsTable> {
  $$PlaybackSessionsTableOrderingComposer({
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

  ColumnOrderings<String> get songIdsJson => $composableBuilder(
    column: $table.songIdsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentIndex => $composableBuilder(
    column: $table.currentIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get shuffleEnabled => $composableBuilder(
    column: $table.shuffleEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get repeatMode => $composableBuilder(
    column: $table.repeatMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get speed => $composableBuilder(
    column: $table.speed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourcePlaylistId => $composableBuilder(
    column: $table.sourcePlaylistId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlaybackSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaybackSessionsTable> {
  $$PlaybackSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get songIdsJson => $composableBuilder(
    column: $table.songIdsJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get currentIndex => $composableBuilder(
    column: $table.currentIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get shuffleEnabled => $composableBuilder(
    column: $table.shuffleEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<String> get repeatMode => $composableBuilder(
    column: $table.repeatMode,
    builder: (column) => column,
  );

  GeneratedColumn<double> get speed =>
      $composableBuilder(column: $table.speed, builder: (column) => column);

  GeneratedColumn<String> get sourcePlaylistId => $composableBuilder(
    column: $table.sourcePlaylistId,
    builder: (column) => column,
  );
}

class $$PlaybackSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlaybackSessionsTable,
          PlaybackSessionRow,
          $$PlaybackSessionsTableFilterComposer,
          $$PlaybackSessionsTableOrderingComposer,
          $$PlaybackSessionsTableAnnotationComposer,
          $$PlaybackSessionsTableCreateCompanionBuilder,
          $$PlaybackSessionsTableUpdateCompanionBuilder,
          (
            PlaybackSessionRow,
            BaseReferences<
              _$AppDatabase,
              $PlaybackSessionsTable,
              PlaybackSessionRow
            >,
          ),
          PlaybackSessionRow,
          PrefetchHooks Function()
        > {
  $$PlaybackSessionsTableTableManager(
    _$AppDatabase db,
    $PlaybackSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaybackSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaybackSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaybackSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> songIdsJson = const Value.absent(),
                Value<int> currentIndex = const Value.absent(),
                Value<int> positionMs = const Value.absent(),
                Value<bool> shuffleEnabled = const Value.absent(),
                Value<String> repeatMode = const Value.absent(),
                Value<double> speed = const Value.absent(),
                Value<String?> sourcePlaylistId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlaybackSessionsCompanion(
                id: id,
                songIdsJson: songIdsJson,
                currentIndex: currentIndex,
                positionMs: positionMs,
                shuffleEnabled: shuffleEnabled,
                repeatMode: repeatMode,
                speed: speed,
                sourcePlaylistId: sourcePlaylistId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> songIdsJson = const Value.absent(),
                Value<int> currentIndex = const Value.absent(),
                Value<int> positionMs = const Value.absent(),
                Value<bool> shuffleEnabled = const Value.absent(),
                Value<String> repeatMode = const Value.absent(),
                Value<double> speed = const Value.absent(),
                Value<String?> sourcePlaylistId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlaybackSessionsCompanion.insert(
                id: id,
                songIdsJson: songIdsJson,
                currentIndex: currentIndex,
                positionMs: positionMs,
                shuffleEnabled: shuffleEnabled,
                repeatMode: repeatMode,
                speed: speed,
                sourcePlaylistId: sourcePlaylistId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlaybackSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlaybackSessionsTable,
      PlaybackSessionRow,
      $$PlaybackSessionsTableFilterComposer,
      $$PlaybackSessionsTableOrderingComposer,
      $$PlaybackSessionsTableAnnotationComposer,
      $$PlaybackSessionsTableCreateCompanionBuilder,
      $$PlaybackSessionsTableUpdateCompanionBuilder,
      (
        PlaybackSessionRow,
        BaseReferences<
          _$AppDatabase,
          $PlaybackSessionsTable,
          PlaybackSessionRow
        >,
      ),
      PlaybackSessionRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$VibeCategoriesTableTableManager get vibeCategories =>
      $$VibeCategoriesTableTableManager(_db, _db.vibeCategories);
  $$VibeTagsTableTableManager get vibeTags =>
      $$VibeTagsTableTableManager(_db, _db.vibeTags);
  $$SongsTableTableManager get songs =>
      $$SongsTableTableManager(_db, _db.songs);
  $$SongVibesTableTableManager get songVibes =>
      $$SongVibesTableTableManager(_db, _db.songVibes);
  $$GameScoresTableTableManager get gameScores =>
      $$GameScoresTableTableManager(_db, _db.gameScores);
  $$PlaylistsTableTableManager get playlists =>
      $$PlaylistsTableTableManager(_db, _db.playlists);
  $$PlaylistSongsTableTableManager get playlistSongs =>
      $$PlaylistSongsTableTableManager(_db, _db.playlistSongs);
  $$EqualizerPresetsTableTableManager get equalizerPresets =>
      $$EqualizerPresetsTableTableManager(_db, _db.equalizerPresets);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$BackupsTableTableManager get backups =>
      $$BackupsTableTableManager(_db, _db.backups);
  $$PlaybackSessionsTableTableManager get playbackSessions =>
      $$PlaybackSessionsTableTableManager(_db, _db.playbackSessions);
}
