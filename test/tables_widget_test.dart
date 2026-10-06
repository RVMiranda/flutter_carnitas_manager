import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:exquisssita_manager/app/theme/app_theme.dart';
import 'package:exquisssita_manager/data/local/database/app_database.dart';
import 'package:exquisssita_manager/features/orders/data/local_orders_repository.dart';
import 'package:exquisssita_manager/features/orders/data/orders_providers.dart';
import 'package:exquisssita_manager/features/orders/domain/order_models.dart';
import 'package:exquisssita_manager/features/orders/presentation/orders_view.dart';
import 'package:exquisssita_manager/shared/widgets/exquisssita_components.dart';

Future<void> settle(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 30)),
  );
  await tester.pumpAndSettle(
    const Duration(milliseconds: 100),
    EnginePhase.sendSemanticsUpdate,
    const Duration(seconds: 5),
  );
}

Future<void> release(WidgetTester tester, AppDatabase db) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
  await tester.runAsync(db.close);
}

Future<AppDatabase> host(
  WidgetTester tester, {
  bool table = true,
  bool occupied = false,
  bool orphan = false,
}) async {
  late AppDatabase db;
  await tester.runAsync(() async {
    db = AppDatabase(executor: NativeDatabase.memory());
    final repo = LocalOrdersRepository(db);
    if (table) {
      await repo.createTable('1');
      final id = (await db.select(db.mesasTable).get()).single.id;
      if (occupied) {
        await repo.openOrResumeOrder(
          tableId: id,
          serviceType: ServiceType.table,
        );
      }
      if (orphan) {
        await (db.update(db.mesasTable)..where((t) => t.id.equals(id))).write(
          const MesasTableCompanion(estado: Value('Ocupada')),
        );
      }
    }
  });
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ordersRepositoryProvider.overrideWithValue(LocalOrdersRepository(db)),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(body: OrdersView()),
      ),
    ),
  );
  await settle(tester);
  return db;
}

void main() {
  testWidgets(
    'mesa ocupada sigue accesible, muestra la misma orden y permite volver',
    (tester) async {
      final db = await host(tester, occupied: true);
      try {
        await tester.runAsync(() => tester.tap(find.text('Mesa 1')));
        await settle(tester);
        expect(find.text('Orden abierta'), findsOneWidget);
        expect(find.text('Mesa 1'), findsOneWidget);
        await tester.tap(find.byKey(const Key('back_to_tables_button')));
        await settle(tester);
        await tester.runAsync(() => tester.tap(find.text('Mesa 1')));
        await settle(tester);
        await tester.runAsync(() async {
          expect((await db.select(db.ordenesTable).get()).length, 1);
        });
        expect(tester.takeException(), isNull);
      } finally {
        await release(tester, db);
      }
    },
  );
  testWidgets(
    'Agregar visible sin mesas; guarda offline y rechaza duplicados sin cerrar formulario',
    (tester) async {
      final db = await host(tester, table: false);
      try {
        expect(find.textContaining('Aún no hay mesas'), findsOneWidget);
        await tester.tap(find.byKey(const Key('add_table_button')));
        await settle(tester);
        await tester.enterText(
          find.byKey(const Key('table_number_field')),
          '2',
        );
        await tester.runAsync(
          () => tester.tap(find.byKey(const Key('save_table_button'))),
        );
        await settle(tester);
        expect(find.text('Mesa 2'), findsOneWidget);
        expect(find.text('Pendiente de envío'), findsOneWidget);
        await tester.tap(find.byKey(const Key('add_table_button')));
        await settle(tester);
        await tester.enterText(
          find.byKey(const Key('table_number_field')),
          '02',
        );
        await tester.runAsync(
          () => tester.tap(find.byKey(const Key('save_table_button'))),
        );
        await settle(tester);
        expect(find.byType(ExquisssitaModal), findsOneWidget);
        expect(find.text('Ya existe una mesa con ese número.'), findsWidgets);
        await tester.runAsync(() async {
          expect((await db.select(db.mesasTable).get()).length, 1);
        });
        expect(tester.takeException(), isNull);
      } finally {
        await release(tester, db);
      }
    },
  );
  testWidgets('ocupada sin orden presenta motivo y recupera controles', (
    tester,
  ) async {
    final db = await host(tester, orphan: true);
    try {
      await tester.runAsync(() => tester.tap(find.text('Mesa 1')));
      await settle(tester);
      expect(
        find.textContaining('su orden no está disponible'),
        findsOneWidget,
      );
      expect(find.byType(OrderDetailView), findsNothing);
      await tester.tap(find.byKey(const Key('add_table_button')));
      await settle(tester);
      expect(find.byType(ExquisssitaModal), findsOneWidget);
    } finally {
      await release(tester, db);
    }
  });
}
