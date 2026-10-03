import 'dart:async';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:exquisssita_manager/app/theme/app_theme.dart';
import 'package:exquisssita_manager/data/local/database/app_database.dart';
import 'package:exquisssita_manager/features/auth/data/auth_repository.dart';
import 'package:exquisssita_manager/features/auth/presentation/view_models/auth_vm.dart';
import 'package:exquisssita_manager/features/auth/presentation/views/login_view.dart';
import 'package:exquisssita_manager/features/orders/data/local_orders_repository.dart';
import 'package:exquisssita_manager/features/orders/data/orders_providers.dart';
import 'package:exquisssita_manager/features/orders/presentation/orders_view.dart';

class _Auth extends Mock implements AuthRepository {}

class _User extends Fake implements User {}

// Shared UI scenarios run under flutter_test and the native integration binding.
void registerPlatformFlows() {
  testWidgets('login valida y bloquea envíos duplicados hasta completar', (
    tester,
  ) async {
    final repository = _Auth();
    final completion = Completer<User>();
    when(
      () => repository.signIn(
        email: 'cashier@example.test',
        password: 'test-password',
      ),
    ).thenAnswer((_) => completion.future);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp(theme: AppTheme.lightTheme, home: const LoginView()),
      ),
    );
    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pump();
    expect(find.text('Ingresa tu correo electrónico'), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('login_email_field')),
      'cashier@example.test',
    );
    await tester.enterText(
      find.byKey(const Key('login_password_field')),
      'test-password',
    );
    await tester.ensureVisible(find.byKey(const Key('login_button')));
    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('login_button')));
    completion.complete(_User());
    await tester.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 5),
    );
    verify(
      () => repository.signIn(
        email: 'cashier@example.test',
        password: 'test-password',
      ),
    ).called(1);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('abre orden offline desde UI y conserva la intención en Drift', (
    tester,
  ) async {
    late AppDatabase db;
    await tester.runAsync(() async {
      db = AppDatabase(executor: NativeDatabase.memory());
      await db
          .into(db.mesasTable)
          .insert(
            MesasTableCompanion.insert(
              id: 'e7ea0e5d-3098-42ed-9200-f5b904aa1704',
              numeroMesa: '1',
              createdAt: 1,
              updatedAt: 1,
            ),
          );
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ordersRepositoryProvider.overrideWithValue(LocalOrdersRepository(db)),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const OrdersView(),
        ),
      ),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 5),
    );
    await tester.runAsync(() => tester.tap(find.text('Mesa 1')));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 5),
    );
    expect(find.text('Agrega productos desde el menú.'), findsOneWidget);
    await tester.runAsync(() async {
      expect((await db.select(db.ordenesTable).get()).single.estado, 'Abierta');
      expect(
        (await db.select(db.syncQueueTable).get()).single.status,
        'pending',
      );
    });
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await tester.runAsync(db.close);
  });
}
