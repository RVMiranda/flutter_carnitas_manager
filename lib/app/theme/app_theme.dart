import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:exquisssita_manager/app/theme/app_colors.dart';
import 'package:exquisssita_manager/app/theme/app_text_styles.dart';

/// Sistema de tema completo de Exquisssita Manager.
///
/// Soporta modo claro y oscuro. Los valores son coherentes con
/// design_example/index.css y DESIGN_PROMPT.md.
abstract final class AppTheme {
  // ── Constantes de forma ───────────────────────────────────────────────────

  /// Radio estándar para tarjetas y contenedores
  static const double radiusCard = 18.0;

  /// Radio para botones
  static const double radiusButton = 14.0;

  /// Radio para chips y badges
  static const double radiusChip = 24.0;

  /// Radio para el nav bar pill
  static const double radiusNav = 28.0;

  /// Radio grande para bottom sheets
  static const double radiusBottomSheet = 24.0;

  // ── Espaciado ────────────────────────────────────────────────────────────

  static const double spacingXs = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 12.0;
  static const double spacingL = 16.0;
  static const double spacingXl = 20.0;
  static const double spacingXxl = 24.0;

  // ── Elevaciones ───────────────────────────────────────────────────────────

  static const double elevationCard = 2.0;
  static const double elevationNav = 8.0;
  static const double elevationFab = 6.0;

  // ─────────────────────────────────────────────────────────────────────────
  // TEMA CLARO
  // ─────────────────────────────────────────────────────────────────────────

  static ThemeData get lightTheme {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.lightPrimary,
      onPrimary: AppColors.lightPrimaryForeground,
      primaryContainer: AppColors.lightSecondary,
      onPrimaryContainer: AppColors.lightForeground,
      secondary: AppColors.lightAccent,
      onSecondary: AppColors.lightAccentForeground,
      secondaryContainer: AppColors.lightSecondary,
      onSecondaryContainer: AppColors.lightForeground,
      tertiary: AppColors.lightAccent,
      onTertiary: AppColors.lightAccentForeground,
      error: AppColors.lightPrimary,
      onError: AppColors.lightPrimaryForeground,
      surface: AppColors.lightCard,
      onSurface: AppColors.lightForeground,
      surfaceContainerLow: AppColors.lightCard,
      surfaceContainerHighest: AppColors.lightMuted,
      outline: AppColors.lightBorder,
      outlineVariant: AppColors.lightBorder,
      shadow: Color(0x0F000000),
      scrim: Color(0x66000000),
      inverseSurface: AppColors.lightForeground,
      onInverseSurface: AppColors.lightCard,
      inversePrimary: AppColors.lightPrimary,
    );

