import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_service.g.dart';

/// Estado de conectividad del dispositivo.
enum ConnectivityStatus {
  /// El dispositivo tiene acceso a internet.
  online,

  reconnecting,

  syncing,

  syncError,

  /// El dispositivo no tiene acceso a internet.
  offline,

  /// Estado inicial desconocido (antes de la primera verificación).
  unknown,
}

/// Servicio que monitorea el estado de conectividad de red.
///
/// Expone un stream reactivo que la UI y el SyncWorker pueden escuchar
/// para reaccionar automáticamente a cambios de conectividad.
class ConnectivityService {
  ConnectivityService(this._connectivity);

  final Connectivity _connectivity;

  ConnectivityStatus _current = ConnectivityStatus.unknown;
  ConnectivityStatus get current => _current;

  late final StreamController<ConnectivityStatus> _controller =
      StreamController<ConnectivityStatus>.broadcast(onListen: _init);

  Stream<ConnectivityStatus> get statusStream => _controller.stream;

  void _init() {
    // Verificar estado inicial
    _connectivity.checkConnectivity().then(_onConnectivityChanged);

    // Escuchar cambios futuros
    _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    final isOnline = results.any(
      (r) =>
          r == ConnectivityResult.mobile ||
          r == ConnectivityResult.wifi ||
          r == ConnectivityResult.ethernet,
    );

    final newStatus = isOnline
        ? ConnectivityStatus.online
        : ConnectivityStatus.offline;

    if (newStatus != _current) {
      _current = newStatus;
      _controller.add(_current);
    }
  }

  /// Verifica el estado de conectividad de forma síncrona (caché).
  bool get isOnline => _current == ConnectivityStatus.online;

  void setStatus(ConnectivityStatus status) {
    if (_current == status || _controller.isClosed) return;
    _current = status;
    _controller.add(status);
  }

  void dispose() {
    _controller.close();
  }
}

@riverpod
ConnectivityService connectivityService(Ref ref) {
  final service = ConnectivityService(Connectivity());
  ref.onDispose(service.dispose);
  return service;
}

@riverpod
Stream<ConnectivityStatus> connectivityStatus(Ref ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.statusStream;
}
