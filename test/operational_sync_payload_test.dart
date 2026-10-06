import 'package:flutter_test/flutter_test.dart';
import 'package:exquisssita_manager/data/sync/operational_sync_payload.dart';

void main() {
  test(
    'legacy timestamps converted without mutating intent, cents kept integer',
    () {
      final original = <String, dynamic>{
        'id': 'order',
        'fecha_apertura': 1780000000000,
        'updated_at': 1,
      };
      final converted = operationalSyncPayload('ordenes', original);
      expect(
        converted['fecha_apertura'],
        DateTime.fromMillisecondsSinceEpoch(
          1780000000000,
        ).toUtc().toIso8601String(),
      );
      expect(converted, isNot(contains('updated_at')));
      expect(original['fecha_apertura'], isA<int>());
      expect(operationalSyncPayload('ordenes', converted), converted);
      expect(
        operationalSyncPayload('detalle_orden', {
          'precio_unitario_centavos': 2550,
        })['precio_unitario'],
        2550,
      );
    },
  );
  test('financial and inventory RPCs are never normalized', () {
    final payload = <String, dynamic>{'updated_at': 1, 'monto_centavos': 2500};
    expect(operationalSyncPayload('registrar_pago', payload), payload);
    expect(
      operationalSyncPayload('registrar_movimiento_inventario', payload),
      payload,
    );
    expect(hasLegacyOperationalPayload('registrar_pago', payload), isFalse);
  });
}
