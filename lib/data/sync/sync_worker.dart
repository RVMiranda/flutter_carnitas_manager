import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/connectivity/connectivity_service.dart';
import '../local/database/database_provider.dart';
import '../repositories/sync_repository.dart';
import 'drift_sync_store.dart';
import 'sync_coordinator.dart';
import 'sync_models.dart';
import 'critical_operation_repository.dart';
part 'sync_worker.g.dart';

typedef SyncWorker = SyncCoordinator;
@Riverpod(keepAlive: true)
SyncWorker syncWorker(Ref ref) {
  final network = ref.watch(connectivityServiceProvider);
  final worker = SyncCoordinator(
    DriftSyncStore(ref.watch(appDatabaseProvider)),
    SupabaseSyncRepository(Supabase.instance.client),
    isOnline: () => network.isOnline,
    networkChanges: network.statusStream,
  );
  unawaited(worker.start());
  ref.onDispose(() => unawaited(worker.dispose()));
  return worker;
}

final syncSnapshotProvider = StreamProvider<SyncSnapshot>((ref) async* {
  final coordinator = ref.watch(syncWorkerProvider);
  yield coordinator.current;
  yield* coordinator.states;
});

final criticalOperationsProvider = StreamProvider<List<CriticalOperation>>(
  (ref) => CriticalOperationRepository(ref.watch(appDatabaseProvider)).watch(),
);
