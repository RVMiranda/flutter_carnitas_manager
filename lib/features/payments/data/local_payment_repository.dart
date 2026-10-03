import 'package:uuid/uuid.dart';

import 'package:exquisssita_manager/data/local/database/app_database.dart';
import 'package:exquisssita_manager/data/local/database/local_persistence.dart';
import 'package:exquisssita_manager/data/local/tables/sync_queue_table.dart';
import '../domain/payment_models.dart';

abstract interface class PaymentRepository {
  Future<void> register(PaymentRequest request);
}

class LocalPaymentRepository implements PaymentRepository {
  LocalPaymentRepository(this._database);
  final AppDatabase _database;

  @override
  Future<void> register(PaymentRequest request) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _database.transaction(() async {
      await _database
          .into(_database.transaccionesTable)
          .insert(
            TransaccionesTableCompanion.insert(
              id: request.transactionId,
              ordenId: request.orderId,
              montoCentavos: request.amountCents,
              metodoPago: request.method.databaseValue,
              fecha: now,
              idempotencyKey: request.idempotencyKey,
              createdAt: now,
            ),
          );
      await _database.batch((batch) {
        batch.insertAll(
          _database.pagoDetallesTable,
          request.allocations
              .map(
                (allocation) => PagoDetallesTableCompanion.insert(
                  id: const Uuid().v4(),
                  transaccionId: request.transactionId,
                  detalleOrdenId: allocation.detailId,
                  cantidad: allocation.quantity,
                  montoCentavos: allocation.amountCents,
                  createdAt: now,
                ),
              )
              .toList(),
        );
        batch.insert(
          _database.syncQueueTable,
          SyncQueueTableCompanion.insert(
            id: const Uuid().v4(),
            entity: 'registrar_pago',
            entityId: request.transactionId,
            operation: SyncOperation.insert,
            payload: LocalPersistence.encodePayload(request.toRpcPayload()),
            idempotencyKey: request.idempotencyKey,
            createdAt: now,
          ),
        );
      });
    });
  }
}
