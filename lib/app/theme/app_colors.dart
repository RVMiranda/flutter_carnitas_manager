import 'package:flutter/material.dart';

/// Paleta de colores de Exquisssita Manager.
///
/// Extraída exactamente del design_example/index.css.
/// Usar estas constantes en toda la aplicación. Nunca hardcodear colores.
abstract final class AppColors {
  // ── Modo Claro ──────────────────────────────────────────────────────────────

  /// Fondo principal: salmón pastel muy tenue (casi crema)
  static const lightBackground = Color(0xFFFDF5EF);

  /// Texto principal: Azul marino oscuro
  static const lightForeground = Color(0xFF1A2744);

  /// Tarjetas / superficies: Blanco puro
  static const lightCard = Color(0xFFFFFFFF);

  /// Color primario: Rojo lona
  static const lightPrimary = Color(0xFFD94F3D);

  /// Texto sobre primario
  static const lightPrimaryForeground = Color(0xFFFFFFFF);

  /// Fondo secundario: salmón muy suave
  static const lightSecondary = Color(0xFFFBE9DF);

  /// Texto sobre secundario
  static const lightSecondaryForeground = Color(0xFF1A2744);

  /// Superficies apagadas
  static const lightMuted = Color(0xFFF5EBE4);

  /// Texto apagado / subtítulos
  static const lightMutedForeground = Color(0xFF6B7A99);

  /// Acento: Amarillo cálido (botón QR central, highlights)
  static const lightAccent = Color(0xFFF5A623);

  /// Texto sobre acento
  static const lightAccentForeground = Color(0xFF1A2744);

  /// Color de borde
  static const lightBorder = Color(0x1A1A2744); // rgba(26,39,68,0.1)

  // ── Modo Oscuro ─────────────────────────────────────────────────────────────

  /// Fondo principal: Azul medianoche
  static const darkBackground = Color(0xFF0F1523);

  /// Texto principal: Blanco ahumado
  static const darkForeground = Color(0xFFE8E4DF);

  /// Tarjetas / superficies
  static const darkCard = Color(0xFF1A2337);

  /// Color primario (más brillante para modo oscuro)
  static const darkPrimary = Color(0xFFE8715A);

  /// Texto sobre primario
  static const darkPrimaryForeground = Color(0xFFFFFFFF);

  /// Fondo secundario
  static const darkSecondary = Color(0xFF1E2D45);

  /// Texto sobre secundario
  static const darkSecondaryForeground = Color(0xFFE8E4DF);

  /// Superficies apagadas
  static const darkMuted = Color(0xFF16213A);

  /// Texto apagado / subtítulos
  static const darkMutedForeground = Color(0xFF8A9BB8);

  /// Acento (igual en ambos modos)
  static const darkAccent = Color(0xFFF5A623);

  /// Texto sobre acento en modo oscuro
  static const darkAccentForeground = Color(0xFF0F1523);

  /// Color de borde en modo oscuro
  static const darkBorder = Color(0x1AE8E4DF); // rgba(232,228,223,0.1)

  // ── Colores semánticos (independientes del tema) ──────────────────────────

  /// Verde para stock lleno / estado activo
  static const stockGood = Color(0xFF22C55E);

  /// Amarillo para stock bajo
  static const stockWarning = Color(0xFFF5A623);

  /// Rojo para stock crítico / alerta
  static const stockCritical = Color(0xFFD94F3D);

  /// Verde para estado "Activo" de empleado
  static const activeGreen = Color(0xFF16A34A);

  /// Fondo suave del badge verde
  static const activeBadgeBg = Color(0x1F22C55E); // rgba(34,197,94,0.12)
}
