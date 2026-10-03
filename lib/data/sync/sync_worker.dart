import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:exquisssita_manager/core/connectivity/connectivity_service.dart';
import 'package:exquisssita_manager/core/logging/app_logger.dart';
import 'package:exquisssita_manager/data/local/database/database_provider.dart';
import 'package:exquisssita_manager/data/local/database/app_database.dart';
import 'package:exquisssita_manager/data/local/database/local_persistence.dart';
import 'package:exquisssita_manager/data/repositories/sync_repository.dart';
import 'package:exquisssita_manager/data/remote/remote_providers.dart';

part 'sync_worker.g.dart';

class SyncWorker {
  SyncWorker(this._connectivity, this._local, this._repository, this._client);
  final ConnectivityService _connectivity;
  final LocalPersistence _local;
  final SyncRepository _repository;
  final SupabaseClient _client;
  StreamSubscription<ConnectivityStatus>? _subscription;
  bool _isSyncing = false;

  void start() {
    AppLogger.info('SyncWorker iniciado', tag: 'Sync');
    _subscription = _connectivity.statusStream.listen((status) {
      if (status == ConnectivityStatus.online) unawaited(syncNow());
    });
    if (_connectivity.isOnline) unawaited(syncNow());
  }

  Future<void> syncNow() async {
    if (_isSyncing ||
        !_connectivity.isOnline ||
        _client.auth.currentSession == null) {
      return;
    }
    _isSyncing = true;
    try {
      for (final operation in await _local.pendingSyncBatch()) {
        await _process(operation);
      }
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _process(SyncQueueTableData operation) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _local.markSyncProcessing(operation.id, now);
    try {
      await _repository.push(operation);
      await _local.markSyncCompleted(operation.id);
    } catch (error, stackTrace) {
      AppLogger.error(
        'Falló operación ${operation.id}',
        tag: 'Sync',
        error: error,
        stackTrace: stackTrace,
      );
      if (_isRetryable(error) && operation.attempts < 8) {
        await _local.markSyncRetry(
          id: operation.id,
          attempts: operation.attempts,
          now: now,
          error: error.toString(),
        );
      } else {
        await _local.markSyncFailed(operation.id, error.toString(), now);
      }
    }
  }

  bool _isRetryable(Object error) {
    if (error is PostgrestException) {
      final code = error.code;
      return code == '408' || code == '429' || (code?.startsWith('5') ?? false);
    }
    return error is TimeoutException || error is SocketException;
  }

  void dispose() {
    _subscription?.cancel();
    AppLogger.info('SyncWorker detenido', tag: 'Sync');
  }
}

@Riverpod(keepAlive: true)
SyncWorker syncWorker(Ref ref) {
  final worker = SyncWorker(
    ref.watch(connectivityServiceProvider),
    ref.watch(localPersistenceProvider),
    SupabaseSyncRepository(ref.watch(supabaseDataSourceProvider)),
    Supabase.instance.client,
  );
  worker.start();
  ref.onDispose(worker.dispose);
  return worker;
}
