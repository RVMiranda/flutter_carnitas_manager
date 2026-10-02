import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:exquisssita_manager/app/router/app_router.dart';
import 'package:exquisssita_manager/app/theme/app_colors.dart';
import 'package:exquisssita_manager/app/theme/app_text_styles.dart';
import 'package:exquisssita_manager/app/theme/app_theme.dart';
import 'package:exquisssita_manager/features/auth/presentation/view_models/auth_vm.dart';
import 'package:exquisssita_manager/shared/navigation/settings_bottom_sheet.dart';
import 'package:exquisssita_manager/app/theme/theme_controller.dart';

/// Shell principal que envuelve todas las pantallas con:
/// - Top bar (fecha + nombre del empleado + acciones)
/// - Bottom navigation pill flotante
/// - Banner de estado offline
class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  // ── Índice del tab activo ───────────────────────────────────────────────

  static const _routes = [
    AppRoutes.salon,
    AppRoutes.inventory,
    AppRoutes.loyaltyQr,
    AppRoutes.employees,
    AppRoutes.promotions,
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final idx = _routes.indexWhere((r) => location.startsWith(r));
    return idx < 0 ? 0 : idx;
  }

  void _onTabTap(int index, BuildContext context) {
    if (index == _currentIndex(context)) return;
    context.go(_routes[index]);
  }

  // ── Fecha formateada ────────────────────────────────────────────────────

  String get _formattedDate {
    final now = DateTime.now();
    final formatted = DateFormat('EEEE, d \'de\' MMMM', 'es_MX').format(now);
    return '${formatted[0].toUpperCase()}${formatted.substring(1)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentUser = ref.watch(currentUserProvider);
    final roleState = ref.watch(currentUserRoleProvider);
    final currentRole = roleState.valueOrNull ?? AppRole.employee;
    final userName =
        currentUser?.userMetadata?['nombre'] as String? ?? 'Empleado';
    final roleLabel = currentRole == AppRole.admin
        ? 'Administrador'
        : 'Empleado';

    return Scaffold(
      body: Column(
        children: [
          // ── Top Bar ───────────────────────────────────────────────────────
          _TopBar(
            date: _formattedDate,
            userName: userName,
            role: currentRole,
            roleLabel: roleLabel,
            isDark: isDark,
            onSettingsTap: () => _showSettings(context),
            onThemeToggle: () {
              final current = ref.read(themeModeProvider);
              ref.read(themeModeProvider.notifier).state =
                  current == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
            },
          ),

          // ── Contenido de la pantalla ───────────────────────────────────
          Expanded(child: widget.child),
        ],
      ),

      // ── Bottom Navigation Pill ───────────────────────────────────────────
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Builder(
        builder: (context) {
          final index = _currentIndex(context);
          return _PillNavBar(
            currentIndex: index,
            isDark: isDark,
            onTap: (i) => _onTabTap(i, context),
          );
        },
      ),
    );
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SettingsBottomSheet(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Top Bar
// ─────────────────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.date,
    required this.userName,
    required this.role,
    required this.roleLabel,
    required this.isDark,
    required this.onSettingsTap,
    required this.onThemeToggle,
  });

  final String date;
  final String userName;
  final AppRole role;
  final String roleLabel;
  final bool isDark;
  final VoidCallback onSettingsTap;
  final VoidCallback onThemeToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppTheme.spacingXl,
          AppTheme.spacingM,
          AppTheme.spacingXl,
          AppTheme.spacingS,
        ),
        child: Row(
          children: [
            // ── Fecha y saludo ─────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    date,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isDark
                          ? AppColors.darkMutedForeground
                          : AppColors.lightMutedForeground,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Hola, $userName 👋',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    roleLabel,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: role == AppRole.admin
                          ? Colors.amber
                          : theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),

            // ── Toggle de tema ─────────────────────────────────────────────
            _TopBarButton(
              onTap: onThemeToggle,
              child: Text(
                isDark ? '☀️' : '🌙',
                style: const TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(width: AppTheme.spacingS),

            // ── Botón de ajustes ───────────────────────────────────────────
            _TopBarButton(
              key: const Key('settings_button'),
              onTap: onSettingsTap,
              child: Icon(
                Icons.settings_outlined,
                size: 18,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBarButton extends StatelessWidget {
  const _TopBarButton({super.key, required this.onTap, required this.child});
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 40 : 15),
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pill Navigation Bar
// ─────────────────────────────────────────────────────────────────────────────

class _PillNavBar extends StatelessWidget {
  const _PillNavBar({
    required this.currentIndex,
    required this.isDark,
    required this.onTap,
  });

  final int currentIndex;
  final bool isDark;
  final ValueChanged<int> onTap;

  static const _tabs = [
    _NavTab(icon: _TablesIcon(), label: 'Mesas', isCenter: false),
    _NavTab(icon: _MenuIcon(), label: 'Menú', isCenter: false),
    _NavTab(icon: _QrIcon(), label: 'QR', isCenter: true),
    _NavTab(icon: _EmployeesIcon(), label: 'Equipo', isCenter: false),
    _NavTab(icon: _PromosIcon(), label: 'Promos', isCenter: false),
  ];

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark
        ? const Color(0xF51A2337) // rgba(26,35,55,0.96)
        : const Color(0xF5FFFFFF); // rgba(255,255,255,0.96)

    final shadowColor = isDark
        ? const Color(0x80000000)
        : const Color(0x24000000);

    return Padding(
      padding: EdgeInsets.only(
        left: AppTheme.spacingM,
        right: AppTheme.spacingM,
        bottom: MediaQuery.paddingOf(context).bottom + AppTheme.spacingS,
        top: AppTheme.spacingXs,
      ),
      child: Container(
        height: 68,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusNav),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 32,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: (isDark ? Colors.white : Colors.black).withAlpha(10),
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_tabs.length, (i) {
            final tab = _tabs[i];
            final isActive = i == currentIndex;

            if (tab.isCenter) {
              return _CenterNavItem(
                icon: tab.icon,
                label: tab.label,
                isActive: isActive,
                onTap: () => onTap(i),
              );
            }

            return _RegularNavItem(
              icon: tab.icon,
              label: tab.label,
              isActive: isActive,
              isDark: isDark,
              onTap: () => onTap(i),
            );
          }),
        ),
      ),
    );
  }
}

class _NavTab {
  const _NavTab({
    required this.icon,
    required this.label,
    required this.isCenter,
  });
  final Widget icon;
  final String label;
  final bool isCenter;
}

class _RegularNavItem extends StatelessWidget {
  const _RegularNavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.isDark,
    required this.onTap,
  });

  final Widget icon;
  final String label;
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = theme.colorScheme.primary;
    final mutedColor = isDark
        ? AppColors.darkMutedForeground
        : AppColors.lightMutedForeground;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: isActive ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ColorFiltered(
                colorFilter: ColorFilter.mode(
                  isActive ? activeColor : mutedColor,
                  BlendMode.srcIn,
                ),
                child: icon,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: AppTextStyles.navLabel.copyWith(
                  color: isActive ? activeColor : mutedColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CenterNavItem extends StatelessWidget {
  const _CenterNavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final Widget icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isActive ? AppColors.lightAccent : theme.colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Transform.translate(
        offset: const Offset(0, -12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withAlpha(100),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: ColorFiltered(
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                  child: icon,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.navLabel.copyWith(
                color: isActive
                    ? AppColors.lightAccent
                    : AppColors.lightMutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Íconos SVG del nav bar (adaptados de design_example/app.tsx)
// ─────────────────────────────────────────────────────────────────────────────

class _TablesIcon extends StatelessWidget {
  const _TablesIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(22, 22), painter: _TablesPainter());
  }
}

class _TablesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final s = size.width / 24;
    // Mesa (rect horizontal superior)
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(3 * s, 7 * s, 18 * s, 3 * s),
      const Radius.circular(1.5),
    );
    canvas.drawRRect(rect, paint);
    // Patas
    canvas.drawLine(Offset(7 * s, 10 * s), Offset(7 * s, 18 * s), paint);
    canvas.drawLine(Offset(17 * s, 10 * s), Offset(17 * s, 18 * s), paint);
    canvas.drawLine(Offset(5 * s, 18 * s), Offset(19 * s, 18 * s), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MenuIcon extends StatelessWidget {
  const _MenuIcon();

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.menu_book_outlined, size: 22);
  }
}

class _QrIcon extends StatelessWidget {
  const _QrIcon();

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.qr_code_scanner_rounded, size: 24);
  }
}

class _EmployeesIcon extends StatelessWidget {
  const _EmployeesIcon();

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.people_outline_rounded, size: 22);
  }
}

class _PromosIcon extends StatelessWidget {
  const _PromosIcon();

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.star_outline_rounded, size: 22);
  }
}
