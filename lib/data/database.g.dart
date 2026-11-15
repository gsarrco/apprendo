// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $DecksTable extends Decks with TableInfo<$DecksTable, DeckRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DecksTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _keepAttachmentsOfflineMeta =
      const VerificationMeta('keepAttachmentsOffline');
  @override
  late final GeneratedColumn<bool> keepAttachmentsOffline =
      GeneratedColumn<bool>(
        'keep_attachments_offline',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("keep_attachments_offline" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    keepAttachmentsOffline,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'decks';
  @override
  VerificationContext validateIntegrity(
    Insertable<DeckRow> instance, {
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
    if (data.containsKey('keep_attachments_offline')) {
      context.handle(
        _keepAttachmentsOfflineMeta,
        keepAttachmentsOffline.isAcceptableOrUnknown(
          data['keep_attachments_offline']!,
          _keepAttachmentsOfflineMeta,
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
  DeckRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeckRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      keepAttachmentsOffline: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}keep_attachments_offline'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $DecksTable createAlias(String alias) {
    return $DecksTable(attachedDatabase, alias);
  }
}

class DeckRow extends DataClass implements Insertable<DeckRow> {
  final String id;
  final String name;
  final bool keepAttachmentsOffline;
  final int createdAt;
  const DeckRow({
    required this.id,
    required this.name,
    required this.keepAttachmentsOffline,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['keep_attachments_offline'] = Variable<bool>(keepAttachmentsOffline);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  DecksCompanion toCompanion(bool nullToAbsent) {
    return DecksCompanion(
      id: Value(id),
      name: Value(name),
      keepAttachmentsOffline: Value(keepAttachmentsOffline),
      createdAt: Value(createdAt),
    );
  }

  factory DeckRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeckRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      keepAttachmentsOffline: serializer.fromJson<bool>(
        json['keepAttachmentsOffline'],
      ),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'keepAttachmentsOffline': serializer.toJson<bool>(keepAttachmentsOffline),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  DeckRow copyWith({
    String? id,
    String? name,
    bool? keepAttachmentsOffline,
    int? createdAt,
  }) => DeckRow(
    id: id ?? this.id,
    name: name ?? this.name,
    keepAttachmentsOffline:
        keepAttachmentsOffline ?? this.keepAttachmentsOffline,
    createdAt: createdAt ?? this.createdAt,
  );
  DeckRow copyWithCompanion(DecksCompanion data) {
    return DeckRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      keepAttachmentsOffline: data.keepAttachmentsOffline.present
          ? data.keepAttachmentsOffline.value
          : this.keepAttachmentsOffline,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeckRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('keepAttachmentsOffline: $keepAttachmentsOffline, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, keepAttachmentsOffline, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeckRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.keepAttachmentsOffline == this.keepAttachmentsOffline &&
          other.createdAt == this.createdAt);
}

class DecksCompanion extends UpdateCompanion<DeckRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<bool> keepAttachmentsOffline;
  final Value<int> createdAt;
  final Value<int> rowid;
  const DecksCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.keepAttachmentsOffline = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DecksCompanion.insert({
    required String id,
    required String name,
    this.keepAttachmentsOffline = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<DeckRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<bool>? keepAttachmentsOffline,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (keepAttachmentsOffline != null)
        'keep_attachments_offline': keepAttachmentsOffline,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DecksCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<bool>? keepAttachmentsOffline,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return DecksCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      keepAttachmentsOffline:
          keepAttachmentsOffline ?? this.keepAttachmentsOffline,
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
    if (keepAttachmentsOffline.present) {
      map['keep_attachments_offline'] = Variable<bool>(
        keepAttachmentsOffline.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DecksCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('keepAttachmentsOffline: $keepAttachmentsOffline, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CardsTable extends Cards with TableInfo<$CardsTable, CardRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deckIdMeta = const VerificationMeta('deckId');
  @override
  late final GeneratedColumn<String> deckId = GeneratedColumn<String>(
    'deck_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES decks (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _frontMeta = const VerificationMeta('front');
  @override
  late final GeneratedColumn<String> front = GeneratedColumn<String>(
    'front',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _backMeta = const VerificationMeta('back');
  @override
  late final GeneratedColumn<String> back = GeneratedColumn<String>(
    'back',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueMeta = const VerificationMeta('due');
  @override
  late final GeneratedColumn<String> due = GeneratedColumn<String>(
    'due',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stabilityMeta = const VerificationMeta(
    'stability',
  );
  @override
  late final GeneratedColumn<double> stability = GeneratedColumn<double>(
    'stability',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _difficultyMeta = const VerificationMeta(
    'difficulty',
  );
  @override
  late final GeneratedColumn<double> difficulty = GeneratedColumn<double>(
    'difficulty',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _elapsedDaysMeta = const VerificationMeta(
    'elapsedDays',
  );
  @override
  late final GeneratedColumn<int> elapsedDays = GeneratedColumn<int>(
    'elapsed_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _scheduledDaysMeta = const VerificationMeta(
    'scheduledDays',
  );
  @override
  late final GeneratedColumn<int> scheduledDays = GeneratedColumn<int>(
    'scheduled_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _learningStepsMeta = const VerificationMeta(
    'learningSteps',
  );
  @override
  late final GeneratedColumn<int> learningSteps = GeneratedColumn<int>(
    'learning_steps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _repsMeta = const VerificationMeta('reps');
  @override
  late final GeneratedColumn<int> reps = GeneratedColumn<int>(
    'reps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lapsesMeta = const VerificationMeta('lapses');
  @override
  late final GeneratedColumn<int> lapses = GeneratedColumn<int>(
    'lapses',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<int> state = GeneratedColumn<int>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastReviewMeta = const VerificationMeta(
    'lastReview',
  );
  @override
  late final GeneratedColumn<String> lastReview = GeneratedColumn<String>(
    'last_review',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deckId,
    front,
    back,
    due,
    stability,
    difficulty,
    elapsedDays,
    scheduledDays,
    learningSteps,
    reps,
    lapses,
    state,
    lastReview,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cards';
  @override
  VerificationContext validateIntegrity(
    Insertable<CardRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('deck_id')) {
      context.handle(
        _deckIdMeta,
        deckId.isAcceptableOrUnknown(data['deck_id']!, _deckIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deckIdMeta);
    }
    if (data.containsKey('front')) {
      context.handle(
        _frontMeta,
        front.isAcceptableOrUnknown(data['front']!, _frontMeta),
      );
    } else if (isInserting) {
      context.missing(_frontMeta);
    }
    if (data.containsKey('back')) {
      context.handle(
        _backMeta,
        back.isAcceptableOrUnknown(data['back']!, _backMeta),
      );
    } else if (isInserting) {
      context.missing(_backMeta);
    }
    if (data.containsKey('due')) {
      context.handle(
        _dueMeta,
        due.isAcceptableOrUnknown(data['due']!, _dueMeta),
      );
    } else if (isInserting) {
      context.missing(_dueMeta);
    }
    if (data.containsKey('stability')) {
      context.handle(
        _stabilityMeta,
        stability.isAcceptableOrUnknown(data['stability']!, _stabilityMeta),
      );
    }
    if (data.containsKey('difficulty')) {
      context.handle(
        _difficultyMeta,
        difficulty.isAcceptableOrUnknown(data['difficulty']!, _difficultyMeta),
      );
    }
    if (data.containsKey('elapsed_days')) {
      context.handle(
        _elapsedDaysMeta,
        elapsedDays.isAcceptableOrUnknown(
          data['elapsed_days']!,
          _elapsedDaysMeta,
        ),
      );
    }
    if (data.containsKey('scheduled_days')) {
      context.handle(
        _scheduledDaysMeta,
        scheduledDays.isAcceptableOrUnknown(
          data['scheduled_days']!,
          _scheduledDaysMeta,
        ),
      );
    }
    if (data.containsKey('learning_steps')) {
      context.handle(
        _learningStepsMeta,
        learningSteps.isAcceptableOrUnknown(
          data['learning_steps']!,
          _learningStepsMeta,
        ),
      );
    }
    if (data.containsKey('reps')) {
      context.handle(
        _repsMeta,
        reps.isAcceptableOrUnknown(data['reps']!, _repsMeta),
      );
    }
    if (data.containsKey('lapses')) {
      context.handle(
        _lapsesMeta,
        lapses.isAcceptableOrUnknown(data['lapses']!, _lapsesMeta),
      );
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    }
    if (data.containsKey('last_review')) {
      context.handle(
        _lastReviewMeta,
        lastReview.isAcceptableOrUnknown(data['last_review']!, _lastReviewMeta),
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
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CardRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CardRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      deckId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deck_id'],
      )!,
      front: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}front'],
      )!,
      back: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}back'],
      )!,
      due: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}due'],
      )!,
      stability: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}stability'],
      )!,
      difficulty: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}difficulty'],
      )!,
      elapsedDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}elapsed_days'],
      )!,
      scheduledDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}scheduled_days'],
      )!,
      learningSteps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}learning_steps'],
      )!,
      reps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reps'],
      )!,
      lapses: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lapses'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}state'],
      )!,
      lastReview: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_review'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CardsTable createAlias(String alias) {
    return $CardsTable(attachedDatabase, alias);
  }
}

class CardRow extends DataClass implements Insertable<CardRow> {
  final String id;
  final String deckId;
  final String front;
  final String back;

  /// ISO-8601 timestamp of the next due date.
  final String due;
  final double stability;
  final double difficulty;
  final int elapsedDays;
  final int scheduledDays;
  final int learningSteps;
  final int reps;
  final int lapses;

  /// 0 = new, 1 = learning, 2 = review, 3 = relearning.
  final int state;
  final String? lastReview;
  final int createdAt;
  final int updatedAt;
  const CardRow({
    required this.id,
    required this.deckId,
    required this.front,
    required this.back,
    required this.due,
    required this.stability,
    required this.difficulty,
    required this.elapsedDays,
    required this.scheduledDays,
    required this.learningSteps,
    required this.reps,
    required this.lapses,
    required this.state,
    this.lastReview,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['deck_id'] = Variable<String>(deckId);
    map['front'] = Variable<String>(front);
    map['back'] = Variable<String>(back);
    map['due'] = Variable<String>(due);
    map['stability'] = Variable<double>(stability);
    map['difficulty'] = Variable<double>(difficulty);
    map['elapsed_days'] = Variable<int>(elapsedDays);
    map['scheduled_days'] = Variable<int>(scheduledDays);
    map['learning_steps'] = Variable<int>(learningSteps);
    map['reps'] = Variable<int>(reps);
    map['lapses'] = Variable<int>(lapses);
    map['state'] = Variable<int>(state);
    if (!nullToAbsent || lastReview != null) {
      map['last_review'] = Variable<String>(lastReview);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  CardsCompanion toCompanion(bool nullToAbsent) {
    return CardsCompanion(
      id: Value(id),
      deckId: Value(deckId),
      front: Value(front),
      back: Value(back),
      due: Value(due),
      stability: Value(stability),
      difficulty: Value(difficulty),
      elapsedDays: Value(elapsedDays),
      scheduledDays: Value(scheduledDays),
      learningSteps: Value(learningSteps),
      reps: Value(reps),
      lapses: Value(lapses),
      state: Value(state),
      lastReview: lastReview == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReview),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CardRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CardRow(
      id: serializer.fromJson<String>(json['id']),
      deckId: serializer.fromJson<String>(json['deckId']),
      front: serializer.fromJson<String>(json['front']),
      back: serializer.fromJson<String>(json['back']),
      due: serializer.fromJson<String>(json['due']),
      stability: serializer.fromJson<double>(json['stability']),
      difficulty: serializer.fromJson<double>(json['difficulty']),
      elapsedDays: serializer.fromJson<int>(json['elapsedDays']),
      scheduledDays: serializer.fromJson<int>(json['scheduledDays']),
      learningSteps: serializer.fromJson<int>(json['learningSteps']),
      reps: serializer.fromJson<int>(json['reps']),
      lapses: serializer.fromJson<int>(json['lapses']),
      state: serializer.fromJson<int>(json['state']),
      lastReview: serializer.fromJson<String?>(json['lastReview']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'deckId': serializer.toJson<String>(deckId),
      'front': serializer.toJson<String>(front),
      'back': serializer.toJson<String>(back),
      'due': serializer.toJson<String>(due),
      'stability': serializer.toJson<double>(stability),
      'difficulty': serializer.toJson<double>(difficulty),
      'elapsedDays': serializer.toJson<int>(elapsedDays),
      'scheduledDays': serializer.toJson<int>(scheduledDays),
      'learningSteps': serializer.toJson<int>(learningSteps),
      'reps': serializer.toJson<int>(reps),
      'lapses': serializer.toJson<int>(lapses),
      'state': serializer.toJson<int>(state),
      'lastReview': serializer.toJson<String?>(lastReview),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  CardRow copyWith({
    String? id,
    String? deckId,
    String? front,
    String? back,
    String? due,
    double? stability,
    double? difficulty,
    int? elapsedDays,
    int? scheduledDays,
    int? learningSteps,
    int? reps,
    int? lapses,
    int? state,
    Value<String?> lastReview = const Value.absent(),
    int? createdAt,
    int? updatedAt,
  }) => CardRow(
    id: id ?? this.id,
    deckId: deckId ?? this.deckId,
    front: front ?? this.front,
    back: back ?? this.back,
    due: due ?? this.due,
    stability: stability ?? this.stability,
    difficulty: difficulty ?? this.difficulty,
    elapsedDays: elapsedDays ?? this.elapsedDays,
    scheduledDays: scheduledDays ?? this.scheduledDays,
    learningSteps: learningSteps ?? this.learningSteps,
    reps: reps ?? this.reps,
    lapses: lapses ?? this.lapses,
    state: state ?? this.state,
    lastReview: lastReview.present ? lastReview.value : this.lastReview,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CardRow copyWithCompanion(CardsCompanion data) {
    return CardRow(
      id: data.id.present ? data.id.value : this.id,
      deckId: data.deckId.present ? data.deckId.value : this.deckId,
      front: data.front.present ? data.front.value : this.front,
      back: data.back.present ? data.back.value : this.back,
      due: data.due.present ? data.due.value : this.due,
      stability: data.stability.present ? data.stability.value : this.stability,
      difficulty: data.difficulty.present
          ? data.difficulty.value
          : this.difficulty,
      elapsedDays: data.elapsedDays.present
          ? data.elapsedDays.value
          : this.elapsedDays,
      scheduledDays: data.scheduledDays.present
          ? data.scheduledDays.value
          : this.scheduledDays,
      learningSteps: data.learningSteps.present
          ? data.learningSteps.value
          : this.learningSteps,
      reps: data.reps.present ? data.reps.value : this.reps,
      lapses: data.lapses.present ? data.lapses.value : this.lapses,
      state: data.state.present ? data.state.value : this.state,
      lastReview: data.lastReview.present
          ? data.lastReview.value
          : this.lastReview,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CardRow(')
          ..write('id: $id, ')
          ..write('deckId: $deckId, ')
          ..write('front: $front, ')
          ..write('back: $back, ')
          ..write('due: $due, ')
          ..write('stability: $stability, ')
          ..write('difficulty: $difficulty, ')
          ..write('elapsedDays: $elapsedDays, ')
          ..write('scheduledDays: $scheduledDays, ')
          ..write('learningSteps: $learningSteps, ')
          ..write('reps: $reps, ')
          ..write('lapses: $lapses, ')
          ..write('state: $state, ')
          ..write('lastReview: $lastReview, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    deckId,
    front,
    back,
    due,
    stability,
    difficulty,
    elapsedDays,
    scheduledDays,
    learningSteps,
    reps,
    lapses,
    state,
    lastReview,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CardRow &&
          other.id == this.id &&
          other.deckId == this.deckId &&
          other.front == this.front &&
          other.back == this.back &&
          other.due == this.due &&
          other.stability == this.stability &&
          other.difficulty == this.difficulty &&
          other.elapsedDays == this.elapsedDays &&
          other.scheduledDays == this.scheduledDays &&
          other.learningSteps == this.learningSteps &&
          other.reps == this.reps &&
          other.lapses == this.lapses &&
          other.state == this.state &&
          other.lastReview == this.lastReview &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CardsCompanion extends UpdateCompanion<CardRow> {
  final Value<String> id;
  final Value<String> deckId;
  final Value<String> front;
  final Value<String> back;
  final Value<String> due;
  final Value<double> stability;
  final Value<double> difficulty;
  final Value<int> elapsedDays;
  final Value<int> scheduledDays;
  final Value<int> learningSteps;
  final Value<int> reps;
  final Value<int> lapses;
  final Value<int> state;
  final Value<String?> lastReview;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const CardsCompanion({
    this.id = const Value.absent(),
    this.deckId = const Value.absent(),
    this.front = const Value.absent(),
    this.back = const Value.absent(),
    this.due = const Value.absent(),
    this.stability = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.elapsedDays = const Value.absent(),
    this.scheduledDays = const Value.absent(),
    this.learningSteps = const Value.absent(),
    this.reps = const Value.absent(),
    this.lapses = const Value.absent(),
    this.state = const Value.absent(),
    this.lastReview = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CardsCompanion.insert({
    required String id,
    required String deckId,
    required String front,
    required String back,
    required String due,
    this.stability = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.elapsedDays = const Value.absent(),
    this.scheduledDays = const Value.absent(),
    this.learningSteps = const Value.absent(),
    this.reps = const Value.absent(),
    this.lapses = const Value.absent(),
    this.state = const Value.absent(),
    this.lastReview = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       deckId = Value(deckId),
       front = Value(front),
       back = Value(back),
       due = Value(due),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<CardRow> custom({
    Expression<String>? id,
    Expression<String>? deckId,
    Expression<String>? front,
    Expression<String>? back,
    Expression<String>? due,
    Expression<double>? stability,
    Expression<double>? difficulty,
    Expression<int>? elapsedDays,
    Expression<int>? scheduledDays,
    Expression<int>? learningSteps,
    Expression<int>? reps,
    Expression<int>? lapses,
    Expression<int>? state,
    Expression<String>? lastReview,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deckId != null) 'deck_id': deckId,
      if (front != null) 'front': front,
      if (back != null) 'back': back,
      if (due != null) 'due': due,
      if (stability != null) 'stability': stability,
      if (difficulty != null) 'difficulty': difficulty,
      if (elapsedDays != null) 'elapsed_days': elapsedDays,
      if (scheduledDays != null) 'scheduled_days': scheduledDays,
      if (learningSteps != null) 'learning_steps': learningSteps,
      if (reps != null) 'reps': reps,
      if (lapses != null) 'lapses': lapses,
      if (state != null) 'state': state,
      if (lastReview != null) 'last_review': lastReview,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CardsCompanion copyWith({
    Value<String>? id,
    Value<String>? deckId,
    Value<String>? front,
    Value<String>? back,
    Value<String>? due,
    Value<double>? stability,
    Value<double>? difficulty,
    Value<int>? elapsedDays,
    Value<int>? scheduledDays,
    Value<int>? learningSteps,
    Value<int>? reps,
    Value<int>? lapses,
    Value<int>? state,
    Value<String?>? lastReview,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return CardsCompanion(
      id: id ?? this.id,
      deckId: deckId ?? this.deckId,
      front: front ?? this.front,
      back: back ?? this.back,
      due: due ?? this.due,
      stability: stability ?? this.stability,
      difficulty: difficulty ?? this.difficulty,
      elapsedDays: elapsedDays ?? this.elapsedDays,
      scheduledDays: scheduledDays ?? this.scheduledDays,
      learningSteps: learningSteps ?? this.learningSteps,
      reps: reps ?? this.reps,
      lapses: lapses ?? this.lapses,
      state: state ?? this.state,
      lastReview: lastReview ?? this.lastReview,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (deckId.present) {
      map['deck_id'] = Variable<String>(deckId.value);
    }
    if (front.present) {
      map['front'] = Variable<String>(front.value);
    }
    if (back.present) {
      map['back'] = Variable<String>(back.value);
    }
    if (due.present) {
      map['due'] = Variable<String>(due.value);
    }
    if (stability.present) {
      map['stability'] = Variable<double>(stability.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<double>(difficulty.value);
    }
    if (elapsedDays.present) {
      map['elapsed_days'] = Variable<int>(elapsedDays.value);
    }
    if (scheduledDays.present) {
      map['scheduled_days'] = Variable<int>(scheduledDays.value);
    }
    if (learningSteps.present) {
      map['learning_steps'] = Variable<int>(learningSteps.value);
    }
    if (reps.present) {
      map['reps'] = Variable<int>(reps.value);
    }
    if (lapses.present) {
      map['lapses'] = Variable<int>(lapses.value);
    }
    if (state.present) {
      map['state'] = Variable<int>(state.value);
    }
    if (lastReview.present) {
      map['last_review'] = Variable<String>(lastReview.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardsCompanion(')
          ..write('id: $id, ')
          ..write('deckId: $deckId, ')
          ..write('front: $front, ')
          ..write('back: $back, ')
          ..write('due: $due, ')
          ..write('stability: $stability, ')
          ..write('difficulty: $difficulty, ')
          ..write('elapsedDays: $elapsedDays, ')
          ..write('scheduledDays: $scheduledDays, ')
          ..write('learningSteps: $learningSteps, ')
          ..write('reps: $reps, ')
          ..write('lapses: $lapses, ')
          ..write('state: $state, ')
          ..write('lastReview: $lastReview, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CardAttachmentsTable extends CardAttachments
    with TableInfo<$CardAttachmentsTable, CardAttachmentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardAttachmentsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<String> cardId = GeneratedColumn<String>(
    'card_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cards (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sideMeta = const VerificationMeta('side');
  @override
  late final GeneratedColumn<String> side = GeneratedColumn<String>(
    'side',
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
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
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
  static const VerificationMeta _captionMeta = const VerificationMeta(
    'caption',
  );
  @override
  late final GeneratedColumn<String> caption = GeneratedColumn<String>(
    'caption',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _attributionMeta = const VerificationMeta(
    'attribution',
  );
  @override
  late final GeneratedColumn<String> attribution = GeneratedColumn<String>(
    'attribution',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _languageQidMeta = const VerificationMeta(
    'languageQid',
  );
  @override
  late final GeneratedColumn<String> languageQid = GeneratedColumn<String>(
    'language_qid',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _blobContentMeta = const VerificationMeta(
    'blobContent',
  );
  @override
  late final GeneratedColumn<String> blobContent = GeneratedColumn<String>(
    'blob_content',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cardId,
    side,
    position,
    type,
    url,
    caption,
    attribution,
    languageQid,
    blobContent,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'card_attachments';
  @override
  VerificationContext validateIntegrity(
    Insertable<CardAttachmentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('card_id')) {
      context.handle(
        _cardIdMeta,
        cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cardIdMeta);
    }
    if (data.containsKey('side')) {
      context.handle(
        _sideMeta,
        side.isAcceptableOrUnknown(data['side']!, _sideMeta),
      );
    } else if (isInserting) {
      context.missing(_sideMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    }
    if (data.containsKey('caption')) {
      context.handle(
        _captionMeta,
        caption.isAcceptableOrUnknown(data['caption']!, _captionMeta),
      );
    }
    if (data.containsKey('attribution')) {
      context.handle(
        _attributionMeta,
        attribution.isAcceptableOrUnknown(
          data['attribution']!,
          _attributionMeta,
        ),
      );
    }
    if (data.containsKey('language_qid')) {
      context.handle(
        _languageQidMeta,
        languageQid.isAcceptableOrUnknown(
          data['language_qid']!,
          _languageQidMeta,
        ),
      );
    }
    if (data.containsKey('blob_content')) {
      context.handle(
        _blobContentMeta,
        blobContent.isAcceptableOrUnknown(
          data['blob_content']!,
          _blobContentMeta,
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
  CardAttachmentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CardAttachmentRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}card_id'],
      )!,
      side: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}side'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      ),
      caption: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}caption'],
      )!,
      attribution: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attribution'],
      ),
      languageQid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language_qid'],
      ),
      blobContent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}blob_content'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CardAttachmentsTable createAlias(String alias) {
    return $CardAttachmentsTable(attachedDatabase, alias);
  }
}

class CardAttachmentRow extends DataClass
    implements Insertable<CardAttachmentRow> {
  final int id;
  final String cardId;

  /// Either 'front' or 'back'.
  final String side;
  final int position;

  /// Either 'image' or 'audio'.
  final String type;
  final String? url;
  final String caption;
  final String? attribution;
  final String? languageQid;

  /// Base64 data URL cached for offline use.
  final String? blobContent;
  final int createdAt;
  const CardAttachmentRow({
    required this.id,
    required this.cardId,
    required this.side,
    required this.position,
    required this.type,
    this.url,
    required this.caption,
    this.attribution,
    this.languageQid,
    this.blobContent,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['card_id'] = Variable<String>(cardId);
    map['side'] = Variable<String>(side);
    map['position'] = Variable<int>(position);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || url != null) {
      map['url'] = Variable<String>(url);
    }
    map['caption'] = Variable<String>(caption);
    if (!nullToAbsent || attribution != null) {
      map['attribution'] = Variable<String>(attribution);
    }
    if (!nullToAbsent || languageQid != null) {
      map['language_qid'] = Variable<String>(languageQid);
    }
    if (!nullToAbsent || blobContent != null) {
      map['blob_content'] = Variable<String>(blobContent);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  CardAttachmentsCompanion toCompanion(bool nullToAbsent) {
    return CardAttachmentsCompanion(
      id: Value(id),
      cardId: Value(cardId),
      side: Value(side),
      position: Value(position),
      type: Value(type),
      url: url == null && nullToAbsent ? const Value.absent() : Value(url),
      caption: Value(caption),
      attribution: attribution == null && nullToAbsent
          ? const Value.absent()
          : Value(attribution),
      languageQid: languageQid == null && nullToAbsent
          ? const Value.absent()
          : Value(languageQid),
      blobContent: blobContent == null && nullToAbsent
          ? const Value.absent()
          : Value(blobContent),
      createdAt: Value(createdAt),
    );
  }

  factory CardAttachmentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CardAttachmentRow(
      id: serializer.fromJson<int>(json['id']),
      cardId: serializer.fromJson<String>(json['cardId']),
      side: serializer.fromJson<String>(json['side']),
      position: serializer.fromJson<int>(json['position']),
      type: serializer.fromJson<String>(json['type']),
      url: serializer.fromJson<String?>(json['url']),
      caption: serializer.fromJson<String>(json['caption']),
      attribution: serializer.fromJson<String?>(json['attribution']),
      languageQid: serializer.fromJson<String?>(json['languageQid']),
      blobContent: serializer.fromJson<String?>(json['blobContent']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cardId': serializer.toJson<String>(cardId),
      'side': serializer.toJson<String>(side),
      'position': serializer.toJson<int>(position),
      'type': serializer.toJson<String>(type),
      'url': serializer.toJson<String?>(url),
      'caption': serializer.toJson<String>(caption),
      'attribution': serializer.toJson<String?>(attribution),
      'languageQid': serializer.toJson<String?>(languageQid),
      'blobContent': serializer.toJson<String?>(blobContent),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  CardAttachmentRow copyWith({
    int? id,
    String? cardId,
    String? side,
    int? position,
    String? type,
    Value<String?> url = const Value.absent(),
    String? caption,
    Value<String?> attribution = const Value.absent(),
    Value<String?> languageQid = const Value.absent(),
    Value<String?> blobContent = const Value.absent(),
    int? createdAt,
  }) => CardAttachmentRow(
    id: id ?? this.id,
    cardId: cardId ?? this.cardId,
    side: side ?? this.side,
    position: position ?? this.position,
    type: type ?? this.type,
    url: url.present ? url.value : this.url,
    caption: caption ?? this.caption,
    attribution: attribution.present ? attribution.value : this.attribution,
    languageQid: languageQid.present ? languageQid.value : this.languageQid,
    blobContent: blobContent.present ? blobContent.value : this.blobContent,
    createdAt: createdAt ?? this.createdAt,
  );
  CardAttachmentRow copyWithCompanion(CardAttachmentsCompanion data) {
    return CardAttachmentRow(
      id: data.id.present ? data.id.value : this.id,
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      side: data.side.present ? data.side.value : this.side,
      position: data.position.present ? data.position.value : this.position,
      type: data.type.present ? data.type.value : this.type,
      url: data.url.present ? data.url.value : this.url,
      caption: data.caption.present ? data.caption.value : this.caption,
      attribution: data.attribution.present
          ? data.attribution.value
          : this.attribution,
      languageQid: data.languageQid.present
          ? data.languageQid.value
          : this.languageQid,
      blobContent: data.blobContent.present
          ? data.blobContent.value
          : this.blobContent,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CardAttachmentRow(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('side: $side, ')
          ..write('position: $position, ')
          ..write('type: $type, ')
          ..write('url: $url, ')
          ..write('caption: $caption, ')
          ..write('attribution: $attribution, ')
          ..write('languageQid: $languageQid, ')
          ..write('blobContent: $blobContent, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    cardId,
    side,
    position,
    type,
    url,
    caption,
    attribution,
    languageQid,
    blobContent,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CardAttachmentRow &&
          other.id == this.id &&
          other.cardId == this.cardId &&
          other.side == this.side &&
          other.position == this.position &&
          other.type == this.type &&
          other.url == this.url &&
          other.caption == this.caption &&
          other.attribution == this.attribution &&
          other.languageQid == this.languageQid &&
          other.blobContent == this.blobContent &&
          other.createdAt == this.createdAt);
}

class CardAttachmentsCompanion extends UpdateCompanion<CardAttachmentRow> {
  final Value<int> id;
  final Value<String> cardId;
  final Value<String> side;
  final Value<int> position;
  final Value<String> type;
  final Value<String?> url;
  final Value<String> caption;
  final Value<String?> attribution;
  final Value<String?> languageQid;
  final Value<String?> blobContent;
  final Value<int> createdAt;
  const CardAttachmentsCompanion({
    this.id = const Value.absent(),
    this.cardId = const Value.absent(),
    this.side = const Value.absent(),
    this.position = const Value.absent(),
    this.type = const Value.absent(),
    this.url = const Value.absent(),
    this.caption = const Value.absent(),
    this.attribution = const Value.absent(),
    this.languageQid = const Value.absent(),
    this.blobContent = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  CardAttachmentsCompanion.insert({
    this.id = const Value.absent(),
    required String cardId,
    required String side,
    required int position,
    required String type,
    this.url = const Value.absent(),
    this.caption = const Value.absent(),
    this.attribution = const Value.absent(),
    this.languageQid = const Value.absent(),
    this.blobContent = const Value.absent(),
    required int createdAt,
  }) : cardId = Value(cardId),
       side = Value(side),
       position = Value(position),
       type = Value(type),
       createdAt = Value(createdAt);
  static Insertable<CardAttachmentRow> custom({
    Expression<int>? id,
    Expression<String>? cardId,
    Expression<String>? side,
    Expression<int>? position,
    Expression<String>? type,
    Expression<String>? url,
    Expression<String>? caption,
    Expression<String>? attribution,
    Expression<String>? languageQid,
    Expression<String>? blobContent,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cardId != null) 'card_id': cardId,
      if (side != null) 'side': side,
      if (position != null) 'position': position,
      if (type != null) 'type': type,
      if (url != null) 'url': url,
      if (caption != null) 'caption': caption,
      if (attribution != null) 'attribution': attribution,
      if (languageQid != null) 'language_qid': languageQid,
      if (blobContent != null) 'blob_content': blobContent,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  CardAttachmentsCompanion copyWith({
    Value<int>? id,
    Value<String>? cardId,
    Value<String>? side,
    Value<int>? position,
    Value<String>? type,
    Value<String?>? url,
    Value<String>? caption,
    Value<String?>? attribution,
    Value<String?>? languageQid,
    Value<String?>? blobContent,
    Value<int>? createdAt,
  }) {
    return CardAttachmentsCompanion(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      side: side ?? this.side,
      position: position ?? this.position,
      type: type ?? this.type,
      url: url ?? this.url,
      caption: caption ?? this.caption,
      attribution: attribution ?? this.attribution,
      languageQid: languageQid ?? this.languageQid,
      blobContent: blobContent ?? this.blobContent,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cardId.present) {
      map['card_id'] = Variable<String>(cardId.value);
    }
    if (side.present) {
      map['side'] = Variable<String>(side.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (caption.present) {
      map['caption'] = Variable<String>(caption.value);
    }
    if (attribution.present) {
      map['attribution'] = Variable<String>(attribution.value);
    }
    if (languageQid.present) {
      map['language_qid'] = Variable<String>(languageQid.value);
    }
    if (blobContent.present) {
      map['blob_content'] = Variable<String>(blobContent.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardAttachmentsCompanion(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('side: $side, ')
          ..write('position: $position, ')
          ..write('type: $type, ')
          ..write('url: $url, ')
          ..write('caption: $caption, ')
          ..write('attribution: $attribution, ')
          ..write('languageQid: $languageQid, ')
          ..write('blobContent: $blobContent, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ReviewLogsTable extends ReviewLogs
    with TableInfo<$ReviewLogsTable, ReviewLogRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReviewLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<String> cardId = GeneratedColumn<String>(
    'card_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<int> rating = GeneratedColumn<int>(
    'rating',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<int> state = GeneratedColumn<int>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueMeta = const VerificationMeta('due');
  @override
  late final GeneratedColumn<String> due = GeneratedColumn<String>(
    'due',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stabilityMeta = const VerificationMeta(
    'stability',
  );
  @override
  late final GeneratedColumn<double> stability = GeneratedColumn<double>(
    'stability',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _difficultyMeta = const VerificationMeta(
    'difficulty',
  );
  @override
  late final GeneratedColumn<double> difficulty = GeneratedColumn<double>(
    'difficulty',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _elapsedDaysMeta = const VerificationMeta(
    'elapsedDays',
  );
  @override
  late final GeneratedColumn<int> elapsedDays = GeneratedColumn<int>(
    'elapsed_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastElapsedDaysMeta = const VerificationMeta(
    'lastElapsedDays',
  );
  @override
  late final GeneratedColumn<int> lastElapsedDays = GeneratedColumn<int>(
    'last_elapsed_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scheduledDaysMeta = const VerificationMeta(
    'scheduledDays',
  );
  @override
  late final GeneratedColumn<int> scheduledDays = GeneratedColumn<int>(
    'scheduled_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _learningStepsMeta = const VerificationMeta(
    'learningSteps',
  );
  @override
  late final GeneratedColumn<int> learningSteps = GeneratedColumn<int>(
    'learning_steps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reviewMeta = const VerificationMeta('review');
  @override
  late final GeneratedColumn<String> review = GeneratedColumn<String>(
    'review',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cardId,
    rating,
    state,
    due,
    stability,
    difficulty,
    elapsedDays,
    lastElapsedDays,
    scheduledDays,
    learningSteps,
    review,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'review_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReviewLogRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('card_id')) {
      context.handle(
        _cardIdMeta,
        cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cardIdMeta);
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    } else if (isInserting) {
      context.missing(_ratingMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('due')) {
      context.handle(
        _dueMeta,
        due.isAcceptableOrUnknown(data['due']!, _dueMeta),
      );
    } else if (isInserting) {
      context.missing(_dueMeta);
    }
    if (data.containsKey('stability')) {
      context.handle(
        _stabilityMeta,
        stability.isAcceptableOrUnknown(data['stability']!, _stabilityMeta),
      );
    } else if (isInserting) {
      context.missing(_stabilityMeta);
    }
    if (data.containsKey('difficulty')) {
      context.handle(
        _difficultyMeta,
        difficulty.isAcceptableOrUnknown(data['difficulty']!, _difficultyMeta),
      );
    } else if (isInserting) {
      context.missing(_difficultyMeta);
    }
    if (data.containsKey('elapsed_days')) {
      context.handle(
        _elapsedDaysMeta,
        elapsedDays.isAcceptableOrUnknown(
          data['elapsed_days']!,
          _elapsedDaysMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_elapsedDaysMeta);
    }
    if (data.containsKey('last_elapsed_days')) {
      context.handle(
        _lastElapsedDaysMeta,
        lastElapsedDays.isAcceptableOrUnknown(
          data['last_elapsed_days']!,
          _lastElapsedDaysMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastElapsedDaysMeta);
    }
    if (data.containsKey('scheduled_days')) {
      context.handle(
        _scheduledDaysMeta,
        scheduledDays.isAcceptableOrUnknown(
          data['scheduled_days']!,
          _scheduledDaysMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduledDaysMeta);
    }
    if (data.containsKey('learning_steps')) {
      context.handle(
        _learningStepsMeta,
        learningSteps.isAcceptableOrUnknown(
          data['learning_steps']!,
          _learningStepsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_learningStepsMeta);
    }
    if (data.containsKey('review')) {
      context.handle(
        _reviewMeta,
        review.isAcceptableOrUnknown(data['review']!, _reviewMeta),
      );
    } else if (isInserting) {
      context.missing(_reviewMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReviewLogRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReviewLogRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      cardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}card_id'],
      )!,
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rating'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}state'],
      )!,
      due: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}due'],
      )!,
      stability: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}stability'],
      )!,
      difficulty: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}difficulty'],
      )!,
      elapsedDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}elapsed_days'],
      )!,
      lastElapsedDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_elapsed_days'],
      )!,
      scheduledDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}scheduled_days'],
      )!,
      learningSteps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}learning_steps'],
      )!,
      review: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}review'],
      )!,
    );
  }

  @override
  $ReviewLogsTable createAlias(String alias) {
    return $ReviewLogsTable(attachedDatabase, alias);
  }
}

class ReviewLogRow extends DataClass implements Insertable<ReviewLogRow> {
  final String id;
  final String cardId;
  final int rating;
  final int state;
  final String due;
  final double stability;
  final double difficulty;
  final int elapsedDays;
  final int lastElapsedDays;
  final int scheduledDays;
  final int learningSteps;
  final String review;
  const ReviewLogRow({
    required this.id,
    required this.cardId,
    required this.rating,
    required this.state,
    required this.due,
    required this.stability,
    required this.difficulty,
    required this.elapsedDays,
    required this.lastElapsedDays,
    required this.scheduledDays,
    required this.learningSteps,
    required this.review,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['card_id'] = Variable<String>(cardId);
    map['rating'] = Variable<int>(rating);
    map['state'] = Variable<int>(state);
    map['due'] = Variable<String>(due);
    map['stability'] = Variable<double>(stability);
    map['difficulty'] = Variable<double>(difficulty);
    map['elapsed_days'] = Variable<int>(elapsedDays);
    map['last_elapsed_days'] = Variable<int>(lastElapsedDays);
    map['scheduled_days'] = Variable<int>(scheduledDays);
    map['learning_steps'] = Variable<int>(learningSteps);
    map['review'] = Variable<String>(review);
    return map;
  }

  ReviewLogsCompanion toCompanion(bool nullToAbsent) {
    return ReviewLogsCompanion(
      id: Value(id),
      cardId: Value(cardId),
      rating: Value(rating),
      state: Value(state),
      due: Value(due),
      stability: Value(stability),
      difficulty: Value(difficulty),
      elapsedDays: Value(elapsedDays),
      lastElapsedDays: Value(lastElapsedDays),
      scheduledDays: Value(scheduledDays),
      learningSteps: Value(learningSteps),
      review: Value(review),
    );
  }

  factory ReviewLogRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReviewLogRow(
      id: serializer.fromJson<String>(json['id']),
      cardId: serializer.fromJson<String>(json['cardId']),
      rating: serializer.fromJson<int>(json['rating']),
      state: serializer.fromJson<int>(json['state']),
      due: serializer.fromJson<String>(json['due']),
      stability: serializer.fromJson<double>(json['stability']),
      difficulty: serializer.fromJson<double>(json['difficulty']),
      elapsedDays: serializer.fromJson<int>(json['elapsedDays']),
      lastElapsedDays: serializer.fromJson<int>(json['lastElapsedDays']),
      scheduledDays: serializer.fromJson<int>(json['scheduledDays']),
      learningSteps: serializer.fromJson<int>(json['learningSteps']),
      review: serializer.fromJson<String>(json['review']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'cardId': serializer.toJson<String>(cardId),
      'rating': serializer.toJson<int>(rating),
      'state': serializer.toJson<int>(state),
      'due': serializer.toJson<String>(due),
      'stability': serializer.toJson<double>(stability),
      'difficulty': serializer.toJson<double>(difficulty),
      'elapsedDays': serializer.toJson<int>(elapsedDays),
      'lastElapsedDays': serializer.toJson<int>(lastElapsedDays),
      'scheduledDays': serializer.toJson<int>(scheduledDays),
      'learningSteps': serializer.toJson<int>(learningSteps),
      'review': serializer.toJson<String>(review),
    };
  }

  ReviewLogRow copyWith({
    String? id,
    String? cardId,
    int? rating,
    int? state,
    String? due,
    double? stability,
    double? difficulty,
    int? elapsedDays,
    int? lastElapsedDays,
    int? scheduledDays,
    int? learningSteps,
    String? review,
  }) => ReviewLogRow(
    id: id ?? this.id,
    cardId: cardId ?? this.cardId,
    rating: rating ?? this.rating,
    state: state ?? this.state,
    due: due ?? this.due,
    stability: stability ?? this.stability,
    difficulty: difficulty ?? this.difficulty,
    elapsedDays: elapsedDays ?? this.elapsedDays,
    lastElapsedDays: lastElapsedDays ?? this.lastElapsedDays,
    scheduledDays: scheduledDays ?? this.scheduledDays,
    learningSteps: learningSteps ?? this.learningSteps,
    review: review ?? this.review,
  );
  ReviewLogRow copyWithCompanion(ReviewLogsCompanion data) {
    return ReviewLogRow(
      id: data.id.present ? data.id.value : this.id,
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      rating: data.rating.present ? data.rating.value : this.rating,
      state: data.state.present ? data.state.value : this.state,
      due: data.due.present ? data.due.value : this.due,
      stability: data.stability.present ? data.stability.value : this.stability,
      difficulty: data.difficulty.present
          ? data.difficulty.value
          : this.difficulty,
      elapsedDays: data.elapsedDays.present
          ? data.elapsedDays.value
          : this.elapsedDays,
      lastElapsedDays: data.lastElapsedDays.present
          ? data.lastElapsedDays.value
          : this.lastElapsedDays,
      scheduledDays: data.scheduledDays.present
          ? data.scheduledDays.value
          : this.scheduledDays,
      learningSteps: data.learningSteps.present
          ? data.learningSteps.value
          : this.learningSteps,
      review: data.review.present ? data.review.value : this.review,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReviewLogRow(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('rating: $rating, ')
          ..write('state: $state, ')
          ..write('due: $due, ')
          ..write('stability: $stability, ')
          ..write('difficulty: $difficulty, ')
          ..write('elapsedDays: $elapsedDays, ')
          ..write('lastElapsedDays: $lastElapsedDays, ')
          ..write('scheduledDays: $scheduledDays, ')
          ..write('learningSteps: $learningSteps, ')
          ..write('review: $review')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    cardId,
    rating,
    state,
    due,
    stability,
    difficulty,
    elapsedDays,
    lastElapsedDays,
    scheduledDays,
    learningSteps,
    review,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReviewLogRow &&
          other.id == this.id &&
          other.cardId == this.cardId &&
          other.rating == this.rating &&
          other.state == this.state &&
          other.due == this.due &&
          other.stability == this.stability &&
          other.difficulty == this.difficulty &&
          other.elapsedDays == this.elapsedDays &&
          other.lastElapsedDays == this.lastElapsedDays &&
          other.scheduledDays == this.scheduledDays &&
          other.learningSteps == this.learningSteps &&
          other.review == this.review);
}

class ReviewLogsCompanion extends UpdateCompanion<ReviewLogRow> {
  final Value<String> id;
  final Value<String> cardId;
  final Value<int> rating;
  final Value<int> state;
  final Value<String> due;
  final Value<double> stability;
  final Value<double> difficulty;
  final Value<int> elapsedDays;
  final Value<int> lastElapsedDays;
  final Value<int> scheduledDays;
  final Value<int> learningSteps;
  final Value<String> review;
  final Value<int> rowid;
  const ReviewLogsCompanion({
    this.id = const Value.absent(),
    this.cardId = const Value.absent(),
    this.rating = const Value.absent(),
    this.state = const Value.absent(),
    this.due = const Value.absent(),
    this.stability = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.elapsedDays = const Value.absent(),
    this.lastElapsedDays = const Value.absent(),
    this.scheduledDays = const Value.absent(),
    this.learningSteps = const Value.absent(),
    this.review = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReviewLogsCompanion.insert({
    required String id,
    required String cardId,
    required int rating,
    required int state,
    required String due,
    required double stability,
    required double difficulty,
    required int elapsedDays,
    required int lastElapsedDays,
    required int scheduledDays,
    required int learningSteps,
    required String review,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       cardId = Value(cardId),
       rating = Value(rating),
       state = Value(state),
       due = Value(due),
       stability = Value(stability),
       difficulty = Value(difficulty),
       elapsedDays = Value(elapsedDays),
       lastElapsedDays = Value(lastElapsedDays),
       scheduledDays = Value(scheduledDays),
       learningSteps = Value(learningSteps),
       review = Value(review);
  static Insertable<ReviewLogRow> custom({
    Expression<String>? id,
    Expression<String>? cardId,
    Expression<int>? rating,
    Expression<int>? state,
    Expression<String>? due,
    Expression<double>? stability,
    Expression<double>? difficulty,
    Expression<int>? elapsedDays,
    Expression<int>? lastElapsedDays,
    Expression<int>? scheduledDays,
    Expression<int>? learningSteps,
    Expression<String>? review,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cardId != null) 'card_id': cardId,
      if (rating != null) 'rating': rating,
      if (state != null) 'state': state,
      if (due != null) 'due': due,
      if (stability != null) 'stability': stability,
      if (difficulty != null) 'difficulty': difficulty,
      if (elapsedDays != null) 'elapsed_days': elapsedDays,
      if (lastElapsedDays != null) 'last_elapsed_days': lastElapsedDays,
      if (scheduledDays != null) 'scheduled_days': scheduledDays,
      if (learningSteps != null) 'learning_steps': learningSteps,
      if (review != null) 'review': review,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReviewLogsCompanion copyWith({
    Value<String>? id,
    Value<String>? cardId,
    Value<int>? rating,
    Value<int>? state,
    Value<String>? due,
    Value<double>? stability,
    Value<double>? difficulty,
    Value<int>? elapsedDays,
    Value<int>? lastElapsedDays,
    Value<int>? scheduledDays,
    Value<int>? learningSteps,
    Value<String>? review,
    Value<int>? rowid,
  }) {
    return ReviewLogsCompanion(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      rating: rating ?? this.rating,
      state: state ?? this.state,
      due: due ?? this.due,
      stability: stability ?? this.stability,
      difficulty: difficulty ?? this.difficulty,
      elapsedDays: elapsedDays ?? this.elapsedDays,
      lastElapsedDays: lastElapsedDays ?? this.lastElapsedDays,
      scheduledDays: scheduledDays ?? this.scheduledDays,
      learningSteps: learningSteps ?? this.learningSteps,
      review: review ?? this.review,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (cardId.present) {
      map['card_id'] = Variable<String>(cardId.value);
    }
    if (rating.present) {
      map['rating'] = Variable<int>(rating.value);
    }
    if (state.present) {
      map['state'] = Variable<int>(state.value);
    }
    if (due.present) {
      map['due'] = Variable<String>(due.value);
    }
    if (stability.present) {
      map['stability'] = Variable<double>(stability.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<double>(difficulty.value);
    }
    if (elapsedDays.present) {
      map['elapsed_days'] = Variable<int>(elapsedDays.value);
    }
    if (lastElapsedDays.present) {
      map['last_elapsed_days'] = Variable<int>(lastElapsedDays.value);
    }
    if (scheduledDays.present) {
      map['scheduled_days'] = Variable<int>(scheduledDays.value);
    }
    if (learningSteps.present) {
      map['learning_steps'] = Variable<int>(learningSteps.value);
    }
    if (review.present) {
      map['review'] = Variable<String>(review.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReviewLogsCompanion(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('rating: $rating, ')
          ..write('state: $state, ')
          ..write('due: $due, ')
          ..write('stability: $stability, ')
          ..write('difficulty: $difficulty, ')
          ..write('elapsedDays: $elapsedDays, ')
          ..write('lastElapsedDays: $lastElapsedDays, ')
          ..write('scheduledDays: $scheduledDays, ')
          ..write('learningSteps: $learningSteps, ')
          ..write('review: $review, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StudyTagsTable extends StudyTags
    with TableInfo<$StudyTagsTable, StudyTagRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StudyTagsTable(this.attachedDatabase, [this._alias]);
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
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'study_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<StudyTagRow> instance, {
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
  StudyTagRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StudyTagRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $StudyTagsTable createAlias(String alias) {
    return $StudyTagsTable(attachedDatabase, alias);
  }
}

class StudyTagRow extends DataClass implements Insertable<StudyTagRow> {
  final String id;
  final String name;
  final int createdAt;
  const StudyTagRow({
    required this.id,
    required this.name,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  StudyTagsCompanion toCompanion(bool nullToAbsent) {
    return StudyTagsCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
    );
  }

  factory StudyTagRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StudyTagRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  StudyTagRow copyWith({String? id, String? name, int? createdAt}) =>
      StudyTagRow(
        id: id ?? this.id,
        name: name ?? this.name,
        createdAt: createdAt ?? this.createdAt,
      );
  StudyTagRow copyWithCompanion(StudyTagsCompanion data) {
    return StudyTagRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StudyTagRow(')
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
      (other is StudyTagRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt);
}

class StudyTagsCompanion extends UpdateCompanion<StudyTagRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> createdAt;
  final Value<int> rowid;
  const StudyTagsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StudyTagsCompanion.insert({
    required String id,
    this.name = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt);
  static Insertable<StudyTagRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StudyTagsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return StudyTagsCompanion(
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
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StudyTagsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StudyTagDecksTable extends StudyTagDecks
    with TableInfo<$StudyTagDecksTable, StudyTagDeckRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StudyTagDecksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _studyTagIdMeta = const VerificationMeta(
    'studyTagId',
  );
  @override
  late final GeneratedColumn<String> studyTagId = GeneratedColumn<String>(
    'study_tag_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES study_tags (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _deckIdMeta = const VerificationMeta('deckId');
  @override
  late final GeneratedColumn<String> deckId = GeneratedColumn<String>(
    'deck_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES decks (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [studyTagId, deckId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'study_tag_decks';
  @override
  VerificationContext validateIntegrity(
    Insertable<StudyTagDeckRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('study_tag_id')) {
      context.handle(
        _studyTagIdMeta,
        studyTagId.isAcceptableOrUnknown(
          data['study_tag_id']!,
          _studyTagIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_studyTagIdMeta);
    }
    if (data.containsKey('deck_id')) {
      context.handle(
        _deckIdMeta,
        deckId.isAcceptableOrUnknown(data['deck_id']!, _deckIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deckIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {studyTagId, deckId};
  @override
  StudyTagDeckRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StudyTagDeckRow(
      studyTagId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}study_tag_id'],
      )!,
      deckId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deck_id'],
      )!,
    );
  }

  @override
  $StudyTagDecksTable createAlias(String alias) {
    return $StudyTagDecksTable(attachedDatabase, alias);
  }
}

class StudyTagDeckRow extends DataClass implements Insertable<StudyTagDeckRow> {
  final String studyTagId;
  final String deckId;
  const StudyTagDeckRow({required this.studyTagId, required this.deckId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['study_tag_id'] = Variable<String>(studyTagId);
    map['deck_id'] = Variable<String>(deckId);
    return map;
  }

  StudyTagDecksCompanion toCompanion(bool nullToAbsent) {
    return StudyTagDecksCompanion(
      studyTagId: Value(studyTagId),
      deckId: Value(deckId),
    );
  }

  factory StudyTagDeckRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StudyTagDeckRow(
      studyTagId: serializer.fromJson<String>(json['studyTagId']),
      deckId: serializer.fromJson<String>(json['deckId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'studyTagId': serializer.toJson<String>(studyTagId),
      'deckId': serializer.toJson<String>(deckId),
    };
  }

  StudyTagDeckRow copyWith({String? studyTagId, String? deckId}) =>
      StudyTagDeckRow(
        studyTagId: studyTagId ?? this.studyTagId,
        deckId: deckId ?? this.deckId,
      );
  StudyTagDeckRow copyWithCompanion(StudyTagDecksCompanion data) {
    return StudyTagDeckRow(
      studyTagId: data.studyTagId.present
          ? data.studyTagId.value
          : this.studyTagId,
      deckId: data.deckId.present ? data.deckId.value : this.deckId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StudyTagDeckRow(')
          ..write('studyTagId: $studyTagId, ')
          ..write('deckId: $deckId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(studyTagId, deckId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StudyTagDeckRow &&
          other.studyTagId == this.studyTagId &&
          other.deckId == this.deckId);
}

class StudyTagDecksCompanion extends UpdateCompanion<StudyTagDeckRow> {
  final Value<String> studyTagId;
  final Value<String> deckId;
  final Value<int> rowid;
  const StudyTagDecksCompanion({
    this.studyTagId = const Value.absent(),
    this.deckId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StudyTagDecksCompanion.insert({
    required String studyTagId,
    required String deckId,
    this.rowid = const Value.absent(),
  }) : studyTagId = Value(studyTagId),
       deckId = Value(deckId);
  static Insertable<StudyTagDeckRow> custom({
    Expression<String>? studyTagId,
    Expression<String>? deckId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (studyTagId != null) 'study_tag_id': studyTagId,
      if (deckId != null) 'deck_id': deckId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StudyTagDecksCompanion copyWith({
    Value<String>? studyTagId,
    Value<String>? deckId,
    Value<int>? rowid,
  }) {
    return StudyTagDecksCompanion(
      studyTagId: studyTagId ?? this.studyTagId,
      deckId: deckId ?? this.deckId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (studyTagId.present) {
      map['study_tag_id'] = Variable<String>(studyTagId.value);
    }
    if (deckId.present) {
      map['deck_id'] = Variable<String>(deckId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StudyTagDecksCompanion(')
          ..write('studyTagId: $studyTagId, ')
          ..write('deckId: $deckId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DecksTable decks = $DecksTable(this);
  late final $CardsTable cards = $CardsTable(this);
  late final $CardAttachmentsTable cardAttachments = $CardAttachmentsTable(
    this,
  );
  late final $ReviewLogsTable reviewLogs = $ReviewLogsTable(this);
  late final $StudyTagsTable studyTags = $StudyTagsTable(this);
  late final $StudyTagDecksTable studyTagDecks = $StudyTagDecksTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    decks,
    cards,
    cardAttachments,
    reviewLogs,
    studyTags,
    studyTagDecks,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'decks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('cards', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'cards',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('card_attachments', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'study_tags',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('study_tag_decks', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'decks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('study_tag_decks', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$DecksTableCreateCompanionBuilder = DecksCompanion Function({
  required String id,
  required String name,
  Value<bool> keepAttachmentsOffline,
  required int createdAt,
  Value<int> rowid,
});
typedef $$DecksTableUpdateCompanionBuilder = DecksCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<bool> keepAttachmentsOffline,
  Value<int> createdAt,
  Value<int> rowid,
});

final class $$DecksTableReferences
    extends BaseReferences<_$AppDatabase, $DecksTable, DeckRow> {
  $$DecksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CardsTable, List<CardRow>> _cardsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.cards,
    aliasName: 'decks__id__cards__deck_id',
  );

  $$CardsTableProcessedTableManager get cardsRefs {
    final manager = $$CardsTableTableManager(
      $_db,
      $_db.cards,
    ).filter((f) => f.deckId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_cardsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$StudyTagDecksTable, List<StudyTagDeckRow>>
  _studyTagDecksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.studyTagDecks,
    aliasName: 'decks__id__study_tag_decks__deck_id',
  );

  $$StudyTagDecksTableProcessedTableManager get studyTagDecksRefs {
    final manager = $$StudyTagDecksTableTableManager(
      $_db,
      $_db.studyTagDecks,
    ).filter((f) => f.deckId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_studyTagDecksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DecksTableFilterComposer extends Composer<_$AppDatabase, $DecksTable> {
  $$DecksTableFilterComposer({
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

  ColumnFilters<bool> get keepAttachmentsOffline => $composableBuilder(
    column: $table.keepAttachmentsOffline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> cardsRefs(
    Expression<bool> Function($$CardsTableFilterComposer f) f,
  ) {
    final $$CardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cards,
      getReferencedColumn: (t) => t.deckId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardsTableFilterComposer(
            $db: $db,
            $table: $db.cards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> studyTagDecksRefs(
    Expression<bool> Function($$StudyTagDecksTableFilterComposer f) f,
  ) {
    final $$StudyTagDecksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.studyTagDecks,
      getReferencedColumn: (t) => t.deckId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudyTagDecksTableFilterComposer(
            $db: $db,
            $table: $db.studyTagDecks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DecksTableOrderingComposer
    extends Composer<_$AppDatabase, $DecksTable> {
  $$DecksTableOrderingComposer({
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

  ColumnOrderings<bool> get keepAttachmentsOffline => $composableBuilder(
    column: $table.keepAttachmentsOffline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DecksTableAnnotationComposer
    extends Composer<_$AppDatabase, $DecksTable> {
  $$DecksTableAnnotationComposer({
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

  GeneratedColumn<bool> get keepAttachmentsOffline => $composableBuilder(
    column: $table.keepAttachmentsOffline,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> cardsRefs<T extends Object>(
    Expression<T> Function($$CardsTableAnnotationComposer a) f,
  ) {
    final $$CardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cards,
      getReferencedColumn: (t) => t.deckId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardsTableAnnotationComposer(
            $db: $db,
            $table: $db.cards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> studyTagDecksRefs<T extends Object>(
    Expression<T> Function($$StudyTagDecksTableAnnotationComposer a) f,
  ) {
    final $$StudyTagDecksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.studyTagDecks,
      getReferencedColumn: (t) => t.deckId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudyTagDecksTableAnnotationComposer(
            $db: $db,
            $table: $db.studyTagDecks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DecksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DecksTable,
          DeckRow,
          $$DecksTableFilterComposer,
          $$DecksTableOrderingComposer,
          $$DecksTableAnnotationComposer,
          $$DecksTableCreateCompanionBuilder,
          $$DecksTableUpdateCompanionBuilder,
          (DeckRow, $$DecksTableReferences),
          DeckRow,
          PrefetchHooks Function({bool cardsRefs, bool studyTagDecksRefs})
        > {
  $$DecksTableTableManager(_$AppDatabase db, $DecksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DecksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DecksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DecksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<bool> keepAttachmentsOffline = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DecksCompanion(
                id: id,
                name: name,
                keepAttachmentsOffline: keepAttachmentsOffline,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<bool> keepAttachmentsOffline = const Value.absent(),
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => DecksCompanion.insert(
                id: id,
                name: name,
                keepAttachmentsOffline: keepAttachmentsOffline,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DecksTable, DeckRow>(table),
                  $$DecksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({cardsRefs = false, studyTagDecksRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (cardsRefs) db.cards,
                    if (studyTagDecksRefs) db.studyTagDecks,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (cardsRefs)
                        await $_getPrefetchedDataByColumns<
                          DeckRow,
                          $DecksTable,
                          CardRow,
                          $CardsTable
                        >(
                          currentTable: table,
                          referencedTable: $$DecksTableReferences
                              ._cardsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DecksTableReferences(db, table, p0).cardsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'deck_id',
                          typedResults: items,
                        ),
                      if (studyTagDecksRefs)
                        await $_getPrefetchedDataByColumns<
                          DeckRow,
                          $DecksTable,
                          StudyTagDeckRow,
                          $StudyTagDecksTable
                        >(
                          currentTable: table,
                          referencedTable: $$DecksTableReferences
                              ._studyTagDecksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DecksTableReferences(
                                db,
                                table,
                                p0,
                              ).studyTagDecksRefs,
                          currentColumn: 'id',
                          referencedColumn: 'deck_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$DecksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DecksTable,
      DeckRow,
      $$DecksTableFilterComposer,
      $$DecksTableOrderingComposer,
      $$DecksTableAnnotationComposer,
      $$DecksTableCreateCompanionBuilder,
      $$DecksTableUpdateCompanionBuilder,
      (DeckRow, $$DecksTableReferences),
      DeckRow,
      PrefetchHooks Function({bool cardsRefs, bool studyTagDecksRefs})
    >;
typedef $$CardsTableCreateCompanionBuilder = CardsCompanion Function({
  required String id,
  required String deckId,
  required String front,
  required String back,
  required String due,
  Value<double> stability,
  Value<double> difficulty,
  Value<int> elapsedDays,
  Value<int> scheduledDays,
  Value<int> learningSteps,
  Value<int> reps,
  Value<int> lapses,
  Value<int> state,
  Value<String?> lastReview,
  required int createdAt,
  required int updatedAt,
  Value<int> rowid,
});
typedef $$CardsTableUpdateCompanionBuilder = CardsCompanion Function({
  Value<String> id,
  Value<String> deckId,
  Value<String> front,
  Value<String> back,
  Value<String> due,
  Value<double> stability,
  Value<double> difficulty,
  Value<int> elapsedDays,
  Value<int> scheduledDays,
  Value<int> learningSteps,
  Value<int> reps,
  Value<int> lapses,
  Value<int> state,
  Value<String?> lastReview,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int> rowid,
});

final class $$CardsTableReferences
    extends BaseReferences<_$AppDatabase, $CardsTable, CardRow> {
  $$CardsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DecksTable _deckIdTable(_$AppDatabase db) =>
      db.decks.createAlias('cards__deck_id__decks__id');

  $$DecksTableProcessedTableManager get deckId {
    final $_column = $_itemColumn<String>('deck_id')!;

    final manager = $$DecksTableTableManager(
      $_db,
      $_db.decks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_deckIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$CardAttachmentsTable, List<CardAttachmentRow>>
  _cardAttachmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.cardAttachments,
    aliasName: 'cards__id__card_attachments__card_id',
  );

  $$CardAttachmentsTableProcessedTableManager get cardAttachmentsRefs {
    final manager = $$CardAttachmentsTableTableManager(
      $_db,
      $_db.cardAttachments,
    ).filter((f) => f.cardId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _cardAttachmentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CardsTableFilterComposer extends Composer<_$AppDatabase, $CardsTable> {
  $$CardsTableFilterComposer({
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

  ColumnFilters<String> get front => $composableBuilder(
    column: $table.front,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get back => $composableBuilder(
    column: $table.back,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get due => $composableBuilder(
    column: $table.due,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get stability => $composableBuilder(
    column: $table.stability,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get elapsedDays => $composableBuilder(
    column: $table.elapsedDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get scheduledDays => $composableBuilder(
    column: $table.scheduledDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get learningSteps => $composableBuilder(
    column: $table.learningSteps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lapses => $composableBuilder(
    column: $table.lapses,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastReview => $composableBuilder(
    column: $table.lastReview,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$DecksTableFilterComposer get deckId {
    final $$DecksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deckId,
      referencedTable: $db.decks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DecksTableFilterComposer(
            $db: $db,
            $table: $db.decks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> cardAttachmentsRefs(
    Expression<bool> Function($$CardAttachmentsTableFilterComposer f) f,
  ) {
    final $$CardAttachmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cardAttachments,
      getReferencedColumn: (t) => t.cardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardAttachmentsTableFilterComposer(
            $db: $db,
            $table: $db.cardAttachments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CardsTableOrderingComposer
    extends Composer<_$AppDatabase, $CardsTable> {
  $$CardsTableOrderingComposer({
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

  ColumnOrderings<String> get front => $composableBuilder(
    column: $table.front,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get back => $composableBuilder(
    column: $table.back,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get due => $composableBuilder(
    column: $table.due,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get stability => $composableBuilder(
    column: $table.stability,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get elapsedDays => $composableBuilder(
    column: $table.elapsedDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get scheduledDays => $composableBuilder(
    column: $table.scheduledDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get learningSteps => $composableBuilder(
    column: $table.learningSteps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lapses => $composableBuilder(
    column: $table.lapses,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastReview => $composableBuilder(
    column: $table.lastReview,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$DecksTableOrderingComposer get deckId {
    final $$DecksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deckId,
      referencedTable: $db.decks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DecksTableOrderingComposer(
            $db: $db,
            $table: $db.decks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CardsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CardsTable> {
  $$CardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get front =>
      $composableBuilder(column: $table.front, builder: (column) => column);

  GeneratedColumn<String> get back =>
      $composableBuilder(column: $table.back, builder: (column) => column);

  GeneratedColumn<String> get due =>
      $composableBuilder(column: $table.due, builder: (column) => column);

  GeneratedColumn<double> get stability =>
      $composableBuilder(column: $table.stability, builder: (column) => column);

  GeneratedColumn<double> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => column,
  );

  GeneratedColumn<int> get elapsedDays => $composableBuilder(
    column: $table.elapsedDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get scheduledDays => $composableBuilder(
    column: $table.scheduledDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get learningSteps => $composableBuilder(
    column: $table.learningSteps,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => column);

  GeneratedColumn<int> get lapses =>
      $composableBuilder(column: $table.lapses, builder: (column) => column);

  GeneratedColumn<int> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get lastReview => $composableBuilder(
    column: $table.lastReview,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$DecksTableAnnotationComposer get deckId {
    final $$DecksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deckId,
      referencedTable: $db.decks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DecksTableAnnotationComposer(
            $db: $db,
            $table: $db.decks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> cardAttachmentsRefs<T extends Object>(
    Expression<T> Function($$CardAttachmentsTableAnnotationComposer a) f,
  ) {
    final $$CardAttachmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cardAttachments,
      getReferencedColumn: (t) => t.cardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardAttachmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.cardAttachments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CardsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CardsTable,
          CardRow,
          $$CardsTableFilterComposer,
          $$CardsTableOrderingComposer,
          $$CardsTableAnnotationComposer,
          $$CardsTableCreateCompanionBuilder,
          $$CardsTableUpdateCompanionBuilder,
          (CardRow, $$CardsTableReferences),
          CardRow,
          PrefetchHooks Function({bool deckId, bool cardAttachmentsRefs})
        > {
  $$CardsTableTableManager(_$AppDatabase db, $CardsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> deckId = const Value.absent(),
                Value<String> front = const Value.absent(),
                Value<String> back = const Value.absent(),
                Value<String> due = const Value.absent(),
                Value<double> stability = const Value.absent(),
                Value<double> difficulty = const Value.absent(),
                Value<int> elapsedDays = const Value.absent(),
                Value<int> scheduledDays = const Value.absent(),
                Value<int> learningSteps = const Value.absent(),
                Value<int> reps = const Value.absent(),
                Value<int> lapses = const Value.absent(),
                Value<int> state = const Value.absent(),
                Value<String?> lastReview = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CardsCompanion(
                id: id,
                deckId: deckId,
                front: front,
                back: back,
                due: due,
                stability: stability,
                difficulty: difficulty,
                elapsedDays: elapsedDays,
                scheduledDays: scheduledDays,
                learningSteps: learningSteps,
                reps: reps,
                lapses: lapses,
                state: state,
                lastReview: lastReview,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String deckId,
                required String front,
                required String back,
                required String due,
                Value<double> stability = const Value.absent(),
                Value<double> difficulty = const Value.absent(),
                Value<int> elapsedDays = const Value.absent(),
                Value<int> scheduledDays = const Value.absent(),
                Value<int> learningSteps = const Value.absent(),
                Value<int> reps = const Value.absent(),
                Value<int> lapses = const Value.absent(),
                Value<int> state = const Value.absent(),
                Value<String?> lastReview = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CardsCompanion.insert(
                id: id,
                deckId: deckId,
                front: front,
                back: back,
                due: due,
                stability: stability,
                difficulty: difficulty,
                elapsedDays: elapsedDays,
                scheduledDays: scheduledDays,
                learningSteps: learningSteps,
                reps: reps,
                lapses: lapses,
                state: state,
                lastReview: lastReview,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CardsTable, CardRow>(table),
                  $$CardsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({deckId = false, cardAttachmentsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (cardAttachmentsRefs) db.cardAttachments,
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
                        if (deckId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.deckId,
                            referencedTable: $$CardsTableReferences
                                ._deckIdTable(db),
                            referencedColumn: $$CardsTableReferences
                                ._deckIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (cardAttachmentsRefs)
                        await $_getPrefetchedDataByColumns<
                          CardRow,
                          $CardsTable,
                          CardAttachmentRow,
                          $CardAttachmentsTable
                        >(
                          currentTable: table,
                          referencedTable: $$CardsTableReferences
                              ._cardAttachmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CardsTableReferences(
                                db,
                                table,
                                p0,
                              ).cardAttachmentsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'card_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CardsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CardsTable,
      CardRow,
      $$CardsTableFilterComposer,
      $$CardsTableOrderingComposer,
      $$CardsTableAnnotationComposer,
      $$CardsTableCreateCompanionBuilder,
      $$CardsTableUpdateCompanionBuilder,
      (CardRow, $$CardsTableReferences),
      CardRow,
      PrefetchHooks Function({bool deckId, bool cardAttachmentsRefs})
    >;
typedef $$CardAttachmentsTableCreateCompanionBuilder =
    CardAttachmentsCompanion Function({
      Value<int> id,
      required String cardId,
      required String side,
      required int position,
      required String type,
      Value<String?> url,
      Value<String> caption,
      Value<String?> attribution,
      Value<String?> languageQid,
      Value<String?> blobContent,
      required int createdAt,
    });
typedef $$CardAttachmentsTableUpdateCompanionBuilder =
    CardAttachmentsCompanion Function({
      Value<int> id,
      Value<String> cardId,
      Value<String> side,
      Value<int> position,
      Value<String> type,
      Value<String?> url,
      Value<String> caption,
      Value<String?> attribution,
      Value<String?> languageQid,
      Value<String?> blobContent,
      Value<int> createdAt,
    });

final class $$CardAttachmentsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CardAttachmentsTable,
          CardAttachmentRow
        > {
  $$CardAttachmentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CardsTable _cardIdTable(_$AppDatabase db) =>
      db.cards.createAlias('card_attachments__card_id__cards__id');

  $$CardsTableProcessedTableManager get cardId {
    final $_column = $_itemColumn<String>('card_id')!;

    final manager = $$CardsTableTableManager(
      $_db,
      $_db.cards,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cardIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CardAttachmentsTableFilterComposer
    extends Composer<_$AppDatabase, $CardAttachmentsTable> {
  $$CardAttachmentsTableFilterComposer({
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

  ColumnFilters<String> get side => $composableBuilder(
    column: $table.side,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get caption => $composableBuilder(
    column: $table.caption,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get attribution => $composableBuilder(
    column: $table.attribution,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get languageQid => $composableBuilder(
    column: $table.languageQid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get blobContent => $composableBuilder(
    column: $table.blobContent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CardsTableFilterComposer get cardId {
    final $$CardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.cards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardsTableFilterComposer(
            $db: $db,
            $table: $db.cards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CardAttachmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $CardAttachmentsTable> {
  $$CardAttachmentsTableOrderingComposer({
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

  ColumnOrderings<String> get side => $composableBuilder(
    column: $table.side,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get caption => $composableBuilder(
    column: $table.caption,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get attribution => $composableBuilder(
    column: $table.attribution,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get languageQid => $composableBuilder(
    column: $table.languageQid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get blobContent => $composableBuilder(
    column: $table.blobContent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CardsTableOrderingComposer get cardId {
    final $$CardsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.cards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardsTableOrderingComposer(
            $db: $db,
            $table: $db.cards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CardAttachmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CardAttachmentsTable> {
  $$CardAttachmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get side =>
      $composableBuilder(column: $table.side, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get caption =>
      $composableBuilder(column: $table.caption, builder: (column) => column);

  GeneratedColumn<String> get attribution => $composableBuilder(
    column: $table.attribution,
    builder: (column) => column,
  );

  GeneratedColumn<String> get languageQid => $composableBuilder(
    column: $table.languageQid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get blobContent => $composableBuilder(
    column: $table.blobContent,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$CardsTableAnnotationComposer get cardId {
    final $$CardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.cards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardsTableAnnotationComposer(
            $db: $db,
            $table: $db.cards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CardAttachmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CardAttachmentsTable,
          CardAttachmentRow,
          $$CardAttachmentsTableFilterComposer,
          $$CardAttachmentsTableOrderingComposer,
          $$CardAttachmentsTableAnnotationComposer,
          $$CardAttachmentsTableCreateCompanionBuilder,
          $$CardAttachmentsTableUpdateCompanionBuilder,
          (CardAttachmentRow, $$CardAttachmentsTableReferences),
          CardAttachmentRow,
          PrefetchHooks Function({bool cardId})
        > {
  $$CardAttachmentsTableTableManager(
    _$AppDatabase db,
    $CardAttachmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CardAttachmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CardAttachmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CardAttachmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> cardId = const Value.absent(),
                Value<String> side = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> url = const Value.absent(),
                Value<String> caption = const Value.absent(),
                Value<String?> attribution = const Value.absent(),
                Value<String?> languageQid = const Value.absent(),
                Value<String?> blobContent = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
              }) => CardAttachmentsCompanion(
                id: id,
                cardId: cardId,
                side: side,
                position: position,
                type: type,
                url: url,
                caption: caption,
                attribution: attribution,
                languageQid: languageQid,
                blobContent: blobContent,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String cardId,
                required String side,
                required int position,
                required String type,
                Value<String?> url = const Value.absent(),
                Value<String> caption = const Value.absent(),
                Value<String?> attribution = const Value.absent(),
                Value<String?> languageQid = const Value.absent(),
                Value<String?> blobContent = const Value.absent(),
                required int createdAt,
              }) => CardAttachmentsCompanion.insert(
                id: id,
                cardId: cardId,
                side: side,
                position: position,
                type: type,
                url: url,
                caption: caption,
                attribution: attribution,
                languageQid: languageQid,
                blobContent: blobContent,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CardAttachmentsTable, CardAttachmentRow>(table),
                  $$CardAttachmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({cardId = false}) {
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
                    if (cardId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.cardId,
                        referencedTable: $$CardAttachmentsTableReferences
                            ._cardIdTable(db),
                        referencedColumn: $$CardAttachmentsTableReferences
                            ._cardIdTable(db)
                            .id,
                      ) as T;
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

typedef $$CardAttachmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CardAttachmentsTable,
      CardAttachmentRow,
      $$CardAttachmentsTableFilterComposer,
      $$CardAttachmentsTableOrderingComposer,
      $$CardAttachmentsTableAnnotationComposer,
      $$CardAttachmentsTableCreateCompanionBuilder,
      $$CardAttachmentsTableUpdateCompanionBuilder,
      (CardAttachmentRow, $$CardAttachmentsTableReferences),
      CardAttachmentRow,
      PrefetchHooks Function({bool cardId})
    >;
typedef $$ReviewLogsTableCreateCompanionBuilder = ReviewLogsCompanion Function({
  required String id,
  required String cardId,
  required int rating,
  required int state,
  required String due,
  required double stability,
  required double difficulty,
  required int elapsedDays,
  required int lastElapsedDays,
  required int scheduledDays,
  required int learningSteps,
  required String review,
  Value<int> rowid,
});
typedef $$ReviewLogsTableUpdateCompanionBuilder = ReviewLogsCompanion Function({
  Value<String> id,
  Value<String> cardId,
  Value<int> rating,
  Value<int> state,
  Value<String> due,
  Value<double> stability,
  Value<double> difficulty,
  Value<int> elapsedDays,
  Value<int> lastElapsedDays,
  Value<int> scheduledDays,
  Value<int> learningSteps,
  Value<String> review,
  Value<int> rowid,
});

class $$ReviewLogsTableFilterComposer
    extends Composer<_$AppDatabase, $ReviewLogsTable> {
  $$ReviewLogsTableFilterComposer({
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

  ColumnFilters<String> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get due => $composableBuilder(
    column: $table.due,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get stability => $composableBuilder(
    column: $table.stability,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get elapsedDays => $composableBuilder(
    column: $table.elapsedDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastElapsedDays => $composableBuilder(
    column: $table.lastElapsedDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get scheduledDays => $composableBuilder(
    column: $table.scheduledDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get learningSteps => $composableBuilder(
    column: $table.learningSteps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get review => $composableBuilder(
    column: $table.review,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReviewLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReviewLogsTable> {
  $$ReviewLogsTableOrderingComposer({
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

  ColumnOrderings<String> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get due => $composableBuilder(
    column: $table.due,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get stability => $composableBuilder(
    column: $table.stability,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get elapsedDays => $composableBuilder(
    column: $table.elapsedDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastElapsedDays => $composableBuilder(
    column: $table.lastElapsedDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get scheduledDays => $composableBuilder(
    column: $table.scheduledDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get learningSteps => $composableBuilder(
    column: $table.learningSteps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get review => $composableBuilder(
    column: $table.review,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReviewLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReviewLogsTable> {
  $$ReviewLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get cardId =>
      $composableBuilder(column: $table.cardId, builder: (column) => column);

  GeneratedColumn<int> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<int> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get due =>
      $composableBuilder(column: $table.due, builder: (column) => column);

  GeneratedColumn<double> get stability =>
      $composableBuilder(column: $table.stability, builder: (column) => column);

  GeneratedColumn<double> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => column,
  );

  GeneratedColumn<int> get elapsedDays => $composableBuilder(
    column: $table.elapsedDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastElapsedDays => $composableBuilder(
    column: $table.lastElapsedDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get scheduledDays => $composableBuilder(
    column: $table.scheduledDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get learningSteps => $composableBuilder(
    column: $table.learningSteps,
    builder: (column) => column,
  );

  GeneratedColumn<String> get review =>
      $composableBuilder(column: $table.review, builder: (column) => column);
}

class $$ReviewLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReviewLogsTable,
          ReviewLogRow,
          $$ReviewLogsTableFilterComposer,
          $$ReviewLogsTableOrderingComposer,
          $$ReviewLogsTableAnnotationComposer,
          $$ReviewLogsTableCreateCompanionBuilder,
          $$ReviewLogsTableUpdateCompanionBuilder,
          (
            ReviewLogRow,
            BaseReferences<_$AppDatabase, $ReviewLogsTable, ReviewLogRow>,
          ),
          ReviewLogRow,
          PrefetchHooks Function()
        > {
  $$ReviewLogsTableTableManager(_$AppDatabase db, $ReviewLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReviewLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReviewLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReviewLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> cardId = const Value.absent(),
                Value<int> rating = const Value.absent(),
                Value<int> state = const Value.absent(),
                Value<String> due = const Value.absent(),
                Value<double> stability = const Value.absent(),
                Value<double> difficulty = const Value.absent(),
                Value<int> elapsedDays = const Value.absent(),
                Value<int> lastElapsedDays = const Value.absent(),
                Value<int> scheduledDays = const Value.absent(),
                Value<int> learningSteps = const Value.absent(),
                Value<String> review = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReviewLogsCompanion(
                id: id,
                cardId: cardId,
                rating: rating,
                state: state,
                due: due,
                stability: stability,
                difficulty: difficulty,
                elapsedDays: elapsedDays,
                lastElapsedDays: lastElapsedDays,
                scheduledDays: scheduledDays,
                learningSteps: learningSteps,
                review: review,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String cardId,
                required int rating,
                required int state,
                required String due,
                required double stability,
                required double difficulty,
                required int elapsedDays,
                required int lastElapsedDays,
                required int scheduledDays,
                required int learningSteps,
                required String review,
                Value<int> rowid = const Value.absent(),
              }) => ReviewLogsCompanion.insert(
                id: id,
                cardId: cardId,
                rating: rating,
                state: state,
                due: due,
                stability: stability,
                difficulty: difficulty,
                elapsedDays: elapsedDays,
                lastElapsedDays: lastElapsedDays,
                scheduledDays: scheduledDays,
                learningSteps: learningSteps,
                review: review,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReviewLogsTable, ReviewLogRow>(table),
                  BaseReferences<_$AppDatabase, $ReviewLogsTable, ReviewLogRow>(
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

typedef $$ReviewLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReviewLogsTable,
      ReviewLogRow,
      $$ReviewLogsTableFilterComposer,
      $$ReviewLogsTableOrderingComposer,
      $$ReviewLogsTableAnnotationComposer,
      $$ReviewLogsTableCreateCompanionBuilder,
      $$ReviewLogsTableUpdateCompanionBuilder,
      (
        ReviewLogRow,
        BaseReferences<_$AppDatabase, $ReviewLogsTable, ReviewLogRow>,
      ),
      ReviewLogRow,
      PrefetchHooks Function()
    >;
typedef $$StudyTagsTableCreateCompanionBuilder = StudyTagsCompanion Function({
  required String id,
  Value<String> name,
  required int createdAt,
  Value<int> rowid,
});
typedef $$StudyTagsTableUpdateCompanionBuilder = StudyTagsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<int> createdAt,
  Value<int> rowid,
});

final class $$StudyTagsTableReferences
    extends BaseReferences<_$AppDatabase, $StudyTagsTable, StudyTagRow> {
  $$StudyTagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$StudyTagDecksTable, List<StudyTagDeckRow>>
  _studyTagDecksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.studyTagDecks,
    aliasName: 'study_tags__id__study_tag_decks__study_tag_id',
  );

  $$StudyTagDecksTableProcessedTableManager get studyTagDecksRefs {
    final manager = $$StudyTagDecksTableTableManager(
      $_db,
      $_db.studyTagDecks,
    ).filter((f) => f.studyTagId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_studyTagDecksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$StudyTagsTableFilterComposer
    extends Composer<_$AppDatabase, $StudyTagsTable> {
  $$StudyTagsTableFilterComposer({
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

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> studyTagDecksRefs(
    Expression<bool> Function($$StudyTagDecksTableFilterComposer f) f,
  ) {
    final $$StudyTagDecksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.studyTagDecks,
      getReferencedColumn: (t) => t.studyTagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudyTagDecksTableFilterComposer(
            $db: $db,
            $table: $db.studyTagDecks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StudyTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $StudyTagsTable> {
  $$StudyTagsTableOrderingComposer({
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

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StudyTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StudyTagsTable> {
  $$StudyTagsTableAnnotationComposer({
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

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> studyTagDecksRefs<T extends Object>(
    Expression<T> Function($$StudyTagDecksTableAnnotationComposer a) f,
  ) {
    final $$StudyTagDecksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.studyTagDecks,
      getReferencedColumn: (t) => t.studyTagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudyTagDecksTableAnnotationComposer(
            $db: $db,
            $table: $db.studyTagDecks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StudyTagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StudyTagsTable,
          StudyTagRow,
          $$StudyTagsTableFilterComposer,
          $$StudyTagsTableOrderingComposer,
          $$StudyTagsTableAnnotationComposer,
          $$StudyTagsTableCreateCompanionBuilder,
          $$StudyTagsTableUpdateCompanionBuilder,
          (StudyTagRow, $$StudyTagsTableReferences),
          StudyTagRow,
          PrefetchHooks Function({bool studyTagDecksRefs})
        > {
  $$StudyTagsTableTableManager(_$AppDatabase db, $StudyTagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StudyTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StudyTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StudyTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StudyTagsCompanion(
                id: id,
                name: name,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> name = const Value.absent(),
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => StudyTagsCompanion.insert(
                id: id,
                name: name,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$StudyTagsTable, StudyTagRow>(table),
                  $$StudyTagsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({studyTagDecksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (studyTagDecksRefs) db.studyTagDecks,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (studyTagDecksRefs)
                    await $_getPrefetchedDataByColumns<
                      StudyTagRow,
                      $StudyTagsTable,
                      StudyTagDeckRow,
                      $StudyTagDecksTable
                    >(
                      currentTable: table,
                      referencedTable: $$StudyTagsTableReferences
                          ._studyTagDecksRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$StudyTagsTableReferences(
                            db,
                            table,
                            p0,
                          ).studyTagDecksRefs,
                      currentColumn: 'id',
                      referencedColumn: 'study_tag_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$StudyTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StudyTagsTable,
      StudyTagRow,
      $$StudyTagsTableFilterComposer,
      $$StudyTagsTableOrderingComposer,
      $$StudyTagsTableAnnotationComposer,
      $$StudyTagsTableCreateCompanionBuilder,
      $$StudyTagsTableUpdateCompanionBuilder,
      (StudyTagRow, $$StudyTagsTableReferences),
      StudyTagRow,
      PrefetchHooks Function({bool studyTagDecksRefs})
    >;
typedef $$StudyTagDecksTableCreateCompanionBuilder =
    StudyTagDecksCompanion Function({
      required String studyTagId,
      required String deckId,
      Value<int> rowid,
    });
typedef $$StudyTagDecksTableUpdateCompanionBuilder =
    StudyTagDecksCompanion Function({
      Value<String> studyTagId,
      Value<String> deckId,
      Value<int> rowid,
    });

final class $$StudyTagDecksTableReferences
    extends
        BaseReferences<_$AppDatabase, $StudyTagDecksTable, StudyTagDeckRow> {
  $$StudyTagDecksTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $StudyTagsTable _studyTagIdTable(_$AppDatabase db) =>
      db.studyTags.createAlias('study_tag_decks__study_tag_id__study_tags__id');

  $$StudyTagsTableProcessedTableManager get studyTagId {
    final $_column = $_itemColumn<String>('study_tag_id')!;

    final manager = $$StudyTagsTableTableManager(
      $_db,
      $_db.studyTags,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_studyTagIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $DecksTable _deckIdTable(_$AppDatabase db) =>
      db.decks.createAlias('study_tag_decks__deck_id__decks__id');

  $$DecksTableProcessedTableManager get deckId {
    final $_column = $_itemColumn<String>('deck_id')!;

    final manager = $$DecksTableTableManager(
      $_db,
      $_db.decks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_deckIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$StudyTagDecksTableFilterComposer
    extends Composer<_$AppDatabase, $StudyTagDecksTable> {
  $$StudyTagDecksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$StudyTagsTableFilterComposer get studyTagId {
    final $$StudyTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studyTagId,
      referencedTable: $db.studyTags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudyTagsTableFilterComposer(
            $db: $db,
            $table: $db.studyTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DecksTableFilterComposer get deckId {
    final $$DecksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deckId,
      referencedTable: $db.decks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DecksTableFilterComposer(
            $db: $db,
            $table: $db.decks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StudyTagDecksTableOrderingComposer
    extends Composer<_$AppDatabase, $StudyTagDecksTable> {
  $$StudyTagDecksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$StudyTagsTableOrderingComposer get studyTagId {
    final $$StudyTagsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studyTagId,
      referencedTable: $db.studyTags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudyTagsTableOrderingComposer(
            $db: $db,
            $table: $db.studyTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DecksTableOrderingComposer get deckId {
    final $$DecksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deckId,
      referencedTable: $db.decks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DecksTableOrderingComposer(
            $db: $db,
            $table: $db.decks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StudyTagDecksTableAnnotationComposer
    extends Composer<_$AppDatabase, $StudyTagDecksTable> {
  $$StudyTagDecksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$StudyTagsTableAnnotationComposer get studyTagId {
    final $$StudyTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studyTagId,
      referencedTable: $db.studyTags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudyTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.studyTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DecksTableAnnotationComposer get deckId {
    final $$DecksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deckId,
      referencedTable: $db.decks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DecksTableAnnotationComposer(
            $db: $db,
            $table: $db.decks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StudyTagDecksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StudyTagDecksTable,
          StudyTagDeckRow,
          $$StudyTagDecksTableFilterComposer,
          $$StudyTagDecksTableOrderingComposer,
          $$StudyTagDecksTableAnnotationComposer,
          $$StudyTagDecksTableCreateCompanionBuilder,
          $$StudyTagDecksTableUpdateCompanionBuilder,
          (StudyTagDeckRow, $$StudyTagDecksTableReferences),
          StudyTagDeckRow,
          PrefetchHooks Function({bool studyTagId, bool deckId})
        > {
  $$StudyTagDecksTableTableManager(_$AppDatabase db, $StudyTagDecksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StudyTagDecksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StudyTagDecksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StudyTagDecksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> studyTagId = const Value.absent(),
                Value<String> deckId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StudyTagDecksCompanion(
                studyTagId: studyTagId,
                deckId: deckId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String studyTagId,
                required String deckId,
                Value<int> rowid = const Value.absent(),
              }) => StudyTagDecksCompanion.insert(
                studyTagId: studyTagId,
                deckId: deckId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$StudyTagDecksTable, StudyTagDeckRow>(table),
                  $$StudyTagDecksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({studyTagId = false, deckId = false}) {
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
                    if (studyTagId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.studyTagId,
                        referencedTable: $$StudyTagDecksTableReferences
                            ._studyTagIdTable(db),
                        referencedColumn: $$StudyTagDecksTableReferences
                            ._studyTagIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (deckId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.deckId,
                        referencedTable: $$StudyTagDecksTableReferences
                            ._deckIdTable(db),
                        referencedColumn: $$StudyTagDecksTableReferences
                            ._deckIdTable(db)
                            .id,
                      ) as T;
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

typedef $$StudyTagDecksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StudyTagDecksTable,
      StudyTagDeckRow,
      $$StudyTagDecksTableFilterComposer,
      $$StudyTagDecksTableOrderingComposer,
      $$StudyTagDecksTableAnnotationComposer,
      $$StudyTagDecksTableCreateCompanionBuilder,
      $$StudyTagDecksTableUpdateCompanionBuilder,
      (StudyTagDeckRow, $$StudyTagDecksTableReferences),
      StudyTagDeckRow,
      PrefetchHooks Function({bool studyTagId, bool deckId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DecksTableTableManager get decks =>
      $$DecksTableTableManager(_db, _db.decks);
  $$CardsTableTableManager get cards =>
      $$CardsTableTableManager(_db, _db.cards);
  $$CardAttachmentsTableTableManager get cardAttachments =>
      $$CardAttachmentsTableTableManager(_db, _db.cardAttachments);
  $$ReviewLogsTableTableManager get reviewLogs =>
      $$ReviewLogsTableTableManager(_db, _db.reviewLogs);
  $$StudyTagsTableTableManager get studyTags =>
      $$StudyTagsTableTableManager(_db, _db.studyTags);
  $$StudyTagDecksTableTableManager get studyTagDecks =>
      $$StudyTagDecksTableTableManager(_db, _db.studyTagDecks);
}
