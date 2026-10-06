import 'dart:convert';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../local/database/app_database.dart';
import '../sync/sync_models.dart';
import '../sync/operational_sync_payload.dart';

abstract interface class SyncRepository {
  String? get scope;
  Stream<void> get signals;
  Future<Map<String, Object?>> push(
    SyncQueueTableData operation,
    int baseVersion,
  );
  Future<PullPage> pull({required int cursor, int? watermark});
  Future<void> dispose();
}

extension SyncQueuePayload on SyncQueueTableData {
  Map<String, dynamic> get payloadMap =>
      jsonDecode(payload) as Map<String, dynamic>;
}

class SupabaseSyncRepository implements SyncRepository {
  SupabaseSyncRepository(this._client);
  final SupabaseClient _client;
  RealtimeChannel? _channel;
  StreamSubscription<AuthState>? _authSubscription;
  late final _signals = StreamController<void>.broadcast(
    onListen: _startSignals,
  );
  bool _signalsStarted = false;
  @override
  String? get scope => _client.auth.currentSession?.user.id;
  @override
  Stream<void> get signals => _signals.stream;
  void _startSignals() {
    if (_signalsStarted) return;
    _signalsStarted = true;
    void onSignal() {
      if (!_signals.isClosed) _signals.add(null);
    }

    _authSubscription = _client.auth.onAuthStateChange.listen(
      (_) => onSignal(),
    );
    _channel = _client
        .channel('drift-sync-invalidation')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          callback: (_) => onSignal(),
        )
        .subscribe((status, error) {
          if (status == RealtimeSubscribeStatus.subscribed) onSignal();
        });
  }

  @override
  Future<Map<String, Object?>> push(
    SyncQueueTableData operation,
    int baseVersion,
  ) async {
    final payload = operationalSyncPayload(
      operation.entity,
      operation.payloadMap,
    );
    // Installed builds before the remote-column contract persisted the local
    // Drift name. Repair those queued intents on retry instead of discarding
    // them or requiring the user to recreate the product.
    if (operation.entity == 'productos' &&
        payload.containsKey('precio_centavos')) {
      payload['precio'] = payload.remove('precio_centavos');
    }
    // Repair payroll intents queued by older app builds without changing their
    // idempotency key. The remote schema stores integer cents as `monto`.
    if (operation.entity == 'historial_pagos_empleados' &&
        payload.containsKey('monto_centavos')) {
      payload['monto'] = payload.remove('monto_centavos');
    }
    final response = await _client.rpc(
      'sync_execute_v2',
      params: {
        'p_entity': operation.entity,
        'p_entity_id': operation.entityId,
        'p_operation': operation.operation,
        'p_payload': payload,
        'p_key': operation.idempotencyKey,
        'p_expected_version': baseVersion,
      },
    );
    return Map<String, Object?>.from(response as Map);
  }

  @override
  Future<PullPage> pull({required int cursor, int? watermark}) async {
    final result = Map<String, dynamic>.from(
      await _client.rpc(
            'sync_pull',
            params: {
              'p_after': cursor,
              'p_watermark': watermark,
              'p_limit': 200,
            },
          )
          as Map,
    );
    final changes = (result['changes'] as List).map((raw) {
      final row = Map<String, dynamic>.from(raw as Map);
      return RemoteChange(
        cursor: row['seq'] as int,
        entity: row['entity'] as String,
        id: row['entity_id'] as String,
        version: row['version'] as int,
        data: Map<String, Object?>.from(row['data'] as Map),
        deleted: row['deleted'] as bool,
      );
    }).toList();
    return PullPage(
      changes,
      result['cursor'] as int,
      result['watermark'] as int,
      result['has_more'] as bool,
    );
  }

  @override
  Future<void> dispose() async {
    await _authSubscription?.cancel();
    final channel = _channel;
    if (channel != null) await _client.removeChannel(channel);
    await _signals.close();
  }
}
