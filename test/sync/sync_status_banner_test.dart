import 'package:flutter/material.dart';
import 'package:exquisssita_manager/app/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:exquisssita_manager/core/connectivity/connectivity_service.dart';
import 'package:exquisssita_manager/data/sync/sync_models.dart';
import 'package:exquisssita_manager/data/sync/sync_worker.dart';
import 'package:exquisssita_manager/shared/widgets/sync_status_banner.dart';
import 'package:exquisssita_manager/shared/widgets/critical_operations_sheet.dart';

void main() {
  testWidgets(
    'global banner above Navigator opens the local operations sheet',
    (tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            syncSnapshotProvider.overrideWith(
              (ref) => Stream.value(
                const SyncSnapshot(
                  ConnectivityStatus.offline,
                  pending: 3,
                  failed: 1,
                ),
              ),
            ),
            criticalOperationsProvider.overrideWith((ref) => Stream.value([])),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            navigatorKey: navigatorKey,
            builder: (context, child) => Column(
              children: [
                SyncStatusBanner(navigatorKey: navigatorKey),
                Expanded(child: child!),
              ],
            ),
            home: const Scaffold(body: SizedBox.shrink()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sin conexión · 3 pendientes · 1 fallidas'));
      await tester.pumpAndSettle();
      expect(find.byType(CriticalOperationsSheet), findsOneWidget);
      expect(find.text('Sin operaciones por atender.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  for (final entry in {
    ConnectivityStatus.online: 'En línea',
    ConnectivityStatus.offline: 'Sin conexión',
    ConnectivityStatus.reconnecting: 'Reconectando',
    ConnectivityStatus.syncing: 'Sincronizando',
    ConnectivityStatus.syncError: 'Sincronización requiere atención',
  }.entries) {
    testWidgets('safe status and counters: ${entry.key}', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            syncSnapshotProvider.overrideWith(
              (ref) =>
                  Stream.value(SyncSnapshot(entry.key, pending: 3, failed: 1)),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const Scaffold(body: SyncStatusBanner()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('${entry.value} · 3 pendientes · 1 fallidas'),
        findsOneWidget,
      );
    });
  }
}
