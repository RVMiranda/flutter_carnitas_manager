import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:exquisssita_manager/core/permissions/permission.dart';
import 'package:exquisssita_manager/data/local/database/app_database.dart';
import 'package:exquisssita_manager/features/employees/data/employee_repository.dart';
import 'package:exquisssita_manager/features/employees/domain/payroll_models.dart';

void main() {
  test(
    'employee edit stays an insert offline and payment uses remote columns',
    () async {
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
      final employee = await db.select(db.empleadosTable).getSingle();
      await repository.save(
        EmployeeDraft(
          id: employee.id,
          firstName: 'María',
          lastName: 'López',
          phone: '5512345678',
          salaryPesos: '1200.50',
          payDay: 2,
          active: true,
        ),
      );

      final queuedEmployee = await (db.select(
        db.syncQueueTable,
      )..where((entry) => entry.entity.equals('empleados'))).getSingle();
      expect(queuedEmployee.operation, 'INSERT');
      expect(queuedEmployee.payload, contains('"salario":120050'));
      expect(queuedEmployee.payload, isNot(contains('salario_centavos')));

      await repository.registerPayment(
        employee.id,
        DateTime(2026, 10, 6),
        'Pagado',
        periodStart: DateTime(2026, 10, 5),
      );
      final queuedPayment =
          await (db.select(db.syncQueueTable)..where(
                (entry) => entry.entity.equals('historial_pagos_empleados'),
              ))
              .getSingle();
      expect(queuedPayment.payload, contains('"monto":120050'));
      expect(queuedPayment.payload, contains('"periodo_inicio":"2026-10-05"'));
      expect(
        queuedPayment.payload,
        contains('"fecha_programada":"2026-10-06"'),
      );
      expect(queuedPayment.payload, isNot(contains('monto_centavos')));
      expect(
        () => repository.registerPayment(
          employee.id,
          DateTime(2026, 10, 7),
          '',
          periodStart: DateTime(2026, 10, 5),
        ),
        throwsStateError,
      );
    },
  );
}
