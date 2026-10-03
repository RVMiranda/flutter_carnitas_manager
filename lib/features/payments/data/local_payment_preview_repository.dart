import 'package:exquisssita_manager/data/local/database/app_database.dart';
import 'package:exquisssita_manager/features/payments/domain/payment_preview.dart';

class LocalPaymentPreviewRepository implements PaymentPreviewRepository {
  LocalPaymentPreviewRepository(this._database);
  final AppDatabase _database;

  @override
  Future<PaymentPreview> preview(String orderId) async {
    final details = await (_database.select(
      _database.detalleOrdenTable,
    )..where((table) => table.ordenId.equals(orderId))).get();
    final products = await _database.select(_database.productosTable).get();
    final productsById = {for (final product in products) product.id: product};
    final payments = await (_database.select(
      _database.transaccionesTable,
    )..where((table) => table.ordenId.equals(orderId))).get();
    final paidCents = payments.fold(
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
      final detailPaid = detailPayments.fold(
        0,
        (sum, payment) => sum + payment.montoCentavos,
      );
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
    return PaymentPreview(orderId: orderId, lines: lines, paidCents: paidCents);
  }
}
