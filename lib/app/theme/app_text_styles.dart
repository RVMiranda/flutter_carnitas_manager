import 'package:flutter/material.dart';

/// Estilos de texto de la aplicación.
///
/// Usa las fuentes bundleadas:
/// - Fraunces (serif) → títulos de pantalla y display
/// - Outfit (sans-serif) → todo el resto de la UI
abstract final class AppTextStyles {
  // ── Familia de fuentes ────────────────────────────────────────────────────

  static const String _serif = 'Fraunces';
  static const String _sans = 'Outfit';

  // ── Display / Títulos de pantalla (Fraunces serif) ────────────────────────

  /// Título principal de cada pantalla. Ejemplo: "Salón", "Menú e Inventario"
  static const displayLarge = TextStyle(
    fontFamily: _serif,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: -0.3,
  );

  static const displayMedium = TextStyle(
    fontFamily: _serif,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static const displaySmall = TextStyle(
    fontFamily: _serif,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  // ── Cuerpo / UI (Outfit sans-serif) ──────────────────────────────────────

  static const bodyLarge = TextStyle(
    fontFamily: _sans,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const bodyMedium = TextStyle(
    fontFamily: _sans,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const bodySmall = TextStyle(
    fontFamily: _sans,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  // ── Labels / Etiquetas ────────────────────────────────────────────────────

  static const labelLarge = TextStyle(
    fontFamily: _sans,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const labelMedium = TextStyle(
    fontFamily: _sans,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.1,
  );

  static const labelSmall = TextStyle(
    fontFamily: _sans,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0.2,
  );

  // ── Moneda / Números tabulares ────────────────────────────────────────────

  static const currencyLarge = TextStyle(
    fontFamily: _sans,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const currencyMedium = TextStyle(
    fontFamily: _sans,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const currencySmall = TextStyle(
    fontFamily: _sans,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  // ── Navegación ────────────────────────────────────────────────────────────

  static const navLabel = TextStyle(
    fontFamily: _sans,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );

  // ── Botones ───────────────────────────────────────────────────────────────

  static const buttonLarge = TextStyle(
    fontFamily: _sans,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  static const buttonMedium = TextStyle(
    fontFamily: _sans,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );
}
