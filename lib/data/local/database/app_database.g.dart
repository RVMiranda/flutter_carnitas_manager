// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SyncQueueTableTable extends SyncQueueTable
    with TableInfo<$SyncQueueTableTable, SyncQueueTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
    'entity',
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
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idempotencyKeyMeta = const VerificationMeta(
    'idempotencyKey',
  );
  @override
  late final GeneratedColumn<String> idempotencyKey = GeneratedColumn<String>(
    'idempotency_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
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
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastAttemptAtMeta = const VerificationMeta(
    'lastAttemptAt',
  );
  @override
  late final GeneratedColumn<int> lastAttemptAt = GeneratedColumn<int>(
    'last_attempt_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _errorMessageMeta = const VerificationMeta(
    'errorMessage',
  );
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
    'error_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entity,
    entityId,
    operation,
    payload,
    idempotencyKey,
    createdAt,
    attempts,
    lastAttemptAt,
    status,
    errorMessage,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncQueueTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entity')) {
      context.handle(
        _entityMeta,
        entity.isAcceptableOrUnknown(data['entity']!, _entityMeta),
      );
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('idempotency_key')) {
      context.handle(
        _idempotencyKeyMeta,
        idempotencyKey.isAcceptableOrUnknown(
          data['idempotency_key']!,
          _idempotencyKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_idempotencyKeyMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('last_attempt_at')) {
      context.handle(
        _lastAttemptAtMeta,
        lastAttemptAt.isAcceptableOrUnknown(
          data['last_attempt_at']!,
          _lastAttemptAtMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('error_message')) {
      context.handle(
        _errorMessageMeta,
        errorMessage.isAcceptableOrUnknown(
          data['error_message']!,
          _errorMessageMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      entity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      idempotencyKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}idempotency_key'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      lastAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_attempt_at'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      errorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_message'],
      ),
    );
  }

  @override
  $SyncQueueTableTable createAlias(String alias) {
    return $SyncQueueTableTable(attachedDatabase, alias);
  }
}

class SyncQueueTableData extends DataClass
    implements Insertable<SyncQueueTableData> {
  final String id;
  final String entity;
  final String entityId;
  final String operation;
  final String payload;
  final String idempotencyKey;
  final int createdAt;
  final int attempts;
  final int? lastAttemptAt;
  final String status;
  final String? errorMessage;
  const SyncQueueTableData({
    required this.id,
    required this.entity,
    required this.entityId,
    required this.operation,
    required this.payload,
    required this.idempotencyKey,
    required this.createdAt,
    required this.attempts,
    this.lastAttemptAt,
    required this.status,
    this.errorMessage,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entity'] = Variable<String>(entity);
    map['entity_id'] = Variable<String>(entityId);
    map['operation'] = Variable<String>(operation);
    map['payload'] = Variable<String>(payload);
    map['idempotency_key'] = Variable<String>(idempotencyKey);
    map['created_at'] = Variable<int>(createdAt);
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || lastAttemptAt != null) {
      map['last_attempt_at'] = Variable<int>(lastAttemptAt);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    return map;
  }

  SyncQueueTableCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueTableCompanion(
      id: Value(id),
      entity: Value(entity),
      entityId: Value(entityId),
      operation: Value(operation),
      payload: Value(payload),
      idempotencyKey: Value(idempotencyKey),
      createdAt: Value(createdAt),
      attempts: Value(attempts),
      lastAttemptAt: lastAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAttemptAt),
      status: Value(status),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
    );
  }

  factory SyncQueueTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueTableData(
      id: serializer.fromJson<String>(json['id']),
      entity: serializer.fromJson<String>(json['entity']),
      entityId: serializer.fromJson<String>(json['entityId']),
      operation: serializer.fromJson<String>(json['operation']),
      payload: serializer.fromJson<String>(json['payload']),
      idempotencyKey: serializer.fromJson<String>(json['idempotencyKey']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      attempts: serializer.fromJson<int>(json['attempts']),
      lastAttemptAt: serializer.fromJson<int?>(json['lastAttemptAt']),
      status: serializer.fromJson<String>(json['status']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entity': serializer.toJson<String>(entity),
      'entityId': serializer.toJson<String>(entityId),
      'operation': serializer.toJson<String>(operation),
      'payload': serializer.toJson<String>(payload),
      'idempotencyKey': serializer.toJson<String>(idempotencyKey),
      'createdAt': serializer.toJson<int>(createdAt),
      'attempts': serializer.toJson<int>(attempts),
      'lastAttemptAt': serializer.toJson<int?>(lastAttemptAt),
      'status': serializer.toJson<String>(status),
      'errorMessage': serializer.toJson<String?>(errorMessage),
    };
  }

  SyncQueueTableData copyWith({
    String? id,
    String? entity,
    String? entityId,
    String? operation,
    String? payload,
    String? idempotencyKey,
    int? createdAt,
    int? attempts,
    Value<int?> lastAttemptAt = const Value.absent(),
    String? status,
    Value<String?> errorMessage = const Value.absent(),
  }) => SyncQueueTableData(
    id: id ?? this.id,
    entity: entity ?? this.entity,
    entityId: entityId ?? this.entityId,
    operation: operation ?? this.operation,
    payload: payload ?? this.payload,
    idempotencyKey: idempotencyKey ?? this.idempotencyKey,
    createdAt: createdAt ?? this.createdAt,
    attempts: attempts ?? this.attempts,
    lastAttemptAt: lastAttemptAt.present
        ? lastAttemptAt.value
        : this.lastAttemptAt,
    status: status ?? this.status,
    errorMessage: errorMessage.present ? errorMessage.value : this.errorMessage,
  );
  SyncQueueTableData copyWithCompanion(SyncQueueTableCompanion data) {
    return SyncQueueTableData(
      id: data.id.present ? data.id.value : this.id,
      entity: data.entity.present ? data.entity.value : this.entity,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      operation: data.operation.present ? data.operation.value : this.operation,
      payload: data.payload.present ? data.payload.value : this.payload,
      idempotencyKey: data.idempotencyKey.present
          ? data.idempotencyKey.value
          : this.idempotencyKey,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      lastAttemptAt: data.lastAttemptAt.present
          ? data.lastAttemptAt.value
          : this.lastAttemptAt,
      status: data.status.present ? data.status.value : this.status,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueTableData(')
          ..write('id: $id, ')
          ..write('entity: $entity, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('createdAt: $createdAt, ')
          ..write('attempts: $attempts, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('status: $status, ')
          ..write('errorMessage: $errorMessage')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entity,
    entityId,
    operation,
    payload,
    idempotencyKey,
    createdAt,
    attempts,
    lastAttemptAt,
    status,
    errorMessage,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueTableData &&
          other.id == this.id &&
          other.entity == this.entity &&
          other.entityId == this.entityId &&
          other.operation == this.operation &&
          other.payload == this.payload &&
          other.idempotencyKey == this.idempotencyKey &&
          other.createdAt == this.createdAt &&
          other.attempts == this.attempts &&
          other.lastAttemptAt == this.lastAttemptAt &&
          other.status == this.status &&
          other.errorMessage == this.errorMessage);
}

class SyncQueueTableCompanion extends UpdateCompanion<SyncQueueTableData> {
  final Value<String> id;
  final Value<String> entity;
  final Value<String> entityId;
  final Value<String> operation;
  final Value<String> payload;
  final Value<String> idempotencyKey;
  final Value<int> createdAt;
  final Value<int> attempts;
  final Value<int?> lastAttemptAt;
  final Value<String> status;
  final Value<String?> errorMessage;
  final Value<int> rowid;
  const SyncQueueTableCompanion({
    this.id = const Value.absent(),
    this.entity = const Value.absent(),
    this.entityId = const Value.absent(),
    this.operation = const Value.absent(),
    this.payload = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.attempts = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    this.status = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncQueueTableCompanion.insert({
    required String id,
    required String entity,
    required String entityId,
    required String operation,
    required String payload,
    required String idempotencyKey,
    required int createdAt,
    this.attempts = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    this.status = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       entity = Value(entity),
       entityId = Value(entityId),
       operation = Value(operation),
       payload = Value(payload),
       idempotencyKey = Value(idempotencyKey),
       createdAt = Value(createdAt);
  static Insertable<SyncQueueTableData> custom({
    Expression<String>? id,
    Expression<String>? entity,
    Expression<String>? entityId,
    Expression<String>? operation,
    Expression<String>? payload,
    Expression<String>? idempotencyKey,
    Expression<int>? createdAt,
    Expression<int>? attempts,
    Expression<int>? lastAttemptAt,
    Expression<String>? status,
    Expression<String>? errorMessage,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entity != null) 'entity': entity,
      if (entityId != null) 'entity_id': entityId,
      if (operation != null) 'operation': operation,
      if (payload != null) 'payload': payload,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (createdAt != null) 'created_at': createdAt,
      if (attempts != null) 'attempts': attempts,
      if (lastAttemptAt != null) 'last_attempt_at': lastAttemptAt,
      if (status != null) 'status': status,
      if (errorMessage != null) 'error_message': errorMessage,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncQueueTableCompanion copyWith({
    Value<String>? id,
    Value<String>? entity,
    Value<String>? entityId,
    Value<String>? operation,
    Value<String>? payload,
    Value<String>? idempotencyKey,
    Value<int>? createdAt,
    Value<int>? attempts,
    Value<int?>? lastAttemptAt,
    Value<String>? status,
    Value<String?>? errorMessage,
    Value<int>? rowid,
  }) {
    return SyncQueueTableCompanion(
      id: id ?? this.id,
      entity: entity ?? this.entity,
      entityId: entityId ?? this.entityId,
      operation: operation ?? this.operation,
      payload: payload ?? this.payload,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      createdAt: createdAt ?? this.createdAt,
      attempts: attempts ?? this.attempts,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (idempotencyKey.present) {
      map['idempotency_key'] = Variable<String>(idempotencyKey.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (lastAttemptAt.present) {
      map['last_attempt_at'] = Variable<int>(lastAttemptAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueTableCompanion(')
          ..write('id: $id, ')
          ..write('entity: $entity, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('createdAt: $createdAt, ')
          ..write('attempts: $attempts, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('status: $status, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MesasTableTable extends MesasTable
    with TableInfo<$MesasTableTable, MesasTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MesasTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _numeroMesaMeta = const VerificationMeta(
    'numeroMesa',
  );
  @override
  late final GeneratedColumn<String> numeroMesa = GeneratedColumn<String>(
    'numero_mesa',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _estadoMeta = const VerificationMeta('estado');
  @override
  late final GeneratedColumn<String> estado = GeneratedColumn<String>(
    'estado',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Libre'),
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
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    numeroMesa,
    estado,
    createdAt,
    updatedAt,
    isSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mesas';
  @override
  VerificationContext validateIntegrity(
    Insertable<MesasTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('numero_mesa')) {
      context.handle(
        _numeroMesaMeta,
        numeroMesa.isAcceptableOrUnknown(data['numero_mesa']!, _numeroMesaMeta),
      );
    } else if (isInserting) {
      context.missing(_numeroMesaMeta);
    }
    if (data.containsKey('estado')) {
      context.handle(
        _estadoMeta,
        estado.isAcceptableOrUnknown(data['estado']!, _estadoMeta),
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
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MesasTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MesasTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      numeroMesa: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}numero_mesa'],
      )!,
      estado: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estado'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
    );
  }

  @override
  $MesasTableTable createAlias(String alias) {
    return $MesasTableTable(attachedDatabase, alias);
  }
}

class MesasTableData extends DataClass implements Insertable<MesasTableData> {
  final String id;
  final String numeroMesa;
  final String estado;
  final int createdAt;
  final int updatedAt;
  final bool isSynced;
  const MesasTableData({
    required this.id,
    required this.numeroMesa,
    required this.estado,
    required this.createdAt,
    required this.updatedAt,
    required this.isSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['numero_mesa'] = Variable<String>(numeroMesa);
    map['estado'] = Variable<String>(estado);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  MesasTableCompanion toCompanion(bool nullToAbsent) {
    return MesasTableCompanion(
      id: Value(id),
      numeroMesa: Value(numeroMesa),
      estado: Value(estado),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isSynced: Value(isSynced),
    );
  }

  factory MesasTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MesasTableData(
      id: serializer.fromJson<String>(json['id']),
      numeroMesa: serializer.fromJson<String>(json['numeroMesa']),
      estado: serializer.fromJson<String>(json['estado']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'numeroMesa': serializer.toJson<String>(numeroMesa),
      'estado': serializer.toJson<String>(estado),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  MesasTableData copyWith({
    String? id,
    String? numeroMesa,
    String? estado,
    int? createdAt,
    int? updatedAt,
    bool? isSynced,
  }) => MesasTableData(
    id: id ?? this.id,
    numeroMesa: numeroMesa ?? this.numeroMesa,
    estado: estado ?? this.estado,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isSynced: isSynced ?? this.isSynced,
  );
  MesasTableData copyWithCompanion(MesasTableCompanion data) {
    return MesasTableData(
      id: data.id.present ? data.id.value : this.id,
      numeroMesa: data.numeroMesa.present
          ? data.numeroMesa.value
          : this.numeroMesa,
      estado: data.estado.present ? data.estado.value : this.estado,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MesasTableData(')
          ..write('id: $id, ')
          ..write('numeroMesa: $numeroMesa, ')
          ..write('estado: $estado, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, numeroMesa, estado, createdAt, updatedAt, isSynced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MesasTableData &&
          other.id == this.id &&
          other.numeroMesa == this.numeroMesa &&
          other.estado == this.estado &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isSynced == this.isSynced);
}

class MesasTableCompanion extends UpdateCompanion<MesasTableData> {
  final Value<String> id;
  final Value<String> numeroMesa;
  final Value<String> estado;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<bool> isSynced;
  final Value<int> rowid;
  const MesasTableCompanion({
    this.id = const Value.absent(),
    this.numeroMesa = const Value.absent(),
    this.estado = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MesasTableCompanion.insert({
    required String id,
    required String numeroMesa,
    this.estado = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       numeroMesa = Value(numeroMesa),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<MesasTableData> custom({
    Expression<String>? id,
    Expression<String>? numeroMesa,
    Expression<String>? estado,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<bool>? isSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (numeroMesa != null) 'numero_mesa': numeroMesa,
      if (estado != null) 'estado': estado,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MesasTableCompanion copyWith({
    Value<String>? id,
    Value<String>? numeroMesa,
    Value<String>? estado,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<bool>? isSynced,
    Value<int>? rowid,
  }) {
    return MesasTableCompanion(
      id: id ?? this.id,
      numeroMesa: numeroMesa ?? this.numeroMesa,
      estado: estado ?? this.estado,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (numeroMesa.present) {
      map['numero_mesa'] = Variable<String>(numeroMesa.value);
    }
    if (estado.present) {
      map['estado'] = Variable<String>(estado.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MesasTableCompanion(')
          ..write('id: $id, ')
          ..write('numeroMesa: $numeroMesa, ')
          ..write('estado: $estado, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ClientesTableTable extends ClientesTable
    with TableInfo<$ClientesTableTable, ClientesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClientesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _telefonoMeta = const VerificationMeta(
    'telefono',
  );
  @override
  late final GeneratedColumn<String> telefono = GeneratedColumn<String>(
    'telefono',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _visitasTotalesMeta = const VerificationMeta(
    'visitasTotales',
  );
  @override
  late final GeneratedColumn<int> visitasTotales = GeneratedColumn<int>(
    'visitas_totales',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _puntosLealtadMeta = const VerificationMeta(
    'puntosLealtad',
  );
  @override
  late final GeneratedColumn<int> puntosLealtad = GeneratedColumn<int>(
    'puntos_lealtad',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _fechaRegistroMeta = const VerificationMeta(
    'fechaRegistro',
  );
  @override
  late final GeneratedColumn<int> fechaRegistro = GeneratedColumn<int>(
    'fecha_registro',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
    userId,
    nombre,
    telefono,
    visitasTotales,
    puntosLealtad,
    fechaRegistro,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'clientes_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ClientesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('telefono')) {
      context.handle(
        _telefonoMeta,
        telefono.isAcceptableOrUnknown(data['telefono']!, _telefonoMeta),
      );
    }
    if (data.containsKey('visitas_totales')) {
      context.handle(
        _visitasTotalesMeta,
        visitasTotales.isAcceptableOrUnknown(
          data['visitas_totales']!,
          _visitasTotalesMeta,
        ),
      );
    }
    if (data.containsKey('puntos_lealtad')) {
      context.handle(
        _puntosLealtadMeta,
        puntosLealtad.isAcceptableOrUnknown(
          data['puntos_lealtad']!,
          _puntosLealtadMeta,
        ),
      );
    }
    if (data.containsKey('fecha_registro')) {
      context.handle(
        _fechaRegistroMeta,
        fechaRegistro.isAcceptableOrUnknown(
          data['fecha_registro']!,
          _fechaRegistroMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fechaRegistroMeta);
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
  ClientesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClientesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      telefono: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}telefono'],
      ),
      visitasTotales: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}visitas_totales'],
      )!,
      puntosLealtad: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}puntos_lealtad'],
      )!,
      fechaRegistro: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fecha_registro'],
      )!,
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
  $ClientesTableTable createAlias(String alias) {
    return $ClientesTableTable(attachedDatabase, alias);
  }
}

class ClientesTableData extends DataClass
    implements Insertable<ClientesTableData> {
  final String id;
  final String? userId;
  final String nombre;
  final String? telefono;
  final int visitasTotales;
  final int puntosLealtad;
  final int fechaRegistro;
  final int createdAt;
  final int updatedAt;
  const ClientesTableData({
    required this.id,
    this.userId,
    required this.nombre,
    this.telefono,
    required this.visitasTotales,
    required this.puntosLealtad,
    required this.fechaRegistro,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['nombre'] = Variable<String>(nombre);
    if (!nullToAbsent || telefono != null) {
      map['telefono'] = Variable<String>(telefono);
    }
    map['visitas_totales'] = Variable<int>(visitasTotales);
    map['puntos_lealtad'] = Variable<int>(puntosLealtad);
    map['fecha_registro'] = Variable<int>(fechaRegistro);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  ClientesTableCompanion toCompanion(bool nullToAbsent) {
    return ClientesTableCompanion(
      id: Value(id),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
      nombre: Value(nombre),
      telefono: telefono == null && nullToAbsent
          ? const Value.absent()
          : Value(telefono),
      visitasTotales: Value(visitasTotales),
      puntosLealtad: Value(puntosLealtad),
      fechaRegistro: Value(fechaRegistro),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ClientesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ClientesTableData(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String?>(json['userId']),
      nombre: serializer.fromJson<String>(json['nombre']),
      telefono: serializer.fromJson<String?>(json['telefono']),
      visitasTotales: serializer.fromJson<int>(json['visitasTotales']),
      puntosLealtad: serializer.fromJson<int>(json['puntosLealtad']),
      fechaRegistro: serializer.fromJson<int>(json['fechaRegistro']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String?>(userId),
      'nombre': serializer.toJson<String>(nombre),
      'telefono': serializer.toJson<String?>(telefono),
      'visitasTotales': serializer.toJson<int>(visitasTotales),
      'puntosLealtad': serializer.toJson<int>(puntosLealtad),
      'fechaRegistro': serializer.toJson<int>(fechaRegistro),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  ClientesTableData copyWith({
    String? id,
    Value<String?> userId = const Value.absent(),
    String? nombre,
    Value<String?> telefono = const Value.absent(),
    int? visitasTotales,
    int? puntosLealtad,
    int? fechaRegistro,
    int? createdAt,
    int? updatedAt,
  }) => ClientesTableData(
    id: id ?? this.id,
    userId: userId.present ? userId.value : this.userId,
    nombre: nombre ?? this.nombre,
    telefono: telefono.present ? telefono.value : this.telefono,
    visitasTotales: visitasTotales ?? this.visitasTotales,
    puntosLealtad: puntosLealtad ?? this.puntosLealtad,
    fechaRegistro: fechaRegistro ?? this.fechaRegistro,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ClientesTableData copyWithCompanion(ClientesTableCompanion data) {
    return ClientesTableData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      telefono: data.telefono.present ? data.telefono.value : this.telefono,
      visitasTotales: data.visitasTotales.present
          ? data.visitasTotales.value
          : this.visitasTotales,
      puntosLealtad: data.puntosLealtad.present
          ? data.puntosLealtad.value
          : this.puntosLealtad,
      fechaRegistro: data.fechaRegistro.present
          ? data.fechaRegistro.value
          : this.fechaRegistro,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClientesTableData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('nombre: $nombre, ')
          ..write('telefono: $telefono, ')
          ..write('visitasTotales: $visitasTotales, ')
          ..write('puntosLealtad: $puntosLealtad, ')
          ..write('fechaRegistro: $fechaRegistro, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    nombre,
    telefono,
    visitasTotales,
    puntosLealtad,
    fechaRegistro,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClientesTableData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.nombre == this.nombre &&
          other.telefono == this.telefono &&
          other.visitasTotales == this.visitasTotales &&
          other.puntosLealtad == this.puntosLealtad &&
          other.fechaRegistro == this.fechaRegistro &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ClientesTableCompanion extends UpdateCompanion<ClientesTableData> {
  final Value<String> id;
  final Value<String?> userId;
  final Value<String> nombre;
  final Value<String?> telefono;
  final Value<int> visitasTotales;
  final Value<int> puntosLealtad;
  final Value<int> fechaRegistro;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const ClientesTableCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.nombre = const Value.absent(),
    this.telefono = const Value.absent(),
    this.visitasTotales = const Value.absent(),
    this.puntosLealtad = const Value.absent(),
    this.fechaRegistro = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ClientesTableCompanion.insert({
    required String id,
    this.userId = const Value.absent(),
    required String nombre,
    this.telefono = const Value.absent(),
    this.visitasTotales = const Value.absent(),
    this.puntosLealtad = const Value.absent(),
    required int fechaRegistro,
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       nombre = Value(nombre),
       fechaRegistro = Value(fechaRegistro),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ClientesTableData> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? nombre,
    Expression<String>? telefono,
    Expression<int>? visitasTotales,
    Expression<int>? puntosLealtad,
    Expression<int>? fechaRegistro,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (nombre != null) 'nombre': nombre,
      if (telefono != null) 'telefono': telefono,
      if (visitasTotales != null) 'visitas_totales': visitasTotales,
      if (puntosLealtad != null) 'puntos_lealtad': puntosLealtad,
      if (fechaRegistro != null) 'fecha_registro': fechaRegistro,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ClientesTableCompanion copyWith({
    Value<String>? id,
    Value<String?>? userId,
    Value<String>? nombre,
    Value<String?>? telefono,
    Value<int>? visitasTotales,
    Value<int>? puntosLealtad,
    Value<int>? fechaRegistro,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return ClientesTableCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      nombre: nombre ?? this.nombre,
      telefono: telefono ?? this.telefono,
      visitasTotales: visitasTotales ?? this.visitasTotales,
      puntosLealtad: puntosLealtad ?? this.puntosLealtad,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
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
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (telefono.present) {
      map['telefono'] = Variable<String>(telefono.value);
    }
    if (visitasTotales.present) {
      map['visitas_totales'] = Variable<int>(visitasTotales.value);
    }
    if (puntosLealtad.present) {
      map['puntos_lealtad'] = Variable<int>(puntosLealtad.value);
    }
    if (fechaRegistro.present) {
      map['fecha_registro'] = Variable<int>(fechaRegistro.value);
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
    return (StringBuffer('ClientesTableCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('nombre: $nombre, ')
          ..write('telefono: $telefono, ')
          ..write('visitasTotales: $visitasTotales, ')
          ..write('puntosLealtad: $puntosLealtad, ')
          ..write('fechaRegistro: $fechaRegistro, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProductosTableTable extends ProductosTable
    with TableInfo<$ProductosTableTable, ProductosTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductosTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _precioCentavosMeta = const VerificationMeta(
    'precioCentavos',
  );
  @override
  late final GeneratedColumn<int> precioCentavos = GeneratedColumn<int>(
    'precio_centavos',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoriaMeta = const VerificationMeta(
    'categoria',
  );
  @override
  late final GeneratedColumn<String> categoria = GeneratedColumn<String>(
    'categoria',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _controlaInventarioMeta =
      const VerificationMeta('controlaInventario');
  @override
  late final GeneratedColumn<bool> controlaInventario = GeneratedColumn<bool>(
    'controla_inventario',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("controla_inventario" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _stockActualMeta = const VerificationMeta(
    'stockActual',
  );
  @override
  late final GeneratedColumn<int> stockActual = GeneratedColumn<int>(
    'stock_actual',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _stockMinimoMeta = const VerificationMeta(
    'stockMinimo',
  );
  @override
  late final GeneratedColumn<int> stockMinimo = GeneratedColumn<int>(
    'stock_minimo',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _activoMeta = const VerificationMeta('activo');
  @override
  late final GeneratedColumn<bool> activo = GeneratedColumn<bool>(
    'activo',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("activo" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
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
    nombre,
    precioCentavos,
    categoria,
    controlaInventario,
    stockActual,
    stockMinimo,
    activo,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'productos_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProductosTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('precio_centavos')) {
      context.handle(
        _precioCentavosMeta,
        precioCentavos.isAcceptableOrUnknown(
          data['precio_centavos']!,
          _precioCentavosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_precioCentavosMeta);
    }
    if (data.containsKey('categoria')) {
      context.handle(
        _categoriaMeta,
        categoria.isAcceptableOrUnknown(data['categoria']!, _categoriaMeta),
      );
    } else if (isInserting) {
      context.missing(_categoriaMeta);
    }
    if (data.containsKey('controla_inventario')) {
      context.handle(
        _controlaInventarioMeta,
        controlaInventario.isAcceptableOrUnknown(
          data['controla_inventario']!,
          _controlaInventarioMeta,
        ),
      );
    }
    if (data.containsKey('stock_actual')) {
      context.handle(
        _stockActualMeta,
        stockActual.isAcceptableOrUnknown(
          data['stock_actual']!,
          _stockActualMeta,
        ),
      );
    }
    if (data.containsKey('stock_minimo')) {
      context.handle(
        _stockMinimoMeta,
        stockMinimo.isAcceptableOrUnknown(
          data['stock_minimo']!,
          _stockMinimoMeta,
        ),
      );
    }
    if (data.containsKey('activo')) {
      context.handle(
        _activoMeta,
        activo.isAcceptableOrUnknown(data['activo']!, _activoMeta),
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
  ProductosTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductosTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      precioCentavos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}precio_centavos'],
      )!,
      categoria: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}categoria'],
      )!,
      controlaInventario: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}controla_inventario'],
      )!,
      stockActual: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stock_actual'],
      )!,
      stockMinimo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stock_minimo'],
      )!,
      activo: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}activo'],
      )!,
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
  $ProductosTableTable createAlias(String alias) {
    return $ProductosTableTable(attachedDatabase, alias);
  }
}

class ProductosTableData extends DataClass
    implements Insertable<ProductosTableData> {
  final String id;
  final String nombre;
  final int precioCentavos;
  final String categoria;
  final bool controlaInventario;
  final int stockActual;
  final int stockMinimo;
  final bool activo;
  final int createdAt;
  final int updatedAt;
  const ProductosTableData({
    required this.id,
    required this.nombre,
    required this.precioCentavos,
    required this.categoria,
    required this.controlaInventario,
    required this.stockActual,
    required this.stockMinimo,
    required this.activo,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['nombre'] = Variable<String>(nombre);
    map['precio_centavos'] = Variable<int>(precioCentavos);
    map['categoria'] = Variable<String>(categoria);
    map['controla_inventario'] = Variable<bool>(controlaInventario);
    map['stock_actual'] = Variable<int>(stockActual);
    map['stock_minimo'] = Variable<int>(stockMinimo);
    map['activo'] = Variable<bool>(activo);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  ProductosTableCompanion toCompanion(bool nullToAbsent) {
    return ProductosTableCompanion(
      id: Value(id),
      nombre: Value(nombre),
      precioCentavos: Value(precioCentavos),
      categoria: Value(categoria),
      controlaInventario: Value(controlaInventario),
      stockActual: Value(stockActual),
      stockMinimo: Value(stockMinimo),
      activo: Value(activo),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ProductosTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductosTableData(
      id: serializer.fromJson<String>(json['id']),
      nombre: serializer.fromJson<String>(json['nombre']),
      precioCentavos: serializer.fromJson<int>(json['precioCentavos']),
      categoria: serializer.fromJson<String>(json['categoria']),
      controlaInventario: serializer.fromJson<bool>(json['controlaInventario']),
      stockActual: serializer.fromJson<int>(json['stockActual']),
      stockMinimo: serializer.fromJson<int>(json['stockMinimo']),
      activo: serializer.fromJson<bool>(json['activo']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'nombre': serializer.toJson<String>(nombre),
      'precioCentavos': serializer.toJson<int>(precioCentavos),
      'categoria': serializer.toJson<String>(categoria),
      'controlaInventario': serializer.toJson<bool>(controlaInventario),
      'stockActual': serializer.toJson<int>(stockActual),
      'stockMinimo': serializer.toJson<int>(stockMinimo),
      'activo': serializer.toJson<bool>(activo),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  ProductosTableData copyWith({
    String? id,
    String? nombre,
    int? precioCentavos,
    String? categoria,
    bool? controlaInventario,
    int? stockActual,
    int? stockMinimo,
    bool? activo,
    int? createdAt,
    int? updatedAt,
  }) => ProductosTableData(
    id: id ?? this.id,
    nombre: nombre ?? this.nombre,
    precioCentavos: precioCentavos ?? this.precioCentavos,
    categoria: categoria ?? this.categoria,
    controlaInventario: controlaInventario ?? this.controlaInventario,
    stockActual: stockActual ?? this.stockActual,
    stockMinimo: stockMinimo ?? this.stockMinimo,
    activo: activo ?? this.activo,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ProductosTableData copyWithCompanion(ProductosTableCompanion data) {
    return ProductosTableData(
      id: data.id.present ? data.id.value : this.id,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      precioCentavos: data.precioCentavos.present
          ? data.precioCentavos.value
          : this.precioCentavos,
      categoria: data.categoria.present ? data.categoria.value : this.categoria,
      controlaInventario: data.controlaInventario.present
          ? data.controlaInventario.value
          : this.controlaInventario,
      stockActual: data.stockActual.present
          ? data.stockActual.value
          : this.stockActual,
      stockMinimo: data.stockMinimo.present
          ? data.stockMinimo.value
          : this.stockMinimo,
      activo: data.activo.present ? data.activo.value : this.activo,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductosTableData(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('precioCentavos: $precioCentavos, ')
          ..write('categoria: $categoria, ')
          ..write('controlaInventario: $controlaInventario, ')
          ..write('stockActual: $stockActual, ')
          ..write('stockMinimo: $stockMinimo, ')
          ..write('activo: $activo, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    nombre,
    precioCentavos,
    categoria,
    controlaInventario,
    stockActual,
    stockMinimo,
    activo,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductosTableData &&
          other.id == this.id &&
          other.nombre == this.nombre &&
          other.precioCentavos == this.precioCentavos &&
          other.categoria == this.categoria &&
          other.controlaInventario == this.controlaInventario &&
          other.stockActual == this.stockActual &&
          other.stockMinimo == this.stockMinimo &&
          other.activo == this.activo &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ProductosTableCompanion extends UpdateCompanion<ProductosTableData> {
  final Value<String> id;
  final Value<String> nombre;
  final Value<int> precioCentavos;
  final Value<String> categoria;
  final Value<bool> controlaInventario;
  final Value<int> stockActual;
  final Value<int> stockMinimo;
  final Value<bool> activo;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const ProductosTableCompanion({
    this.id = const Value.absent(),
    this.nombre = const Value.absent(),
    this.precioCentavos = const Value.absent(),
    this.categoria = const Value.absent(),
    this.controlaInventario = const Value.absent(),
    this.stockActual = const Value.absent(),
    this.stockMinimo = const Value.absent(),
    this.activo = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductosTableCompanion.insert({
    required String id,
    required String nombre,
    required int precioCentavos,
    required String categoria,
    this.controlaInventario = const Value.absent(),
    this.stockActual = const Value.absent(),
    this.stockMinimo = const Value.absent(),
    this.activo = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       nombre = Value(nombre),
       precioCentavos = Value(precioCentavos),
       categoria = Value(categoria),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ProductosTableData> custom({
    Expression<String>? id,
    Expression<String>? nombre,
    Expression<int>? precioCentavos,
    Expression<String>? categoria,
    Expression<bool>? controlaInventario,
    Expression<int>? stockActual,
    Expression<int>? stockMinimo,
    Expression<bool>? activo,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nombre != null) 'nombre': nombre,
      if (precioCentavos != null) 'precio_centavos': precioCentavos,
      if (categoria != null) 'categoria': categoria,
      if (controlaInventario != null) 'controla_inventario': controlaInventario,
      if (stockActual != null) 'stock_actual': stockActual,
      if (stockMinimo != null) 'stock_minimo': stockMinimo,
      if (activo != null) 'activo': activo,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductosTableCompanion copyWith({
    Value<String>? id,
    Value<String>? nombre,
    Value<int>? precioCentavos,
    Value<String>? categoria,
    Value<bool>? controlaInventario,
    Value<int>? stockActual,
    Value<int>? stockMinimo,
    Value<bool>? activo,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return ProductosTableCompanion(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      precioCentavos: precioCentavos ?? this.precioCentavos,
      categoria: categoria ?? this.categoria,
      controlaInventario: controlaInventario ?? this.controlaInventario,
      stockActual: stockActual ?? this.stockActual,
      stockMinimo: stockMinimo ?? this.stockMinimo,
      activo: activo ?? this.activo,
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
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (precioCentavos.present) {
      map['precio_centavos'] = Variable<int>(precioCentavos.value);
    }
    if (categoria.present) {
      map['categoria'] = Variable<String>(categoria.value);
    }
    if (controlaInventario.present) {
      map['controla_inventario'] = Variable<bool>(controlaInventario.value);
    }
    if (stockActual.present) {
      map['stock_actual'] = Variable<int>(stockActual.value);
    }
    if (stockMinimo.present) {
      map['stock_minimo'] = Variable<int>(stockMinimo.value);
    }
    if (activo.present) {
      map['activo'] = Variable<bool>(activo.value);
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
    return (StringBuffer('ProductosTableCompanion(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('precioCentavos: $precioCentavos, ')
          ..write('categoria: $categoria, ')
          ..write('controlaInventario: $controlaInventario, ')
          ..write('stockActual: $stockActual, ')
          ..write('stockMinimo: $stockMinimo, ')
          ..write('activo: $activo, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OrdenesTableTable extends OrdenesTable
    with TableInfo<$OrdenesTableTable, OrdenesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrdenesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mesaIdMeta = const VerificationMeta('mesaId');
  @override
  late final GeneratedColumn<String> mesaId = GeneratedColumn<String>(
    'mesa_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _clienteIdMeta = const VerificationMeta(
    'clienteId',
  );
  @override
  late final GeneratedColumn<String> clienteId = GeneratedColumn<String>(
    'cliente_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tipoServicioMeta = const VerificationMeta(
    'tipoServicio',
  );
  @override
  late final GeneratedColumn<String> tipoServicio = GeneratedColumn<String>(
    'tipo_servicio',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _estadoMeta = const VerificationMeta('estado');
  @override
  late final GeneratedColumn<String> estado = GeneratedColumn<String>(
    'estado',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Abierta'),
  );
  static const VerificationMeta _fechaAperturaMeta = const VerificationMeta(
    'fechaApertura',
  );
  @override
  late final GeneratedColumn<int> fechaApertura = GeneratedColumn<int>(
    'fecha_apertura',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fechaCierreMeta = const VerificationMeta(
    'fechaCierre',
  );
  @override
  late final GeneratedColumn<int> fechaCierre = GeneratedColumn<int>(
    'fecha_cierre',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notasMeta = const VerificationMeta('notas');
  @override
  late final GeneratedColumn<String> notas = GeneratedColumn<String>(
    'notas',
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
    mesaId,
    clienteId,
    tipoServicio,
    estado,
    fechaApertura,
    fechaCierre,
    notas,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ordenes_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<OrdenesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('mesa_id')) {
      context.handle(
        _mesaIdMeta,
        mesaId.isAcceptableOrUnknown(data['mesa_id']!, _mesaIdMeta),
      );
    }
    if (data.containsKey('cliente_id')) {
      context.handle(
        _clienteIdMeta,
        clienteId.isAcceptableOrUnknown(data['cliente_id']!, _clienteIdMeta),
      );
    }
    if (data.containsKey('tipo_servicio')) {
      context.handle(
        _tipoServicioMeta,
        tipoServicio.isAcceptableOrUnknown(
          data['tipo_servicio']!,
          _tipoServicioMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_tipoServicioMeta);
    }
    if (data.containsKey('estado')) {
      context.handle(
        _estadoMeta,
        estado.isAcceptableOrUnknown(data['estado']!, _estadoMeta),
      );
    }
    if (data.containsKey('fecha_apertura')) {
      context.handle(
        _fechaAperturaMeta,
        fechaApertura.isAcceptableOrUnknown(
          data['fecha_apertura']!,
          _fechaAperturaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fechaAperturaMeta);
    }
    if (data.containsKey('fecha_cierre')) {
      context.handle(
        _fechaCierreMeta,
        fechaCierre.isAcceptableOrUnknown(
          data['fecha_cierre']!,
          _fechaCierreMeta,
        ),
      );
    }
    if (data.containsKey('notas')) {
      context.handle(
        _notasMeta,
        notas.isAcceptableOrUnknown(data['notas']!, _notasMeta),
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
  OrdenesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OrdenesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      mesaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mesa_id'],
      ),
      clienteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cliente_id'],
      ),
      tipoServicio: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo_servicio'],
      )!,
      estado: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estado'],
      )!,
      fechaApertura: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fecha_apertura'],
      )!,
      fechaCierre: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fecha_cierre'],
      ),
      notas: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notas'],
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
  $OrdenesTableTable createAlias(String alias) {
    return $OrdenesTableTable(attachedDatabase, alias);
  }
}

class OrdenesTableData extends DataClass
    implements Insertable<OrdenesTableData> {
  final String id;
  final String? mesaId;
  final String? clienteId;
  final String tipoServicio;
  final String estado;
  final int fechaApertura;
  final int? fechaCierre;
  final String? notas;
  final int createdAt;
  final int updatedAt;
  const OrdenesTableData({
    required this.id,
    this.mesaId,
    this.clienteId,
    required this.tipoServicio,
    required this.estado,
    required this.fechaApertura,
    this.fechaCierre,
    this.notas,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || mesaId != null) {
      map['mesa_id'] = Variable<String>(mesaId);
    }
    if (!nullToAbsent || clienteId != null) {
      map['cliente_id'] = Variable<String>(clienteId);
    }
    map['tipo_servicio'] = Variable<String>(tipoServicio);
    map['estado'] = Variable<String>(estado);
    map['fecha_apertura'] = Variable<int>(fechaApertura);
    if (!nullToAbsent || fechaCierre != null) {
      map['fecha_cierre'] = Variable<int>(fechaCierre);
    }
    if (!nullToAbsent || notas != null) {
      map['notas'] = Variable<String>(notas);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  OrdenesTableCompanion toCompanion(bool nullToAbsent) {
    return OrdenesTableCompanion(
      id: Value(id),
      mesaId: mesaId == null && nullToAbsent
          ? const Value.absent()
          : Value(mesaId),
      clienteId: clienteId == null && nullToAbsent
          ? const Value.absent()
          : Value(clienteId),
      tipoServicio: Value(tipoServicio),
      estado: Value(estado),
      fechaApertura: Value(fechaApertura),
      fechaCierre: fechaCierre == null && nullToAbsent
          ? const Value.absent()
          : Value(fechaCierre),
      notas: notas == null && nullToAbsent
          ? const Value.absent()
          : Value(notas),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory OrdenesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OrdenesTableData(
      id: serializer.fromJson<String>(json['id']),
      mesaId: serializer.fromJson<String?>(json['mesaId']),
      clienteId: serializer.fromJson<String?>(json['clienteId']),
      tipoServicio: serializer.fromJson<String>(json['tipoServicio']),
      estado: serializer.fromJson<String>(json['estado']),
      fechaApertura: serializer.fromJson<int>(json['fechaApertura']),
      fechaCierre: serializer.fromJson<int?>(json['fechaCierre']),
      notas: serializer.fromJson<String?>(json['notas']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'mesaId': serializer.toJson<String?>(mesaId),
      'clienteId': serializer.toJson<String?>(clienteId),
      'tipoServicio': serializer.toJson<String>(tipoServicio),
      'estado': serializer.toJson<String>(estado),
      'fechaApertura': serializer.toJson<int>(fechaApertura),
      'fechaCierre': serializer.toJson<int?>(fechaCierre),
      'notas': serializer.toJson<String?>(notas),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  OrdenesTableData copyWith({
    String? id,
    Value<String?> mesaId = const Value.absent(),
    Value<String?> clienteId = const Value.absent(),
    String? tipoServicio,
    String? estado,
    int? fechaApertura,
    Value<int?> fechaCierre = const Value.absent(),
    Value<String?> notas = const Value.absent(),
    int? createdAt,
    int? updatedAt,
  }) => OrdenesTableData(
    id: id ?? this.id,
    mesaId: mesaId.present ? mesaId.value : this.mesaId,
    clienteId: clienteId.present ? clienteId.value : this.clienteId,
    tipoServicio: tipoServicio ?? this.tipoServicio,
    estado: estado ?? this.estado,
    fechaApertura: fechaApertura ?? this.fechaApertura,
    fechaCierre: fechaCierre.present ? fechaCierre.value : this.fechaCierre,
    notas: notas.present ? notas.value : this.notas,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  OrdenesTableData copyWithCompanion(OrdenesTableCompanion data) {
    return OrdenesTableData(
      id: data.id.present ? data.id.value : this.id,
      mesaId: data.mesaId.present ? data.mesaId.value : this.mesaId,
      clienteId: data.clienteId.present ? data.clienteId.value : this.clienteId,
      tipoServicio: data.tipoServicio.present
          ? data.tipoServicio.value
          : this.tipoServicio,
      estado: data.estado.present ? data.estado.value : this.estado,
      fechaApertura: data.fechaApertura.present
          ? data.fechaApertura.value
          : this.fechaApertura,
      fechaCierre: data.fechaCierre.present
          ? data.fechaCierre.value
          : this.fechaCierre,
      notas: data.notas.present ? data.notas.value : this.notas,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OrdenesTableData(')
          ..write('id: $id, ')
          ..write('mesaId: $mesaId, ')
          ..write('clienteId: $clienteId, ')
          ..write('tipoServicio: $tipoServicio, ')
          ..write('estado: $estado, ')
          ..write('fechaApertura: $fechaApertura, ')
          ..write('fechaCierre: $fechaCierre, ')
          ..write('notas: $notas, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    mesaId,
    clienteId,
    tipoServicio,
    estado,
    fechaApertura,
    fechaCierre,
    notas,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OrdenesTableData &&
          other.id == this.id &&
          other.mesaId == this.mesaId &&
          other.clienteId == this.clienteId &&
          other.tipoServicio == this.tipoServicio &&
          other.estado == this.estado &&
          other.fechaApertura == this.fechaApertura &&
          other.fechaCierre == this.fechaCierre &&
          other.notas == this.notas &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class OrdenesTableCompanion extends UpdateCompanion<OrdenesTableData> {
  final Value<String> id;
  final Value<String?> mesaId;
  final Value<String?> clienteId;
  final Value<String> tipoServicio;
  final Value<String> estado;
  final Value<int> fechaApertura;
  final Value<int?> fechaCierre;
  final Value<String?> notas;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const OrdenesTableCompanion({
    this.id = const Value.absent(),
    this.mesaId = const Value.absent(),
    this.clienteId = const Value.absent(),
    this.tipoServicio = const Value.absent(),
    this.estado = const Value.absent(),
    this.fechaApertura = const Value.absent(),
    this.fechaCierre = const Value.absent(),
    this.notas = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OrdenesTableCompanion.insert({
    required String id,
    this.mesaId = const Value.absent(),
    this.clienteId = const Value.absent(),
    required String tipoServicio,
    this.estado = const Value.absent(),
    required int fechaApertura,
    this.fechaCierre = const Value.absent(),
    this.notas = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tipoServicio = Value(tipoServicio),
       fechaApertura = Value(fechaApertura),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<OrdenesTableData> custom({
    Expression<String>? id,
    Expression<String>? mesaId,
    Expression<String>? clienteId,
    Expression<String>? tipoServicio,
    Expression<String>? estado,
    Expression<int>? fechaApertura,
    Expression<int>? fechaCierre,
    Expression<String>? notas,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mesaId != null) 'mesa_id': mesaId,
      if (clienteId != null) 'cliente_id': clienteId,
      if (tipoServicio != null) 'tipo_servicio': tipoServicio,
      if (estado != null) 'estado': estado,
      if (fechaApertura != null) 'fecha_apertura': fechaApertura,
      if (fechaCierre != null) 'fecha_cierre': fechaCierre,
      if (notas != null) 'notas': notas,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OrdenesTableCompanion copyWith({
    Value<String>? id,
    Value<String?>? mesaId,
    Value<String?>? clienteId,
    Value<String>? tipoServicio,
    Value<String>? estado,
    Value<int>? fechaApertura,
    Value<int?>? fechaCierre,
    Value<String?>? notas,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return OrdenesTableCompanion(
      id: id ?? this.id,
      mesaId: mesaId ?? this.mesaId,
      clienteId: clienteId ?? this.clienteId,
      tipoServicio: tipoServicio ?? this.tipoServicio,
      estado: estado ?? this.estado,
      fechaApertura: fechaApertura ?? this.fechaApertura,
      fechaCierre: fechaCierre ?? this.fechaCierre,
      notas: notas ?? this.notas,
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
    if (mesaId.present) {
      map['mesa_id'] = Variable<String>(mesaId.value);
    }
    if (clienteId.present) {
      map['cliente_id'] = Variable<String>(clienteId.value);
    }
    if (tipoServicio.present) {
      map['tipo_servicio'] = Variable<String>(tipoServicio.value);
    }
    if (estado.present) {
      map['estado'] = Variable<String>(estado.value);
    }
    if (fechaApertura.present) {
      map['fecha_apertura'] = Variable<int>(fechaApertura.value);
    }
    if (fechaCierre.present) {
      map['fecha_cierre'] = Variable<int>(fechaCierre.value);
    }
    if (notas.present) {
      map['notas'] = Variable<String>(notas.value);
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
    return (StringBuffer('OrdenesTableCompanion(')
          ..write('id: $id, ')
          ..write('mesaId: $mesaId, ')
          ..write('clienteId: $clienteId, ')
          ..write('tipoServicio: $tipoServicio, ')
          ..write('estado: $estado, ')
          ..write('fechaApertura: $fechaApertura, ')
          ..write('fechaCierre: $fechaCierre, ')
          ..write('notas: $notas, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DetalleOrdenTableTable extends DetalleOrdenTable
    with TableInfo<$DetalleOrdenTableTable, DetalleOrdenTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DetalleOrdenTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ordenIdMeta = const VerificationMeta(
    'ordenId',
  );
  @override
  late final GeneratedColumn<String> ordenId = GeneratedColumn<String>(
    'orden_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productoIdMeta = const VerificationMeta(
    'productoId',
  );
  @override
  late final GeneratedColumn<String> productoId = GeneratedColumn<String>(
    'producto_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cantidadMeta = const VerificationMeta(
    'cantidad',
  );
  @override
  late final GeneratedColumn<int> cantidad = GeneratedColumn<int>(
    'cantidad',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _precioUnitarioCentavosMeta =
      const VerificationMeta('precioUnitarioCentavos');
  @override
  late final GeneratedColumn<int> precioUnitarioCentavos = GeneratedColumn<int>(
    'precio_unitario_centavos',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _estadoPagoMeta = const VerificationMeta(
    'estadoPago',
  );
  @override
  late final GeneratedColumn<String> estadoPago = GeneratedColumn<String>(
    'estado_pago',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Pendiente'),
  );
  static const VerificationMeta _notasMeta = const VerificationMeta('notas');
  @override
  late final GeneratedColumn<String> notas = GeneratedColumn<String>(
    'notas',
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
    ordenId,
    productoId,
    cantidad,
    precioUnitarioCentavos,
    estadoPago,
    notas,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'detalle_orden_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<DetalleOrdenTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('orden_id')) {
      context.handle(
        _ordenIdMeta,
        ordenId.isAcceptableOrUnknown(data['orden_id']!, _ordenIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ordenIdMeta);
    }
    if (data.containsKey('producto_id')) {
      context.handle(
        _productoIdMeta,
        productoId.isAcceptableOrUnknown(data['producto_id']!, _productoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productoIdMeta);
    }
    if (data.containsKey('cantidad')) {
      context.handle(
        _cantidadMeta,
        cantidad.isAcceptableOrUnknown(data['cantidad']!, _cantidadMeta),
      );
    } else if (isInserting) {
      context.missing(_cantidadMeta);
    }
    if (data.containsKey('precio_unitario_centavos')) {
      context.handle(
        _precioUnitarioCentavosMeta,
        precioUnitarioCentavos.isAcceptableOrUnknown(
          data['precio_unitario_centavos']!,
          _precioUnitarioCentavosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_precioUnitarioCentavosMeta);
    }
    if (data.containsKey('estado_pago')) {
      context.handle(
        _estadoPagoMeta,
        estadoPago.isAcceptableOrUnknown(data['estado_pago']!, _estadoPagoMeta),
      );
    }
    if (data.containsKey('notas')) {
      context.handle(
        _notasMeta,
        notas.isAcceptableOrUnknown(data['notas']!, _notasMeta),
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
  DetalleOrdenTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DetalleOrdenTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ordenId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}orden_id'],
      )!,
      productoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}producto_id'],
      )!,
      cantidad: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cantidad'],
      )!,
      precioUnitarioCentavos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}precio_unitario_centavos'],
      )!,
      estadoPago: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estado_pago'],
      )!,
      notas: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notas'],
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
  $DetalleOrdenTableTable createAlias(String alias) {
    return $DetalleOrdenTableTable(attachedDatabase, alias);
  }
}

class DetalleOrdenTableData extends DataClass
    implements Insertable<DetalleOrdenTableData> {
  final String id;
  final String ordenId;
  final String productoId;
  final int cantidad;
  final int precioUnitarioCentavos;
  final String estadoPago;
  final String? notas;
  final int createdAt;
  final int updatedAt;
  const DetalleOrdenTableData({
    required this.id,
    required this.ordenId,
    required this.productoId,
    required this.cantidad,
    required this.precioUnitarioCentavos,
    required this.estadoPago,
    this.notas,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['orden_id'] = Variable<String>(ordenId);
    map['producto_id'] = Variable<String>(productoId);
    map['cantidad'] = Variable<int>(cantidad);
    map['precio_unitario_centavos'] = Variable<int>(precioUnitarioCentavos);
    map['estado_pago'] = Variable<String>(estadoPago);
    if (!nullToAbsent || notas != null) {
      map['notas'] = Variable<String>(notas);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  DetalleOrdenTableCompanion toCompanion(bool nullToAbsent) {
    return DetalleOrdenTableCompanion(
      id: Value(id),
      ordenId: Value(ordenId),
      productoId: Value(productoId),
      cantidad: Value(cantidad),
      precioUnitarioCentavos: Value(precioUnitarioCentavos),
      estadoPago: Value(estadoPago),
      notas: notas == null && nullToAbsent
          ? const Value.absent()
          : Value(notas),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DetalleOrdenTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DetalleOrdenTableData(
      id: serializer.fromJson<String>(json['id']),
      ordenId: serializer.fromJson<String>(json['ordenId']),
      productoId: serializer.fromJson<String>(json['productoId']),
      cantidad: serializer.fromJson<int>(json['cantidad']),
      precioUnitarioCentavos: serializer.fromJson<int>(
        json['precioUnitarioCentavos'],
      ),
      estadoPago: serializer.fromJson<String>(json['estadoPago']),
      notas: serializer.fromJson<String?>(json['notas']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ordenId': serializer.toJson<String>(ordenId),
      'productoId': serializer.toJson<String>(productoId),
      'cantidad': serializer.toJson<int>(cantidad),
      'precioUnitarioCentavos': serializer.toJson<int>(precioUnitarioCentavos),
      'estadoPago': serializer.toJson<String>(estadoPago),
      'notas': serializer.toJson<String?>(notas),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  DetalleOrdenTableData copyWith({
    String? id,
    String? ordenId,
    String? productoId,
    int? cantidad,
    int? precioUnitarioCentavos,
    String? estadoPago,
    Value<String?> notas = const Value.absent(),
    int? createdAt,
    int? updatedAt,
  }) => DetalleOrdenTableData(
    id: id ?? this.id,
    ordenId: ordenId ?? this.ordenId,
    productoId: productoId ?? this.productoId,
    cantidad: cantidad ?? this.cantidad,
    precioUnitarioCentavos:
        precioUnitarioCentavos ?? this.precioUnitarioCentavos,
    estadoPago: estadoPago ?? this.estadoPago,
    notas: notas.present ? notas.value : this.notas,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DetalleOrdenTableData copyWithCompanion(DetalleOrdenTableCompanion data) {
    return DetalleOrdenTableData(
      id: data.id.present ? data.id.value : this.id,
      ordenId: data.ordenId.present ? data.ordenId.value : this.ordenId,
      productoId: data.productoId.present
          ? data.productoId.value
          : this.productoId,
      cantidad: data.cantidad.present ? data.cantidad.value : this.cantidad,
      precioUnitarioCentavos: data.precioUnitarioCentavos.present
          ? data.precioUnitarioCentavos.value
          : this.precioUnitarioCentavos,
      estadoPago: data.estadoPago.present
          ? data.estadoPago.value
          : this.estadoPago,
      notas: data.notas.present ? data.notas.value : this.notas,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DetalleOrdenTableData(')
          ..write('id: $id, ')
          ..write('ordenId: $ordenId, ')
          ..write('productoId: $productoId, ')
          ..write('cantidad: $cantidad, ')
          ..write('precioUnitarioCentavos: $precioUnitarioCentavos, ')
          ..write('estadoPago: $estadoPago, ')
          ..write('notas: $notas, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ordenId,
    productoId,
    cantidad,
    precioUnitarioCentavos,
    estadoPago,
    notas,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DetalleOrdenTableData &&
          other.id == this.id &&
          other.ordenId == this.ordenId &&
          other.productoId == this.productoId &&
          other.cantidad == this.cantidad &&
          other.precioUnitarioCentavos == this.precioUnitarioCentavos &&
          other.estadoPago == this.estadoPago &&
          other.notas == this.notas &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class DetalleOrdenTableCompanion
    extends UpdateCompanion<DetalleOrdenTableData> {
  final Value<String> id;
  final Value<String> ordenId;
  final Value<String> productoId;
  final Value<int> cantidad;
  final Value<int> precioUnitarioCentavos;
  final Value<String> estadoPago;
  final Value<String?> notas;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const DetalleOrdenTableCompanion({
    this.id = const Value.absent(),
    this.ordenId = const Value.absent(),
    this.productoId = const Value.absent(),
    this.cantidad = const Value.absent(),
    this.precioUnitarioCentavos = const Value.absent(),
    this.estadoPago = const Value.absent(),
    this.notas = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DetalleOrdenTableCompanion.insert({
    required String id,
    required String ordenId,
    required String productoId,
    required int cantidad,
    required int precioUnitarioCentavos,
    this.estadoPago = const Value.absent(),
    this.notas = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ordenId = Value(ordenId),
       productoId = Value(productoId),
       cantidad = Value(cantidad),
       precioUnitarioCentavos = Value(precioUnitarioCentavos),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<DetalleOrdenTableData> custom({
    Expression<String>? id,
    Expression<String>? ordenId,
    Expression<String>? productoId,
    Expression<int>? cantidad,
    Expression<int>? precioUnitarioCentavos,
    Expression<String>? estadoPago,
    Expression<String>? notas,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ordenId != null) 'orden_id': ordenId,
      if (productoId != null) 'producto_id': productoId,
      if (cantidad != null) 'cantidad': cantidad,
      if (precioUnitarioCentavos != null)
        'precio_unitario_centavos': precioUnitarioCentavos,
      if (estadoPago != null) 'estado_pago': estadoPago,
      if (notas != null) 'notas': notas,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DetalleOrdenTableCompanion copyWith({
    Value<String>? id,
    Value<String>? ordenId,
    Value<String>? productoId,
    Value<int>? cantidad,
    Value<int>? precioUnitarioCentavos,
    Value<String>? estadoPago,
    Value<String?>? notas,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return DetalleOrdenTableCompanion(
      id: id ?? this.id,
      ordenId: ordenId ?? this.ordenId,
      productoId: productoId ?? this.productoId,
      cantidad: cantidad ?? this.cantidad,
      precioUnitarioCentavos:
          precioUnitarioCentavos ?? this.precioUnitarioCentavos,
      estadoPago: estadoPago ?? this.estadoPago,
      notas: notas ?? this.notas,
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
    if (ordenId.present) {
      map['orden_id'] = Variable<String>(ordenId.value);
    }
    if (productoId.present) {
      map['producto_id'] = Variable<String>(productoId.value);
    }
    if (cantidad.present) {
      map['cantidad'] = Variable<int>(cantidad.value);
    }
    if (precioUnitarioCentavos.present) {
      map['precio_unitario_centavos'] = Variable<int>(
        precioUnitarioCentavos.value,
      );
    }
    if (estadoPago.present) {
      map['estado_pago'] = Variable<String>(estadoPago.value);
    }
    if (notas.present) {
      map['notas'] = Variable<String>(notas.value);
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
    return (StringBuffer('DetalleOrdenTableCompanion(')
          ..write('id: $id, ')
          ..write('ordenId: $ordenId, ')
          ..write('productoId: $productoId, ')
          ..write('cantidad: $cantidad, ')
          ..write('precioUnitarioCentavos: $precioUnitarioCentavos, ')
          ..write('estadoPago: $estadoPago, ')
          ..write('notas: $notas, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransaccionesTableTable extends TransaccionesTable
    with TableInfo<$TransaccionesTableTable, TransaccionesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransaccionesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ordenIdMeta = const VerificationMeta(
    'ordenId',
  );
  @override
  late final GeneratedColumn<String> ordenId = GeneratedColumn<String>(
    'orden_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _montoCentavosMeta = const VerificationMeta(
    'montoCentavos',
  );
  @override
  late final GeneratedColumn<int> montoCentavos = GeneratedColumn<int>(
    'monto_centavos',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _metodoPagoMeta = const VerificationMeta(
    'metodoPago',
  );
  @override
  late final GeneratedColumn<String> metodoPago = GeneratedColumn<String>(
    'metodo_pago',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<int> fecha = GeneratedColumn<int>(
    'fecha',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idempotencyKeyMeta = const VerificationMeta(
    'idempotencyKey',
  );
  @override
  late final GeneratedColumn<String> idempotencyKey = GeneratedColumn<String>(
    'idempotency_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
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
    ordenId,
    montoCentavos,
    metodoPago,
    fecha,
    idempotencyKey,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transacciones_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransaccionesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('orden_id')) {
      context.handle(
        _ordenIdMeta,
        ordenId.isAcceptableOrUnknown(data['orden_id']!, _ordenIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ordenIdMeta);
    }
    if (data.containsKey('monto_centavos')) {
      context.handle(
        _montoCentavosMeta,
        montoCentavos.isAcceptableOrUnknown(
          data['monto_centavos']!,
          _montoCentavosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_montoCentavosMeta);
    }
    if (data.containsKey('metodo_pago')) {
      context.handle(
        _metodoPagoMeta,
        metodoPago.isAcceptableOrUnknown(data['metodo_pago']!, _metodoPagoMeta),
      );
    } else if (isInserting) {
      context.missing(_metodoPagoMeta);
    }
    if (data.containsKey('fecha')) {
      context.handle(
        _fechaMeta,
        fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta),
      );
    } else if (isInserting) {
      context.missing(_fechaMeta);
    }
    if (data.containsKey('idempotency_key')) {
      context.handle(
        _idempotencyKeyMeta,
        idempotencyKey.isAcceptableOrUnknown(
          data['idempotency_key']!,
          _idempotencyKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_idempotencyKeyMeta);
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
  TransaccionesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransaccionesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ordenId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}orden_id'],
      )!,
      montoCentavos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}monto_centavos'],
      )!,
      metodoPago: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metodo_pago'],
      )!,
      fecha: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fecha'],
      )!,
      idempotencyKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}idempotency_key'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TransaccionesTableTable createAlias(String alias) {
    return $TransaccionesTableTable(attachedDatabase, alias);
  }
}

class TransaccionesTableData extends DataClass
    implements Insertable<TransaccionesTableData> {
  final String id;
  final String ordenId;
  final int montoCentavos;
  final String metodoPago;
  final int fecha;
  final String idempotencyKey;
  final int createdAt;
  const TransaccionesTableData({
    required this.id,
    required this.ordenId,
    required this.montoCentavos,
    required this.metodoPago,
    required this.fecha,
    required this.idempotencyKey,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['orden_id'] = Variable<String>(ordenId);
    map['monto_centavos'] = Variable<int>(montoCentavos);
    map['metodo_pago'] = Variable<String>(metodoPago);
    map['fecha'] = Variable<int>(fecha);
    map['idempotency_key'] = Variable<String>(idempotencyKey);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  TransaccionesTableCompanion toCompanion(bool nullToAbsent) {
    return TransaccionesTableCompanion(
      id: Value(id),
      ordenId: Value(ordenId),
      montoCentavos: Value(montoCentavos),
      metodoPago: Value(metodoPago),
      fecha: Value(fecha),
      idempotencyKey: Value(idempotencyKey),
      createdAt: Value(createdAt),
    );
  }

  factory TransaccionesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransaccionesTableData(
      id: serializer.fromJson<String>(json['id']),
      ordenId: serializer.fromJson<String>(json['ordenId']),
      montoCentavos: serializer.fromJson<int>(json['montoCentavos']),
      metodoPago: serializer.fromJson<String>(json['metodoPago']),
      fecha: serializer.fromJson<int>(json['fecha']),
      idempotencyKey: serializer.fromJson<String>(json['idempotencyKey']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ordenId': serializer.toJson<String>(ordenId),
      'montoCentavos': serializer.toJson<int>(montoCentavos),
      'metodoPago': serializer.toJson<String>(metodoPago),
      'fecha': serializer.toJson<int>(fecha),
      'idempotencyKey': serializer.toJson<String>(idempotencyKey),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  TransaccionesTableData copyWith({
    String? id,
    String? ordenId,
    int? montoCentavos,
    String? metodoPago,
    int? fecha,
    String? idempotencyKey,
    int? createdAt,
  }) => TransaccionesTableData(
    id: id ?? this.id,
    ordenId: ordenId ?? this.ordenId,
    montoCentavos: montoCentavos ?? this.montoCentavos,
    metodoPago: metodoPago ?? this.metodoPago,
    fecha: fecha ?? this.fecha,
    idempotencyKey: idempotencyKey ?? this.idempotencyKey,
    createdAt: createdAt ?? this.createdAt,
  );
  TransaccionesTableData copyWithCompanion(TransaccionesTableCompanion data) {
    return TransaccionesTableData(
      id: data.id.present ? data.id.value : this.id,
      ordenId: data.ordenId.present ? data.ordenId.value : this.ordenId,
      montoCentavos: data.montoCentavos.present
          ? data.montoCentavos.value
          : this.montoCentavos,
      metodoPago: data.metodoPago.present
          ? data.metodoPago.value
          : this.metodoPago,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      idempotencyKey: data.idempotencyKey.present
          ? data.idempotencyKey.value
          : this.idempotencyKey,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransaccionesTableData(')
          ..write('id: $id, ')
          ..write('ordenId: $ordenId, ')
          ..write('montoCentavos: $montoCentavos, ')
          ..write('metodoPago: $metodoPago, ')
          ..write('fecha: $fecha, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ordenId,
    montoCentavos,
    metodoPago,
    fecha,
    idempotencyKey,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransaccionesTableData &&
          other.id == this.id &&
          other.ordenId == this.ordenId &&
          other.montoCentavos == this.montoCentavos &&
          other.metodoPago == this.metodoPago &&
          other.fecha == this.fecha &&
          other.idempotencyKey == this.idempotencyKey &&
          other.createdAt == this.createdAt);
}

class TransaccionesTableCompanion
    extends UpdateCompanion<TransaccionesTableData> {
  final Value<String> id;
  final Value<String> ordenId;
  final Value<int> montoCentavos;
  final Value<String> metodoPago;
  final Value<int> fecha;
  final Value<String> idempotencyKey;
  final Value<int> createdAt;
  final Value<int> rowid;
  const TransaccionesTableCompanion({
    this.id = const Value.absent(),
    this.ordenId = const Value.absent(),
    this.montoCentavos = const Value.absent(),
    this.metodoPago = const Value.absent(),
    this.fecha = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransaccionesTableCompanion.insert({
    required String id,
    required String ordenId,
    required int montoCentavos,
    required String metodoPago,
    required int fecha,
    required String idempotencyKey,
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ordenId = Value(ordenId),
       montoCentavos = Value(montoCentavos),
       metodoPago = Value(metodoPago),
       fecha = Value(fecha),
       idempotencyKey = Value(idempotencyKey),
       createdAt = Value(createdAt);
  static Insertable<TransaccionesTableData> custom({
    Expression<String>? id,
    Expression<String>? ordenId,
    Expression<int>? montoCentavos,
    Expression<String>? metodoPago,
    Expression<int>? fecha,
    Expression<String>? idempotencyKey,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ordenId != null) 'orden_id': ordenId,
      if (montoCentavos != null) 'monto_centavos': montoCentavos,
      if (metodoPago != null) 'metodo_pago': metodoPago,
      if (fecha != null) 'fecha': fecha,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransaccionesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? ordenId,
    Value<int>? montoCentavos,
    Value<String>? metodoPago,
    Value<int>? fecha,
    Value<String>? idempotencyKey,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return TransaccionesTableCompanion(
      id: id ?? this.id,
      ordenId: ordenId ?? this.ordenId,
      montoCentavos: montoCentavos ?? this.montoCentavos,
      metodoPago: metodoPago ?? this.metodoPago,
      fecha: fecha ?? this.fecha,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
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
    if (ordenId.present) {
      map['orden_id'] = Variable<String>(ordenId.value);
    }
    if (montoCentavos.present) {
      map['monto_centavos'] = Variable<int>(montoCentavos.value);
    }
    if (metodoPago.present) {
      map['metodo_pago'] = Variable<String>(metodoPago.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<int>(fecha.value);
    }
    if (idempotencyKey.present) {
      map['idempotency_key'] = Variable<String>(idempotencyKey.value);
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
    return (StringBuffer('TransaccionesTableCompanion(')
          ..write('id: $id, ')
          ..write('ordenId: $ordenId, ')
          ..write('montoCentavos: $montoCentavos, ')
          ..write('metodoPago: $metodoPago, ')
          ..write('fecha: $fecha, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PagoDetallesTableTable extends PagoDetallesTable
    with TableInfo<$PagoDetallesTableTable, PagoDetallesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PagoDetallesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transaccionIdMeta = const VerificationMeta(
    'transaccionId',
  );
  @override
  late final GeneratedColumn<String> transaccionId = GeneratedColumn<String>(
    'transaccion_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _detalleOrdenIdMeta = const VerificationMeta(
    'detalleOrdenId',
  );
  @override
  late final GeneratedColumn<String> detalleOrdenId = GeneratedColumn<String>(
    'detalle_orden_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cantidadMeta = const VerificationMeta(
    'cantidad',
  );
  @override
  late final GeneratedColumn<int> cantidad = GeneratedColumn<int>(
    'cantidad',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _montoCentavosMeta = const VerificationMeta(
    'montoCentavos',
  );
  @override
  late final GeneratedColumn<int> montoCentavos = GeneratedColumn<int>(
    'monto_centavos',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
    transaccionId,
    detalleOrdenId,
    cantidad,
    montoCentavos,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pago_detalles_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<PagoDetallesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('transaccion_id')) {
      context.handle(
        _transaccionIdMeta,
        transaccionId.isAcceptableOrUnknown(
          data['transaccion_id']!,
          _transaccionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transaccionIdMeta);
    }
    if (data.containsKey('detalle_orden_id')) {
      context.handle(
        _detalleOrdenIdMeta,
        detalleOrdenId.isAcceptableOrUnknown(
          data['detalle_orden_id']!,
          _detalleOrdenIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_detalleOrdenIdMeta);
    }
    if (data.containsKey('cantidad')) {
      context.handle(
        _cantidadMeta,
        cantidad.isAcceptableOrUnknown(data['cantidad']!, _cantidadMeta),
      );
    } else if (isInserting) {
      context.missing(_cantidadMeta);
    }
    if (data.containsKey('monto_centavos')) {
      context.handle(
        _montoCentavosMeta,
        montoCentavos.isAcceptableOrUnknown(
          data['monto_centavos']!,
          _montoCentavosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_montoCentavosMeta);
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
  PagoDetallesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PagoDetallesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      transaccionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaccion_id'],
      )!,
      detalleOrdenId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}detalle_orden_id'],
      )!,
      cantidad: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cantidad'],
      )!,
      montoCentavos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}monto_centavos'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PagoDetallesTableTable createAlias(String alias) {
    return $PagoDetallesTableTable(attachedDatabase, alias);
  }
}

class PagoDetallesTableData extends DataClass
    implements Insertable<PagoDetallesTableData> {
  final String id;
  final String transaccionId;
  final String detalleOrdenId;
  final int cantidad;
  final int montoCentavos;
  final int createdAt;
  const PagoDetallesTableData({
    required this.id,
    required this.transaccionId,
    required this.detalleOrdenId,
    required this.cantidad,
    required this.montoCentavos,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['transaccion_id'] = Variable<String>(transaccionId);
    map['detalle_orden_id'] = Variable<String>(detalleOrdenId);
    map['cantidad'] = Variable<int>(cantidad);
    map['monto_centavos'] = Variable<int>(montoCentavos);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  PagoDetallesTableCompanion toCompanion(bool nullToAbsent) {
    return PagoDetallesTableCompanion(
      id: Value(id),
      transaccionId: Value(transaccionId),
      detalleOrdenId: Value(detalleOrdenId),
      cantidad: Value(cantidad),
      montoCentavos: Value(montoCentavos),
      createdAt: Value(createdAt),
    );
  }

  factory PagoDetallesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PagoDetallesTableData(
      id: serializer.fromJson<String>(json['id']),
      transaccionId: serializer.fromJson<String>(json['transaccionId']),
      detalleOrdenId: serializer.fromJson<String>(json['detalleOrdenId']),
      cantidad: serializer.fromJson<int>(json['cantidad']),
      montoCentavos: serializer.fromJson<int>(json['montoCentavos']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'transaccionId': serializer.toJson<String>(transaccionId),
      'detalleOrdenId': serializer.toJson<String>(detalleOrdenId),
      'cantidad': serializer.toJson<int>(cantidad),
      'montoCentavos': serializer.toJson<int>(montoCentavos),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  PagoDetallesTableData copyWith({
    String? id,
    String? transaccionId,
    String? detalleOrdenId,
    int? cantidad,
    int? montoCentavos,
    int? createdAt,
  }) => PagoDetallesTableData(
    id: id ?? this.id,
    transaccionId: transaccionId ?? this.transaccionId,
    detalleOrdenId: detalleOrdenId ?? this.detalleOrdenId,
    cantidad: cantidad ?? this.cantidad,
    montoCentavos: montoCentavos ?? this.montoCentavos,
    createdAt: createdAt ?? this.createdAt,
  );
  PagoDetallesTableData copyWithCompanion(PagoDetallesTableCompanion data) {
    return PagoDetallesTableData(
      id: data.id.present ? data.id.value : this.id,
      transaccionId: data.transaccionId.present
          ? data.transaccionId.value
          : this.transaccionId,
      detalleOrdenId: data.detalleOrdenId.present
          ? data.detalleOrdenId.value
          : this.detalleOrdenId,
      cantidad: data.cantidad.present ? data.cantidad.value : this.cantidad,
      montoCentavos: data.montoCentavos.present
          ? data.montoCentavos.value
          : this.montoCentavos,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PagoDetallesTableData(')
          ..write('id: $id, ')
          ..write('transaccionId: $transaccionId, ')
          ..write('detalleOrdenId: $detalleOrdenId, ')
          ..write('cantidad: $cantidad, ')
          ..write('montoCentavos: $montoCentavos, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    transaccionId,
    detalleOrdenId,
    cantidad,
    montoCentavos,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PagoDetallesTableData &&
          other.id == this.id &&
          other.transaccionId == this.transaccionId &&
          other.detalleOrdenId == this.detalleOrdenId &&
          other.cantidad == this.cantidad &&
          other.montoCentavos == this.montoCentavos &&
          other.createdAt == this.createdAt);
}

class PagoDetallesTableCompanion
    extends UpdateCompanion<PagoDetallesTableData> {
  final Value<String> id;
  final Value<String> transaccionId;
  final Value<String> detalleOrdenId;
  final Value<int> cantidad;
  final Value<int> montoCentavos;
  final Value<int> createdAt;
  final Value<int> rowid;
  const PagoDetallesTableCompanion({
    this.id = const Value.absent(),
    this.transaccionId = const Value.absent(),
    this.detalleOrdenId = const Value.absent(),
    this.cantidad = const Value.absent(),
    this.montoCentavos = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PagoDetallesTableCompanion.insert({
    required String id,
    required String transaccionId,
    required String detalleOrdenId,
    required int cantidad,
    required int montoCentavos,
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       transaccionId = Value(transaccionId),
       detalleOrdenId = Value(detalleOrdenId),
       cantidad = Value(cantidad),
       montoCentavos = Value(montoCentavos),
       createdAt = Value(createdAt);
  static Insertable<PagoDetallesTableData> custom({
    Expression<String>? id,
    Expression<String>? transaccionId,
    Expression<String>? detalleOrdenId,
    Expression<int>? cantidad,
    Expression<int>? montoCentavos,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (transaccionId != null) 'transaccion_id': transaccionId,
      if (detalleOrdenId != null) 'detalle_orden_id': detalleOrdenId,
      if (cantidad != null) 'cantidad': cantidad,
      if (montoCentavos != null) 'monto_centavos': montoCentavos,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PagoDetallesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? transaccionId,
    Value<String>? detalleOrdenId,
    Value<int>? cantidad,
    Value<int>? montoCentavos,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return PagoDetallesTableCompanion(
      id: id ?? this.id,
      transaccionId: transaccionId ?? this.transaccionId,
      detalleOrdenId: detalleOrdenId ?? this.detalleOrdenId,
      cantidad: cantidad ?? this.cantidad,
      montoCentavos: montoCentavos ?? this.montoCentavos,
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
    if (transaccionId.present) {
      map['transaccion_id'] = Variable<String>(transaccionId.value);
    }
    if (detalleOrdenId.present) {
      map['detalle_orden_id'] = Variable<String>(detalleOrdenId.value);
    }
    if (cantidad.present) {
      map['cantidad'] = Variable<int>(cantidad.value);
    }
    if (montoCentavos.present) {
      map['monto_centavos'] = Variable<int>(montoCentavos.value);
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
    return (StringBuffer('PagoDetallesTableCompanion(')
          ..write('id: $id, ')
          ..write('transaccionId: $transaccionId, ')
          ..write('detalleOrdenId: $detalleOrdenId, ')
          ..write('cantidad: $cantidad, ')
          ..write('montoCentavos: $montoCentavos, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MovimientosInventarioTableTable extends MovimientosInventarioTable
    with
        TableInfo<
          $MovimientosInventarioTableTable,
          MovimientosInventarioTableData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MovimientosInventarioTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productoIdMeta = const VerificationMeta(
    'productoId',
  );
  @override
  late final GeneratedColumn<String> productoId = GeneratedColumn<String>(
    'producto_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cantidadMeta = const VerificationMeta(
    'cantidad',
  );
  @override
  late final GeneratedColumn<int> cantidad = GeneratedColumn<int>(
    'cantidad',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  @override
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>(
    'tipo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _referenciaIdMeta = const VerificationMeta(
    'referenciaId',
  );
  @override
  late final GeneratedColumn<String> referenciaId = GeneratedColumn<String>(
    'referencia_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notasMeta = const VerificationMeta('notas');
  @override
  late final GeneratedColumn<String> notas = GeneratedColumn<String>(
    'notas',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _creadoPorMeta = const VerificationMeta(
    'creadoPor',
  );
  @override
  late final GeneratedColumn<String> creadoPor = GeneratedColumn<String>(
    'creado_por',
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
  static const VerificationMeta _idempotencyKeyMeta = const VerificationMeta(
    'idempotencyKey',
  );
  @override
  late final GeneratedColumn<String> idempotencyKey = GeneratedColumn<String>(
    'idempotency_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    productoId,
    cantidad,
    tipo,
    referenciaId,
    notas,
    creadoPor,
    createdAt,
    idempotencyKey,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'movimientos_inventario_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<MovimientosInventarioTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('producto_id')) {
      context.handle(
        _productoIdMeta,
        productoId.isAcceptableOrUnknown(data['producto_id']!, _productoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productoIdMeta);
    }
    if (data.containsKey('cantidad')) {
      context.handle(
        _cantidadMeta,
        cantidad.isAcceptableOrUnknown(data['cantidad']!, _cantidadMeta),
      );
    } else if (isInserting) {
      context.missing(_cantidadMeta);
    }
    if (data.containsKey('tipo')) {
      context.handle(
        _tipoMeta,
        tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta),
      );
    } else if (isInserting) {
      context.missing(_tipoMeta);
    }
    if (data.containsKey('referencia_id')) {
      context.handle(
        _referenciaIdMeta,
        referenciaId.isAcceptableOrUnknown(
          data['referencia_id']!,
          _referenciaIdMeta,
        ),
      );
    }
    if (data.containsKey('notas')) {
      context.handle(
        _notasMeta,
        notas.isAcceptableOrUnknown(data['notas']!, _notasMeta),
      );
    }
    if (data.containsKey('creado_por')) {
      context.handle(
        _creadoPorMeta,
        creadoPor.isAcceptableOrUnknown(data['creado_por']!, _creadoPorMeta),
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
    if (data.containsKey('idempotency_key')) {
      context.handle(
        _idempotencyKeyMeta,
        idempotencyKey.isAcceptableOrUnknown(
          data['idempotency_key']!,
          _idempotencyKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_idempotencyKeyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MovimientosInventarioTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MovimientosInventarioTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      productoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}producto_id'],
      )!,
      cantidad: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cantidad'],
      )!,
      tipo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo'],
      )!,
      referenciaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}referencia_id'],
      ),
      notas: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notas'],
      ),
      creadoPor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}creado_por'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      idempotencyKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}idempotency_key'],
      )!,
    );
  }

  @override
  $MovimientosInventarioTableTable createAlias(String alias) {
    return $MovimientosInventarioTableTable(attachedDatabase, alias);
  }
}

class MovimientosInventarioTableData extends DataClass
    implements Insertable<MovimientosInventarioTableData> {
  final String id;
  final String productoId;
  final int cantidad;
  final String tipo;
  final String? referenciaId;
  final String? notas;
  final String? creadoPor;
  final int createdAt;
  final String idempotencyKey;
  const MovimientosInventarioTableData({
    required this.id,
    required this.productoId,
    required this.cantidad,
    required this.tipo,
    this.referenciaId,
    this.notas,
    this.creadoPor,
    required this.createdAt,
    required this.idempotencyKey,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['producto_id'] = Variable<String>(productoId);
    map['cantidad'] = Variable<int>(cantidad);
    map['tipo'] = Variable<String>(tipo);
    if (!nullToAbsent || referenciaId != null) {
      map['referencia_id'] = Variable<String>(referenciaId);
    }
    if (!nullToAbsent || notas != null) {
      map['notas'] = Variable<String>(notas);
    }
    if (!nullToAbsent || creadoPor != null) {
      map['creado_por'] = Variable<String>(creadoPor);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['idempotency_key'] = Variable<String>(idempotencyKey);
    return map;
  }

  MovimientosInventarioTableCompanion toCompanion(bool nullToAbsent) {
    return MovimientosInventarioTableCompanion(
      id: Value(id),
      productoId: Value(productoId),
      cantidad: Value(cantidad),
      tipo: Value(tipo),
      referenciaId: referenciaId == null && nullToAbsent
          ? const Value.absent()
          : Value(referenciaId),
      notas: notas == null && nullToAbsent
          ? const Value.absent()
          : Value(notas),
      creadoPor: creadoPor == null && nullToAbsent
          ? const Value.absent()
          : Value(creadoPor),
      createdAt: Value(createdAt),
      idempotencyKey: Value(idempotencyKey),
    );
  }

  factory MovimientosInventarioTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MovimientosInventarioTableData(
      id: serializer.fromJson<String>(json['id']),
      productoId: serializer.fromJson<String>(json['productoId']),
      cantidad: serializer.fromJson<int>(json['cantidad']),
      tipo: serializer.fromJson<String>(json['tipo']),
      referenciaId: serializer.fromJson<String?>(json['referenciaId']),
      notas: serializer.fromJson<String?>(json['notas']),
      creadoPor: serializer.fromJson<String?>(json['creadoPor']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      idempotencyKey: serializer.fromJson<String>(json['idempotencyKey']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'productoId': serializer.toJson<String>(productoId),
      'cantidad': serializer.toJson<int>(cantidad),
      'tipo': serializer.toJson<String>(tipo),
      'referenciaId': serializer.toJson<String?>(referenciaId),
      'notas': serializer.toJson<String?>(notas),
      'creadoPor': serializer.toJson<String?>(creadoPor),
      'createdAt': serializer.toJson<int>(createdAt),
      'idempotencyKey': serializer.toJson<String>(idempotencyKey),
    };
  }

  MovimientosInventarioTableData copyWith({
    String? id,
    String? productoId,
    int? cantidad,
    String? tipo,
    Value<String?> referenciaId = const Value.absent(),
    Value<String?> notas = const Value.absent(),
    Value<String?> creadoPor = const Value.absent(),
    int? createdAt,
    String? idempotencyKey,
  }) => MovimientosInventarioTableData(
    id: id ?? this.id,
    productoId: productoId ?? this.productoId,
    cantidad: cantidad ?? this.cantidad,
    tipo: tipo ?? this.tipo,
    referenciaId: referenciaId.present ? referenciaId.value : this.referenciaId,
    notas: notas.present ? notas.value : this.notas,
    creadoPor: creadoPor.present ? creadoPor.value : this.creadoPor,
    createdAt: createdAt ?? this.createdAt,
    idempotencyKey: idempotencyKey ?? this.idempotencyKey,
  );
  MovimientosInventarioTableData copyWithCompanion(
    MovimientosInventarioTableCompanion data,
  ) {
    return MovimientosInventarioTableData(
      id: data.id.present ? data.id.value : this.id,
      productoId: data.productoId.present
          ? data.productoId.value
          : this.productoId,
      cantidad: data.cantidad.present ? data.cantidad.value : this.cantidad,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      referenciaId: data.referenciaId.present
          ? data.referenciaId.value
          : this.referenciaId,
      notas: data.notas.present ? data.notas.value : this.notas,
      creadoPor: data.creadoPor.present ? data.creadoPor.value : this.creadoPor,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      idempotencyKey: data.idempotencyKey.present
          ? data.idempotencyKey.value
          : this.idempotencyKey,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MovimientosInventarioTableData(')
          ..write('id: $id, ')
          ..write('productoId: $productoId, ')
          ..write('cantidad: $cantidad, ')
          ..write('tipo: $tipo, ')
          ..write('referenciaId: $referenciaId, ')
          ..write('notas: $notas, ')
          ..write('creadoPor: $creadoPor, ')
          ..write('createdAt: $createdAt, ')
          ..write('idempotencyKey: $idempotencyKey')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    productoId,
    cantidad,
    tipo,
    referenciaId,
    notas,
    creadoPor,
    createdAt,
    idempotencyKey,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MovimientosInventarioTableData &&
          other.id == this.id &&
          other.productoId == this.productoId &&
          other.cantidad == this.cantidad &&
          other.tipo == this.tipo &&
          other.referenciaId == this.referenciaId &&
          other.notas == this.notas &&
          other.creadoPor == this.creadoPor &&
          other.createdAt == this.createdAt &&
          other.idempotencyKey == this.idempotencyKey);
}

class MovimientosInventarioTableCompanion
    extends UpdateCompanion<MovimientosInventarioTableData> {
  final Value<String> id;
  final Value<String> productoId;
  final Value<int> cantidad;
  final Value<String> tipo;
  final Value<String?> referenciaId;
  final Value<String?> notas;
  final Value<String?> creadoPor;
  final Value<int> createdAt;
  final Value<String> idempotencyKey;
  final Value<int> rowid;
  const MovimientosInventarioTableCompanion({
    this.id = const Value.absent(),
    this.productoId = const Value.absent(),
    this.cantidad = const Value.absent(),
    this.tipo = const Value.absent(),
    this.referenciaId = const Value.absent(),
    this.notas = const Value.absent(),
    this.creadoPor = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MovimientosInventarioTableCompanion.insert({
    required String id,
    required String productoId,
    required int cantidad,
    required String tipo,
    this.referenciaId = const Value.absent(),
    this.notas = const Value.absent(),
    this.creadoPor = const Value.absent(),
    required int createdAt,
    required String idempotencyKey,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       productoId = Value(productoId),
       cantidad = Value(cantidad),
       tipo = Value(tipo),
       createdAt = Value(createdAt),
       idempotencyKey = Value(idempotencyKey);
  static Insertable<MovimientosInventarioTableData> custom({
    Expression<String>? id,
    Expression<String>? productoId,
    Expression<int>? cantidad,
    Expression<String>? tipo,
    Expression<String>? referenciaId,
    Expression<String>? notas,
    Expression<String>? creadoPor,
    Expression<int>? createdAt,
    Expression<String>? idempotencyKey,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (productoId != null) 'producto_id': productoId,
      if (cantidad != null) 'cantidad': cantidad,
      if (tipo != null) 'tipo': tipo,
      if (referenciaId != null) 'referencia_id': referenciaId,
      if (notas != null) 'notas': notas,
      if (creadoPor != null) 'creado_por': creadoPor,
      if (createdAt != null) 'created_at': createdAt,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MovimientosInventarioTableCompanion copyWith({
    Value<String>? id,
    Value<String>? productoId,
    Value<int>? cantidad,
    Value<String>? tipo,
    Value<String?>? referenciaId,
    Value<String?>? notas,
    Value<String?>? creadoPor,
    Value<int>? createdAt,
    Value<String>? idempotencyKey,
    Value<int>? rowid,
  }) {
    return MovimientosInventarioTableCompanion(
      id: id ?? this.id,
      productoId: productoId ?? this.productoId,
      cantidad: cantidad ?? this.cantidad,
      tipo: tipo ?? this.tipo,
      referenciaId: referenciaId ?? this.referenciaId,
      notas: notas ?? this.notas,
      creadoPor: creadoPor ?? this.creadoPor,
      createdAt: createdAt ?? this.createdAt,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (productoId.present) {
      map['producto_id'] = Variable<String>(productoId.value);
    }
    if (cantidad.present) {
      map['cantidad'] = Variable<int>(cantidad.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(tipo.value);
    }
    if (referenciaId.present) {
      map['referencia_id'] = Variable<String>(referenciaId.value);
    }
    if (notas.present) {
      map['notas'] = Variable<String>(notas.value);
    }
    if (creadoPor.present) {
      map['creado_por'] = Variable<String>(creadoPor.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (idempotencyKey.present) {
      map['idempotency_key'] = Variable<String>(idempotencyKey.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MovimientosInventarioTableCompanion(')
          ..write('id: $id, ')
          ..write('productoId: $productoId, ')
          ..write('cantidad: $cantidad, ')
          ..write('tipo: $tipo, ')
          ..write('referenciaId: $referenciaId, ')
          ..write('notas: $notas, ')
          ..write('creadoPor: $creadoPor, ')
          ..write('createdAt: $createdAt, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VisitasClientesTableTable extends VisitasClientesTable
    with TableInfo<$VisitasClientesTableTable, VisitasClientesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VisitasClientesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clienteIdMeta = const VerificationMeta(
    'clienteId',
  );
  @override
  late final GeneratedColumn<String> clienteId = GeneratedColumn<String>(
    'cliente_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<String> fecha = GeneratedColumn<String>(
    'fecha',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _puntosOtorgadosMeta = const VerificationMeta(
    'puntosOtorgados',
  );
  @override
  late final GeneratedColumn<int> puntosOtorgados = GeneratedColumn<int>(
    'puntos_otorgados',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(10),
  );
  static const VerificationMeta _registradoPorMeta = const VerificationMeta(
    'registradoPor',
  );
  @override
  late final GeneratedColumn<String> registradoPor = GeneratedColumn<String>(
    'registrado_por',
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
    clienteId,
    fecha,
    puntosOtorgados,
    registradoPor,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'visitas_clientes_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<VisitasClientesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('cliente_id')) {
      context.handle(
        _clienteIdMeta,
        clienteId.isAcceptableOrUnknown(data['cliente_id']!, _clienteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clienteIdMeta);
    }
    if (data.containsKey('fecha')) {
      context.handle(
        _fechaMeta,
        fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta),
      );
    } else if (isInserting) {
      context.missing(_fechaMeta);
    }
    if (data.containsKey('puntos_otorgados')) {
      context.handle(
        _puntosOtorgadosMeta,
        puntosOtorgados.isAcceptableOrUnknown(
          data['puntos_otorgados']!,
          _puntosOtorgadosMeta,
        ),
      );
    }
    if (data.containsKey('registrado_por')) {
      context.handle(
        _registradoPorMeta,
        registradoPor.isAcceptableOrUnknown(
          data['registrado_por']!,
          _registradoPorMeta,
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
  VisitasClientesTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VisitasClientesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      clienteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cliente_id'],
      )!,
      fecha: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fecha'],
      )!,
      puntosOtorgados: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}puntos_otorgados'],
      )!,
      registradoPor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}registrado_por'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $VisitasClientesTableTable createAlias(String alias) {
    return $VisitasClientesTableTable(attachedDatabase, alias);
  }
}

class VisitasClientesTableData extends DataClass
    implements Insertable<VisitasClientesTableData> {
  final String id;
  final String clienteId;
  final String fecha;
  final int puntosOtorgados;
  final String? registradoPor;
  final int createdAt;
  const VisitasClientesTableData({
    required this.id,
    required this.clienteId,
    required this.fecha,
    required this.puntosOtorgados,
    this.registradoPor,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['cliente_id'] = Variable<String>(clienteId);
    map['fecha'] = Variable<String>(fecha);
    map['puntos_otorgados'] = Variable<int>(puntosOtorgados);
    if (!nullToAbsent || registradoPor != null) {
      map['registrado_por'] = Variable<String>(registradoPor);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  VisitasClientesTableCompanion toCompanion(bool nullToAbsent) {
    return VisitasClientesTableCompanion(
      id: Value(id),
      clienteId: Value(clienteId),
      fecha: Value(fecha),
      puntosOtorgados: Value(puntosOtorgados),
      registradoPor: registradoPor == null && nullToAbsent
          ? const Value.absent()
          : Value(registradoPor),
      createdAt: Value(createdAt),
    );
  }

  factory VisitasClientesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VisitasClientesTableData(
      id: serializer.fromJson<String>(json['id']),
      clienteId: serializer.fromJson<String>(json['clienteId']),
      fecha: serializer.fromJson<String>(json['fecha']),
      puntosOtorgados: serializer.fromJson<int>(json['puntosOtorgados']),
      registradoPor: serializer.fromJson<String?>(json['registradoPor']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'clienteId': serializer.toJson<String>(clienteId),
      'fecha': serializer.toJson<String>(fecha),
      'puntosOtorgados': serializer.toJson<int>(puntosOtorgados),
      'registradoPor': serializer.toJson<String?>(registradoPor),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  VisitasClientesTableData copyWith({
    String? id,
    String? clienteId,
    String? fecha,
    int? puntosOtorgados,
    Value<String?> registradoPor = const Value.absent(),
    int? createdAt,
  }) => VisitasClientesTableData(
    id: id ?? this.id,
    clienteId: clienteId ?? this.clienteId,
    fecha: fecha ?? this.fecha,
    puntosOtorgados: puntosOtorgados ?? this.puntosOtorgados,
    registradoPor: registradoPor.present
        ? registradoPor.value
        : this.registradoPor,
    createdAt: createdAt ?? this.createdAt,
  );
  VisitasClientesTableData copyWithCompanion(
    VisitasClientesTableCompanion data,
  ) {
    return VisitasClientesTableData(
      id: data.id.present ? data.id.value : this.id,
      clienteId: data.clienteId.present ? data.clienteId.value : this.clienteId,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      puntosOtorgados: data.puntosOtorgados.present
          ? data.puntosOtorgados.value
          : this.puntosOtorgados,
      registradoPor: data.registradoPor.present
          ? data.registradoPor.value
          : this.registradoPor,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VisitasClientesTableData(')
          ..write('id: $id, ')
          ..write('clienteId: $clienteId, ')
          ..write('fecha: $fecha, ')
          ..write('puntosOtorgados: $puntosOtorgados, ')
          ..write('registradoPor: $registradoPor, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    clienteId,
    fecha,
    puntosOtorgados,
    registradoPor,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VisitasClientesTableData &&
          other.id == this.id &&
          other.clienteId == this.clienteId &&
          other.fecha == this.fecha &&
          other.puntosOtorgados == this.puntosOtorgados &&
          other.registradoPor == this.registradoPor &&
          other.createdAt == this.createdAt);
}

class VisitasClientesTableCompanion
    extends UpdateCompanion<VisitasClientesTableData> {
  final Value<String> id;
  final Value<String> clienteId;
  final Value<String> fecha;
  final Value<int> puntosOtorgados;
  final Value<String?> registradoPor;
  final Value<int> createdAt;
  final Value<int> rowid;
  const VisitasClientesTableCompanion({
    this.id = const Value.absent(),
    this.clienteId = const Value.absent(),
    this.fecha = const Value.absent(),
    this.puntosOtorgados = const Value.absent(),
    this.registradoPor = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VisitasClientesTableCompanion.insert({
    required String id,
    required String clienteId,
    required String fecha,
    this.puntosOtorgados = const Value.absent(),
    this.registradoPor = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       clienteId = Value(clienteId),
       fecha = Value(fecha),
       createdAt = Value(createdAt);
  static Insertable<VisitasClientesTableData> custom({
    Expression<String>? id,
    Expression<String>? clienteId,
    Expression<String>? fecha,
    Expression<int>? puntosOtorgados,
    Expression<String>? registradoPor,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (clienteId != null) 'cliente_id': clienteId,
      if (fecha != null) 'fecha': fecha,
      if (puntosOtorgados != null) 'puntos_otorgados': puntosOtorgados,
      if (registradoPor != null) 'registrado_por': registradoPor,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VisitasClientesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? clienteId,
    Value<String>? fecha,
    Value<int>? puntosOtorgados,
    Value<String?>? registradoPor,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return VisitasClientesTableCompanion(
      id: id ?? this.id,
      clienteId: clienteId ?? this.clienteId,
      fecha: fecha ?? this.fecha,
      puntosOtorgados: puntosOtorgados ?? this.puntosOtorgados,
      registradoPor: registradoPor ?? this.registradoPor,
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
    if (clienteId.present) {
      map['cliente_id'] = Variable<String>(clienteId.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<String>(fecha.value);
    }
    if (puntosOtorgados.present) {
      map['puntos_otorgados'] = Variable<int>(puntosOtorgados.value);
    }
    if (registradoPor.present) {
      map['registrado_por'] = Variable<String>(registradoPor.value);
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
    return (StringBuffer('VisitasClientesTableCompanion(')
          ..write('id: $id, ')
          ..write('clienteId: $clienteId, ')
          ..write('fecha: $fecha, ')
          ..write('puntosOtorgados: $puntosOtorgados, ')
          ..write('registradoPor: $registradoPor, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AuditoriaEventosTableTable extends AuditoriaEventosTable
    with TableInfo<$AuditoriaEventosTableTable, AuditoriaEventosTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AuditoriaEventosTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actorIdMeta = const VerificationMeta(
    'actorId',
  );
  @override
  late final GeneratedColumn<String> actorId = GeneratedColumn<String>(
    'actor_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _entidadMeta = const VerificationMeta(
    'entidad',
  );
  @override
  late final GeneratedColumn<String> entidad = GeneratedColumn<String>(
    'entidad',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entidadIdMeta = const VerificationMeta(
    'entidadId',
  );
  @override
  late final GeneratedColumn<String> entidadId = GeneratedColumn<String>(
    'entidad_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accionMeta = const VerificationMeta('accion');
  @override
  late final GeneratedColumn<String> accion = GeneratedColumn<String>(
    'accion',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _datosJsonMeta = const VerificationMeta(
    'datosJson',
  );
  @override
  late final GeneratedColumn<String> datosJson = GeneratedColumn<String>(
    'datos_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _dispositivoIdMeta = const VerificationMeta(
    'dispositivoId',
  );
  @override
  late final GeneratedColumn<String> dispositivoId = GeneratedColumn<String>(
    'dispositivo_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _offlineMeta = const VerificationMeta(
    'offline',
  );
  @override
  late final GeneratedColumn<bool> offline = GeneratedColumn<bool>(
    'offline',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("offline" IN (0, 1))',
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
    actorId,
    entidad,
    entidadId,
    accion,
    datosJson,
    dispositivoId,
    offline,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'auditoria_eventos_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<AuditoriaEventosTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('actor_id')) {
      context.handle(
        _actorIdMeta,
        actorId.isAcceptableOrUnknown(data['actor_id']!, _actorIdMeta),
      );
    }
    if (data.containsKey('entidad')) {
      context.handle(
        _entidadMeta,
        entidad.isAcceptableOrUnknown(data['entidad']!, _entidadMeta),
      );
    } else if (isInserting) {
      context.missing(_entidadMeta);
    }
    if (data.containsKey('entidad_id')) {
      context.handle(
        _entidadIdMeta,
        entidadId.isAcceptableOrUnknown(data['entidad_id']!, _entidadIdMeta),
      );
    }
    if (data.containsKey('accion')) {
      context.handle(
        _accionMeta,
        accion.isAcceptableOrUnknown(data['accion']!, _accionMeta),
      );
    } else if (isInserting) {
      context.missing(_accionMeta);
    }
    if (data.containsKey('datos_json')) {
      context.handle(
        _datosJsonMeta,
        datosJson.isAcceptableOrUnknown(data['datos_json']!, _datosJsonMeta),
      );
    }
    if (data.containsKey('dispositivo_id')) {
      context.handle(
        _dispositivoIdMeta,
        dispositivoId.isAcceptableOrUnknown(
          data['dispositivo_id']!,
          _dispositivoIdMeta,
        ),
      );
    }
    if (data.containsKey('offline')) {
      context.handle(
        _offlineMeta,
        offline.isAcceptableOrUnknown(data['offline']!, _offlineMeta),
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
  AuditoriaEventosTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AuditoriaEventosTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      actorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}actor_id'],
      ),
      entidad: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entidad'],
      )!,
      entidadId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entidad_id'],
      ),
      accion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}accion'],
      )!,
      datosJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}datos_json'],
      )!,
      dispositivoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dispositivo_id'],
      ),
      offline: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}offline'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AuditoriaEventosTableTable createAlias(String alias) {
    return $AuditoriaEventosTableTable(attachedDatabase, alias);
  }
}

class AuditoriaEventosTableData extends DataClass
    implements Insertable<AuditoriaEventosTableData> {
  final String id;
  final String? actorId;
  final String entidad;
  final String? entidadId;
  final String accion;
  final String datosJson;
  final String? dispositivoId;
  final bool offline;
  final int createdAt;
  const AuditoriaEventosTableData({
    required this.id,
    this.actorId,
    required this.entidad,
    this.entidadId,
    required this.accion,
    required this.datosJson,
    this.dispositivoId,
    required this.offline,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || actorId != null) {
      map['actor_id'] = Variable<String>(actorId);
    }
    map['entidad'] = Variable<String>(entidad);
    if (!nullToAbsent || entidadId != null) {
      map['entidad_id'] = Variable<String>(entidadId);
    }
    map['accion'] = Variable<String>(accion);
    map['datos_json'] = Variable<String>(datosJson);
    if (!nullToAbsent || dispositivoId != null) {
      map['dispositivo_id'] = Variable<String>(dispositivoId);
    }
    map['offline'] = Variable<bool>(offline);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  AuditoriaEventosTableCompanion toCompanion(bool nullToAbsent) {
    return AuditoriaEventosTableCompanion(
      id: Value(id),
      actorId: actorId == null && nullToAbsent
          ? const Value.absent()
          : Value(actorId),
      entidad: Value(entidad),
      entidadId: entidadId == null && nullToAbsent
          ? const Value.absent()
          : Value(entidadId),
      accion: Value(accion),
      datosJson: Value(datosJson),
      dispositivoId: dispositivoId == null && nullToAbsent
          ? const Value.absent()
          : Value(dispositivoId),
      offline: Value(offline),
      createdAt: Value(createdAt),
    );
  }

  factory AuditoriaEventosTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AuditoriaEventosTableData(
      id: serializer.fromJson<String>(json['id']),
      actorId: serializer.fromJson<String?>(json['actorId']),
      entidad: serializer.fromJson<String>(json['entidad']),
      entidadId: serializer.fromJson<String?>(json['entidadId']),
      accion: serializer.fromJson<String>(json['accion']),
      datosJson: serializer.fromJson<String>(json['datosJson']),
      dispositivoId: serializer.fromJson<String?>(json['dispositivoId']),
      offline: serializer.fromJson<bool>(json['offline']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'actorId': serializer.toJson<String?>(actorId),
      'entidad': serializer.toJson<String>(entidad),
      'entidadId': serializer.toJson<String?>(entidadId),
      'accion': serializer.toJson<String>(accion),
      'datosJson': serializer.toJson<String>(datosJson),
      'dispositivoId': serializer.toJson<String?>(dispositivoId),
      'offline': serializer.toJson<bool>(offline),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  AuditoriaEventosTableData copyWith({
    String? id,
    Value<String?> actorId = const Value.absent(),
    String? entidad,
    Value<String?> entidadId = const Value.absent(),
    String? accion,
    String? datosJson,
    Value<String?> dispositivoId = const Value.absent(),
    bool? offline,
    int? createdAt,
  }) => AuditoriaEventosTableData(
    id: id ?? this.id,
    actorId: actorId.present ? actorId.value : this.actorId,
    entidad: entidad ?? this.entidad,
    entidadId: entidadId.present ? entidadId.value : this.entidadId,
    accion: accion ?? this.accion,
    datosJson: datosJson ?? this.datosJson,
    dispositivoId: dispositivoId.present
        ? dispositivoId.value
        : this.dispositivoId,
    offline: offline ?? this.offline,
    createdAt: createdAt ?? this.createdAt,
  );
  AuditoriaEventosTableData copyWithCompanion(
    AuditoriaEventosTableCompanion data,
  ) {
    return AuditoriaEventosTableData(
      id: data.id.present ? data.id.value : this.id,
      actorId: data.actorId.present ? data.actorId.value : this.actorId,
      entidad: data.entidad.present ? data.entidad.value : this.entidad,
      entidadId: data.entidadId.present ? data.entidadId.value : this.entidadId,
      accion: data.accion.present ? data.accion.value : this.accion,
      datosJson: data.datosJson.present ? data.datosJson.value : this.datosJson,
      dispositivoId: data.dispositivoId.present
          ? data.dispositivoId.value
          : this.dispositivoId,
      offline: data.offline.present ? data.offline.value : this.offline,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AuditoriaEventosTableData(')
          ..write('id: $id, ')
          ..write('actorId: $actorId, ')
          ..write('entidad: $entidad, ')
          ..write('entidadId: $entidadId, ')
          ..write('accion: $accion, ')
          ..write('datosJson: $datosJson, ')
          ..write('dispositivoId: $dispositivoId, ')
          ..write('offline: $offline, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    actorId,
    entidad,
    entidadId,
    accion,
    datosJson,
    dispositivoId,
    offline,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuditoriaEventosTableData &&
          other.id == this.id &&
          other.actorId == this.actorId &&
          other.entidad == this.entidad &&
          other.entidadId == this.entidadId &&
          other.accion == this.accion &&
          other.datosJson == this.datosJson &&
          other.dispositivoId == this.dispositivoId &&
          other.offline == this.offline &&
          other.createdAt == this.createdAt);
}

class AuditoriaEventosTableCompanion
    extends UpdateCompanion<AuditoriaEventosTableData> {
  final Value<String> id;
  final Value<String?> actorId;
  final Value<String> entidad;
  final Value<String?> entidadId;
  final Value<String> accion;
  final Value<String> datosJson;
  final Value<String?> dispositivoId;
  final Value<bool> offline;
  final Value<int> createdAt;
  final Value<int> rowid;
  const AuditoriaEventosTableCompanion({
    this.id = const Value.absent(),
    this.actorId = const Value.absent(),
    this.entidad = const Value.absent(),
    this.entidadId = const Value.absent(),
    this.accion = const Value.absent(),
    this.datosJson = const Value.absent(),
    this.dispositivoId = const Value.absent(),
    this.offline = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AuditoriaEventosTableCompanion.insert({
    required String id,
    this.actorId = const Value.absent(),
    required String entidad,
    this.entidadId = const Value.absent(),
    required String accion,
    this.datosJson = const Value.absent(),
    this.dispositivoId = const Value.absent(),
    this.offline = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       entidad = Value(entidad),
       accion = Value(accion),
       createdAt = Value(createdAt);
  static Insertable<AuditoriaEventosTableData> custom({
    Expression<String>? id,
    Expression<String>? actorId,
    Expression<String>? entidad,
    Expression<String>? entidadId,
    Expression<String>? accion,
    Expression<String>? datosJson,
    Expression<String>? dispositivoId,
    Expression<bool>? offline,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (actorId != null) 'actor_id': actorId,
      if (entidad != null) 'entidad': entidad,
      if (entidadId != null) 'entidad_id': entidadId,
      if (accion != null) 'accion': accion,
      if (datosJson != null) 'datos_json': datosJson,
      if (dispositivoId != null) 'dispositivo_id': dispositivoId,
      if (offline != null) 'offline': offline,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AuditoriaEventosTableCompanion copyWith({
    Value<String>? id,
    Value<String?>? actorId,
    Value<String>? entidad,
    Value<String?>? entidadId,
    Value<String>? accion,
    Value<String>? datosJson,
    Value<String?>? dispositivoId,
    Value<bool>? offline,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return AuditoriaEventosTableCompanion(
      id: id ?? this.id,
      actorId: actorId ?? this.actorId,
      entidad: entidad ?? this.entidad,
      entidadId: entidadId ?? this.entidadId,
      accion: accion ?? this.accion,
      datosJson: datosJson ?? this.datosJson,
      dispositivoId: dispositivoId ?? this.dispositivoId,
      offline: offline ?? this.offline,
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
    if (actorId.present) {
      map['actor_id'] = Variable<String>(actorId.value);
    }
    if (entidad.present) {
      map['entidad'] = Variable<String>(entidad.value);
    }
    if (entidadId.present) {
      map['entidad_id'] = Variable<String>(entidadId.value);
    }
    if (accion.present) {
      map['accion'] = Variable<String>(accion.value);
    }
    if (datosJson.present) {
      map['datos_json'] = Variable<String>(datosJson.value);
    }
    if (dispositivoId.present) {
      map['dispositivo_id'] = Variable<String>(dispositivoId.value);
    }
    if (offline.present) {
      map['offline'] = Variable<bool>(offline.value);
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
    return (StringBuffer('AuditoriaEventosTableCompanion(')
          ..write('id: $id, ')
          ..write('actorId: $actorId, ')
          ..write('entidad: $entidad, ')
          ..write('entidadId: $entidadId, ')
          ..write('accion: $accion, ')
          ..write('datosJson: $datosJson, ')
          ..write('dispositivoId: $dispositivoId, ')
          ..write('offline: $offline, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SyncQueueTableTable syncQueueTable = $SyncQueueTableTable(this);
  late final $MesasTableTable mesasTable = $MesasTableTable(this);
  late final $ClientesTableTable clientesTable = $ClientesTableTable(this);
  late final $ProductosTableTable productosTable = $ProductosTableTable(this);
  late final $OrdenesTableTable ordenesTable = $OrdenesTableTable(this);
  late final $DetalleOrdenTableTable detalleOrdenTable =
      $DetalleOrdenTableTable(this);
  late final $TransaccionesTableTable transaccionesTable =
      $TransaccionesTableTable(this);
  late final $PagoDetallesTableTable pagoDetallesTable =
      $PagoDetallesTableTable(this);
  late final $MovimientosInventarioTableTable movimientosInventarioTable =
      $MovimientosInventarioTableTable(this);
  late final $VisitasClientesTableTable visitasClientesTable =
      $VisitasClientesTableTable(this);
  late final $AuditoriaEventosTableTable auditoriaEventosTable =
      $AuditoriaEventosTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    syncQueueTable,
    mesasTable,
    clientesTable,
    productosTable,
    ordenesTable,
    detalleOrdenTable,
    transaccionesTable,
    pagoDetallesTable,
    movimientosInventarioTable,
    visitasClientesTable,
    auditoriaEventosTable,
  ];
}

typedef $$SyncQueueTableTableCreateCompanionBuilder =
    SyncQueueTableCompanion Function({
      required String id,
      required String entity,
      required String entityId,
      required String operation,
      required String payload,
      required String idempotencyKey,
      required int createdAt,
      Value<int> attempts,
      Value<int?> lastAttemptAt,
      Value<String> status,
      Value<String?> errorMessage,
      Value<int> rowid,
    });
typedef $$SyncQueueTableTableUpdateCompanionBuilder =
    SyncQueueTableCompanion Function({
      Value<String> id,
      Value<String> entity,
      Value<String> entityId,
      Value<String> operation,
      Value<String> payload,
      Value<String> idempotencyKey,
      Value<int> createdAt,
      Value<int> attempts,
      Value<int?> lastAttemptAt,
      Value<String> status,
      Value<String?> errorMessage,
      Value<int> rowid,
    });

class $$SyncQueueTableTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueTableTable> {
  $$SyncQueueTableTableFilterComposer({
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

  ColumnFilters<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncQueueTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueTableTable> {
  $$SyncQueueTableTableOrderingComposer({
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

  ColumnOrderings<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncQueueTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueTableTable> {
  $$SyncQueueTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<int> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => column,
  );
}

class $$SyncQueueTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncQueueTableTable,
          SyncQueueTableData,
          $$SyncQueueTableTableFilterComposer,
          $$SyncQueueTableTableOrderingComposer,
          $$SyncQueueTableTableAnnotationComposer,
          $$SyncQueueTableTableCreateCompanionBuilder,
          $$SyncQueueTableTableUpdateCompanionBuilder,
          (
            SyncQueueTableData,
            BaseReferences<
              _$AppDatabase,
              $SyncQueueTableTable,
              SyncQueueTableData
            >,
          ),
          SyncQueueTableData,
          PrefetchHooks Function()
        > {
  $$SyncQueueTableTableTableManager(
    _$AppDatabase db,
    $SyncQueueTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> entity = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<String> idempotencyKey = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<int?> lastAttemptAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncQueueTableCompanion(
                id: id,
                entity: entity,
                entityId: entityId,
                operation: operation,
                payload: payload,
                idempotencyKey: idempotencyKey,
                createdAt: createdAt,
                attempts: attempts,
                lastAttemptAt: lastAttemptAt,
                status: status,
                errorMessage: errorMessage,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String entity,
                required String entityId,
                required String operation,
                required String payload,
                required String idempotencyKey,
                required int createdAt,
                Value<int> attempts = const Value.absent(),
                Value<int?> lastAttemptAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncQueueTableCompanion.insert(
                id: id,
                entity: entity,
                entityId: entityId,
                operation: operation,
                payload: payload,
                idempotencyKey: idempotencyKey,
                createdAt: createdAt,
                attempts: attempts,
                lastAttemptAt: lastAttemptAt,
                status: status,
                errorMessage: errorMessage,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncQueueTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncQueueTableTable,
      SyncQueueTableData,
      $$SyncQueueTableTableFilterComposer,
      $$SyncQueueTableTableOrderingComposer,
      $$SyncQueueTableTableAnnotationComposer,
      $$SyncQueueTableTableCreateCompanionBuilder,
      $$SyncQueueTableTableUpdateCompanionBuilder,
      (
        SyncQueueTableData,
        BaseReferences<_$AppDatabase, $SyncQueueTableTable, SyncQueueTableData>,
      ),
      SyncQueueTableData,
      PrefetchHooks Function()
    >;
typedef $$MesasTableTableCreateCompanionBuilder =
    MesasTableCompanion Function({
      required String id,
      required String numeroMesa,
      Value<String> estado,
      required int createdAt,
      required int updatedAt,
      Value<bool> isSynced,
      Value<int> rowid,
    });
typedef $$MesasTableTableUpdateCompanionBuilder =
    MesasTableCompanion Function({
      Value<String> id,
      Value<String> numeroMesa,
      Value<String> estado,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<bool> isSynced,
      Value<int> rowid,
    });

class $$MesasTableTableFilterComposer
    extends Composer<_$AppDatabase, $MesasTableTable> {
  $$MesasTableTableFilterComposer({
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

  ColumnFilters<String> get numeroMesa => $composableBuilder(
    column: $table.numeroMesa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get estado => $composableBuilder(
    column: $table.estado,
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

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MesasTableTableOrderingComposer
    extends Composer<_$AppDatabase, $MesasTableTable> {
  $$MesasTableTableOrderingComposer({
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

  ColumnOrderings<String> get numeroMesa => $composableBuilder(
    column: $table.numeroMesa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estado => $composableBuilder(
    column: $table.estado,
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

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MesasTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $MesasTableTable> {
  $$MesasTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get numeroMesa => $composableBuilder(
    column: $table.numeroMesa,
    builder: (column) => column,
  );

  GeneratedColumn<String> get estado =>
      $composableBuilder(column: $table.estado, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);
}

class $$MesasTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MesasTableTable,
          MesasTableData,
          $$MesasTableTableFilterComposer,
          $$MesasTableTableOrderingComposer,
          $$MesasTableTableAnnotationComposer,
          $$MesasTableTableCreateCompanionBuilder,
          $$MesasTableTableUpdateCompanionBuilder,
          (
            MesasTableData,
            BaseReferences<_$AppDatabase, $MesasTableTable, MesasTableData>,
          ),
          MesasTableData,
          PrefetchHooks Function()
        > {
  $$MesasTableTableTableManager(_$AppDatabase db, $MesasTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MesasTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MesasTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MesasTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> numeroMesa = const Value.absent(),
                Value<String> estado = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MesasTableCompanion(
                id: id,
                numeroMesa: numeroMesa,
                estado: estado,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isSynced: isSynced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String numeroMesa,
                Value<String> estado = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MesasTableCompanion.insert(
                id: id,
                numeroMesa: numeroMesa,
                estado: estado,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isSynced: isSynced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MesasTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MesasTableTable,
      MesasTableData,
      $$MesasTableTableFilterComposer,
      $$MesasTableTableOrderingComposer,
      $$MesasTableTableAnnotationComposer,
      $$MesasTableTableCreateCompanionBuilder,
      $$MesasTableTableUpdateCompanionBuilder,
      (
        MesasTableData,
        BaseReferences<_$AppDatabase, $MesasTableTable, MesasTableData>,
      ),
      MesasTableData,
      PrefetchHooks Function()
    >;
typedef $$ClientesTableTableCreateCompanionBuilder =
    ClientesTableCompanion Function({
      required String id,
      Value<String?> userId,
      required String nombre,
      Value<String?> telefono,
      Value<int> visitasTotales,
      Value<int> puntosLealtad,
      required int fechaRegistro,
      required int createdAt,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$ClientesTableTableUpdateCompanionBuilder =
    ClientesTableCompanion Function({
      Value<String> id,
      Value<String?> userId,
      Value<String> nombre,
      Value<String?> telefono,
      Value<int> visitasTotales,
      Value<int> puntosLealtad,
      Value<int> fechaRegistro,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$ClientesTableTableFilterComposer
    extends Composer<_$AppDatabase, $ClientesTableTable> {
  $$ClientesTableTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get telefono => $composableBuilder(
    column: $table.telefono,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get visitasTotales => $composableBuilder(
    column: $table.visitasTotales,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get puntosLealtad => $composableBuilder(
    column: $table.puntosLealtad,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fechaRegistro => $composableBuilder(
    column: $table.fechaRegistro,
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
}

class $$ClientesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ClientesTableTable> {
  $$ClientesTableTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get telefono => $composableBuilder(
    column: $table.telefono,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get visitasTotales => $composableBuilder(
    column: $table.visitasTotales,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get puntosLealtad => $composableBuilder(
    column: $table.puntosLealtad,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fechaRegistro => $composableBuilder(
    column: $table.fechaRegistro,
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
}

class $$ClientesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClientesTableTable> {
  $$ClientesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<String> get telefono =>
      $composableBuilder(column: $table.telefono, builder: (column) => column);

  GeneratedColumn<int> get visitasTotales => $composableBuilder(
    column: $table.visitasTotales,
    builder: (column) => column,
  );

  GeneratedColumn<int> get puntosLealtad => $composableBuilder(
    column: $table.puntosLealtad,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fechaRegistro => $composableBuilder(
    column: $table.fechaRegistro,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ClientesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ClientesTableTable,
          ClientesTableData,
          $$ClientesTableTableFilterComposer,
          $$ClientesTableTableOrderingComposer,
          $$ClientesTableTableAnnotationComposer,
          $$ClientesTableTableCreateCompanionBuilder,
          $$ClientesTableTableUpdateCompanionBuilder,
          (
            ClientesTableData,
            BaseReferences<
              _$AppDatabase,
              $ClientesTableTable,
              ClientesTableData
            >,
          ),
          ClientesTableData,
          PrefetchHooks Function()
        > {
  $$ClientesTableTableTableManager(_$AppDatabase db, $ClientesTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClientesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClientesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClientesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<String?> telefono = const Value.absent(),
                Value<int> visitasTotales = const Value.absent(),
                Value<int> puntosLealtad = const Value.absent(),
                Value<int> fechaRegistro = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClientesTableCompanion(
                id: id,
                userId: userId,
                nombre: nombre,
                telefono: telefono,
                visitasTotales: visitasTotales,
                puntosLealtad: puntosLealtad,
                fechaRegistro: fechaRegistro,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> userId = const Value.absent(),
                required String nombre,
                Value<String?> telefono = const Value.absent(),
                Value<int> visitasTotales = const Value.absent(),
                Value<int> puntosLealtad = const Value.absent(),
                required int fechaRegistro,
                required int createdAt,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ClientesTableCompanion.insert(
                id: id,
                userId: userId,
                nombre: nombre,
                telefono: telefono,
                visitasTotales: visitasTotales,
                puntosLealtad: puntosLealtad,
                fechaRegistro: fechaRegistro,
                createdAt: createdAt,
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

typedef $$ClientesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ClientesTableTable,
      ClientesTableData,
      $$ClientesTableTableFilterComposer,
      $$ClientesTableTableOrderingComposer,
      $$ClientesTableTableAnnotationComposer,
      $$ClientesTableTableCreateCompanionBuilder,
      $$ClientesTableTableUpdateCompanionBuilder,
      (
        ClientesTableData,
        BaseReferences<_$AppDatabase, $ClientesTableTable, ClientesTableData>,
      ),
      ClientesTableData,
      PrefetchHooks Function()
    >;
typedef $$ProductosTableTableCreateCompanionBuilder =
    ProductosTableCompanion Function({
      required String id,
      required String nombre,
      required int precioCentavos,
      required String categoria,
      Value<bool> controlaInventario,
      Value<int> stockActual,
      Value<int> stockMinimo,
      Value<bool> activo,
      required int createdAt,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$ProductosTableTableUpdateCompanionBuilder =
    ProductosTableCompanion Function({
      Value<String> id,
      Value<String> nombre,
      Value<int> precioCentavos,
      Value<String> categoria,
      Value<bool> controlaInventario,
      Value<int> stockActual,
      Value<int> stockMinimo,
      Value<bool> activo,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$ProductosTableTableFilterComposer
    extends Composer<_$AppDatabase, $ProductosTableTable> {
  $$ProductosTableTableFilterComposer({
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

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get precioCentavos => $composableBuilder(
    column: $table.precioCentavos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoria => $composableBuilder(
    column: $table.categoria,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get controlaInventario => $composableBuilder(
    column: $table.controlaInventario,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stockActual => $composableBuilder(
    column: $table.stockActual,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stockMinimo => $composableBuilder(
    column: $table.stockMinimo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get activo => $composableBuilder(
    column: $table.activo,
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
}

class $$ProductosTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductosTableTable> {
  $$ProductosTableTableOrderingComposer({
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

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get precioCentavos => $composableBuilder(
    column: $table.precioCentavos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoria => $composableBuilder(
    column: $table.categoria,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get controlaInventario => $composableBuilder(
    column: $table.controlaInventario,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stockActual => $composableBuilder(
    column: $table.stockActual,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stockMinimo => $composableBuilder(
    column: $table.stockMinimo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get activo => $composableBuilder(
    column: $table.activo,
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
}

class $$ProductosTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductosTableTable> {
  $$ProductosTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<int> get precioCentavos => $composableBuilder(
    column: $table.precioCentavos,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoria =>
      $composableBuilder(column: $table.categoria, builder: (column) => column);

  GeneratedColumn<bool> get controlaInventario => $composableBuilder(
    column: $table.controlaInventario,
    builder: (column) => column,
  );

  GeneratedColumn<int> get stockActual => $composableBuilder(
    column: $table.stockActual,
    builder: (column) => column,
  );

  GeneratedColumn<int> get stockMinimo => $composableBuilder(
    column: $table.stockMinimo,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get activo =>
      $composableBuilder(column: $table.activo, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ProductosTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductosTableTable,
          ProductosTableData,
          $$ProductosTableTableFilterComposer,
          $$ProductosTableTableOrderingComposer,
          $$ProductosTableTableAnnotationComposer,
          $$ProductosTableTableCreateCompanionBuilder,
          $$ProductosTableTableUpdateCompanionBuilder,
          (
            ProductosTableData,
            BaseReferences<
              _$AppDatabase,
              $ProductosTableTable,
              ProductosTableData
            >,
          ),
          ProductosTableData,
          PrefetchHooks Function()
        > {
  $$ProductosTableTableTableManager(
    _$AppDatabase db,
    $ProductosTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductosTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductosTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductosTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<int> precioCentavos = const Value.absent(),
                Value<String> categoria = const Value.absent(),
                Value<bool> controlaInventario = const Value.absent(),
                Value<int> stockActual = const Value.absent(),
                Value<int> stockMinimo = const Value.absent(),
                Value<bool> activo = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductosTableCompanion(
                id: id,
                nombre: nombre,
                precioCentavos: precioCentavos,
                categoria: categoria,
                controlaInventario: controlaInventario,
                stockActual: stockActual,
                stockMinimo: stockMinimo,
                activo: activo,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String nombre,
                required int precioCentavos,
                required String categoria,
                Value<bool> controlaInventario = const Value.absent(),
                Value<int> stockActual = const Value.absent(),
                Value<int> stockMinimo = const Value.absent(),
                Value<bool> activo = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ProductosTableCompanion.insert(
                id: id,
                nombre: nombre,
                precioCentavos: precioCentavos,
                categoria: categoria,
                controlaInventario: controlaInventario,
                stockActual: stockActual,
                stockMinimo: stockMinimo,
                activo: activo,
                createdAt: createdAt,
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

typedef $$ProductosTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductosTableTable,
      ProductosTableData,
      $$ProductosTableTableFilterComposer,
      $$ProductosTableTableOrderingComposer,
      $$ProductosTableTableAnnotationComposer,
      $$ProductosTableTableCreateCompanionBuilder,
      $$ProductosTableTableUpdateCompanionBuilder,
      (
        ProductosTableData,
        BaseReferences<_$AppDatabase, $ProductosTableTable, ProductosTableData>,
      ),
      ProductosTableData,
      PrefetchHooks Function()
    >;
typedef $$OrdenesTableTableCreateCompanionBuilder =
    OrdenesTableCompanion Function({
      required String id,
      Value<String?> mesaId,
      Value<String?> clienteId,
      required String tipoServicio,
      Value<String> estado,
      required int fechaApertura,
      Value<int?> fechaCierre,
      Value<String?> notas,
      required int createdAt,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$OrdenesTableTableUpdateCompanionBuilder =
    OrdenesTableCompanion Function({
      Value<String> id,
      Value<String?> mesaId,
      Value<String?> clienteId,
      Value<String> tipoServicio,
      Value<String> estado,
      Value<int> fechaApertura,
      Value<int?> fechaCierre,
      Value<String?> notas,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$OrdenesTableTableFilterComposer
    extends Composer<_$AppDatabase, $OrdenesTableTable> {
  $$OrdenesTableTableFilterComposer({
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

  ColumnFilters<String> get mesaId => $composableBuilder(
    column: $table.mesaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clienteId => $composableBuilder(
    column: $table.clienteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipoServicio => $composableBuilder(
    column: $table.tipoServicio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fechaApertura => $composableBuilder(
    column: $table.fechaApertura,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fechaCierre => $composableBuilder(
    column: $table.fechaCierre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notas => $composableBuilder(
    column: $table.notas,
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
}

class $$OrdenesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $OrdenesTableTable> {
  $$OrdenesTableTableOrderingComposer({
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

  ColumnOrderings<String> get mesaId => $composableBuilder(
    column: $table.mesaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clienteId => $composableBuilder(
    column: $table.clienteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipoServicio => $composableBuilder(
    column: $table.tipoServicio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fechaApertura => $composableBuilder(
    column: $table.fechaApertura,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fechaCierre => $composableBuilder(
    column: $table.fechaCierre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notas => $composableBuilder(
    column: $table.notas,
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
}

class $$OrdenesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $OrdenesTableTable> {
  $$OrdenesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get mesaId =>
      $composableBuilder(column: $table.mesaId, builder: (column) => column);

  GeneratedColumn<String> get clienteId =>
      $composableBuilder(column: $table.clienteId, builder: (column) => column);

  GeneratedColumn<String> get tipoServicio => $composableBuilder(
    column: $table.tipoServicio,
    builder: (column) => column,
  );

  GeneratedColumn<String> get estado =>
      $composableBuilder(column: $table.estado, builder: (column) => column);

  GeneratedColumn<int> get fechaApertura => $composableBuilder(
    column: $table.fechaApertura,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fechaCierre => $composableBuilder(
    column: $table.fechaCierre,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notas =>
      $composableBuilder(column: $table.notas, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$OrdenesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OrdenesTableTable,
          OrdenesTableData,
          $$OrdenesTableTableFilterComposer,
          $$OrdenesTableTableOrderingComposer,
          $$OrdenesTableTableAnnotationComposer,
          $$OrdenesTableTableCreateCompanionBuilder,
          $$OrdenesTableTableUpdateCompanionBuilder,
          (
            OrdenesTableData,
            BaseReferences<_$AppDatabase, $OrdenesTableTable, OrdenesTableData>,
          ),
          OrdenesTableData,
          PrefetchHooks Function()
        > {
  $$OrdenesTableTableTableManager(_$AppDatabase db, $OrdenesTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OrdenesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OrdenesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OrdenesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> mesaId = const Value.absent(),
                Value<String?> clienteId = const Value.absent(),
                Value<String> tipoServicio = const Value.absent(),
                Value<String> estado = const Value.absent(),
                Value<int> fechaApertura = const Value.absent(),
                Value<int?> fechaCierre = const Value.absent(),
                Value<String?> notas = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OrdenesTableCompanion(
                id: id,
                mesaId: mesaId,
                clienteId: clienteId,
                tipoServicio: tipoServicio,
                estado: estado,
                fechaApertura: fechaApertura,
                fechaCierre: fechaCierre,
                notas: notas,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> mesaId = const Value.absent(),
                Value<String?> clienteId = const Value.absent(),
                required String tipoServicio,
                Value<String> estado = const Value.absent(),
                required int fechaApertura,
                Value<int?> fechaCierre = const Value.absent(),
                Value<String?> notas = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => OrdenesTableCompanion.insert(
                id: id,
                mesaId: mesaId,
                clienteId: clienteId,
                tipoServicio: tipoServicio,
                estado: estado,
                fechaApertura: fechaApertura,
                fechaCierre: fechaCierre,
                notas: notas,
                createdAt: createdAt,
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

typedef $$OrdenesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OrdenesTableTable,
      OrdenesTableData,
      $$OrdenesTableTableFilterComposer,
      $$OrdenesTableTableOrderingComposer,
      $$OrdenesTableTableAnnotationComposer,
      $$OrdenesTableTableCreateCompanionBuilder,
      $$OrdenesTableTableUpdateCompanionBuilder,
      (
        OrdenesTableData,
        BaseReferences<_$AppDatabase, $OrdenesTableTable, OrdenesTableData>,
      ),
      OrdenesTableData,
      PrefetchHooks Function()
    >;
typedef $$DetalleOrdenTableTableCreateCompanionBuilder =
    DetalleOrdenTableCompanion Function({
      required String id,
      required String ordenId,
      required String productoId,
      required int cantidad,
      required int precioUnitarioCentavos,
      Value<String> estadoPago,
      Value<String?> notas,
      required int createdAt,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$DetalleOrdenTableTableUpdateCompanionBuilder =
    DetalleOrdenTableCompanion Function({
      Value<String> id,
      Value<String> ordenId,
      Value<String> productoId,
      Value<int> cantidad,
      Value<int> precioUnitarioCentavos,
      Value<String> estadoPago,
      Value<String?> notas,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$DetalleOrdenTableTableFilterComposer
    extends Composer<_$AppDatabase, $DetalleOrdenTableTable> {
  $$DetalleOrdenTableTableFilterComposer({
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

  ColumnFilters<String> get ordenId => $composableBuilder(
    column: $table.ordenId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productoId => $composableBuilder(
    column: $table.productoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cantidad => $composableBuilder(
    column: $table.cantidad,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get precioUnitarioCentavos => $composableBuilder(
    column: $table.precioUnitarioCentavos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get estadoPago => $composableBuilder(
    column: $table.estadoPago,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notas => $composableBuilder(
    column: $table.notas,
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
}

class $$DetalleOrdenTableTableOrderingComposer
    extends Composer<_$AppDatabase, $DetalleOrdenTableTable> {
  $$DetalleOrdenTableTableOrderingComposer({
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

  ColumnOrderings<String> get ordenId => $composableBuilder(
    column: $table.ordenId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productoId => $composableBuilder(
    column: $table.productoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cantidad => $composableBuilder(
    column: $table.cantidad,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get precioUnitarioCentavos => $composableBuilder(
    column: $table.precioUnitarioCentavos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estadoPago => $composableBuilder(
    column: $table.estadoPago,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notas => $composableBuilder(
    column: $table.notas,
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
}

class $$DetalleOrdenTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $DetalleOrdenTableTable> {
  $$DetalleOrdenTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ordenId =>
      $composableBuilder(column: $table.ordenId, builder: (column) => column);

  GeneratedColumn<String> get productoId => $composableBuilder(
    column: $table.productoId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cantidad =>
      $composableBuilder(column: $table.cantidad, builder: (column) => column);

  GeneratedColumn<int> get precioUnitarioCentavos => $composableBuilder(
    column: $table.precioUnitarioCentavos,
    builder: (column) => column,
  );

  GeneratedColumn<String> get estadoPago => $composableBuilder(
    column: $table.estadoPago,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notas =>
      $composableBuilder(column: $table.notas, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DetalleOrdenTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DetalleOrdenTableTable,
          DetalleOrdenTableData,
          $$DetalleOrdenTableTableFilterComposer,
          $$DetalleOrdenTableTableOrderingComposer,
          $$DetalleOrdenTableTableAnnotationComposer,
          $$DetalleOrdenTableTableCreateCompanionBuilder,
          $$DetalleOrdenTableTableUpdateCompanionBuilder,
          (
            DetalleOrdenTableData,
            BaseReferences<
              _$AppDatabase,
              $DetalleOrdenTableTable,
              DetalleOrdenTableData
            >,
          ),
          DetalleOrdenTableData,
          PrefetchHooks Function()
        > {
  $$DetalleOrdenTableTableTableManager(
    _$AppDatabase db,
    $DetalleOrdenTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DetalleOrdenTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DetalleOrdenTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DetalleOrdenTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ordenId = const Value.absent(),
                Value<String> productoId = const Value.absent(),
                Value<int> cantidad = const Value.absent(),
                Value<int> precioUnitarioCentavos = const Value.absent(),
                Value<String> estadoPago = const Value.absent(),
                Value<String?> notas = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DetalleOrdenTableCompanion(
                id: id,
                ordenId: ordenId,
                productoId: productoId,
                cantidad: cantidad,
                precioUnitarioCentavos: precioUnitarioCentavos,
                estadoPago: estadoPago,
                notas: notas,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ordenId,
                required String productoId,
                required int cantidad,
                required int precioUnitarioCentavos,
                Value<String> estadoPago = const Value.absent(),
                Value<String?> notas = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => DetalleOrdenTableCompanion.insert(
                id: id,
                ordenId: ordenId,
                productoId: productoId,
                cantidad: cantidad,
                precioUnitarioCentavos: precioUnitarioCentavos,
                estadoPago: estadoPago,
                notas: notas,
                createdAt: createdAt,
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

typedef $$DetalleOrdenTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DetalleOrdenTableTable,
      DetalleOrdenTableData,
      $$DetalleOrdenTableTableFilterComposer,
      $$DetalleOrdenTableTableOrderingComposer,
      $$DetalleOrdenTableTableAnnotationComposer,
      $$DetalleOrdenTableTableCreateCompanionBuilder,
      $$DetalleOrdenTableTableUpdateCompanionBuilder,
      (
        DetalleOrdenTableData,
        BaseReferences<
          _$AppDatabase,
          $DetalleOrdenTableTable,
          DetalleOrdenTableData
        >,
      ),
      DetalleOrdenTableData,
      PrefetchHooks Function()
    >;
typedef $$TransaccionesTableTableCreateCompanionBuilder =
    TransaccionesTableCompanion Function({
      required String id,
      required String ordenId,
      required int montoCentavos,
      required String metodoPago,
      required int fecha,
      required String idempotencyKey,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$TransaccionesTableTableUpdateCompanionBuilder =
    TransaccionesTableCompanion Function({
      Value<String> id,
      Value<String> ordenId,
      Value<int> montoCentavos,
      Value<String> metodoPago,
      Value<int> fecha,
      Value<String> idempotencyKey,
      Value<int> createdAt,
      Value<int> rowid,
    });

class $$TransaccionesTableTableFilterComposer
    extends Composer<_$AppDatabase, $TransaccionesTableTable> {
  $$TransaccionesTableTableFilterComposer({
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

  ColumnFilters<String> get ordenId => $composableBuilder(
    column: $table.ordenId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get montoCentavos => $composableBuilder(
    column: $table.montoCentavos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metodoPago => $composableBuilder(
    column: $table.metodoPago,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TransaccionesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TransaccionesTableTable> {
  $$TransaccionesTableTableOrderingComposer({
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

  ColumnOrderings<String> get ordenId => $composableBuilder(
    column: $table.ordenId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get montoCentavos => $composableBuilder(
    column: $table.montoCentavos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metodoPago => $composableBuilder(
    column: $table.metodoPago,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TransaccionesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransaccionesTableTable> {
  $$TransaccionesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ordenId =>
      $composableBuilder(column: $table.ordenId, builder: (column) => column);

  GeneratedColumn<int> get montoCentavos => $composableBuilder(
    column: $table.montoCentavos,
    builder: (column) => column,
  );

  GeneratedColumn<String> get metodoPago => $composableBuilder(
    column: $table.metodoPago,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  GeneratedColumn<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$TransaccionesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransaccionesTableTable,
          TransaccionesTableData,
          $$TransaccionesTableTableFilterComposer,
          $$TransaccionesTableTableOrderingComposer,
          $$TransaccionesTableTableAnnotationComposer,
          $$TransaccionesTableTableCreateCompanionBuilder,
          $$TransaccionesTableTableUpdateCompanionBuilder,
          (
            TransaccionesTableData,
            BaseReferences<
              _$AppDatabase,
              $TransaccionesTableTable,
              TransaccionesTableData
            >,
          ),
          TransaccionesTableData,
          PrefetchHooks Function()
        > {
  $$TransaccionesTableTableTableManager(
    _$AppDatabase db,
    $TransaccionesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransaccionesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransaccionesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransaccionesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ordenId = const Value.absent(),
                Value<int> montoCentavos = const Value.absent(),
                Value<String> metodoPago = const Value.absent(),
                Value<int> fecha = const Value.absent(),
                Value<String> idempotencyKey = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransaccionesTableCompanion(
                id: id,
                ordenId: ordenId,
                montoCentavos: montoCentavos,
                metodoPago: metodoPago,
                fecha: fecha,
                idempotencyKey: idempotencyKey,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ordenId,
                required int montoCentavos,
                required String metodoPago,
                required int fecha,
                required String idempotencyKey,
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => TransaccionesTableCompanion.insert(
                id: id,
                ordenId: ordenId,
                montoCentavos: montoCentavos,
                metodoPago: metodoPago,
                fecha: fecha,
                idempotencyKey: idempotencyKey,
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

typedef $$TransaccionesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransaccionesTableTable,
      TransaccionesTableData,
      $$TransaccionesTableTableFilterComposer,
      $$TransaccionesTableTableOrderingComposer,
      $$TransaccionesTableTableAnnotationComposer,
      $$TransaccionesTableTableCreateCompanionBuilder,
      $$TransaccionesTableTableUpdateCompanionBuilder,
      (
        TransaccionesTableData,
        BaseReferences<
          _$AppDatabase,
          $TransaccionesTableTable,
          TransaccionesTableData
        >,
      ),
      TransaccionesTableData,
      PrefetchHooks Function()
    >;
typedef $$PagoDetallesTableTableCreateCompanionBuilder =
    PagoDetallesTableCompanion Function({
      required String id,
      required String transaccionId,
      required String detalleOrdenId,
      required int cantidad,
      required int montoCentavos,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$PagoDetallesTableTableUpdateCompanionBuilder =
    PagoDetallesTableCompanion Function({
      Value<String> id,
      Value<String> transaccionId,
      Value<String> detalleOrdenId,
      Value<int> cantidad,
      Value<int> montoCentavos,
      Value<int> createdAt,
      Value<int> rowid,
    });

class $$PagoDetallesTableTableFilterComposer
    extends Composer<_$AppDatabase, $PagoDetallesTableTable> {
  $$PagoDetallesTableTableFilterComposer({
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

  ColumnFilters<String> get transaccionId => $composableBuilder(
    column: $table.transaccionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get detalleOrdenId => $composableBuilder(
    column: $table.detalleOrdenId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cantidad => $composableBuilder(
    column: $table.cantidad,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get montoCentavos => $composableBuilder(
    column: $table.montoCentavos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PagoDetallesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PagoDetallesTableTable> {
  $$PagoDetallesTableTableOrderingComposer({
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

  ColumnOrderings<String> get transaccionId => $composableBuilder(
    column: $table.transaccionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get detalleOrdenId => $composableBuilder(
    column: $table.detalleOrdenId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cantidad => $composableBuilder(
    column: $table.cantidad,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get montoCentavos => $composableBuilder(
    column: $table.montoCentavos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PagoDetallesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PagoDetallesTableTable> {
  $$PagoDetallesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get transaccionId => $composableBuilder(
    column: $table.transaccionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get detalleOrdenId => $composableBuilder(
    column: $table.detalleOrdenId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cantidad =>
      $composableBuilder(column: $table.cantidad, builder: (column) => column);

  GeneratedColumn<int> get montoCentavos => $composableBuilder(
    column: $table.montoCentavos,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PagoDetallesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PagoDetallesTableTable,
          PagoDetallesTableData,
          $$PagoDetallesTableTableFilterComposer,
          $$PagoDetallesTableTableOrderingComposer,
          $$PagoDetallesTableTableAnnotationComposer,
          $$PagoDetallesTableTableCreateCompanionBuilder,
          $$PagoDetallesTableTableUpdateCompanionBuilder,
          (
            PagoDetallesTableData,
            BaseReferences<
              _$AppDatabase,
              $PagoDetallesTableTable,
              PagoDetallesTableData
            >,
          ),
          PagoDetallesTableData,
          PrefetchHooks Function()
        > {
  $$PagoDetallesTableTableTableManager(
    _$AppDatabase db,
    $PagoDetallesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PagoDetallesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PagoDetallesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PagoDetallesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> transaccionId = const Value.absent(),
                Value<String> detalleOrdenId = const Value.absent(),
                Value<int> cantidad = const Value.absent(),
                Value<int> montoCentavos = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PagoDetallesTableCompanion(
                id: id,
                transaccionId: transaccionId,
                detalleOrdenId: detalleOrdenId,
                cantidad: cantidad,
                montoCentavos: montoCentavos,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String transaccionId,
                required String detalleOrdenId,
                required int cantidad,
                required int montoCentavos,
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => PagoDetallesTableCompanion.insert(
                id: id,
                transaccionId: transaccionId,
                detalleOrdenId: detalleOrdenId,
                cantidad: cantidad,
                montoCentavos: montoCentavos,
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

typedef $$PagoDetallesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PagoDetallesTableTable,
      PagoDetallesTableData,
      $$PagoDetallesTableTableFilterComposer,
      $$PagoDetallesTableTableOrderingComposer,
      $$PagoDetallesTableTableAnnotationComposer,
      $$PagoDetallesTableTableCreateCompanionBuilder,
      $$PagoDetallesTableTableUpdateCompanionBuilder,
      (
        PagoDetallesTableData,
        BaseReferences<
          _$AppDatabase,
          $PagoDetallesTableTable,
          PagoDetallesTableData
        >,
      ),
      PagoDetallesTableData,
      PrefetchHooks Function()
    >;
typedef $$MovimientosInventarioTableTableCreateCompanionBuilder =
    MovimientosInventarioTableCompanion Function({
      required String id,
      required String productoId,
      required int cantidad,
      required String tipo,
      Value<String?> referenciaId,
      Value<String?> notas,
      Value<String?> creadoPor,
      required int createdAt,
      required String idempotencyKey,
      Value<int> rowid,
    });
typedef $$MovimientosInventarioTableTableUpdateCompanionBuilder =
    MovimientosInventarioTableCompanion Function({
      Value<String> id,
      Value<String> productoId,
      Value<int> cantidad,
      Value<String> tipo,
      Value<String?> referenciaId,
      Value<String?> notas,
      Value<String?> creadoPor,
      Value<int> createdAt,
      Value<String> idempotencyKey,
      Value<int> rowid,
    });

class $$MovimientosInventarioTableTableFilterComposer
    extends Composer<_$AppDatabase, $MovimientosInventarioTableTable> {
  $$MovimientosInventarioTableTableFilterComposer({
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

  ColumnFilters<String> get productoId => $composableBuilder(
    column: $table.productoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cantidad => $composableBuilder(
    column: $table.cantidad,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get referenciaId => $composableBuilder(
    column: $table.referenciaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notas => $composableBuilder(
    column: $table.notas,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get creadoPor => $composableBuilder(
    column: $table.creadoPor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MovimientosInventarioTableTableOrderingComposer
    extends Composer<_$AppDatabase, $MovimientosInventarioTableTable> {
  $$MovimientosInventarioTableTableOrderingComposer({
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

  ColumnOrderings<String> get productoId => $composableBuilder(
    column: $table.productoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cantidad => $composableBuilder(
    column: $table.cantidad,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get referenciaId => $composableBuilder(
    column: $table.referenciaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notas => $composableBuilder(
    column: $table.notas,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get creadoPor => $composableBuilder(
    column: $table.creadoPor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MovimientosInventarioTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $MovimientosInventarioTableTable> {
  $$MovimientosInventarioTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get productoId => $composableBuilder(
    column: $table.productoId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cantidad =>
      $composableBuilder(column: $table.cantidad, builder: (column) => column);

  GeneratedColumn<String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<String> get referenciaId => $composableBuilder(
    column: $table.referenciaId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notas =>
      $composableBuilder(column: $table.notas, builder: (column) => column);

  GeneratedColumn<String> get creadoPor =>
      $composableBuilder(column: $table.creadoPor, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => column,
  );
}

class $$MovimientosInventarioTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MovimientosInventarioTableTable,
          MovimientosInventarioTableData,
          $$MovimientosInventarioTableTableFilterComposer,
          $$MovimientosInventarioTableTableOrderingComposer,
          $$MovimientosInventarioTableTableAnnotationComposer,
          $$MovimientosInventarioTableTableCreateCompanionBuilder,
          $$MovimientosInventarioTableTableUpdateCompanionBuilder,
          (
            MovimientosInventarioTableData,
            BaseReferences<
              _$AppDatabase,
              $MovimientosInventarioTableTable,
              MovimientosInventarioTableData
            >,
          ),
          MovimientosInventarioTableData,
          PrefetchHooks Function()
        > {
  $$MovimientosInventarioTableTableTableManager(
    _$AppDatabase db,
    $MovimientosInventarioTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MovimientosInventarioTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$MovimientosInventarioTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$MovimientosInventarioTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> productoId = const Value.absent(),
                Value<int> cantidad = const Value.absent(),
                Value<String> tipo = const Value.absent(),
                Value<String?> referenciaId = const Value.absent(),
                Value<String?> notas = const Value.absent(),
                Value<String?> creadoPor = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<String> idempotencyKey = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MovimientosInventarioTableCompanion(
                id: id,
                productoId: productoId,
                cantidad: cantidad,
                tipo: tipo,
                referenciaId: referenciaId,
                notas: notas,
                creadoPor: creadoPor,
                createdAt: createdAt,
                idempotencyKey: idempotencyKey,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String productoId,
                required int cantidad,
                required String tipo,
                Value<String?> referenciaId = const Value.absent(),
                Value<String?> notas = const Value.absent(),
                Value<String?> creadoPor = const Value.absent(),
                required int createdAt,
                required String idempotencyKey,
                Value<int> rowid = const Value.absent(),
              }) => MovimientosInventarioTableCompanion.insert(
                id: id,
                productoId: productoId,
                cantidad: cantidad,
                tipo: tipo,
                referenciaId: referenciaId,
                notas: notas,
                creadoPor: creadoPor,
                createdAt: createdAt,
                idempotencyKey: idempotencyKey,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MovimientosInventarioTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MovimientosInventarioTableTable,
      MovimientosInventarioTableData,
      $$MovimientosInventarioTableTableFilterComposer,
      $$MovimientosInventarioTableTableOrderingComposer,
      $$MovimientosInventarioTableTableAnnotationComposer,
      $$MovimientosInventarioTableTableCreateCompanionBuilder,
      $$MovimientosInventarioTableTableUpdateCompanionBuilder,
      (
        MovimientosInventarioTableData,
        BaseReferences<
          _$AppDatabase,
          $MovimientosInventarioTableTable,
          MovimientosInventarioTableData
        >,
      ),
      MovimientosInventarioTableData,
      PrefetchHooks Function()
    >;
typedef $$VisitasClientesTableTableCreateCompanionBuilder =
    VisitasClientesTableCompanion Function({
      required String id,
      required String clienteId,
      required String fecha,
      Value<int> puntosOtorgados,
      Value<String?> registradoPor,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$VisitasClientesTableTableUpdateCompanionBuilder =
    VisitasClientesTableCompanion Function({
      Value<String> id,
      Value<String> clienteId,
      Value<String> fecha,
      Value<int> puntosOtorgados,
      Value<String?> registradoPor,
      Value<int> createdAt,
      Value<int> rowid,
    });

class $$VisitasClientesTableTableFilterComposer
    extends Composer<_$AppDatabase, $VisitasClientesTableTable> {
  $$VisitasClientesTableTableFilterComposer({
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

  ColumnFilters<String> get clienteId => $composableBuilder(
    column: $table.clienteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get puntosOtorgados => $composableBuilder(
    column: $table.puntosOtorgados,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get registradoPor => $composableBuilder(
    column: $table.registradoPor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VisitasClientesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $VisitasClientesTableTable> {
  $$VisitasClientesTableTableOrderingComposer({
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

  ColumnOrderings<String> get clienteId => $composableBuilder(
    column: $table.clienteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get puntosOtorgados => $composableBuilder(
    column: $table.puntosOtorgados,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get registradoPor => $composableBuilder(
    column: $table.registradoPor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VisitasClientesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $VisitasClientesTableTable> {
  $$VisitasClientesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get clienteId =>
      $composableBuilder(column: $table.clienteId, builder: (column) => column);

  GeneratedColumn<String> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  GeneratedColumn<int> get puntosOtorgados => $composableBuilder(
    column: $table.puntosOtorgados,
    builder: (column) => column,
  );

  GeneratedColumn<String> get registradoPor => $composableBuilder(
    column: $table.registradoPor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$VisitasClientesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VisitasClientesTableTable,
          VisitasClientesTableData,
          $$VisitasClientesTableTableFilterComposer,
          $$VisitasClientesTableTableOrderingComposer,
          $$VisitasClientesTableTableAnnotationComposer,
          $$VisitasClientesTableTableCreateCompanionBuilder,
          $$VisitasClientesTableTableUpdateCompanionBuilder,
          (
            VisitasClientesTableData,
            BaseReferences<
              _$AppDatabase,
              $VisitasClientesTableTable,
              VisitasClientesTableData
            >,
          ),
          VisitasClientesTableData,
          PrefetchHooks Function()
        > {
  $$VisitasClientesTableTableTableManager(
    _$AppDatabase db,
    $VisitasClientesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VisitasClientesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VisitasClientesTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$VisitasClientesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> clienteId = const Value.absent(),
                Value<String> fecha = const Value.absent(),
                Value<int> puntosOtorgados = const Value.absent(),
                Value<String?> registradoPor = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VisitasClientesTableCompanion(
                id: id,
                clienteId: clienteId,
                fecha: fecha,
                puntosOtorgados: puntosOtorgados,
                registradoPor: registradoPor,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String clienteId,
                required String fecha,
                Value<int> puntosOtorgados = const Value.absent(),
                Value<String?> registradoPor = const Value.absent(),
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => VisitasClientesTableCompanion.insert(
                id: id,
                clienteId: clienteId,
                fecha: fecha,
                puntosOtorgados: puntosOtorgados,
                registradoPor: registradoPor,
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

typedef $$VisitasClientesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VisitasClientesTableTable,
      VisitasClientesTableData,
      $$VisitasClientesTableTableFilterComposer,
      $$VisitasClientesTableTableOrderingComposer,
      $$VisitasClientesTableTableAnnotationComposer,
      $$VisitasClientesTableTableCreateCompanionBuilder,
      $$VisitasClientesTableTableUpdateCompanionBuilder,
      (
        VisitasClientesTableData,
        BaseReferences<
          _$AppDatabase,
          $VisitasClientesTableTable,
          VisitasClientesTableData
        >,
      ),
      VisitasClientesTableData,
      PrefetchHooks Function()
    >;
typedef $$AuditoriaEventosTableTableCreateCompanionBuilder =
    AuditoriaEventosTableCompanion Function({
      required String id,
      Value<String?> actorId,
      required String entidad,
      Value<String?> entidadId,
      required String accion,
      Value<String> datosJson,
      Value<String?> dispositivoId,
      Value<bool> offline,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$AuditoriaEventosTableTableUpdateCompanionBuilder =
    AuditoriaEventosTableCompanion Function({
      Value<String> id,
      Value<String?> actorId,
      Value<String> entidad,
      Value<String?> entidadId,
      Value<String> accion,
      Value<String> datosJson,
      Value<String?> dispositivoId,
      Value<bool> offline,
      Value<int> createdAt,
      Value<int> rowid,
    });

class $$AuditoriaEventosTableTableFilterComposer
    extends Composer<_$AppDatabase, $AuditoriaEventosTableTable> {
  $$AuditoriaEventosTableTableFilterComposer({
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

  ColumnFilters<String> get actorId => $composableBuilder(
    column: $table.actorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entidad => $composableBuilder(
    column: $table.entidad,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entidadId => $composableBuilder(
    column: $table.entidadId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accion => $composableBuilder(
    column: $table.accion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get datosJson => $composableBuilder(
    column: $table.datosJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dispositivoId => $composableBuilder(
    column: $table.dispositivoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get offline => $composableBuilder(
    column: $table.offline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AuditoriaEventosTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AuditoriaEventosTableTable> {
  $$AuditoriaEventosTableTableOrderingComposer({
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

  ColumnOrderings<String> get actorId => $composableBuilder(
    column: $table.actorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entidad => $composableBuilder(
    column: $table.entidad,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entidadId => $composableBuilder(
    column: $table.entidadId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accion => $composableBuilder(
    column: $table.accion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get datosJson => $composableBuilder(
    column: $table.datosJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dispositivoId => $composableBuilder(
    column: $table.dispositivoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get offline => $composableBuilder(
    column: $table.offline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AuditoriaEventosTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AuditoriaEventosTableTable> {
  $$AuditoriaEventosTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get actorId =>
      $composableBuilder(column: $table.actorId, builder: (column) => column);

  GeneratedColumn<String> get entidad =>
      $composableBuilder(column: $table.entidad, builder: (column) => column);

  GeneratedColumn<String> get entidadId =>
      $composableBuilder(column: $table.entidadId, builder: (column) => column);

  GeneratedColumn<String> get accion =>
      $composableBuilder(column: $table.accion, builder: (column) => column);

  GeneratedColumn<String> get datosJson =>
      $composableBuilder(column: $table.datosJson, builder: (column) => column);

  GeneratedColumn<String> get dispositivoId => $composableBuilder(
    column: $table.dispositivoId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get offline =>
      $composableBuilder(column: $table.offline, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$AuditoriaEventosTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AuditoriaEventosTableTable,
          AuditoriaEventosTableData,
          $$AuditoriaEventosTableTableFilterComposer,
          $$AuditoriaEventosTableTableOrderingComposer,
          $$AuditoriaEventosTableTableAnnotationComposer,
          $$AuditoriaEventosTableTableCreateCompanionBuilder,
          $$AuditoriaEventosTableTableUpdateCompanionBuilder,
          (
            AuditoriaEventosTableData,
            BaseReferences<
              _$AppDatabase,
              $AuditoriaEventosTableTable,
              AuditoriaEventosTableData
            >,
          ),
          AuditoriaEventosTableData,
          PrefetchHooks Function()
        > {
  $$AuditoriaEventosTableTableTableManager(
    _$AppDatabase db,
    $AuditoriaEventosTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AuditoriaEventosTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$AuditoriaEventosTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$AuditoriaEventosTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> actorId = const Value.absent(),
                Value<String> entidad = const Value.absent(),
                Value<String?> entidadId = const Value.absent(),
                Value<String> accion = const Value.absent(),
                Value<String> datosJson = const Value.absent(),
                Value<String?> dispositivoId = const Value.absent(),
                Value<bool> offline = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AuditoriaEventosTableCompanion(
                id: id,
                actorId: actorId,
                entidad: entidad,
                entidadId: entidadId,
                accion: accion,
                datosJson: datosJson,
                dispositivoId: dispositivoId,
                offline: offline,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> actorId = const Value.absent(),
                required String entidad,
                Value<String?> entidadId = const Value.absent(),
                required String accion,
                Value<String> datosJson = const Value.absent(),
                Value<String?> dispositivoId = const Value.absent(),
                Value<bool> offline = const Value.absent(),
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => AuditoriaEventosTableCompanion.insert(
                id: id,
                actorId: actorId,
                entidad: entidad,
                entidadId: entidadId,
                accion: accion,
                datosJson: datosJson,
                dispositivoId: dispositivoId,
                offline: offline,
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

typedef $$AuditoriaEventosTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AuditoriaEventosTableTable,
      AuditoriaEventosTableData,
      $$AuditoriaEventosTableTableFilterComposer,
      $$AuditoriaEventosTableTableOrderingComposer,
      $$AuditoriaEventosTableTableAnnotationComposer,
      $$AuditoriaEventosTableTableCreateCompanionBuilder,
      $$AuditoriaEventosTableTableUpdateCompanionBuilder,
      (
        AuditoriaEventosTableData,
        BaseReferences<
          _$AppDatabase,
          $AuditoriaEventosTableTable,
          AuditoriaEventosTableData
        >,
      ),
      AuditoriaEventosTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SyncQueueTableTableTableManager get syncQueueTable =>
      $$SyncQueueTableTableTableManager(_db, _db.syncQueueTable);
  $$MesasTableTableTableManager get mesasTable =>
      $$MesasTableTableTableManager(_db, _db.mesasTable);
  $$ClientesTableTableTableManager get clientesTable =>
      $$ClientesTableTableTableManager(_db, _db.clientesTable);
  $$ProductosTableTableTableManager get productosTable =>
      $$ProductosTableTableTableManager(_db, _db.productosTable);
  $$OrdenesTableTableTableManager get ordenesTable =>
      $$OrdenesTableTableTableManager(_db, _db.ordenesTable);
  $$DetalleOrdenTableTableTableManager get detalleOrdenTable =>
      $$DetalleOrdenTableTableTableManager(_db, _db.detalleOrdenTable);
  $$TransaccionesTableTableTableManager get transaccionesTable =>
      $$TransaccionesTableTableTableManager(_db, _db.transaccionesTable);
  $$PagoDetallesTableTableTableManager get pagoDetallesTable =>
      $$PagoDetallesTableTableTableManager(_db, _db.pagoDetallesTable);
  $$MovimientosInventarioTableTableTableManager
  get movimientosInventarioTable =>
      $$MovimientosInventarioTableTableTableManager(
        _db,
        _db.movimientosInventarioTable,
      );
  $$VisitasClientesTableTableTableManager get visitasClientesTable =>
      $$VisitasClientesTableTableTableManager(_db, _db.visitasClientesTable);
  $$AuditoriaEventosTableTableTableManager get auditoriaEventosTable =>
      $$AuditoriaEventosTableTableTableManager(_db, _db.auditoriaEventosTable);
}
