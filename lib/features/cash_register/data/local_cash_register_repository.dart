import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:exquisssita_manager/data/local/database/app_database.dart';
import 'package:exquisssita_manager/data/local/database/local_persistence.dart';
import 'package:exquisssita_manager/data/local/tables/sync_queue_table.dart';
import '../domain/cash_register_models.dart';

class LocalCashRegisterRepository implements CashRegisterRepository {
  LocalCashRegisterRepository(this._database);
  final AppDatabase _database;

  @override
  Stream<CashRegisterSummary> watchSummary(DateTime date) async* {
    yield await _buildSummary(date);
    await for (final _
        in _database
            .customSelect(
              'SELECT COUNT(*) FROM transacciones',
              readsFrom: {
                _database.transaccionesTable,
                _database.syncQueueTable,
                _database.ventaDiariaTable,
              },
            )
            .watch()) {
      yield await _buildSummary(date);
    }
  }

  Future<CashRegisterSummary> _buildSummary(DateTime date) async {
    final day = DateTime(date.year, date.month, date.day);
    final next = day.add(const Duration(days: 1));
    final transactions =
        await (_database.select(_database.transaccionesTable)..where(
              (t) => t.fecha.isBetweenValues(
                day.millisecondsSinceEpoch,
                next.millisecondsSinceEpoch,
              ),
            ))
            .get();
    var cash = 0, card = 0, other = 0;
    final unsettled =
        await (_database.select(_database.syncQueueTable)..where(
              (t) =>
                  t.entity.equals('registrar_pago') &
                  t.status.isNotValue('completed'),
            ))
            .get();
    final unsettledKeys = unsettled.map((op) => op.idempotencyKey).toSet();
    final confirmed = transactions
        .where((t) => !unsettledKeys.contains(t.idempotencyKey))
        .toList();
    for (final transaction in confirmed) {
      switch (transaction.metodoPago) {
        case 'Efectivo':
          cash += transaction.montoCentavos;
        case 'Tarjeta':
          card += transaction.montoCentavos;
        default:
          other += transaction.montoCentavos;
      }
    }
    final closed = await (_database.select(
      _database.ventaDiariaTable,
    )..where((v) => v.fecha.equals(_dateKey(day)))).getSingleOrNull();
    return CashRegisterSummary(
      date: day,
      cashCents: cash,
      cardCents: card,
      otherCents: other,
      totalCents: cash + card + other,
      orderCount: confirmed.map((t) => t.ordenId).toSet().length,
      closed: closed != null && closed.id > 0,
    );
  }

  @override
  Stream<List<CashRegisterClosure>> watchClosures() async* {
    Future<List<CashRegisterClosure>> read() async {
      final rows =
          await (_database.select(_database.ventaDiariaTable)
                ..where((v) => v.id.isBiggerThanValue(0))
                ..orderBy([(v) => OrderingTerm.desc(v.fecha)]))
              .get();
      return rows
          .map(
            (row) => CashRegisterClosure(
              date: DateTime.parse(row.fecha),
              cashCents: row.totalEfectivoCentavos,
              cardCents: row.totalTarjetaCentavos,
              otherCents: row.totalOtroCentavos,
              totalCents: row.totalGlobalCentavos,
              orderCount: row.numOrdenes,
              closedAt: DateTime.fromMillisecondsSinceEpoch(row.horaCierre),
            ),
          )
          .toList(growable: false);
    }

    yield await read();
    await for (final _
        in _database.select(_database.ventaDiariaTable).watch()) {
      yield await read();
    }
  }

  @override
  Future<CashRegisterSummary> close(DateTime date) async {
    final summary = await _buildSummary(date);
    if (summary.closed) return summary;
    final provisional = await (_database.select(
      _database.ventaDiariaTable,
    )..where((v) => v.fecha.equals(_dateKey(summary.date)))).getSingleOrNull();
    if (provisional != null) return summary;
    final unresolved = await _database
        .customSelect(
          "SELECT q.id FROM sync_queue q JOIN critical_operations c ON c.operation_id=q.id WHERE q.entity='registrar_pago' AND NOT (c.state='rejected' AND c.acknowledged=1) AND (c.state<>'confirmed' OR NOT EXISTS(SELECT 1 FROM transacciones t WHERE t.idempotency_key=q.idempotency_key))",
        )
        .get();
    if (unresolved.isNotEmpty) {
      throw StateError('Hay pagos pendientes de confirmación o revisión.');
    }
    final now = DateTime.now().millisecondsSinceEpoch;
    await _database.transaction(() async {
      await _database
          .into(_database.ventaDiariaTable)
          .insert(
            VentaDiariaTableCompanion.insert(
              id: Value(-now),
              fecha: _dateKey(summary.date),
              totalEfectivoCentavos: Value(summary.cashCents),
              totalTarjetaCentavos: Value(summary.cardCents),
              totalOtroCentavos: Value(summary.otherCents),
              totalGlobalCentavos: summary.totalCents,
              numOrdenes: Value(summary.orderCount),
              horaCierre: now,
            ),
          );
      await _database
          .into(_database.syncQueueTable)
          .insert(
            SyncQueueTableCompanion.insert(
              id: const Uuid().v4(),
              entity: 'realizar_corte_caja_seguro',
              entityId: _dateKey(summary.date),
              operation: SyncOperation.insert,
              payload: LocalPersistence.encodePayload({
                'p_fecha': _dateKey(summary.date),
              }),
              idempotencyKey: const Uuid().v4(),
              createdAt: now,
            ),
          );
    });
    return CashRegisterSummary(
      date: summary.date,
      cashCents: summary.cashCents,
      cardCents: summary.cardCents,
      otherCents: summary.otherCents,
      totalCents: summary.totalCents,
      orderCount: summary.orderCount,
    );
  }

  String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
