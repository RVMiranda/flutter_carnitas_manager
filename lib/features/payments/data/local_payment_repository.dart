import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'package:drift/drift.dart';

import 'package:exquisssita_manager/data/local/database/app_database.dart';
import 'package:exquisssita_manager/data/local/database/local_persistence.dart';
import 'package:exquisssita_manager/data/local/tables/sync_queue_table.dart';
import '../domain/payment_models.dart';
import 'local_payment_preview_repository.dart';

abstract interface class PaymentRepository {
  Future<void> register(PaymentRequest request);
}

class LocalPaymentRepository implements PaymentRepository {
  LocalPaymentRepository(this._database);
  final AppDatabase _database;

  @override
  Future<void> register(PaymentRequest request) async {
    if (request.amountCents <= 0 ||
        request.allocations.isEmpty ||
        request.allocations.any((a) => a.quantity <= 0 || a.amountCents <= 0) ||
        request.allocations.map((a) => a.detailId).toSet().length !=
            request.allocations.length ||
        request.allocations.fold<int>(0, (sum, a) => sum + a.amountCents) !=
            request.amountCents) {
      throw const PaymentValidationException('Asignaciones de pago inválidas.');
    }
    final now = DateTime.now().millisecondsSinceEpoch;
    await _database.transaction(() async {
      final operations = await (_database.select(
        _database.syncQueueTable,
      )..where((t) => t.entity.equals('registrar_pago'))).get();
      for (final operation in operations) {
        if (operation.idempotencyKey == request.idempotencyKey) {
          if (operation.payload ==
              LocalPersistence.encodePayload(request.toRpcPayload())) {
            return;
          }
          throw const PaymentValidationException(
            'El identificador del pago ya fue utilizado.',
          );
        }
        final critical = await _database
            .customSelect(
              'SELECT state,acknowledged FROM critical_operations WHERE operation_id=?',
              variables: [Variable(operation.id)],
            )
            .getSingle();
        final materialized =
            await (_database.select(_database.transaccionesTable)..where(
                  (t) => t.idempotencyKey.equals(operation.idempotencyKey),
                ))
                .getSingleOrNull();
        final resolved =
            (critical.read<String>('state') == 'rejected' &&
                critical.read<int>('acknowledged') == 1) ||
            (critical.read<String>('state') == 'confirmed' &&
                materialized != null);
        if (!resolved &&
            (jsonDecode(operation.payload) as Map)['p_orden_id'] ==
                request.orderId) {
          throw const PaymentValidationException(
            'El pago anterior está pendiente de confirmación o revisión.',
          );
        }
      }
      final preview = await LocalPaymentPreviewRepository(
        _database,
      ).preview(request.orderId);
      if (request.amountCents > preview.pendingCents ||
          request.allocations.any((a) {
            final line = preview.lines
                .where((l) => l.detailId == a.detailId)
                .firstOrNull;
            return line == null ||
                a.quantity > line.quantity ||
                a.amountCents > line.pendingCents ||
                a.amountCents > a.quantity * line.unitPriceCents;
          })) {
        throw const PaymentValidationException(
          'El pago supera el saldo disponible.',
        );
      }
      await _database.batch((batch) {
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
