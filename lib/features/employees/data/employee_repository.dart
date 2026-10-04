import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:exquisssita_manager/core/permissions/permission.dart';
import 'package:exquisssita_manager/core/utils/currency_utils.dart';
import 'package:exquisssita_manager/data/local/database/app_database.dart';
import 'package:exquisssita_manager/data/local/database/local_persistence.dart';
import 'package:exquisssita_manager/data/local/tables/sync_queue_table.dart';
import '../domain/payroll_models.dart';

abstract interface class EmployeeRepository {
  Stream<List<EmpleadosTableData>> watchEmployees();
  Stream<List<HistorialPagosEmpleadosTableData>> watchPayments();
  Future<void> save(EmployeeDraft draft);
  Future<void> registerPayment(String employeeId, DateTime date, String notes);
}

class LocalEmployeeRepository implements EmployeeRepository {
  LocalEmployeeRepository(this.db, {required this.role});
  final AppDatabase db; final AppRole role;
  void _authorize() { if (!PayrollRules.canManage(role)) throw const UnauthorizedException(); }
  @override Stream<List<EmpleadosTableData>> watchEmployees() => (db.select(db.empleadosTable)..orderBy([(e) => OrderingTerm.asc(e.apellido)])).watch();
  @override Stream<List<HistorialPagosEmpleadosTableData>> watchPayments() => (db.select(db.historialPagosEmpleadosTable)..orderBy([(p) => OrderingTerm.desc(p.fechaPago)])).watch();
  @override
  Future<void> save(EmployeeDraft draft) async {
    _authorize();
    final salaryCents = CurrencyUtils.pesosToCentavos(draft.salaryPesos);
    if (PayrollRules.name(draft.firstName) != null ||
        PayrollRules.name(draft.lastName) != null ||
        PayrollRules.salary(draft.salaryPesos) != null ||
        PayrollRules.payDay('${draft.payDay}') != null) {
      throw StateError('Datos de empleado inválidos.');
    }

    final id = draft.id ?? const Uuid().v4();
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.transaction(() async {
      final existing = draft.id == null
          ? null
          : await (db.select(db.empleadosTable)
                ..where((employee) => employee.id.equals(id)))
              .getSingleOrNull();
      await db.into(db.empleadosTable).insertOnConflictUpdate(
            EmpleadosTableCompanion(
              id: Value(id),
              nombre: Value(draft.firstName.trim()),
              apellido: Value(draft.lastName.trim()),
              telefono: Value(draft.phone.trim().isEmpty ? null : draft.phone.trim()),
              salarioCentavos: Value(salaryCents),
              diaPago: Value(draft.payDay),
              activo: Value(draft.active),
              createdAt: Value(existing?.createdAt ?? now),
              updatedAt: Value(now),
            ),
          );

      await (db.delete(db.syncQueueTable)
            ..where((entry) =>
                entry.entity.equals('empleados') & entry.entityId.equals(id)))
          .go();
      await db.into(db.syncQueueTable).insert(
            SyncQueueTableCompanion.insert(
              id: const Uuid().v4(),
              entity: 'empleados',
              entityId: id,
              operation: draft.id == null
                  ? SyncOperation.insert
                  : SyncOperation.update,
              // These keys must match public.empleados. Local Drift uses the
              // *_centavos suffix, but sync_execute_v2 validates remote names.
              payload: LocalPersistence.encodePayload({
                'id': id,
                'nombre': draft.firstName.trim(),
                'apellido': draft.lastName.trim(),
                'telefono': draft.phone.trim().isEmpty ? null : draft.phone.trim(),
                'salario': salaryCents,
                'dia_pago': draft.payDay,
                'activo': draft.active,
              }),
              idempotencyKey: const Uuid().v4(),
              createdAt: now,
            ),
          );
    });
  }
  @override Future<void> registerPayment(String employeeId, DateTime date, String notes) async { _authorize(); final employee = await (db.select(db.empleadosTable)..where((e) => e.id.equals(employeeId))).getSingle(); final dateKey = '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}'; await db.transaction(() async { final exists = await (db.select(db.historialPagosEmpleadosTable)..where((p) => p.empleadoId.equals(employeeId) & p.fechaPago.equals(dateKey))).getSingleOrNull(); if (exists != null) throw StateError('El pago de este periodo ya está registrado.'); final id = const Uuid().v4(); await db.into(db.historialPagosEmpleadosTable).insert(HistorialPagosEmpleadosTableCompanion.insert(id: id, empleadoId: employeeId, montoCentavos: employee.salarioCentavos, fechaPago: dateKey, notas: Value(notes.trim().isEmpty ? null : notes.trim()), createdAt: DateTime.now().millisecondsSinceEpoch)); await db.into(db.syncQueueTable).insert(SyncQueueTableCompanion.insert(id: const Uuid().v4(), entity: 'historial_pagos_empleados', entityId: id, operation: SyncOperation.insert, payload: LocalPersistence.encodePayload({'id': id, 'empleado_id': employeeId, 'monto_centavos': employee.salarioCentavos, 'fecha_pago': dateKey, 'notas': notes.trim()}), idempotencyKey: const Uuid().v4(), createdAt: DateTime.now().millisecondsSinceEpoch)); }); }
}
class UnauthorizedException implements Exception { const UnauthorizedException(); }
