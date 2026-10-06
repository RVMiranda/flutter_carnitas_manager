import 'package:exquisssita_manager/data/local/database/app_database.dart';
import 'package:exquisssita_manager/features/payments/domain/payment_preview.dart';
import 'dart:convert';
import 'package:drift/drift.dart';

class LocalPaymentPreviewRepository implements PaymentPreviewRepository {
  LocalPaymentPreviewRepository(this._database);
  final AppDatabase _database;

  @override
  Future<PaymentPreview> preview(String orderId) async {
    final details =
        await (_database.select(_database.detalleOrdenTable)..where(
              (table) =>
                  table.ordenId.equals(orderId) &
                  table.estadoPago.isNotValue('Cancelado'),
            ))
            .get();
    final products = await _database.select(_database.productosTable).get();
    final productsById = {for (final product in products) product.id: product};
    final payments = await (_database.select(
      _database.transaccionesTable,
    )..where((table) => table.ordenId.equals(orderId))).get();
    final operations = await (_database.select(
      _database.syncQueueTable,
    )..where((t) => t.entity.equals('registrar_pago'))).get();
    final operationByKey = {for (final op in operations) op.idempotencyKey: op};
    final states = await _database
        .customSelect('SELECT * FROM critical_operations')
        .get();
    final stateById = {
      for (final state in states) state.read<String>('operation_id'): state,
    };
    final confirmed = payments.where((payment) {
      final op = operationByKey[payment.idempotencyKey];
      return op == null ||
          stateById[op.id]?.read<String>('state') == 'confirmed';
    }).toList();
    final confirmedIds = confirmed.map((p) => p.id).toSet();
    final unsettled = operations
        .where(
          (op) =>
              (jsonDecode(op.payload) as Map)['p_orden_id'] == orderId &&
              !(stateById[op.id]?.read<String>('state') == 'confirmed' &&
                  confirmed.any(
                    (p) => p.idempotencyKey == op.idempotencyKey,
                  )) &&
              !(stateById[op.id]?.read<String>('state') == 'rejected' &&
                  stateById[op.id]?.read<int>('acknowledged') == 1),
        )
        .toList();
    final awaiting = unsettled
        .where((op) => op.status != 'failed')
        .fold<int>(
          0,
          (sum, op) =>
              sum + ((jsonDecode(op.payload) as Map)['p_monto'] as int),
        );
    final paidCents = confirmed.fold(
      0,
      (sum, payment) => sum + payment.montoCentavos,
    );

    final lines = <PaymentPreviewLine>[];
    for (final detail in details) {
      final product = productsById[detail.productoId];
      if (product == null) {
        throw StateError('Producto ${detail.productoId} no existe localmente');
      }
      final detailPayments = await (_database.select(
        _database.pagoDetallesTable,
      )..where((table) => table.detalleOrdenId.equals(detail.id))).get();
      final detailPaid = detailPayments
          .where((p) => confirmedIds.contains(p.transaccionId))
          .fold(0, (sum, payment) => sum + payment.montoCentavos);
      lines.add(
        PaymentPreviewLine(
          detailId: detail.id,
          productName: product.nombre,
          quantity: detail.cantidad,
          unitPriceCents: detail.precioUnitarioCentavos,
          paidCents: detailPaid,
        ),
      );
    }
    return PaymentPreview(
      orderId: orderId,
      lines: lines,
      paidCents: paidCents,
      awaitingConfirmationCents: awaiting,
      requiresReview: unsettled.any((op) => op.status == 'failed'),
    );
  }
}
