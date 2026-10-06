import 'dart:async';
import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:exquisssita_manager/data/local/database/app_database.dart';
import 'package:exquisssita_manager/features/orders/data/local_orders_repository.dart';
import 'package:exquisssita_manager/features/orders/domain/order_models.dart';

void main() {
  late AppDatabase db;
  late LocalOrdersRepository repo;
  setUp(() {
    db = AppDatabase(executor: NativeDatabase.memory());
    repo = LocalOrdersRepository(db);
  });
  tearDown(() => db.close());
  Future<String> table() async {
    await repo.createTable('1');
    return (await db.select(db.mesasTable).get()).single.id;
  }

  test(
    'mesa offline UUID y outbox atómicos; números normalizados y orden natural',
    () async {
      for (final n in ['10', '02', '1']) {
        await repo.createTable(n);
      }
      final tables = await repo.watchTables().first;
      expect(tables.map((t) => t.number), ['1', '2', '10']);
      expect(tables.every((t) => t.pendingSync), isTrue);
      final queue = await db.select(db.syncQueueTable).get();
      expect(queue.length, 3);
      for (final entry in queue) {
        expect(entry.entityId, matches(RegExp(r'^[0-9a-f-]{36}$')));
        expect(
          jsonDecode(entry.payload),
          containsPair(
            'numero_mesa',
            tables.firstWhere((t) => t.id == entry.entityId).number,
          ),
        );
        expect(jsonDecode(entry.payload), isNot(contains('updated_at')));
      }
      await expectLater(repo.createTable('002'), throwsStateError);
      await expectLater(repo.createTable('0'), throwsArgumentError);
      expect((await db.select(db.mesasTable).get()).length, 3);
      expect((await db.select(db.syncQueueTable).get()).length, 3);
    },
  );

  test(
    'dos taps concurrentes y reapertura devuelven una única orden',
    () async {
      final id = await table();
      final orders = await Future.wait(
        List.generate(
          2,
          (_) => repo.openOrResumeOrder(
            tableId: id,
            serviceType: ServiceType.table,
          ),
        ),
      );
      expect(orders[0].id, orders[1].id);
      expect(
        (await repo.openOrResumeOrder(
          tableId: id,
          serviceType: ServiceType.table,
        )).id,
        orders[0].id,
      );
      expect((await db.select(db.ordenesTable).get()).length, 1);
      expect((await repo.watchOrder(orders[0].id).first)!.tableNumber, '1');
      final queue = await (db.select(
        db.syncQueueTable,
      )..orderBy([(q) => OrderingTerm(expression: q.createdAt)])).get();
      expect(queue.map((q) => '${q.entity}:${q.operation}'), [
        'mesas:INSERT',
        'ordenes:INSERT',
        'mesas:UPDATE',
      ]);
      expect(
        queue[0].createdAt < queue[1].createdAt &&
            queue[1].createdAt < queue[2].createdAt,
        isTrue,
      );
      expect(
        (jsonDecode(queue[1].payload) as Map)['fecha_apertura'],
        isA<String>(),
      );
    },
  );

  test(
    'mesa ocupada sin orden no crea una segunda orden ni queda bloqueada sin motivo',
    () async {
      final id = await table();
      await (db.update(db.mesasTable)..where((t) => t.id.equals(id))).write(
        const MesasTableCompanion(estado: Value('Ocupada')),
      );
      await expectLater(
        repo.openOrResumeOrder(tableId: id, serviceType: ServiceType.table),
        throwsStateError,
      );
      expect(await db.select(db.ordenesTable).get(), isEmpty);
    },
  );

  test(
    'detalle de orden reacciona al agregado de productos sin modificar fila de orden',
    () async {
      final id = await table();
      final order = await repo.openOrResumeOrder(
        tableId: id,
        serviceType: ServiceType.table,
      );
      await db
          .into(db.productosTable)
          .insert(
            ProductosTableCompanion.insert(
              id: 'product',
              nombre: 'Taco',
              precioCentavos: 2500,
              categoria: 'Tacos',
              createdAt: 1,
              updatedAt: 1,
            ),
          );
      final initial = Completer<void>(), changed = Completer<OrderSummary>();
      final subscription = repo.watchOrder(order.id).listen((summary) {
        if (!initial.isCompleted) initial.complete();
        if (summary != null && summary.lines.isNotEmpty && !changed.isCompleted) {
          changed.complete(summary);
        }
      });
      try {
        await initial.future.timeout(const Duration(seconds: 3));
        await repo.addProduct(
          orderId: order.id,
          productId: 'product',
          quantity: 2,
        );
        expect(
          (await changed.future.timeout(const Duration(seconds: 3))).totalCents,
          5000,
        );
        final op = (await db.select(db.syncQueueTable).get()).last;
        expect(jsonDecode(op.payload), containsPair('precio_unitario', 2500));
        expect(
          jsonDecode(op.payload),
          isNot(contains('precio_unitario_centavos')),
        );
      } finally {
        await subscription.cancel();
      }
    },
  );

  test(
    'reintento legado explícito conserva payload y key; no duplica ni reintenta conflictos',
    () async {
      final id = await table();
      final order = await repo.openOrResumeOrder(
        tableId: id,
        serviceType: ServiceType.table,
      );
      final op = (await db.select(db.syncQueueTable).get()).firstWhere(
        (q) => q.entity == 'ordenes',
      );
      final legacy = jsonEncode({
        'id': order.id,
        'fecha_apertura': 1780000000000,
      });
      await (db.update(
        db.syncQueueTable,
      )..where((q) => q.id.equals(op.id))).write(
        SyncQueueTableCompanion(
          status: const Value('failed'),
          payload: Value(legacy),
          errorMessage: const Value('conflict_requires_review'),
        ),
      );
      expect(await repo.retryLegacyOperations(order.id), 0);
      await (db.update(
        db.syncQueueTable,
      )..where((q) => q.id.equals(op.id))).write(
        const SyncQueueTableCompanion(
          errorMessage: Value('operation_requires_review'),
        ),
      );
      expect(await repo.retryLegacyOperations(order.id), 1);
      expect(await repo.retryLegacyOperations(order.id), 0);
      final stored = await (db.select(
        db.syncQueueTable,
      )..where((q) => q.id.equals(op.id))).getSingle();
      expect(stored.idempotencyKey, op.idempotencyKey);
      expect(stored.payload, legacy);
      expect(stored.status, 'pending');
      expect(
        (await db
                .customSelect(
                  "SELECT count(*) AS n FROM sync_trace WHERE event='operator_requested_legacy_retry'",
                )
                .getSingle())
            .read<int>('n'),
        1,
      );
    },
  );
}
