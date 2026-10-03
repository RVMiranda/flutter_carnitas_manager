import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:exquisssita_manager/app/theme/app_theme.dart';
import 'package:exquisssita_manager/core/connectivity/connectivity_service.dart';
import 'package:exquisssita_manager/data/sync/sync_models.dart';
import 'package:exquisssita_manager/data/sync/sync_worker.dart';
import 'package:exquisssita_manager/features/auth/presentation/view_models/auth_vm.dart';
import 'package:exquisssita_manager/shared/navigation/main_shell.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async => initializeDateFormatting('es_MX'));

  for (final width in [360.0, 600.0, 840.0, 1440.0]) {
    testWidgets('MainShell se adapta a ${width.toInt()} px', (tester) async {
      await tester.binding.setSurfaceSize(Size(width, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWithValue(null),
            currentUserRoleProvider.overrideWith(
              (ref) async => AppRole.employee,
            ),
            syncSnapshotProvider.overrideWith(
              (ref) => Stream.value(
                const SyncSnapshot(ConnectivityStatus.online),
              ),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const MainShell(child: Placeholder()),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(MainShell), findsOneWidget);
      if (width < 600) {
        expect(find.byKey(const ValueKey('nav-qr')), findsOneWidget);
      } else if (width < 840) {
        expect(find.byKey(const ValueKey('brand-rail')), findsOneWidget);
        expect(find.text('Mesas'), findsOneWidget);
      } else {
        expect(find.byKey(const ValueKey('brand-sidebar')), findsOneWidget);
        expect(find.text('EXQUISSITA'), findsOneWidget);
      }
    });
  }
}
