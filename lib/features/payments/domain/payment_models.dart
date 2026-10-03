import 'package:uuid/uuid.dart';

import 'payment_preview.dart';

enum PaymentMethod { cash, card, transfer, other }

extension PaymentMethodValue on PaymentMethod {
  String get databaseValue => switch (this) {
    PaymentMethod.cash => 'Efectivo',
    PaymentMethod.card => 'Tarjeta',
    PaymentMethod.transfer => 'Transferencia',
    PaymentMethod.other => 'Otro',
  };
}

class PaymentAllocation {
  const PaymentAllocation({
    required this.detailId,
    required this.quantity,
    required this.amountCents,
  });
  final String detailId;
  final int quantity;
  final int amountCents;

  Map<String, Object> toJson() => {
    'detalle_orden_id': detailId,
    'cantidad': quantity,
    'monto': amountCents,
  };
}

class PaymentRequest {
  PaymentRequest({
    required this.orderId,
    required this.amountCents,
    required this.method,
    required this.allocations,
    String? transactionId,
    String? idempotencyKey,
  }) : transactionId = transactionId ?? const Uuid().v4(),
       idempotencyKey = idempotencyKey ?? const Uuid().v4();

  final String orderId;
  final int amountCents;
  final PaymentMethod method;
  final List<PaymentAllocation> allocations;
  final String transactionId;
  final String idempotencyKey;

  Map<String, Object> toRpcPayload() => {
    'p_orden_id': orderId,
    'p_monto': amountCents,
    'p_metodo_pago': method.databaseValue,
    'p_idempotency_key': idempotencyKey,
    'p_asignaciones': allocations.map((item) => item.toJson()).toList(),
  };
}

class PaymentValidationException implements Exception {
  const PaymentValidationException(this.message);
  final String message;
  @override
  String toString() => message;
}

class PaymentAllocationCalculator {
  const PaymentAllocationCalculator._();

  static PaymentRequest full(PaymentPreview preview, PaymentMethod method) {
    final allocations = preview.lines
        .where((line) => line.pendingCents > 0)
        .map(
          (line) => PaymentAllocation(
            detailId: line.detailId,
            quantity: line.quantity,
            amountCents: line.pendingCents,
          ),
        )
        .toList();
    return create(preview, method, allocations);
  }

  static PaymentRequest byAmount(
    PaymentPreview preview,
    PaymentMethod method,
    int amountCents,
  ) {
    if (amountCents <= 0 || amountCents > preview.pendingCents) {
      throw const PaymentValidationException(
        'El monto supera el saldo pendiente.',
      );
    }
    var remaining = amountCents;
    final allocations = <PaymentAllocation>[];
    for (final line in preview.lines) {
      if (remaining == 0) break;
      final amount = line.pendingCents.clamp(0, remaining);
      if (amount == 0) continue;
      final quantity =
          (amount + line.unitPriceCents - 1) ~/ line.unitPriceCents;
      final appliedAmount = amount < line.pendingCents
          ? amount
          : line.pendingCents;
      allocations.add(
        PaymentAllocation(
          detailId: line.detailId,
          quantity: quantity.clamp(1, line.quantity),
          amountCents: appliedAmount,
        ),
      );
      remaining -= appliedAmount;
    }
    return create(preview, method, allocations);
  }

  static PaymentRequest byQuantity(
    PaymentPreview preview,
    PaymentMethod method,
    String detailId,
    int quantity,
  ) {
    final line = preview.lines.firstWhere(
      (item) => item.detailId == detailId,
      orElse: () =>
          throw const PaymentValidationException('Detalle no encontrado.'),
    );
    if (quantity <= 0 || quantity > line.quantity) {
      throw const PaymentValidationException('Cantidad inválida.');
    }
    final amount = quantity * line.unitPriceCents;
    if (amount > line.pendingCents) {
      throw const PaymentValidationException(
        'La cantidad ya fue pagada parcialmente.',
      );
    }
    return create(preview, method, [
      PaymentAllocation(
        detailId: detailId,
        quantity: quantity,
        amountCents: amount,
      ),
    ]);
  }

  static PaymentRequest create(
    PaymentPreview preview,
    PaymentMethod method,
    List<PaymentAllocation> allocations,
  ) {
    if (preview.awaitingConfirmationCents > 0 || preview.requiresReview) {
      throw const PaymentValidationException(
        'El pago anterior está pendiente de confirmación o revisión.',
      );
    }
    final amount = allocations.fold(0, (sum, item) => sum + item.amountCents);
    if (allocations.isEmpty || amount <= 0 || amount > preview.pendingCents) {
      throw const PaymentValidationException('Asignaciones de pago inválidas.');
    }
    return PaymentRequest(
      orderId: preview.orderId,
      amountCents: amount,
      method: method,
      allocations: allocations,
    );
  }
}
