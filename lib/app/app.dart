import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:exquisssita_manager/app/router/app_router.dart';
import 'package:exquisssita_manager/app/theme/app_theme.dart';
import 'package:exquisssita_manager/data/sync/sync_worker.dart';
import 'package:exquisssita_manager/app/theme/theme_controller.dart';

/// Widget raíz de la aplicación Exquisssita Manager.
///
/// Configura:
/// - Tema visual (light + dark, con soporte de cambio dinámico)
/// - GoRouter como motor de navegación declarativa
/// - Inicialización del SyncWorker en background
class ExquisssitaApp extends ConsumerWidget {
  const ExquisssitaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Inicializar SyncWorker (keep-alive, persiste durante toda la sesión)
    ref.watch(syncWorkerProvider);

    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Exquisssita Manager',
      debugShowCheckedModeBanner: false,

      // ── Tema ───────────────────────────────────────────────────────────
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,

      // ── Router ─────────────────────────────────────────────────────────
      routerConfig: router,

      // ── Localización ────────────────────────────────────────────────────
      locale: const Locale('es', 'MX'),
    );
  }
}
