import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:exquisssita_manager/data/local/database/app_database.dart';
import 'package:exquisssita_manager/data/sync/critical_operation_repository.dart';
import 'package:exquisssita_manager/data/sync/drift_sync_store.dart';
import 'package:exquisssita_manager/data/sync/push_processor.dart';
import 'package:exquisssita_manager/data/sync/retry_policy.dart';
import 'package:exquisssita_manager/features/inventory/data/local_inventory_repository.dart';
import 'package:exquisssita_manager/features/inventory/domain/inventory_models.dart';
import 'package:exquisssita_manager/features/payments/data/local_payment_repository.dart';
import 'package:exquisssita_manager/features/payments/data/local_payment_preview_repository.dart';
import 'package:exquisssita_manager/features/payments/domain/payment_models.dart';
import 'fake_sync_repository.dart';

void main() {
  late AppDatabase db;
  late FakeSyncRepository remote;
  setUp(() async {
    db = AppDatabase(executor: NativeDatabase.memory());
    remote = FakeSyncRepository();
    await db
        .into(db.productosTable)
        .insert(
          ProductosTableCompanion.insert(
            id: 'product',
            nombre: 'Agua',
            precioCentavos: 100,
            categoria: 'Bebidas',
            createdAt: 1,
            updatedAt: 1,
          ),
        );
    await db.customStatement(
      "UPDATE productos SET controla_inventario=1,stock_actual=1 WHERE id='product'",
    );
    await db
        .into(db.detalleOrdenTable)
        .insert(
          DetalleOrdenTableCompanion.insert(
            id: 'detail',
            ordenId: 'order',
            productoId: 'product',
            cantidad: 1,
            precioUnitarioCentavos: 100,
            createdAt: 1,
            updatedAt: 1,
          ),
        );
  });
  tearDown(() async {
    await remote.dispose();
    await db.close();
  });
  PaymentRequest payment() => PaymentRequest(
    orderId: 'order',
    amountCents: 40,
    method: PaymentMethod.cash,
    idempotencyKey: 'same-key',
    allocations: [
      const PaymentAllocation(detailId: 'detail', quantity: 1, amountCents: 40),
    ],
  );
  InventoryMovementRequest sale({String key = 'sale-key'}) =>
      InventoryMovementRequest(
        productId: 'product',
        quantity: -1,
        type: InventoryMovementType.sale,
        idempotencyKey: key,
      );
  Future<String> state() async =>
      (await db
              .customSelect('SELECT state FROM critical_operations')
              .getSingle())
          .read<String>('state');
  Future<void> push() =>
      PushProcessor(DriftSyncStore(db), remote).run(canRun: () => true);

  test(
    'offline intent is not a ledger payment and duplicate key is a no-op',
    () async {
      final request = payment();
      final repo = LocalPaymentRepository(db);
      for (var i = 0; i < 10; i++) {
        await repo.register(request);
      }
      expect(await state(), 'pending_sync');
      expect(await db.select(db.transaccionesTable).get(), isEmpty);
      expect((await db.select(db.syncQueueTable).get()).length, 1);
      expect(
        (await LocalPaymentPreviewRepository(db).preview('order')).paidCents,
        0,
      );
    },
  );
  test(
    'durable rejection never confirms payment; cashier acknowledgement is audited',
    () async {
      await LocalPaymentRepository(db).register(payment());
      remote.nextResult = {'status': 'rejected', 'reason': 'overpayment'};
      await push();
      await push();
      expect(remote.calls, 1);
      expect(await state(), 'rejected');
      expect(
        (await LocalPaymentPreviewRepository(
          db,
        ).preview('order')).requiresReview,
        isTrue,
      );
      final id = (await db.select(db.syncQueueTable).getSingle()).id;
      await CriticalOperationRepository(db).acknowledgeRejection(id);
      expect(
        (await LocalPaymentPreviewRepository(db).preview('order')).canPay,
        isTrue,
      );
      expect(
        (await db
                .customSelect(
                  "SELECT * FROM critical_events WHERE event='rejection_acknowledged_reservation_released'",
                )
                .get())
            .length,
        1,
      );
      expect(await db.select(db.transaccionesTable).get(), isEmpty);
    },
  );
  test(
    'inventory reserves last unit once without overwriting confirmed stock',
    () async {
      final repo = LocalInventoryRepository(db);
      final request = sale();
      expect(await repo.register(request), 0);
      expect(await repo.register(request), 0);
      expect((await db.select(db.productosTable).getSingle()).stockActual, 1);
      expect(await db.select(db.movimientosInventarioTable).get(), isEmpty);
      await expectLater(
        repo.register(sale(key: 'second-sale')),
        throwsA(isA<InventoryValidationException>()),
      );
      expect(
        await CriticalOperationRepository(db).reservedDelta('product'),
        -1,
      );
    },
  );
  test(
    'stock rejection releases reservation with original intent retained',
    () async {
      await LocalInventoryRepository(db).register(sale());
      remote.nextResult = {
        'status': 'rejected',
        'reason': 'insufficient_stock',
      };
      await push();
      expect(await state(), 'rejected');
      expect(await CriticalOperationRepository(db).reservedDelta('product'), 0);
      expect((await db.select(db.productosTable).getSingle()).stockActual, 1);
      expect(
        (await db.select(db.syncQueueTable).getSingle()).payload,
        contains('-1'),
      );
    },
  );
  test(
    'lost acknowledgement exhausted retries requires review; original key replay confirms once',
    () async {
      await LocalPaymentRepository(db).register(payment());
      remote.loseResponse = true;
      await PushProcessor(
        DriftSyncStore(db),
        remote,
        retry: RetryPolicy(maxAttempts: 1),
      ).run(canRun: () => true);
      expect(await state(), 'requires_review');
      expect(remote.receipts.length, 1);
      final id = (await db.select(db.syncQueueTable).getSingle()).id;
      await expectLater(
        CriticalOperationRepository(db).acknowledgeRejection(id),
        throwsStateError,
      );
      await CriticalOperationRepository(db).retryUnknown(id);
      await push();
      expect(await state(), 'confirmed');
      expect(remote.receipts.length, 1);
      // A receipt alone is not a materialized balance; keep order blocked until pull.
      expect(
        (await LocalPaymentPreviewRepository(db).preview('order')).canPay,
        isFalse,
      );
    },
  );
  test(
    'invalid success response and permission rejection require review',
    () async {
      await LocalPaymentRepository(db).register(payment());
      remote.nextResult = {'version': 1};
      await push();
      expect(await state(), 'requires_review');
      final id = (await db.select(db.syncQueueTable).getSingle()).id;
      await CriticalOperationRepository(db).retryUnknown(id);
      remote.reject = const PostgrestException(
        message: 'sensitive',
        code: '42501',
      );
      await push();
      expect(await state(), 'requires_review');
    },
  );
  test('SQLite ledger and critical payload are immutable', () async {
    await LocalPaymentRepository(db).register(payment());
    await expectLater(
      db.customStatement("UPDATE sync_queue SET payload='{}'"),
      throwsA(anything),
    );
    await db
        .into(db.transaccionesTable)
        .insert(
          TransaccionesTableCompanion.insert(
            id: 'tx',
            ordenId: 'order',
            montoCentavos: 10,
            metodoPago: 'Efectivo',
            fecha: 1,
            idempotencyKey: 'confirmed-key',
            createdAt: 1,
          ),
        );
    await expectLater(
      db.customStatement('UPDATE transacciones SET monto_centavos=99'),
      throwsA(anything),
    );
    await expectLater(
      db.customStatement('DELETE FROM transacciones'),
      throwsA(anything),
    );
    expect(
      (await db.select(db.transaccionesTable).getSingle()).montoCentavos,
      10,
    );
  });
  test(
    'processing survives actual database close and repeated same-key replay',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'critical-restart-',
      );
      final file = File('${directory.path}/local.sqlite');
      await db.close();
      final persistent = AppDatabase(executor: NativeDatabase(file));
      try {
        await persistent.customStatement(
          "INSERT INTO productos (id,nombre,precio_centavos,categoria,created_at,updated_at) VALUES('product','Agua',100,'Bebidas',1,1)",
        );
        await persistent.customStatement(
          "INSERT INTO detalle_orden(id,orden_id,producto_id,cantidad,precio_unitario_centavos,created_at,updated_at) VALUES('detail','order','product',1,100,1,1)",
        );
        await LocalPaymentRepository(persistent).register(payment());
        final op = await persistent
            .select(persistent.syncQueueTable)
            .getSingle();
        await DriftSyncStore(persistent).claim(op.id, 1);
        await remote.push(
          op,
          0,
        ); // Server commits, process exits before local ACK.
        await persistent.close();
        final reopened = AppDatabase(executor: NativeDatabase(file));
        try {
          final store = DriftSyncStore(reopened);
          await store.recover(2);
          for (var i = 0; i < 5; i++) {
            await PushProcessor(store, remote).run(canRun: () => true);
          }
          expect(
            (await reopened.select(reopened.syncQueueTable).getSingle()).status,
            'completed',
          );
          expect(remote.receipts.length, 1);
          expect(
            (await reopened
                    .customSelect('SELECT state FROM critical_operations')
                    .getSingle())
                .read<String>('state'),
            'confirmed',
          );
        } finally {
          await reopened.close();
        }
      } finally {
        await directory.delete(recursive: true);
      }
    },
  );
}
