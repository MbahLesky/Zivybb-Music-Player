// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $MoodTagsTable extends MoodTags
    with TableInfo<$MoodTagsTable, MoodTagRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MoodTagsTable(this.attachedDatabase, [this._alias]);
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
  @override
  List<GeneratedColumn> get $columns => [id, label, colorHex];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mood_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<MoodTagRow> instance, {
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MoodTagRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MoodTagRow(
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
    );
  }

  @override
  $MoodTagsTable createAlias(String alias) {
    return $MoodTagsTable(attachedDatabase, alias);
  }
}

class MoodTagRow extends DataClass implements Insertable<MoodTagRow> {
  final String id;
  final String label;
  final String colorHex;
  const MoodTagRow({
    required this.id,
    required this.label,
    required this.colorHex,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['label'] = Variable<String>(label);
    map['color_hex'] = Variable<String>(colorHex);
    return map;
  }

  MoodTagsCompanion toCompanion(bool nullToAbsent) {
    return MoodTagsCompanion(
      id: Value(id),
      label: Value(label),
      colorHex: Value(colorHex),
    );
  }

  factory MoodTagRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MoodTagRow(
      id: serializer.fromJson<String>(json['id']),
      label: serializer.fromJson<String>(json['label']),
      colorHex: serializer.fromJson<String>(json['colorHex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'label': serializer.toJson<String>(label),
      'colorHex': serializer.toJson<String>(colorHex),
    };
  }

  MoodTagRow copyWith({String? id, String? label, String? colorHex}) =>
      MoodTagRow(
        id: id ?? this.id,
        label: label ?? this.label,
        colorHex: colorHex ?? this.colorHex,
      );
  MoodTagRow copyWithCompanion(MoodTagsCompanion data) {
    return MoodTagRow(
      id: data.id.present ? data.id.value : this.id,
      label: data.label.present ? data.label.value : this.label,
      colorHex: data.colorHex.present ? data.colorHex.value : this.colorHex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MoodTagRow(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('colorHex: $colorHex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, label, colorHex);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MoodTagRow &&
          other.id == this.id &&
          other.label == this.label &&
          other.colorHex == this.colorHex);
}

class MoodTagsCompanion extends UpdateCompanion<MoodTagRow> {
  final Value<String> id;
  final Value<String> label;
  final Value<String> colorHex;
  final Value<int> rowid;
  const MoodTagsCompanion({
    this.id = const Value.absent(),
    this.label = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MoodTagsCompanion.insert({
    required String id,
    required String label,
    required String colorHex,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       label = Value(label),
       colorHex = Value(colorHex);
  static Insertable<MoodTagRow> custom({
    Expression<String>? id,
    Expression<String>? label,
    Expression<String>? colorHex,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (label != null) 'label': label,
      if (colorHex != null) 'color_hex': colorHex,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MoodTagsCompanion copyWith({
    Value<String>? id,
    Value<String>? label,
    Value<String>? colorHex,
    Value<int>? rowid,
  }) {
    return MoodTagsCompanion(
      id: id ?? this.id,
      label: label ?? this.label,
      colorHex: colorHex ?? this.colorHex,
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
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MoodTagsCompanion(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('colorHex: $colorHex, ')
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
  static const VerificationMeta _moodTagIdMeta = const VerificationMeta(
    'moodTagId',
  );
  @override
  late final GeneratedColumn<String> moodTagId = GeneratedColumn<String>(
    'mood_tag_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES mood_tags (id) ON DELETE SET NULL',
    ),
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    filePath,
    title,
    artist,
    album,
    durationMs,
    moodTagId,
    isLiked,
    isMissing,
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
    if (data.containsKey('mood_tag_id')) {
      context.handle(
        _moodTagIdMeta,
        moodTagId.isAcceptableOrUnknown(data['mood_tag_id']!, _moodTagIdMeta),
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
      moodTagId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mood_tag_id'],
      ),
      isLiked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_liked'],
      )!,
      isMissing: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_missing'],
      )!,
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
  final String? moodTagId;
  final bool isLiked;
  final bool isMissing;
  const SongRow({
    required this.id,
    required this.filePath,
    required this.title,
    required this.artist,
    required this.album,
    required this.durationMs,
    this.moodTagId,
    required this.isLiked,
    required this.isMissing,
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
    if (!nullToAbsent || moodTagId != null) {
      map['mood_tag_id'] = Variable<String>(moodTagId);
    }
    map['is_liked'] = Variable<bool>(isLiked);
    map['is_missing'] = Variable<bool>(isMissing);
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
      moodTagId: moodTagId == null && nullToAbsent
          ? const Value.absent()
          : Value(moodTagId),
      isLiked: Value(isLiked),
      isMissing: Value(isMissing),
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
      moodTagId: serializer.fromJson<String?>(json['moodTagId']),
      isLiked: serializer.fromJson<bool>(json['isLiked']),
      isMissing: serializer.fromJson<bool>(json['isMissing']),
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
      'moodTagId': serializer.toJson<String?>(moodTagId),
      'isLiked': serializer.toJson<bool>(isLiked),
      'isMissing': serializer.toJson<bool>(isMissing),
    };
  }

  SongRow copyWith({
    String? id,
    String? filePath,
    String? title,
    String? artist,
    String? album,
    int? durationMs,
    Value<String?> moodTagId = const Value.absent(),
    bool? isLiked,
    bool? isMissing,
  }) => SongRow(
    id: id ?? this.id,
    filePath: filePath ?? this.filePath,
    title: title ?? this.title,
    artist: artist ?? this.artist,
    album: album ?? this.album,
    durationMs: durationMs ?? this.durationMs,
    moodTagId: moodTagId.present ? moodTagId.value : this.moodTagId,
    isLiked: isLiked ?? this.isLiked,
    isMissing: isMissing ?? this.isMissing,
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
      moodTagId: data.moodTagId.present ? data.moodTagId.value : this.moodTagId,
      isLiked: data.isLiked.present ? data.isLiked.value : this.isLiked,
      isMissing: data.isMissing.present ? data.isMissing.value : this.isMissing,
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
          ..write('moodTagId: $moodTagId, ')
          ..write('isLiked: $isLiked, ')
          ..write('isMissing: $isMissing')
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
    moodTagId,
    isLiked,
    isMissing,
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
          other.moodTagId == this.moodTagId &&
          other.isLiked == this.isLiked &&
          other.isMissing == this.isMissing);
}

class SongsCompanion extends UpdateCompanion<SongRow> {
  final Value<String> id;
  final Value<String> filePath;
  final Value<String> title;
  final Value<String> artist;
  final Value<String> album;
  final Value<int> durationMs;
  final Value<String?> moodTagId;
  final Value<bool> isLiked;
  final Value<bool> isMissing;
  final Value<int> rowid;
  const SongsCompanion({
    this.id = const Value.absent(),
    this.filePath = const Value.absent(),
    this.title = const Value.absent(),
    this.artist = const Value.absent(),
    this.album = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.moodTagId = const Value.absent(),
    this.isLiked = const Value.absent(),
    this.isMissing = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SongsCompanion.insert({
    required String id,
    required String filePath,
    required String title,
    required String artist,
    required String album,
    required int durationMs,
    this.moodTagId = const Value.absent(),
    this.isLiked = const Value.absent(),
    this.isMissing = const Value.absent(),
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
    Expression<String>? moodTagId,
    Expression<bool>? isLiked,
    Expression<bool>? isMissing,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (filePath != null) 'file_path': filePath,
      if (title != null) 'title': title,
      if (artist != null) 'artist': artist,
      if (album != null) 'album': album,
      if (durationMs != null) 'duration_ms': durationMs,
      if (moodTagId != null) 'mood_tag_id': moodTagId,
      if (isLiked != null) 'is_liked': isLiked,
      if (isMissing != null) 'is_missing': isMissing,
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
    Value<String?>? moodTagId,
    Value<bool>? isLiked,
    Value<bool>? isMissing,
    Value<int>? rowid,
  }) {
    return SongsCompanion(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      durationMs: durationMs ?? this.durationMs,
      moodTagId: moodTagId ?? this.moodTagId,
      isLiked: isLiked ?? this.isLiked,
      isMissing: isMissing ?? this.isMissing,
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
    if (moodTagId.present) {
      map['mood_tag_id'] = Variable<String>(moodTagId.value);
    }
    if (isLiked.present) {
      map['is_liked'] = Variable<bool>(isLiked.value);
    }
    if (isMissing.present) {
      map['is_missing'] = Variable<bool>(isMissing.value);
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
          ..write('moodTagId: $moodTagId, ')
          ..write('isLiked: $isLiked, ')
          ..write('isMissing: $isMissing, ')
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
  static const VerificationMeta _sourceMoodTagIdMeta = const VerificationMeta(
    'sourceMoodTagId',
  );
  @override
  late final GeneratedColumn<String> sourceMoodTagId = GeneratedColumn<String>(
    'source_mood_tag_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES mood_tags (id) ON DELETE SET NULL',
    ),
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
    name,
    isAutoGenerated,
    sourceMoodTagId,
    createdAt,
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
    if (data.containsKey('source_mood_tag_id')) {
      context.handle(
        _sourceMoodTagIdMeta,
        sourceMoodTagId.isAcceptableOrUnknown(
          data['source_mood_tag_id']!,
          _sourceMoodTagIdMeta,
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
      sourceMoodTagId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_mood_tag_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
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
  final String? sourceMoodTagId;
  final DateTime createdAt;
  const PlaylistRow({
    required this.id,
    required this.name,
    required this.isAutoGenerated,
    this.sourceMoodTagId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['is_auto_generated'] = Variable<bool>(isAutoGenerated);
    if (!nullToAbsent || sourceMoodTagId != null) {
      map['source_mood_tag_id'] = Variable<String>(sourceMoodTagId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PlaylistsCompanion toCompanion(bool nullToAbsent) {
    return PlaylistsCompanion(
      id: Value(id),
      name: Value(name),
      isAutoGenerated: Value(isAutoGenerated),
      sourceMoodTagId: sourceMoodTagId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceMoodTagId),
      createdAt: Value(createdAt),
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
      sourceMoodTagId: serializer.fromJson<String?>(json['sourceMoodTagId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'isAutoGenerated': serializer.toJson<bool>(isAutoGenerated),
      'sourceMoodTagId': serializer.toJson<String?>(sourceMoodTagId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PlaylistRow copyWith({
    String? id,
    String? name,
    bool? isAutoGenerated,
    Value<String?> sourceMoodTagId = const Value.absent(),
    DateTime? createdAt,
  }) => PlaylistRow(
    id: id ?? this.id,
    name: name ?? this.name,
    isAutoGenerated: isAutoGenerated ?? this.isAutoGenerated,
    sourceMoodTagId: sourceMoodTagId.present
        ? sourceMoodTagId.value
        : this.sourceMoodTagId,
    createdAt: createdAt ?? this.createdAt,
  );
  PlaylistRow copyWithCompanion(PlaylistsCompanion data) {
    return PlaylistRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      isAutoGenerated: data.isAutoGenerated.present
          ? data.isAutoGenerated.value
          : this.isAutoGenerated,
      sourceMoodTagId: data.sourceMoodTagId.present
          ? data.sourceMoodTagId.value
          : this.sourceMoodTagId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isAutoGenerated: $isAutoGenerated, ')
          ..write('sourceMoodTagId: $sourceMoodTagId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, isAutoGenerated, sourceMoodTagId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaylistRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.isAutoGenerated == this.isAutoGenerated &&
          other.sourceMoodTagId == this.sourceMoodTagId &&
          other.createdAt == this.createdAt);
}

class PlaylistsCompanion extends UpdateCompanion<PlaylistRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<bool> isAutoGenerated;
  final Value<String?> sourceMoodTagId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PlaylistsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.isAutoGenerated = const Value.absent(),
    this.sourceMoodTagId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlaylistsCompanion.insert({
    required String id,
    required String name,
    this.isAutoGenerated = const Value.absent(),
    this.sourceMoodTagId = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<PlaylistRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<bool>? isAutoGenerated,
    Expression<String>? sourceMoodTagId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (isAutoGenerated != null) 'is_auto_generated': isAutoGenerated,
      if (sourceMoodTagId != null) 'source_mood_tag_id': sourceMoodTagId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlaylistsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<bool>? isAutoGenerated,
    Value<String?>? sourceMoodTagId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return PlaylistsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      isAutoGenerated: isAutoGenerated ?? this.isAutoGenerated,
      sourceMoodTagId: sourceMoodTagId ?? this.sourceMoodTagId,
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
    if (isAutoGenerated.present) {
      map['is_auto_generated'] = Variable<bool>(isAutoGenerated.value);
    }
    if (sourceMoodTagId.present) {
      map['source_mood_tag_id'] = Variable<String>(sourceMoodTagId.value);
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
    return (StringBuffer('PlaylistsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isAutoGenerated: $isAutoGenerated, ')
          ..write('sourceMoodTagId: $sourceMoodTagId, ')
          ..write('createdAt: $createdAt, ')
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES playlists (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _songIdMeta = const VerificationMeta('songId');
  @override
  late final GeneratedColumn<String> songId = GeneratedColumn<String>(
    'song_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES songs (id) ON DELETE CASCADE',
    ),
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
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES equalizer_presets (id) ON DELETE SET NULL',
        ),
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
  const SettingsRow({
    required this.id,
    required this.adaptiveDarkModeEnabled,
    this.manualThemeOverride,
    required this.themeSeedColorHex,
    required this.visualizerColorHex,
    required this.crossfadeEnabled,
    required this.crossfadeDurationMs,
    this.currentEqualizerPresetId,
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
          ..write('currentEqualizerPresetId: $currentEqualizerPresetId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    adaptiveDarkModeEnabled,
    manualThemeOverride,
    themeSeedColorHex,
    visualizerColorHex,
    crossfadeEnabled,
    crossfadeDurationMs,
    currentEqualizerPresetId,
  );
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
          other.currentEqualizerPresetId == this.currentEqualizerPresetId);
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

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MoodTagsTable moodTags = $MoodTagsTable(this);
  late final $SongsTable songs = $SongsTable(this);
  late final $PlaylistsTable playlists = $PlaylistsTable(this);
  late final $PlaylistSongsTable playlistSongs = $PlaylistSongsTable(this);
  late final $EqualizerPresetsTable equalizerPresets = $EqualizerPresetsTable(
    this,
  );
  late final $SettingsTable settings = $SettingsTable(this);
  late final $BackupsTable backups = $BackupsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    moodTags,
    songs,
    playlists,
    playlistSongs,
    equalizerPresets,
    settings,
    backups,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'mood_tags',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('songs', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'mood_tags',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('playlists', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'playlists',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('playlist_songs', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'songs',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('playlist_songs', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'equalizer_presets',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('settings', kind: UpdateKind.update)],
    ),
  ]);
}

typedef $$MoodTagsTableCreateCompanionBuilder =
    MoodTagsCompanion Function({
      required String id,
      required String label,
      required String colorHex,
      Value<int> rowid,
    });
typedef $$MoodTagsTableUpdateCompanionBuilder =
    MoodTagsCompanion Function({
      Value<String> id,
      Value<String> label,
      Value<String> colorHex,
      Value<int> rowid,
    });

final class $$MoodTagsTableReferences
    extends BaseReferences<_$AppDatabase, $MoodTagsTable, MoodTagRow> {
  $$MoodTagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SongsTable, List<SongRow>> _songsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.songs,
    aliasName: 'mood_tags__id__songs__mood_tag_id',
  );

  $$SongsTableProcessedTableManager get songsRefs {
    final manager = $$SongsTableTableManager(
      $_db,
      $_db.songs,
    ).filter((f) => f.moodTagId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_songsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PlaylistsTable, List<PlaylistRow>>
  _playlistsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.playlists,
    aliasName: 'mood_tags__id__playlists__source_mood_tag_id',
  );

  $$PlaylistsTableProcessedTableManager get playlistsRefs {
    final manager = $$PlaylistsTableTableManager($_db, $_db.playlists).filter(
      (f) => f.sourceMoodTagId.id.sqlEquals($_itemColumn<String>('id')!),
    );

    final cache = $_typedResult.readTableOrNull(_playlistsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MoodTagsTableFilterComposer
    extends Composer<_$AppDatabase, $MoodTagsTable> {
  $$MoodTagsTableFilterComposer({
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

  Expression<bool> songsRefs(
    Expression<bool> Function($$SongsTableFilterComposer f) f,
  ) {
    final $$SongsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.songs,
      getReferencedColumn: (t) => t.moodTagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongsTableFilterComposer(
            $db: $db,
            $table: $db.songs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> playlistsRefs(
    Expression<bool> Function($$PlaylistsTableFilterComposer f) f,
  ) {
    final $$PlaylistsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playlists,
      getReferencedColumn: (t) => t.sourceMoodTagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableFilterComposer(
            $db: $db,
            $table: $db.playlists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MoodTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $MoodTagsTable> {
  $$MoodTagsTableOrderingComposer({
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
}

class $$MoodTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MoodTagsTable> {
  $$MoodTagsTableAnnotationComposer({
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

  Expression<T> songsRefs<T extends Object>(
    Expression<T> Function($$SongsTableAnnotationComposer a) f,
  ) {
    final $$SongsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.songs,
      getReferencedColumn: (t) => t.moodTagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongsTableAnnotationComposer(
            $db: $db,
            $table: $db.songs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> playlistsRefs<T extends Object>(
    Expression<T> Function($$PlaylistsTableAnnotationComposer a) f,
  ) {
    final $$PlaylistsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playlists,
      getReferencedColumn: (t) => t.sourceMoodTagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableAnnotationComposer(
            $db: $db,
            $table: $db.playlists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MoodTagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MoodTagsTable,
          MoodTagRow,
          $$MoodTagsTableFilterComposer,
          $$MoodTagsTableOrderingComposer,
          $$MoodTagsTableAnnotationComposer,
          $$MoodTagsTableCreateCompanionBuilder,
          $$MoodTagsTableUpdateCompanionBuilder,
          (MoodTagRow, $$MoodTagsTableReferences),
          MoodTagRow,
          PrefetchHooks Function({bool songsRefs, bool playlistsRefs})
        > {
  $$MoodTagsTableTableManager(_$AppDatabase db, $MoodTagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MoodTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MoodTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MoodTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String> colorHex = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MoodTagsCompanion(
                id: id,
                label: label,
                colorHex: colorHex,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String label,
                required String colorHex,
                Value<int> rowid = const Value.absent(),
              }) => MoodTagsCompanion.insert(
                id: id,
                label: label,
                colorHex: colorHex,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MoodTagsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({songsRefs = false, playlistsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (songsRefs) db.songs,
                if (playlistsRefs) db.playlists,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (songsRefs)
                    await $_getPrefetchedData<
                      MoodTagRow,
                      $MoodTagsTable,
                      SongRow
                    >(
                      currentTable: table,
                      referencedTable: $$MoodTagsTableReferences
                          ._songsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$MoodTagsTableReferences(db, table, p0).songsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.moodTagId == item.id),
                      typedResults: items,
                    ),
                  if (playlistsRefs)
                    await $_getPrefetchedData<
                      MoodTagRow,
                      $MoodTagsTable,
                      PlaylistRow
                    >(
                      currentTable: table,
                      referencedTable: $$MoodTagsTableReferences
                          ._playlistsRefsTable(db),
                      managerFromTypedResult: (p0) => $$MoodTagsTableReferences(
                        db,
                        table,
                        p0,
                      ).playlistsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.sourceMoodTagId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$MoodTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MoodTagsTable,
      MoodTagRow,
      $$MoodTagsTableFilterComposer,
      $$MoodTagsTableOrderingComposer,
      $$MoodTagsTableAnnotationComposer,
      $$MoodTagsTableCreateCompanionBuilder,
      $$MoodTagsTableUpdateCompanionBuilder,
      (MoodTagRow, $$MoodTagsTableReferences),
      MoodTagRow,
      PrefetchHooks Function({bool songsRefs, bool playlistsRefs})
    >;
typedef $$SongsTableCreateCompanionBuilder =
    SongsCompanion Function({
      required String id,
      required String filePath,
      required String title,
      required String artist,
      required String album,
      required int durationMs,
      Value<String?> moodTagId,
      Value<bool> isLiked,
      Value<bool> isMissing,
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
      Value<String?> moodTagId,
      Value<bool> isLiked,
      Value<bool> isMissing,
      Value<int> rowid,
    });

final class $$SongsTableReferences
    extends BaseReferences<_$AppDatabase, $SongsTable, SongRow> {
  $$SongsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MoodTagsTable _moodTagIdTable(_$AppDatabase db) =>
      db.moodTags.createAlias('songs__mood_tag_id__mood_tags__id');

  $$MoodTagsTableProcessedTableManager? get moodTagId {
    final $_column = $_itemColumn<String>('mood_tag_id');
    if ($_column == null) return null;
    final manager = $$MoodTagsTableTableManager(
      $_db,
      $_db.moodTags,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_moodTagIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$PlaylistSongsTable, List<PlaylistSongRow>>
  _playlistSongsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.playlistSongs,
    aliasName: 'songs__id__playlist_songs__song_id',
  );

  $$PlaylistSongsTableProcessedTableManager get playlistSongsRefs {
    final manager = $$PlaylistSongsTableTableManager(
      $_db,
      $_db.playlistSongs,
    ).filter((f) => f.songId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_playlistSongsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

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

  ColumnFilters<bool> get isLiked => $composableBuilder(
    column: $table.isLiked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isMissing => $composableBuilder(
    column: $table.isMissing,
    builder: (column) => ColumnFilters(column),
  );

  $$MoodTagsTableFilterComposer get moodTagId {
    final $$MoodTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.moodTagId,
      referencedTable: $db.moodTags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MoodTagsTableFilterComposer(
            $db: $db,
            $table: $db.moodTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> playlistSongsRefs(
    Expression<bool> Function($$PlaylistSongsTableFilterComposer f) f,
  ) {
    final $$PlaylistSongsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playlistSongs,
      getReferencedColumn: (t) => t.songId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistSongsTableFilterComposer(
            $db: $db,
            $table: $db.playlistSongs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
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

  ColumnOrderings<bool> get isLiked => $composableBuilder(
    column: $table.isLiked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isMissing => $composableBuilder(
    column: $table.isMissing,
    builder: (column) => ColumnOrderings(column),
  );

  $$MoodTagsTableOrderingComposer get moodTagId {
    final $$MoodTagsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.moodTagId,
      referencedTable: $db.moodTags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MoodTagsTableOrderingComposer(
            $db: $db,
            $table: $db.moodTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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

  GeneratedColumn<bool> get isLiked =>
      $composableBuilder(column: $table.isLiked, builder: (column) => column);

  GeneratedColumn<bool> get isMissing =>
      $composableBuilder(column: $table.isMissing, builder: (column) => column);

  $$MoodTagsTableAnnotationComposer get moodTagId {
    final $$MoodTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.moodTagId,
      referencedTable: $db.moodTags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MoodTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.moodTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> playlistSongsRefs<T extends Object>(
    Expression<T> Function($$PlaylistSongsTableAnnotationComposer a) f,
  ) {
    final $$PlaylistSongsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playlistSongs,
      getReferencedColumn: (t) => t.songId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistSongsTableAnnotationComposer(
            $db: $db,
            $table: $db.playlistSongs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
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
          (SongRow, $$SongsTableReferences),
          SongRow,
          PrefetchHooks Function({bool moodTagId, bool playlistSongsRefs})
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
                Value<String?> moodTagId = const Value.absent(),
                Value<bool> isLiked = const Value.absent(),
                Value<bool> isMissing = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SongsCompanion(
                id: id,
                filePath: filePath,
                title: title,
                artist: artist,
                album: album,
                durationMs: durationMs,
                moodTagId: moodTagId,
                isLiked: isLiked,
                isMissing: isMissing,
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
                Value<String?> moodTagId = const Value.absent(),
                Value<bool> isLiked = const Value.absent(),
                Value<bool> isMissing = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SongsCompanion.insert(
                id: id,
                filePath: filePath,
                title: title,
                artist: artist,
                album: album,
                durationMs: durationMs,
                moodTagId: moodTagId,
                isLiked: isLiked,
                isMissing: isMissing,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$SongsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({moodTagId = false, playlistSongsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (playlistSongsRefs) db.playlistSongs,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (moodTagId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.moodTagId,
                                    referencedTable: $$SongsTableReferences
                                        ._moodTagIdTable(db),
                                    referencedColumn: $$SongsTableReferences
                                        ._moodTagIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (playlistSongsRefs)
                        await $_getPrefetchedData<
                          SongRow,
                          $SongsTable,
                          PlaylistSongRow
                        >(
                          currentTable: table,
                          referencedTable: $$SongsTableReferences
                              ._playlistSongsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SongsTableReferences(
                                db,
                                table,
                                p0,
                              ).playlistSongsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.songId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
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
      (SongRow, $$SongsTableReferences),
      SongRow,
      PrefetchHooks Function({bool moodTagId, bool playlistSongsRefs})
    >;
typedef $$PlaylistsTableCreateCompanionBuilder =
    PlaylistsCompanion Function({
      required String id,
      required String name,
      Value<bool> isAutoGenerated,
      Value<String?> sourceMoodTagId,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$PlaylistsTableUpdateCompanionBuilder =
    PlaylistsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<bool> isAutoGenerated,
      Value<String?> sourceMoodTagId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$PlaylistsTableReferences
    extends BaseReferences<_$AppDatabase, $PlaylistsTable, PlaylistRow> {
  $$PlaylistsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MoodTagsTable _sourceMoodTagIdTable(_$AppDatabase db) =>
      db.moodTags.createAlias('playlists__source_mood_tag_id__mood_tags__id');

  $$MoodTagsTableProcessedTableManager? get sourceMoodTagId {
    final $_column = $_itemColumn<String>('source_mood_tag_id');
    if ($_column == null) return null;
    final manager = $$MoodTagsTableTableManager(
      $_db,
      $_db.moodTags,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceMoodTagIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$PlaylistSongsTable, List<PlaylistSongRow>>
  _playlistSongsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.playlistSongs,
    aliasName: 'playlists__id__playlist_songs__playlist_id',
  );

  $$PlaylistSongsTableProcessedTableManager get playlistSongsRefs {
    final manager = $$PlaylistSongsTableTableManager(
      $_db,
      $_db.playlistSongs,
    ).filter((f) => f.playlistId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_playlistSongsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$MoodTagsTableFilterComposer get sourceMoodTagId {
    final $$MoodTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceMoodTagId,
      referencedTable: $db.moodTags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MoodTagsTableFilterComposer(
            $db: $db,
            $table: $db.moodTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> playlistSongsRefs(
    Expression<bool> Function($$PlaylistSongsTableFilterComposer f) f,
  ) {
    final $$PlaylistSongsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playlistSongs,
      getReferencedColumn: (t) => t.playlistId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistSongsTableFilterComposer(
            $db: $db,
            $table: $db.playlistSongs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$MoodTagsTableOrderingComposer get sourceMoodTagId {
    final $$MoodTagsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceMoodTagId,
      referencedTable: $db.moodTags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MoodTagsTableOrderingComposer(
            $db: $db,
            $table: $db.moodTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$MoodTagsTableAnnotationComposer get sourceMoodTagId {
    final $$MoodTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceMoodTagId,
      referencedTable: $db.moodTags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MoodTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.moodTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> playlistSongsRefs<T extends Object>(
    Expression<T> Function($$PlaylistSongsTableAnnotationComposer a) f,
  ) {
    final $$PlaylistSongsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playlistSongs,
      getReferencedColumn: (t) => t.playlistId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistSongsTableAnnotationComposer(
            $db: $db,
            $table: $db.playlistSongs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
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
          (PlaylistRow, $$PlaylistsTableReferences),
          PlaylistRow,
          PrefetchHooks Function({bool sourceMoodTagId, bool playlistSongsRefs})
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
                Value<String?> sourceMoodTagId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlaylistsCompanion(
                id: id,
                name: name,
                isAutoGenerated: isAutoGenerated,
                sourceMoodTagId: sourceMoodTagId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<bool> isAutoGenerated = const Value.absent(),
                Value<String?> sourceMoodTagId = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => PlaylistsCompanion.insert(
                id: id,
                name: name,
                isAutoGenerated: isAutoGenerated,
                sourceMoodTagId: sourceMoodTagId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PlaylistsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({sourceMoodTagId = false, playlistSongsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (playlistSongsRefs) db.playlistSongs,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (sourceMoodTagId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.sourceMoodTagId,
                                    referencedTable: $$PlaylistsTableReferences
                                        ._sourceMoodTagIdTable(db),
                                    referencedColumn: $$PlaylistsTableReferences
                                        ._sourceMoodTagIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (playlistSongsRefs)
                        await $_getPrefetchedData<
                          PlaylistRow,
                          $PlaylistsTable,
                          PlaylistSongRow
                        >(
                          currentTable: table,
                          referencedTable: $$PlaylistsTableReferences
                              ._playlistSongsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PlaylistsTableReferences(
                                db,
                                table,
                                p0,
                              ).playlistSongsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.playlistId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
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
      (PlaylistRow, $$PlaylistsTableReferences),
      PlaylistRow,
      PrefetchHooks Function({bool sourceMoodTagId, bool playlistSongsRefs})
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

final class $$PlaylistSongsTableReferences
    extends
        BaseReferences<_$AppDatabase, $PlaylistSongsTable, PlaylistSongRow> {
  $$PlaylistSongsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PlaylistsTable _playlistIdTable(_$AppDatabase db) =>
      db.playlists.createAlias('playlist_songs__playlist_id__playlists__id');

  $$PlaylistsTableProcessedTableManager get playlistId {
    final $_column = $_itemColumn<String>('playlist_id')!;

    final manager = $$PlaylistsTableTableManager(
      $_db,
      $_db.playlists,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_playlistIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SongsTable _songIdTable(_$AppDatabase db) =>
      db.songs.createAlias('playlist_songs__song_id__songs__id');

  $$SongsTableProcessedTableManager get songId {
    final $_column = $_itemColumn<String>('song_id')!;

    final manager = $$SongsTableTableManager(
      $_db,
      $_db.songs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_songIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PlaylistSongsTableFilterComposer
    extends Composer<_$AppDatabase, $PlaylistSongsTable> {
  $$PlaylistSongsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  $$PlaylistsTableFilterComposer get playlistId {
    final $$PlaylistsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableFilterComposer(
            $db: $db,
            $table: $db.playlists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SongsTableFilterComposer get songId {
    final $$SongsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.songs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongsTableFilterComposer(
            $db: $db,
            $table: $db.songs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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
  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  $$PlaylistsTableOrderingComposer get playlistId {
    final $$PlaylistsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableOrderingComposer(
            $db: $db,
            $table: $db.playlists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SongsTableOrderingComposer get songId {
    final $$SongsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.songs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongsTableOrderingComposer(
            $db: $db,
            $table: $db.songs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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
  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  $$PlaylistsTableAnnotationComposer get playlistId {
    final $$PlaylistsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableAnnotationComposer(
            $db: $db,
            $table: $db.playlists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SongsTableAnnotationComposer get songId {
    final $$SongsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.songs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongsTableAnnotationComposer(
            $db: $db,
            $table: $db.songs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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
          (PlaylistSongRow, $$PlaylistSongsTableReferences),
          PlaylistSongRow,
          PrefetchHooks Function({bool playlistId, bool songId})
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
              .map(
                (e) => (
                  e.readTable(table),
                  $$PlaylistSongsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({playlistId = false, songId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (playlistId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.playlistId,
                                referencedTable: $$PlaylistSongsTableReferences
                                    ._playlistIdTable(db),
                                referencedColumn: $$PlaylistSongsTableReferences
                                    ._playlistIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (songId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.songId,
                                referencedTable: $$PlaylistSongsTableReferences
                                    ._songIdTable(db),
                                referencedColumn: $$PlaylistSongsTableReferences
                                    ._songIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
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
      (PlaylistSongRow, $$PlaylistSongsTableReferences),
      PlaylistSongRow,
      PrefetchHooks Function({bool playlistId, bool songId})
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

final class $$EqualizerPresetsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $EqualizerPresetsTable,
          EqualizerPresetRow
        > {
  $$EqualizerPresetsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$SettingsTable, List<SettingsRow>>
  _settingsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.settings,
    aliasName: 'equalizer_presets__id__settings__current_equalizer_preset_id',
  );

  $$SettingsTableProcessedTableManager get settingsRefs {
    final manager = $$SettingsTableTableManager($_db, $_db.settings).filter(
      (f) =>
          f.currentEqualizerPresetId.id.sqlEquals($_itemColumn<String>('id')!),
    );

    final cache = $_typedResult.readTableOrNull(_settingsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

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

  Expression<bool> settingsRefs(
    Expression<bool> Function($$SettingsTableFilterComposer f) f,
  ) {
    final $$SettingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.settings,
      getReferencedColumn: (t) => t.currentEqualizerPresetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SettingsTableFilterComposer(
            $db: $db,
            $table: $db.settings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
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

  Expression<T> settingsRefs<T extends Object>(
    Expression<T> Function($$SettingsTableAnnotationComposer a) f,
  ) {
    final $$SettingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.settings,
      getReferencedColumn: (t) => t.currentEqualizerPresetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SettingsTableAnnotationComposer(
            $db: $db,
            $table: $db.settings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
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
          (EqualizerPresetRow, $$EqualizerPresetsTableReferences),
          EqualizerPresetRow,
          PrefetchHooks Function({bool settingsRefs})
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
              .map(
                (e) => (
                  e.readTable(table),
                  $$EqualizerPresetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({settingsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (settingsRefs) db.settings],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (settingsRefs)
                    await $_getPrefetchedData<
                      EqualizerPresetRow,
                      $EqualizerPresetsTable,
                      SettingsRow
                    >(
                      currentTable: table,
                      referencedTable: $$EqualizerPresetsTableReferences
                          ._settingsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$EqualizerPresetsTableReferences(
                            db,
                            table,
                            p0,
                          ).settingsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.currentEqualizerPresetId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
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
      (EqualizerPresetRow, $$EqualizerPresetsTableReferences),
      EqualizerPresetRow,
      PrefetchHooks Function({bool settingsRefs})
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
      Value<int> rowid,
    });

final class $$SettingsTableReferences
    extends BaseReferences<_$AppDatabase, $SettingsTable, SettingsRow> {
  $$SettingsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $EqualizerPresetsTable _currentEqualizerPresetIdTable(
    _$AppDatabase db,
  ) => db.equalizerPresets.createAlias(
    'settings__current_equalizer_preset_id__equalizer_presets__id',
  );

  $$EqualizerPresetsTableProcessedTableManager? get currentEqualizerPresetId {
    final $_column = $_itemColumn<String>('current_equalizer_preset_id');
    if ($_column == null) return null;
    final manager = $$EqualizerPresetsTableTableManager(
      $_db,
      $_db.equalizerPresets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(
      _currentEqualizerPresetIdTable($_db),
    );
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

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

  $$EqualizerPresetsTableFilterComposer get currentEqualizerPresetId {
    final $$EqualizerPresetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.currentEqualizerPresetId,
      referencedTable: $db.equalizerPresets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EqualizerPresetsTableFilterComposer(
            $db: $db,
            $table: $db.equalizerPresets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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

  $$EqualizerPresetsTableOrderingComposer get currentEqualizerPresetId {
    final $$EqualizerPresetsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.currentEqualizerPresetId,
      referencedTable: $db.equalizerPresets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EqualizerPresetsTableOrderingComposer(
            $db: $db,
            $table: $db.equalizerPresets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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

  $$EqualizerPresetsTableAnnotationComposer get currentEqualizerPresetId {
    final $$EqualizerPresetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.currentEqualizerPresetId,
      referencedTable: $db.equalizerPresets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EqualizerPresetsTableAnnotationComposer(
            $db: $db,
            $table: $db.equalizerPresets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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
          (SettingsRow, $$SettingsTableReferences),
          SettingsRow,
          PrefetchHooks Function({bool currentEqualizerPresetId})
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
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SettingsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({currentEqualizerPresetId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (currentEqualizerPresetId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.currentEqualizerPresetId,
                                referencedTable: $$SettingsTableReferences
                                    ._currentEqualizerPresetIdTable(db),
                                referencedColumn: $$SettingsTableReferences
                                    ._currentEqualizerPresetIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
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
      (SettingsRow, $$SettingsTableReferences),
      SettingsRow,
      PrefetchHooks Function({bool currentEqualizerPresetId})
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

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MoodTagsTableTableManager get moodTags =>
      $$MoodTagsTableTableManager(_db, _db.moodTags);
  $$SongsTableTableManager get songs =>
      $$SongsTableTableManager(_db, _db.songs);
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
}
