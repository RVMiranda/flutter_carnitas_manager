import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// Shipped Exquisssita primitives. Widgets read only `context.exq`.
@immutable
class ExquisssitaMetrics {
  const ExquisssitaMetrics();
  final double hairline = 1, focusWidth = 2, lineWidth = 1.5;
  final double spaceXxs = 2,
      spaceXs = 4,
      spaceS = 8,
      spaceM = 12,
      spaceL = 16,
      spaceXl = 20,
      spaceXxl = 24,
      section = 48;
  final double radiusCard = 18,
      radiusButton = 14,
      radiusChip = 24,
      radiusNav = 28,
      radiusSheet = 24,
      radiusSmall = 12;
  final double elevationCard = 2, elevationNav = 8, elevationFab = 6;
  final double target = 48,
      iconSmall = 18,
      icon = 22,
      iconLarge = 32,
      qrAction = 56,
      logo = 64,
      navMinHeight = 68,
      image = 56;
  final double sheetFraction = .8;
  final double contentMax = 640,
      dialogMax = 560,
      compactWidth = 600,
      scannerMax = 260,
      skeletonHeight = 20,
      shadowBlur = 20;
  final double pressedScale = .98, pressedOpacity = .86, disabledOpacity = .5;
  final Duration press = const Duration(milliseconds: 90),
      release = const Duration(milliseconds: 150),
      transition = const Duration(milliseconds: 200);
  final Curve easing = Curves.easeOutCubic;
}

