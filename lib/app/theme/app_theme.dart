import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:exquisssita_manager/app/theme/app_colors.dart';
import 'exquisssita_tokens.dart';

/// Sistema de tema completo de Exquisssita Manager.
///
/// Soporta modo claro y oscuro. Los valores son coherentes con
/// design_example/index.css y DESIGN_PROMPT.md.
abstract final class AppTheme {
  static const _metrics = ExquisssitaMetrics();
  static ThemeData get highContrastLightTheme => _highContrast(lightTheme);
  static ThemeData get highContrastDarkTheme => _highContrast(darkTheme);
  static ThemeData _highContrast(ThemeData theme) => theme.copyWith(
    extensions: [
      ExquisssitaTokens.forBrightness(theme.brightness, highContrast: true),
    ],
  );
  // ── Constantes de forma ───────────────────────────────────────────────────

  /// Radio estándar para tarjetas y contenedores
  static final double radiusCard = _metrics.radiusCard;

  /// Radio para botones
  static final double radiusButton = _metrics.radiusButton;

  /// Radio para chips y badges
  static final double radiusChip = _metrics.radiusChip;

  /// Radio para el nav bar pill
  static final double radiusNav = _metrics.radiusNav;

  /// Radio grande para bottom sheets
  static final double radiusBottomSheet = _metrics.radiusSheet;

  // ── Espaciado ────────────────────────────────────────────────────────────

  static final double spacingXs = _metrics.spaceXs;
  static final double spacingS = _metrics.spaceS;
  static final double spacingM = _metrics.spaceM;
  static final double spacingL = _metrics.spaceL;
  static final double spacingXl = _metrics.spaceXl;
  static final double spacingXxl = _metrics.spaceXxl;

  // ── Elevaciones ───────────────────────────────────────────────────────────

  static final double elevationCard = _metrics.elevationCard;
  static final double elevationNav = _metrics.elevationNav;
  static final double elevationFab = _metrics.elevationFab;

  // ─────────────────────────────────────────────────────────────────────────
  // TEMA CLARO
  // ─────────────────────────────────────────────────────────────────────────

  static ThemeData get lightTheme {
    final tokens = ExquisssitaTokens.forBrightness(Brightness.light);
    final colorScheme = ColorScheme(
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
      shadow: tokens.shadow,
      scrim: tokens.scrim,
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
    final tokens = ExquisssitaTokens.forBrightness(Brightness.dark);
    final colorScheme = ColorScheme(
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
      shadow: tokens.shadow,
      scrim: tokens.scrim,
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
    final tokens = ExquisssitaTokens.forBrightness(brightness);

    return ThemeData(
      useMaterial3: true,
      extensions: [tokens],
      splashFactory: NoSplash.splashFactory,
      splashColor: tokens.transparent,
      highlightColor: tokens.transparent,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBg,
      fontFamily: tokens.body.fontFamily,

      // ── Tipografía ──────────────────────────────────────────────────────
      textTheme: tokens.text,

      // ── AppBar ──────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: tokens.text.displaySmall,
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
          backgroundColor: tokens.actionBackground,
          foregroundColor: tokens.actionForeground,
          elevation: 0,
          padding: EdgeInsets.symmetric(
            vertical: _metrics.spaceM,
            horizontal: _metrics.spaceXxl,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusButton),
          ),
          textStyle: tokens.button,
          minimumSize: Size(double.infinity, _metrics.target),
        ),
      ),

      // ── Botones de texto ──────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: tokens.foreground,
          textStyle: tokens.label,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusButton),
          ),
        ),
      ),

      // ── Botones outlined ─────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: tokens.foreground,
          side: BorderSide(color: border, width: _metrics.lineWidth),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusButton),
          ),
          textStyle: tokens.label,
          padding: EdgeInsets.symmetric(
            vertical: _metrics.spaceM,
            horizontal: _metrics.spaceXl,
          ),
        ),
      ),

      // ── Campos de texto ──────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: tokens.secondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusButton),
          borderSide: BorderSide(color: border, width: _metrics.lineWidth),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusButton),
          borderSide: BorderSide(color: border, width: _metrics.lineWidth),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusButton),
          borderSide: BorderSide(
            color: tokens.focus,
            width: _metrics.focusWidth,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusButton),
          borderSide: BorderSide(
            color: colorScheme.error,
            width: _metrics.lineWidth,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: _metrics.spaceL,
          vertical: _metrics.spaceM,
        ),
        hintStyle: tokens.body,
        labelStyle: tokens.label,
        floatingLabelStyle: tokens.label,
        errorStyle: tokens.body,
      ),

      // ── Divisores ────────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: border,
        thickness: _metrics.hairline,
        space: 0,
      ),

      // ── Chips ────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusChip),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: _metrics.spaceM,
          vertical: _metrics.spaceS,
        ),
        labelStyle: tokens.label,
      ),

      // ── Bottom sheet ──────────────────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cardBg,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(radiusBottomSheet),
          ),
        ),
        elevation: 0,
      ),

      // ── FAB ───────────────────────────────────────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: tokens.actionBackground,
        foregroundColor: tokens.actionForeground,
        elevation: elevationFab,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_metrics.radiusCard),
        ),
      ),

      // ── Snackbars ─────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_metrics.radiusSmall),
        ),
        backgroundColor: tokens.foreground,
        contentTextStyle: tokens.body.copyWith(color: tokens.card),
      ),

      // ── Progress indicators ────────────────────────────────────────────
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        circularTrackColor: border,
        linearTrackColor: border,
        borderRadius: BorderRadius.all(Radius.circular(_metrics.spaceXs)),
      ),

      // ── ListTile ──────────────────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: _metrics.spaceL,
          vertical: _metrics.spaceXs,
        ),
        tileColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCard),
        ),
      ),
    );
  }
}
