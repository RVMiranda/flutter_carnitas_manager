// Engine integration: real Drift/SQLite + deterministic remote, no device/plugin.
import 'dart:async';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:exquisssita_manager/core/connectivity/connectivity_service.dart';
import 'package:exquisssita_manager/data/local/database/app_database.dart';
import 'package:exquisssita_manager/data/sync/drift_sync_store.dart';
import 'package:exquisssita_manager/data/sync/push_processor.dart';
import 'package:exquisssita_manager/data/sync/pull_processor.dart';
import 'package:exquisssita_manager/data/sync/sync_coordinator.dart';
import 'package:exquisssita_manager/data/sync/sync_models.dart';
import '../sync/fake_sync_repository.dart';
import 'package:exquisssita_manager/features/payments/data/local_payment_repository.dart';
import 'package:exquisssita_manager/features/payments/data/local_payment_preview_repository.dart';
import 'package:exquisssita_manager/features/payments/domain/payment_models.dart';

void main() {
  late AppDatabase db;
  late DriftSyncStore store;
  late FakeSyncRepository remote;
  setUp(() {
    db = AppDatabase(executor: NativeDatabase.memory());
    store = DriftSyncStore(db);
    remote = FakeSyncRepository();
  });
  tearDown(() async {
    await remote.dispose();
    await db.close();
  });
  Future<void> enqueue(String id, {String status = 'pending'}) async {
    await db
        .into(db.syncQueueTable)
        .insert(
          SyncQueueTableCompanion.insert(
            id: id,
            entity: 'mesas',
            entityId: 'mesa-a',
            operation: 'INSERT',
            payload: '{"id":"mesa-a"}',
            idempotencyKey: 'key-$id',
            createdAt: 1,
            status: Value(status),
          ),
        );
  }

  RemoteChange mesa(int seq, {bool deleted = false, int version = 1}) =>
      RemoteChange(
        cursor: seq,
        entity: 'mesas',
        id: 'mesa-a',
        version: version,
        deleted: deleted,
        data: {
          'id': 'mesa-a',
          'numero_mesa': '1',
          'estado': 'Libre',
          'created_at': '2026-10-03T00:00:00Z',
          'updated_at': '2026-10-03T00:00:00Z',
        },
      );

  test(
    'offline enqueue then reconnect pushes and stores initial cursor',
    () async {
      await enqueue('a');
      var online = false;
      final network = StreamController<ConnectivityStatus>.broadcast();
      final coordinator = SyncCoordinator(
        store,
        remote,
        isOnline: () => online,
        networkChanges: network.stream,
      );
      await coordinator.syncNow();
      expect(remote.calls, 0);
      expect(coordinator.current.status, ConnectivityStatus.offline);
      online = true;
      await coordinator.syncNow();
      expect(
        (await db.select(db.syncQueueTable).getSingle()).status,
        'completed',
      );
      expect(await store.cursor('user-a'), 0);
      await coordinator.dispose();
      await network.close();
    },
  );
  test(
    'lost response, crash recovery and duplicate replay create one receipt',
    () async {
      await enqueue('a');
      remote.loseResponse = true;
      final push = PushProcessor(store, remote);
      await push.run(canRun: () => true);
      var row = await db.select(db.syncQueueTable).getSingle();
      expect(row.status, 'pending');
      expect(row.errorMessage, 'temporary_unavailable');
      expect(remote.receipts.length, 1);
      await db.customStatement(
        'UPDATE sync_operation_state SET next_attempt_at=0',
      );
      await store.claim('a', 1);
      await store.recover(2);
      await push.run(canRun: () => true);
      row = await db.select(db.syncQueueTable).getSingle();
      expect(row.status, 'completed');
      expect(remote.receipts.length, 1);
      expect(
        (await db
                .customSelect(
                  "SELECT event FROM sync_trace WHERE event='recovered'",
                )
                .get())
            .length,
        1,
      );
    },
  );
  test('permanent rejection retained and not retried or disclosed', () async {
    await enqueue('a');
    remote.reject = const PostgrestException(
      message: 'secret token',
      code: '42501',
    );
    final push = PushProcessor(store, remote);
    await push.run(canRun: () => true);
    await push.run(canRun: () => true);
    final row = await db.select(db.syncQueueTable).getSingle();
    expect(row.status, 'failed');
    expect(row.errorMessage, 'operation_requires_review');
    expect(remote.calls, 1);
    expect(row.payload, isNotEmpty);
  });
  test(
    'incremental pages and tombstone commit into Drift with watermark',
    () async {
      remote.changes.add(mesa(1));
      final pull = PullProcessor(store, remote);
      await pull.run(scope: 'user-a', canRun: () => true);
      expect((await db.select(db.mesasTable).get()).length, 1);
      remote.changes.addAll([
        mesa(2, version: 2),
        mesa(3, version: 3),
        mesa(4, version: 4, deleted: true),
      ]);
      await pull.run(scope: 'user-a', canRun: () => true);
      expect(await store.cursor('user-a'), 4);
      expect(await db.select(db.mesasTable).get(), isEmpty);
      expect(remote.watermarks.last, 4);
    },
  );
  test('dirty local edits survive competing server version', () async {
    remote.changes.add(mesa(1));
    final pull = PullProcessor(store, remote);
    await pull.run(scope: 'user-a', canRun: () => true);
    await enqueue('a');
    await (db.update(db.mesasTable)..where((t) => t.id.equals('mesa-a'))).write(
      const MesasTableCompanion(estado: Value('Ocupada')),
    );
    remote.changes.add(mesa(2, version: 2));
    await pull.run(scope: 'user-a', canRun: () => true);
    expect((await db.select(db.mesasTable).getSingle()).estado, 'Ocupada');
    expect(
      (await db.customSelect('SELECT * FROM sync_conflicts').get()).length,
      1,
    );
    expect(await store.cursor('user-a'), 2);
  });
  test('page mapper failure rolls back every row and cursor', () async {
    remote.changes.addAll([
      mesa(1),
      const RemoteChange(
        cursor: 2,
        entity: 'unknown',
        id: 'x',
        version: 1,
        data: {},
      ),
    ]);
    await expectLater(
      PullProcessor(store, remote).run(scope: 'user-a', canRun: () => true),
      throwsA(isA<SyncContractException>()),
    );
    expect(await store.cursor('user-a'), 0);
    expect(await db.select(db.mesasTable).get(), isEmpty);
  });
  test(
    'account switch cannot reuse outbox belonging to another account',
    () async {
      await store.bindScope('a');
      await expectLater(
        store.bindScope('b'),
        throwsA(isA<SyncContractException>()),
      );
    },
  );
  test(
    'unconfirmed payments are not settled; canonical UUID reconciles without duplication',
    () async {
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
      final request = PaymentRequest(
        orderId: 'order',
        amountCents: 100,
        method: PaymentMethod.cash,
        transactionId: 'provisional',
        idempotencyKey: 'payment-key',
        allocations: [
          const PaymentAllocation(
            detailId: 'detail',
            quantity: 1,
            amountCents: 100,
          ),
        ],
      );
      final payments = LocalPaymentRepository(db);
      await payments.register(request);
      await payments.register(request);
      final preview = await LocalPaymentPreviewRepository(db).preview('order');
      expect(preview.paidCents, 0);
      expect(preview.awaitingConfirmationCents, 100);
      expect(preview.canPay, isFalse);
      expect(await db.select(db.transaccionesTable).get(), isEmpty);
      final op = await db.select(db.syncQueueTable).getSingle();
      await store.finish(op, status: 'completed', now: 2);
      await store.applyPage(
        'user-a',
        const PullPage(
          [
            RemoteChange(
              cursor: 1,
              entity: 'transacciones',
              id: 'canonical',
              version: 1,
              data: {
                'id': 'canonical',
                'orden_id': 'order',
                'monto': 100,
                'metodo_pago': 'Efectivo',
                'idempotency_key': 'payment-key',
                'fecha': '2026-10-03T00:00:00Z',
                'created_at': '2026-10-03T00:00:00Z',
              },
            ),
            RemoteChange(
              cursor: 2,
              entity: 'pago_detalles',
              id: 'allocation',
              version: 1,
              data: {
                'id': 'allocation',
                'transaccion_id': 'canonical',
                'detalle_orden_id': 'detail',
                'cantidad': 1,
                'monto': 100,
                'created_at': '2026-10-03T00:00:00Z',
              },
            ),
          ],
          2,
          2,
          false,
        ),
      );
      expect(
        (await db.select(db.transaccionesTable).get()).single.id,
        'canonical',
      );
      expect((await db.select(db.pagoDetallesTable).get()).length, 1);
      expect(
        (await LocalPaymentPreviewRepository(db).preview('order')).paidCents,
        100,
      );
    },
  );
  test('a rejected operation blocks later edits on the same entity', () async {
    await enqueue('a');
    await enqueue('b');
    remote.reject = const PostgrestException(message: 'private', code: '42501');
    await PushProcessor(store, remote).run(canRun: () => true);
    expect(remote.calls, 1);
    expect(await store.due(DateTime.now().millisecondsSinceEpoch), isEmpty);
  });
  test(
    'invalidation signal updates Drift; reconnect resumes subscriptions and counts',
    () async {
      var online = false;
      final network = StreamController<ConnectivityStatus>.broadcast();
      final coordinator = SyncCoordinator(
        store,
        remote,
        isOnline: () => online,
        networkChanges: network.stream,
      );
      await coordinator.start();
      remote.changes.add(mesa(1));
      final observed = db
          .select(db.mesasTable)
          .watch()
          .firstWhere((rows) => rows.isNotEmpty);
      online = true;
      network.add(ConnectivityStatus.online);
      await observed.timeout(const Duration(seconds: 2));
      expect((await db.select(db.mesasTable).get()).length, 1);
      remote.changes.add(mesa(2, version: 2, deleted: true));
      final deleted = db
          .select(db.mesasTable)
          .watch()
          .firstWhere((rows) => rows.isEmpty);
      remote.notifications.add(null);
      await deleted.timeout(const Duration(seconds: 2));
      expect(await store.cursor('user-a'), 2);
      await coordinator.dispose();
      await network.close();
    },
  );
}
