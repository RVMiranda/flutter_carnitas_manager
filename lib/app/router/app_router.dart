import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../shared/widgets/design_gallery.dart';
import '../../shared/widgets/exquisssita_components.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:exquisssita_manager/features/auth/presentation/views/login_view.dart';
import 'package:exquisssita_manager/features/auth/presentation/view_models/auth_vm.dart';
import 'package:exquisssita_manager/shared/navigation/main_shell.dart';
import 'package:exquisssita_manager/features/loyalty/presentation/qr_scanner_view.dart';
import 'package:exquisssita_manager/features/promotions/presentation/promotions_view.dart';
import 'package:exquisssita_manager/features/cash_register/presentation/cash_register_view.dart';
import 'package:exquisssita_manager/features/orders/presentation/orders_view.dart';
import 'package:exquisssita_manager/features/inventory/presentation/inventory_view.dart';
import 'package:exquisssita_manager/features/employees/presentation/employees_view.dart';

part 'app_router.g.dart';

/// Rutas nombradas de la aplicación.
abstract final class AppRoutes {
  static const login = '/login';
  static const home = '/';
  static const salon = '/salon';
  static const inventory = '/inventory';
  static const loyaltyQr = '/qr';
  static const employees = '/employees';
  static const promotions = '/promotions';
  static const cashRegister = '/cash-register';
  static const settings = '/settings';
  static const designGallery = '/design-gallery';
}

@riverpod
GoRouter appRouter(Ref ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isOnLogin = state.matchedLocation == AppRoutes.login;

      // Si no está autenticado y no está en login → redirigir al login
      if (!isLoggedIn && !isOnLogin) return AppRoutes.login;

      // Si está autenticado y está en login → redirigir al home
      if (isLoggedIn && isOnLogin) return AppRoutes.home;

      // Sin redirección
      return null;
    },
    routes: [
      // ── Auth ──────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginView(),
      ),

      // ── Shell principal (con BottomNav) ────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(path: AppRoutes.home, redirect: (_, _) => AppRoutes.salon),
          GoRoute(
            path: AppRoutes.salon,
            name: 'salon',
            builder: (context, state) => const OrdersView(),
          ),
          GoRoute(
            path: AppRoutes.inventory,
            name: 'inventory',
            builder: (context, state) => const InventoryView(),
          ),
          GoRoute(
            path: AppRoutes.loyaltyQr,
            name: 'loyalty_qr',
            builder: (context, state) => const QrScannerView(),
          ),
          GoRoute(
            path: AppRoutes.employees,
            name: 'employees',
            builder: (context, state) => const EmployeesView(),
          ),
          GoRoute(
            path: AppRoutes.promotions,
            name: 'promotions',
            builder: (context, state) => const PromotionsView(),
          ),
        ],
      ),
      if (kDebugMode)
        GoRoute(
          path: AppRoutes.designGallery,
          builder: (_, _) => const DesignGalleryView(),
        ),
      GoRoute(
        path: AppRoutes.cashRegister,
        name: 'cash_register',
        builder: (context, state) => const CashRegisterView(),
      ),
    ],
    errorBuilder: (context, state) => const Scaffold(
      body: Center(
        child: ExquisssitaErrorState(message: 'No se encontró esta pantalla.'),
      ),
    ),
  );
}
