import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/connectivity/connectivity_service.dart';
import '../../data/sync/sync_worker.dart';
import '../../data/sync/critical_operation_repository.dart';
import 'critical_operations_sheet.dart';
import 'exquisssita_components.dart';

class SyncStatusBanner extends ConsumerWidget {
  const SyncStatusBanner({super.key, this.navigatorKey});

  /// MaterialApp.builder places this banner above its Navigator.
  final GlobalKey<NavigatorState>? navigatorKey;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(syncSnapshotProvider).valueOrNull;
    if (state == null) return const SizedBox.shrink();
    final critical = ref.watch(criticalOperationsProvider).valueOrNull ?? const [];
    final actionable = critical.where((operation) =>
        !operation.acknowledged &&
        operation.state != CriticalOperationState.confirmed).toList();
    if (actionable.isEmpty && state.status != ConnectivityStatus.syncError) {
      return const SizedBox.shrink();
    }
    final label = switch (state.status) {
      ConnectivityStatus.online => 'En línea',
      ConnectivityStatus.offline => 'Sin conexión',
      ConnectivityStatus.reconnecting => 'Reconectando',
      ConnectivityStatus.syncing => 'Sincronizando',
      ConnectivityStatus.syncError => 'Sincronización requiere atención',
      ConnectivityStatus.unknown => 'Comprobando conexión',
    };
    return ExquisssitaSyncStatus(
      label: label,
      pending: actionable.where((operation) =>
          operation.state == CriticalOperationState.pendingSync).length,
      failed: actionable.where((operation) =>
          operation.state == CriticalOperationState.rejected ||
          operation.state == CriticalOperationState.requiresReview).length,
      onPressed: () => showExquisssitaSheet<void>(
        context: navigatorKey?.currentContext ?? context,
        builder: (_) => const CriticalOperationsSheet(),
      ),
    );
  }
}
