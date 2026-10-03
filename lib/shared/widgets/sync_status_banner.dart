import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/connectivity/connectivity_service.dart';
import '../../data/sync/sync_worker.dart';
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
      pending: state.pending,
      failed: state.failed,
      onPressed: () => showExquisssitaSheet<void>(
        context: navigatorKey?.currentContext ?? context,
        builder: (_) => const CriticalOperationsSheet(),
      ),
    );
  }
}
