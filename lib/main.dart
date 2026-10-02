import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:exquisssita_manager/app/app.dart';
import 'package:exquisssita_manager/core/logging/app_logger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── 1. Cargar variables de entorno ──────────────────────────────────────
  await dotenv.load();

  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

  if (supabaseUrl == null ||
      supabaseUrl.isEmpty ||
      supabaseAnonKey == null ||
      supabaseAnonKey.isEmpty) {
    throw Exception(
      'Las variables SUPABASE_URL y SUPABASE_ANON_KEY no están configuradas en .env\n'
      'Copia .env.example a .env y rellena los valores.',
    );
  }

  // ── 2. Inicializar Supabase ─────────────────────────────────────────────
  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabaseAnonKey,
    debug: false,
  );
  AppLogger.info('Supabase inicializado', tag: 'Bootstrap');

  // ── 3. Inicializar localización (fechas en español) ─────────────────────
  await initializeDateFormatting('es_MX');

  // ── 4. Arrancar la app con Riverpod ────────────────────────────────────
  runApp(
    ProviderScope(
      observers: [_AppProviderObserver()],
      child: const ExquisssitaApp(),
    ),
  );
}

/// Observer de Riverpod para debug de providers.
///
/// Solo loguea en modo debug. No loguea valores de providers sensibles.
class _AppProviderObserver extends ProviderObserver {
  @override
  void didAddProvider(
    ProviderBase<Object?> provider,
    Object? value,
    ProviderContainer container,
  ) {
    AppLogger.debug(
      'Provider añadido: ${provider.name ?? provider.runtimeType}',
      tag: 'Riverpod',
    );
  }

  @override
  void providerDidFail(
    ProviderBase<Object?> provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    AppLogger.error(
      'Provider falló: ${provider.name ?? provider.runtimeType}',
      tag: 'Riverpod',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
