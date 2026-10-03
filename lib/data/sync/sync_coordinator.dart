import 'dart:async';
import '../../core/connectivity/connectivity_service.dart';
import '../repositories/sync_repository.dart';
import 'drift_sync_store.dart';
import 'pull_processor.dart';
import 'push_processor.dart';
import 'sync_models.dart';
import 'retry_policy.dart';

class SyncCoordinator {
  SyncCoordinator(
    this.store,
    this.remote, {
    required this.isOnline,
    required this.networkChanges,
    PushProcessor? push,
    PullProcessor? pull,
    this.interval = const Duration(seconds: 15),
  }) : push = push ?? PushProcessor(store, remote),
       pull = pull ?? PullProcessor(store, remote);
  final DriftSyncStore store;
  final SyncRepository remote;
  final bool Function() isOnline;
  final Stream<ConnectivityStatus> networkChanges;
  final PushProcessor push;
  final PullProcessor pull;
  final Duration interval;
  final _states = StreamController<SyncSnapshot>.broadcast();
  final List<StreamSubscription<Object?>> _subscriptions = [];
  Timer? _timer;
  Timer? _signalTimer;
  final _retry = RetryPolicy();
  int _pullFailures = 0;
  DateTime? _retryAfter;
  bool _running = false, _again = false, _disposed = false;
  Future<void>? _startFuture;
  int _pending = 0, _failed = 0;
  ConnectivityStatus _status = ConnectivityStatus.unknown;
  SyncSnapshot get current =>
      SyncSnapshot(_status, pending: _pending, failed: _failed);
  Stream<SyncSnapshot> get states => _states.stream;
  void _emit(ConnectivityStatus status) {
    if (_disposed) return;
    _status = status;
    _states.add(current);
  }

  Future<void> start() => _startFuture ??= _start();
  Future<void> _start() async {
    try {
      await store.recover(DateTime.now().millisecondsSinceEpoch);
    } catch (_) {
      _emit(ConnectivityStatus.syncError);
      return;
    }
    if (_disposed) return;
    _subscriptions.add(
      store.watchCounts().listen((counts) {
        final increased = counts.$1 > _pending;
        _pending = counts.$1;
        _failed = counts.$2;
        _emit(
          _failed > 0 && isOnline() && !_running
              ? ConnectivityStatus.syncError
              : _status,
        );
        if (increased) {
          unawaited(syncNow());
        }
      }),
    );
    _subscriptions.add(
      networkChanges.listen((status) {
        if (status == ConnectivityStatus.offline) {
          _emit(ConnectivityStatus.offline);
        } else {
          _emit(ConnectivityStatus.reconnecting);
          unawaited(syncNow());
        }
      }),
    );
    _subscriptions.add(
      remote.signals.listen((_) {
        signal();
      }),
    );
    _timer = Timer.periodic(interval, (_) => unawaited(syncNow()));
    await syncNow();
  }

  void signal() {
    _signalTimer?.cancel();
    _signalTimer = Timer(
      const Duration(milliseconds: 250),
      () => unawaited(syncNow()),
    );
  }

  Future<void> syncNow() async {
    if (_disposed) return;
    if (_running) {
      _again = true;
      return;
    }
    if (!isOnline()) {
      _emit(ConnectivityStatus.offline);
      return;
    }
    if (_retryAfter != null && DateTime.now().isBefore(_retryAfter!)) return;
    final scope = remote.scope;
    if (scope == null) {
      _emit(ConnectivityStatus.reconnecting);
      return;
    }
    _running = true;
    bool canRun() => !_disposed && isOnline() && remote.scope == scope;
    try {
      _emit(ConnectivityStatus.syncing);
      await store.bindScope(scope);
      await pull.run(scope: scope, canRun: canRun);
      await store.reconcileAccepted();
      final pushed = await push.run(canRun: canRun);
      await pull.run(scope: scope, canRun: canRun);
      await store.reconcileAccepted();
      final counts = await store.watchCounts().first;
      _pending = counts.$1;
      _failed = counts.$2;
      _pullFailures = 0;
      _retryAfter = null;
      _emit(
        !isOnline()
            ? ConnectivityStatus.offline
            : _failed > 0 || !pushed
            ? ConnectivityStatus.syncError
            : ConnectivityStatus.online,
      );
    } catch (_) {
      _retryAfter = DateTime.now().add(_retry.delay(++_pullFailures));
      _emit(
        isOnline() ? ConnectivityStatus.syncError : ConnectivityStatus.offline,
      );
    } finally {
      _running = false;
      if (_again && !_disposed) {
        _again = false;
        unawaited(syncNow());
      }
    }
  }

  Future<void> dispose() async {
    _disposed = true;
    _timer?.cancel();
    _signalTimer?.cancel();
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    await remote.dispose();
    await _states.close();
  }
}
