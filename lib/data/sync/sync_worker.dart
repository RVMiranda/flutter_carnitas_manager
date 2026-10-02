import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:exquisssita_manager/core/connectivity/connectivity_service.dart';
import 'package:exquisssita_manager/core/logging/app_logger.dart';

part 'sync_worker.g.dart';

/// Worker de sincronización offline → Supabase.
///
/// Escucha cambios de conectividad y procesa la [SyncQueueTable]
/// cuando el dispositivo vuelve a tener acceso a internet.
///
/// TODO (Fase 2): Implementar el procesamiento real de la cola.
/// Por ahora solo loguea los eventos de conectividad.
class SyncWorker {
  SyncWorker(this._connectivityService);

  final ConnectivityService _connectivityService;
  StreamSubscription<ConnectivityStatus>? _subscription;
  bool _isSyncing = false;

  /// Inicia el worker. Debe llamarse una vez al arrancar la app.
  void start() {
    AppLogger.info('SyncWorker iniciado', tag: 'Sync');
    _subscription = _connectivityService.statusStream.listen(
      _onConnectivityChanged,
    );
  }

  void _onConnectivityChanged(ConnectivityStatus status) {
    AppLogger.info('Conectividad: ${status.name}', tag: 'Sync');

    if (status == ConnectivityStatus.online && !_isSyncing) {
      _processPendingOperations();
    }
  }

  Future<void> _processPendingOperations() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      AppLogger.info('Procesando operaciones pendientes...', tag: 'Sync');
      // TODO (Fase 2): Implementar procesamiento real de sync_queue
      // 1. Obtener operaciones con status = 'pending' ORDER BY created_at ASC
      // 2. Para cada operación: ejecutar en Supabase con idempotency_key
      // 3. Marcar como 'completed' o incrementar attempts
      // 4. Aplicar backoff exponencial en fallos temporales
      AppLogger.info('Sincronización completada (placeholder)', tag: 'Sync');
    } catch (e, st) {
      AppLogger.error(
        'Error en sincronización',
        tag: 'Sync',
        error: e,
        stackTrace: st,
      );
    } finally {
      _isSyncing = false;
    }
  }

  /// Detiene el worker y libera recursos.
  void dispose() {
    _subscription?.cancel();
    AppLogger.info('SyncWorker detenido', tag: 'Sync');
  }
}

@Riverpod(keepAlive: true)
SyncWorker syncWorker(Ref ref) {
  final connectivity = ref.watch(connectivityServiceProvider);
  final worker = SyncWorker(connectivity);
  worker.start();
  ref.onDispose(worker.dispose);
  return worker;
}
