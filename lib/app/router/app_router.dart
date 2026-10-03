import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:exquisssita_manager/features/auth/presentation/views/login_view.dart';
import 'package:exquisssita_manager/features/auth/presentation/view_models/auth_vm.dart';
import 'package:exquisssita_manager/shared/navigation/main_shell.dart';
import 'package:exquisssita_manager/features/loyalty/presentation/qr_scanner_view.dart';
import 'package:exquisssita_manager/features/promotions/presentation/promotions_view.dart';
import 'package:exquisssita_manager/features/cash_register/presentation/cash_register_view.dart';

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
            builder: (context, state) =>
                const _PlaceholderScreen(title: 'Salón'),
          ),
          GoRoute(
            path: AppRoutes.inventory,
            name: 'inventory',
            builder: (context, state) =>
                const _PlaceholderScreen(title: 'Menú e Inventario'),
          ),
          GoRoute(
            path: AppRoutes.loyaltyQr,
            name: 'loyalty_qr',
            builder: (context, state) => const QrScannerView(),
          ),
          GoRoute(
            path: AppRoutes.employees,
            name: 'employees',
            builder: (context, state) =>
                const _PlaceholderScreen(title: 'Empleados'),
          ),
          GoRoute(
            path: AppRoutes.promotions,
            name: 'promotions',
            builder: (context, state) => const PromotionsView(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.cashRegister,
        name: 'cash_register',
        builder: (context, state) => const CashRegisterView(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Ruta no encontrada: ${state.error}')),
    ),
  );
}

/// Pantalla placeholder para rutas no implementadas aún.
/// Se reemplaza en fases posteriores.
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(title, style: Theme.of(context).textTheme.displayMedium),
    );
  }
}