    return _buildTheme(
      colorScheme: colorScheme,
      scaffoldBg: AppColors.lightBackground,
      cardBg: AppColors.lightCard,
      foreground: AppColors.lightForeground,
      mutedFg: AppColors.lightMutedForeground,
      border: AppColors.lightBorder,
      brightness: Brightness.light,
      systemUiStyle: SystemUiOverlayStyle.dark,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TEMA OSCURO
  // ─────────────────────────────────────────────────────────────────────────

  static ThemeData get darkTheme {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.darkPrimary,
      onPrimary: AppColors.darkPrimaryForeground,
      primaryContainer: AppColors.darkSecondary,
      onPrimaryContainer: AppColors.darkForeground,
      secondary: AppColors.darkAccent,
      onSecondary: AppColors.darkAccentForeground,
      secondaryContainer: AppColors.darkSecondary,
      onSecondaryContainer: AppColors.darkForeground,
      tertiary: AppColors.darkAccent,
      onTertiary: AppColors.darkAccentForeground,
      error: AppColors.darkPrimary,
      onError: AppColors.darkPrimaryForeground,
      surface: AppColors.darkCard,
      onSurface: AppColors.darkForeground,
      surfaceContainerLow: AppColors.darkCard,
      surfaceContainerHighest: AppColors.darkMuted,
      outline: AppColors.darkBorder,
      outlineVariant: AppColors.darkBorder,
      shadow: Color(0x3F000000),
      scrim: Color(0x80000000),
      inverseSurface: AppColors.darkForeground,
      onInverseSurface: AppColors.darkCard,
      inversePrimary: AppColors.darkPrimary,
    );

    return _buildTheme(
      colorScheme: colorScheme,
      scaffoldBg: AppColors.darkBackground,
      cardBg: AppColors.darkCard,
      foreground: AppColors.darkForeground,
      mutedFg: AppColors.darkMutedForeground,
      border: AppColors.darkBorder,
      brightness: Brightness.dark,
      systemUiStyle: SystemUiOverlayStyle.light,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILDER PRIVADO
  // ─────────────────────────────────────────────────────────────────────────

  static ThemeData _buildTheme({
    required ColorScheme colorScheme,
    required Color scaffoldBg,
    required Color cardBg,
    required Color foreground,
    required Color mutedFg,
    required Color border,
    required Brightness brightness,
    required SystemUiOverlayStyle systemUiStyle,
  }) {
    const fontFamily = 'Outfit';

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBg,
      fontFamily: fontFamily,

      // ── Tipografía ──────────────────────────────────────────────────────
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge.copyWith(color: foreground),
        displayMedium: AppTextStyles.displayMedium.copyWith(color: foreground),
        displaySmall: AppTextStyles.displaySmall.copyWith(color: foreground),
        headlineLarge: AppTextStyles.displayMedium.copyWith(color: foreground),
        headlineMedium: AppTextStyles.displaySmall.copyWith(color: foreground),
        headlineSmall: AppTextStyles.bodyLarge.copyWith(
          color: foreground,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: AppTextStyles.labelLarge.copyWith(
          color: foreground,
          fontSize: 16,
        ),
        titleMedium: AppTextStyles.labelLarge.copyWith(color: foreground),
        titleSmall: AppTextStyles.labelMedium.copyWith(color: foreground),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: foreground),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: foreground),
        bodySmall: AppTextStyles.bodySmall.copyWith(color: mutedFg),
        labelLarge: AppTextStyles.labelLarge.copyWith(color: foreground),
        labelMedium: AppTextStyles.labelMedium.copyWith(color: mutedFg),
        labelSmall: AppTextStyles.labelSmall.copyWith(color: mutedFg),
      ),

      // ── AppBar ──────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: AppTextStyles.displaySmall.copyWith(color: foreground),
        iconTheme: IconThemeData(color: foreground),
        systemOverlayStyle: systemUiStyle,
      ),

      // ── Tarjetas ─────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: cardBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCard),
        ),
        margin: EdgeInsets.zero,
      ),

      // ── Botones elevados (primarios) ──────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusButton),
          ),
          textStyle: AppTextStyles.buttonLarge,
          minimumSize: const Size(double.infinity, 48),
        ),
      ),

      // ── Botones de texto ──────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: AppTextStyles.buttonMedium,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusButton),
          ),
        ),
      ),

      // ── Botones outlined ─────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: border, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusButton),
          ),
          textStyle: AppTextStyles.buttonMedium,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        ),
      ),

      // ── Campos de texto ──────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: brightness == Brightness.light
            ? AppColors.lightSecondary
            : AppColors.darkSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusButton),
          borderSide: BorderSide(color: border, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusButton),
          borderSide: BorderSide(color: border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusButton),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusButton),
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: mutedFg),
        labelStyle: AppTextStyles.labelMedium.copyWith(color: mutedFg),
      ),

      // ── Divisores ────────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 0),

      // ── Chips ────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusChip),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        labelStyle: AppTextStyles.labelMedium,
      ),

      // ── Bottom sheet ──────────────────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cardBg,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(radiusBottomSheet),
          ),
        ),
        elevation: 0,
      ),

      // ── FAB ───────────────────────────────────────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: elevationFab,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // ── Snackbars ─────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: Colors.white,
        ),
      ),

      // ── Progress indicators ────────────────────────────────────────────
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        circularTrackColor: border,
        linearTrackColor: border,
        borderRadius: const BorderRadius.all(Radius.circular(4)),
      ),

      // ── ListTile ──────────────────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        tileColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCard),
        ),
      ),
    );
  }
}
