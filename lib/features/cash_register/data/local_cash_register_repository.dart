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
        in _database.select(_database.transaccionesTable).watch()) {
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
    for (final transaction in transactions) {
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
      orderCount: transactions.map((t) => t.ordenId).toSet().length,
      closed: closed != null,
    );
  }

  @override
  Future<CashRegisterSummary> close(DateTime date) async {
    final summary = await _buildSummary(date);
    if (summary.closed) return summary;
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
      closed: true,
    );
  }

  String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
