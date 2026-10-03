import 'package:flutter/material.dart';
import 'package:exquisssita_manager/app/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:exquisssita_manager/data/sync/critical_operation_repository.dart';
import 'package:exquisssita_manager/data/sync/sync_worker.dart';
import 'package:exquisssita_manager/shared/widgets/critical_operations_sheet.dart';

void main() {
  testWidgets('cashier sees amount, pending and review without payloads', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          criticalOperationsProvider.overrideWith(
            (ref) => Stream.value([
              const CriticalOperation(
                'pending-key',
                'registrar_pago',
                CriticalOperationState.pendingSync,
                false,
                false,
                4050,
                null,
              ),
              const CriticalOperation(
                'review-key',
                'registrar_movimiento_inventario',
                CriticalOperationState.requiresReview,
                false,
                false,
                null,
                -1,
              ),
              const CriticalOperation(
                'reject-key',
                'registrar_pago',
                CriticalOperationState.rejected,
                true,
                false,
                100,
                null,
              ),
            ]),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(body: CriticalOperationsSheet()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(r'Pago $40.50'), findsOneWidget);
    expect(find.textContaining('Pendiente de confirmación'), findsOneWidget);
    expect(find.textContaining('requiere revisión'), findsOneWidget);
    expect(find.text('Atender'), findsOneWidget);
    expect(find.text('Consultar'), findsOneWidget);
    await tester.tap(find.text('Atender'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('no realiza un reembolso bancario'),
      findsOneWidget,
    );
    expect(find.textContaining('p_idempotency_key'), findsNothing);
  });
}