@immutable
class ExquisssitaTokens extends ThemeExtension<ExquisssitaTokens> {
  const ExquisssitaTokens({
    required this.background,
    required this.foreground,
    required this.card,
    required this.primary,
    required this.onPrimary,
    required this.secondary,
    required this.muted,
    required this.mutedForeground,
    required this.accent,
    required this.onAccent,
    required this.border,
    required this.focus,
    required this.actionBackground,
    required this.actionForeground,
    required this.text,
    required this.shadow,
    required this.scrim,
  });
  final Color background,
      foreground,
      card,
      primary,
      onPrimary,
      secondary,
      muted,
      mutedForeground,
      accent,
      onAccent,
      border,
      focus,
      actionBackground,
      actionForeground,
      shadow,
      scrim;
  final TextTheme text;
  ExquisssitaMetrics get metrics => const ExquisssitaMetrics();
  Color get textSecondary =>
      foreground; // Original muted gray fails small-text AA in light.
  Color get transparent => Colors.transparent;
  TextStyle get heading => text.displayMedium!;
  TextStyle get body => text.bodyMedium!;
  TextStyle get label => text.labelLarge!;
  TextStyle get caption => text.labelSmall!;
  TextStyle get button =>
      AppTextStyles.accessibleAction.copyWith(color: actionForeground);
  TextStyle get currency =>
      AppTextStyles.currencyLarge.copyWith(color: foreground);
  TextStyle get currencySmall =>
      AppTextStyles.currencyMedium.copyWith(color: foreground);
  List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: shadow,
      blurRadius: metrics.shadowBlur,
      offset: Offset(0, metrics.elevationCard),
    ),
  ];
  List<BoxShadow> get navShadow => [
    BoxShadow(
      color: shadow,
      blurRadius: metrics.shadowBlur,
      offset: Offset(0, metrics.elevationNav),
    ),
  ];

  factory ExquisssitaTokens.forBrightness(
    Brightness brightness, {
    bool highContrast = false,
  }) {
    final dark = brightness == Brightness.dark;
    final foreground = dark
        ? AppColors.darkForeground
        : AppColors.lightForeground;
    final card = dark ? AppColors.darkCard : AppColors.lightCard;
    final primary = dark ? AppColors.darkPrimary : AppColors.lightPrimary;
    return ExquisssitaTokens(
      background: dark ? AppColors.darkBackground : AppColors.lightBackground,
      foreground: foreground,
      card: card,
      primary: primary,
      onPrimary: dark
          ? AppColors.lightForeground
          : AppColors.lightPrimaryForeground,
      secondary: dark ? AppColors.darkSecondary : AppColors.lightSecondary,
      muted: dark ? AppColors.darkMuted : AppColors.lightMuted,
      mutedForeground: dark
          ? AppColors.darkMutedForeground
          : AppColors.lightMutedForeground,
      accent: AppColors.lightAccent,
      onAccent: dark
          ? AppColors.darkAccentForeground
          : AppColors.lightAccentForeground,
      border: highContrast
          ? foreground
          : dark
          ? AppColors.darkBorder
          : AppColors.lightBorder,
      focus: foreground,
      actionBackground: highContrast ? foreground : primary,
      actionForeground: highContrast
          ? card
          : dark
          ? AppColors.lightForeground
          : AppColors.lightPrimaryForeground,
      shadow: Colors.black.withAlpha(dark ? 63 : 15),
      scrim: Colors.black.withAlpha(dark ? 128 : 102),
      text: TextTheme(
        displayLarge: AppTextStyles.displayLarge.copyWith(color: foreground),
        displayMedium: AppTextStyles.displayMedium.copyWith(color: foreground),
        displaySmall: AppTextStyles.displaySmall.copyWith(color: foreground),
        titleLarge: AppTextStyles.bodyLarge.copyWith(
          color: foreground,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: AppTextStyles.labelLarge.copyWith(color: foreground),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: foreground),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: foreground),
        bodySmall: AppTextStyles.bodySmall.copyWith(color: foreground),
        labelLarge: AppTextStyles.labelLarge.copyWith(color: foreground),
        labelMedium: AppTextStyles.labelMedium.copyWith(color: foreground),
        labelSmall: AppTextStyles.labelSmall.copyWith(color: foreground),
      ),
    );
  }
  @override
  ExquisssitaTokens copyWith({
    Color? background,
    Color? foreground,
    Color? card,
    Color? primary,
    Color? onPrimary,
    Color? secondary,
    Color? muted,
    Color? mutedForeground,
    Color? accent,
    Color? onAccent,
    Color? border,
    Color? focus,
    Color? actionBackground,
    Color? actionForeground,
    TextTheme? text,
    Color? shadow,
    Color? scrim,
  }) => ExquisssitaTokens(
    background: background ?? this.background,
    foreground: foreground ?? this.foreground,
    card: card ?? this.card,
    primary: primary ?? this.primary,
    onPrimary: onPrimary ?? this.onPrimary,
    secondary: secondary ?? this.secondary,
    muted: muted ?? this.muted,
    mutedForeground: mutedForeground ?? this.mutedForeground,
    accent: accent ?? this.accent,
    onAccent: onAccent ?? this.onAccent,
    border: border ?? this.border,
    focus: focus ?? this.focus,
    actionBackground: actionBackground ?? this.actionBackground,
    actionForeground: actionForeground ?? this.actionForeground,
    text: text ?? this.text,
    shadow: shadow ?? this.shadow,
    scrim: scrim ?? this.scrim,
  );
  @override
  ExquisssitaTokens lerp(covariant ExquisssitaTokens? other, double t) {
    if (other == null) return this;
    return copyWith(
      background: Color.lerp(background, other.background, t),
      foreground: Color.lerp(foreground, other.foreground, t),
      card: Color.lerp(card, other.card, t),
      primary: Color.lerp(primary, other.primary, t),
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t),
      secondary: Color.lerp(secondary, other.secondary, t),
      muted: Color.lerp(muted, other.muted, t),
      mutedForeground: Color.lerp(mutedForeground, other.mutedForeground, t),
      accent: Color.lerp(accent, other.accent, t),
      onAccent: Color.lerp(onAccent, other.onAccent, t),
      border: Color.lerp(border, other.border, t),
      focus: Color.lerp(focus, other.focus, t),
      actionBackground: Color.lerp(actionBackground, other.actionBackground, t),
      actionForeground: Color.lerp(actionForeground, other.actionForeground, t),
      text: TextTheme.lerp(text, other.text, t),
      shadow: Color.lerp(shadow, other.shadow, t),
      scrim: Color.lerp(scrim, other.scrim, t),
    );
  }
}

extension ExquisssitaThemeAccess on BuildContext {
  ExquisssitaTokens get exq {
    final tokens = Theme.of(this).extension<ExquisssitaTokens>();
    assert(
      tokens != null,
      'Mount AppTheme before building branded components.',
    );
    return tokens!;
  }
}

/// Includes Android animations, assistive navigation and iOS Reduce Motion.
bool exquisssitaReducedMotion(BuildContext context) =>
    MediaQuery.disableAnimationsOf(context) ||
    MediaQuery.accessibleNavigationOf(context) ||
    exquisssitaPlatformReducedMotion;

bool get exquisssitaPlatformReducedMotion {
  final features =
      WidgetsBinding.instance.platformDispatcher.accessibilityFeatures;
  return features.reduceMotion ||
      features.disableAnimations ||
      features.accessibleNavigation;
}
