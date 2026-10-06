import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:exquisssita_manager/app/theme/app_theme.dart';
import 'package:exquisssita_manager/data/local/database/app_database.dart';
import 'package:exquisssita_manager/data/local/database/database_provider.dart';
import 'package:exquisssita_manager/features/auth/presentation/view_models/auth_vm.dart';
import 'package:exquisssita_manager/features/employees/data/employee_repository.dart';
import 'package:exquisssita_manager/features/employees/domain/payroll_models.dart';
import 'package:exquisssita_manager/features/employees/presentation/employees_view.dart';

void main() {
  testWidgets('payment modal closes without disposed controller errors', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final db = AppDatabase(executor: NativeDatabase.memory());
    addTearDown(db.close);
    final repository = LocalEmployeeRepository(db, role: AppRole.admin);
    await repository.save(
      const EmployeeDraft(
        firstName: 'Maria',
        lastName: 'Lopez',
        phone: '',
        salaryPesos: '1100',
        payDay: 1,
        active: true,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUserRoleProvider.overrideWith((ref) async => AppRole.admin),
          appDatabaseProvider.overrideWith((ref) => db),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const EmployeesView(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('new-employee')), findsOneWidget);
    expect(find.text('Maria Lopez'), findsOneWidget);

    final employee = await db.select(db.empleadosTable).getSingle();
    await tester.tap(find.byKey(ValueKey('pay-employee-${employee.id}')));
    await tester.pumpAndSettle();
    expect(find.text('Pagar a Maria'), findsOneWidget);
    await tester.tap(find.text('Registrar').last);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Pagar a Maria'), findsNothing);
    expect((await db.select(db.historialPagosEmpleadosTable).get()).length, 1);

    await tester.tap(find.byKey(ValueKey('history-employee-${employee.id}')));
    await tester.pumpAndSettle();
    expect(find.text('Historial de pagos'), findsOneWidget);
    expect(find.text('Pagada'), findsOneWidget);
    expect(find.textContaining('Realizado:'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('payment-history-back')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(ValueKey('edit-employee-${employee.id}')));
    await tester.pumpAndSettle();
    expect(find.text('Editar empleado'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).first, 'María');
    await tester.ensureVisible(find.byKey(const ValueKey('save-employee')));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(SingleChildScrollView).last,
        const Offset(0, -300));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('save-employee')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect((await db.select(db.empleadosTable).getSingle()).nombre, 'María');

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
