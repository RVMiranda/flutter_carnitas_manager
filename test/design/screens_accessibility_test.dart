import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:exquisssita_manager/app/router/app_router.dart';
import 'package:exquisssita_manager/app/theme/app_theme.dart';
import 'package:exquisssita_manager/features/auth/presentation/view_models/auth_vm.dart';
import 'package:exquisssita_manager/features/auth/presentation/views/login_view.dart';
import 'package:exquisssita_manager/features/cash_register/data/cash_register_providers.dart';
import 'package:exquisssita_manager/features/cash_register/domain/cash_register_models.dart';
import 'package:exquisssita_manager/features/cash_register/presentation/cash_register_view.dart';
import 'package:exquisssita_manager/features/promotions/data/promotion_providers.dart';
import 'package:exquisssita_manager/features/promotions/presentation/promotions_view.dart';
import 'package:exquisssita_manager/shared/navigation/main_shell.dart';
import 'package:exquisssita_manager/shared/widgets/exquisssita_components.dart';

class _CashFixture implements CashRegisterRepository {
  @override
  Stream<CashRegisterSummary> watchSummary(DateTime date) => Stream.value(
    CashRegisterSummary(
      date: date,
      cashCents: 99999900,
      cardCents: 123400,
      otherCents: 0,
      totalCents: 100123300,
      orderCount: 12345,
      closed: true,
    ),
  );
  @override
  Stream<List<CashRegisterClosure>> watchClosures() => Stream.value([
    CashRegisterClosure(
      date: DateTime(2026, 10, 3),
      cashCents: 1,
      cardCents: 0,
      otherCents: 0,
      totalCents: 99999900,
      orderCount: 12345,
      closedAt: DateTime(2026, 10, 3),
    ),
  ]);
  @override
  Future<CashRegisterSummary> close(DateTime date) =>
      throw StateError('read-only fixture');
}

Widget host(Widget child, {double scale = 1, bool dark = false}) => MaterialApp(
  theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
    child: child!,
  ),
  home: child,
);

Finder get verticalScroll => find
    .byWidgetPredicate(
      (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
    )
    .last;

bool hasSemanticLabel(SemanticsNode node, String label) {
  if (node.label == label) return true;
  var found = false;
  node.visitChildren((child) {
    found = hasSemanticLabel(child, label);
    return !found;
  });
  return found;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await initializeDateFormatting('es_MX');
    for (final family in ['Outfit', 'Fraunces']) {
      final loader = FontLoader(family)
        ..addFont(rootBundle.load('assets/fonts/$family-Regular.ttf'));
      await loader.load();
    }
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });

  for (final scale in [1.0, 2.0, 3.0]) {
    testWidgets(
      'login at 320 px, scale $scale: named fields, password action and validation',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(320, 800));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final semantics = tester.ensureSemantics();
        await tester.pumpWidget(
          ProviderScope(child: host(const LoginView(), scale: scale)),
        );
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(
          find.byKey(const Key('login_password_field')),
          200,
          scrollable: verticalScroll,
        );
        expect(find.bySemanticsLabel(RegExp('Contraseña')), findsWidgets);
        await tester.tap(find.bySemanticsLabel('Mostrar contraseña'));
        await tester.pumpAndSettle();
        expect(find.bySemanticsLabel('Ocultar contraseña'), findsOneWidget);
        await tester.scrollUntilVisible(
          find.text('Iniciar sesión'),
          200,
          scrollable: verticalScroll,
        );
        await tester.tap(find.text('Iniciar sesión'));
        await tester.pumpAndSettle();
        // Validation remains local; these tests never contact Auth or Supabase.
        expect(find.text('Ingresa tu correo electrónico'), findsOneWidget);
        expect(tester.takeException(), isNull);
        semantics.dispose();
      },
    );

    testWidgets(
      'cash summary and history at scale $scale preserve amounts without overflow',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(320, 800));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              cashRegisterRepositoryProvider.overrideWith(
                (ref) => _CashFixture(),
              ),
            ],
            child: host(const CashRegisterView(), scale: scale),
          ),
        );
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(
          find.text('Cortes anteriores'),
          300,
          scrollable: verticalScroll,
        );
        await tester.drag(verticalScroll, const Offset(0, -500));
        await tester.pumpAndSettle();
        expect(find.textContaining('12345 órdenes'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('promotions and editor at scale $scale remain reachable', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(320, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            promotionsProvider.overrideWith((ref) => Stream.value([])),
          ],
          child: host(const PromotionsView(), scale: scale),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Nueva promoción'));
      await tester.pumpAndSettle();
      expect(find.text('URL de imagen (opcional)'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.scrollUntilVisible(
        find.text('Cancelar'),
        200,
        scrollable: verticalScroll,
      );
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'shell at scale $scale: five destinations, settings, keyboard and targets',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(320, 800));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final semantics = tester.ensureSemantics();
        final router = GoRouter(
          initialLocation: AppRoutes.salon,
          routes: [
            ShellRoute(
              builder: (_, _, child) => MainShell(child: child),
              routes: [
                for (final path in [
                  AppRoutes.salon,
                  AppRoutes.inventory,
                  AppRoutes.loyaltyQr,
                  AppRoutes.employees,
                  AppRoutes.promotions,
                ])
                  GoRoute(
                    path: path,
                    builder: (_, _) => const SingleChildScrollView(
                      child: ExquisssitaEmptyState(
                        message: 'Contenido del ejemplo',
                      ),
                    ),
                  ),
              ],
            ),
          ],
        );
        addTearDown(router.dispose);
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              currentUserProvider.overrideWith((ref) => null),
              currentUserRoleProvider.overrideWith(
                (ref) async => AppRole.employee,
              ),
            ],
            child: MaterialApp.router(
              theme: AppTheme.lightTheme,
              routerConfig: router,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(scale)),
                child: child!,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        for (final label in [
          'Mesas',
          'Menú',
          'Escanear QR',
          'Equipo',
          'Promos',
        ]) {
          expect(find.bySemanticsLabel(label), findsOneWidget);
        }
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await tester.tap(find.byKey(const Key('settings_button')));
        await tester.pumpAndSettle();
        expect(find.text('Más opciones'), findsOneWidget);
        expect(find.text('Galería Exquisssita'), findsOneWidget);
        final root = tester
            .binding
            .renderViews
            .single
            .owner!
            .semanticsOwner!
            .rootSemanticsNode!;
        expect(
          hasSemanticLabel(root, 'Mesas'),
          isFalse,
        ); // sheet isolates underlying controls
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        semantics.dispose();
      },
    );
  }

  testWidgets('debug gallery retains authentication guard', (tester) async {
    final container = ProviderContainer(
      overrides: [authStateProvider.overrideWith((ref) => Stream.value(null))],
    );
    addTearDown(container.dispose);
    final router = container.read(appRouterProvider);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          theme: AppTheme.lightTheme,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
    router.go(AppRoutes.designGallery);
    await tester.pumpAndSettle();
    expect(find.byType(LoginView), findsOneWidget);
    expect(find.text('Hecho para el turno'), findsNothing);
  });
}
