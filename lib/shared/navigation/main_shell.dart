import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:exquisssita_manager/app/router/app_router.dart';
import 'package:exquisssita_manager/app/theme/exquisssita_tokens.dart';
import 'package:exquisssita_manager/shared/widgets/exquisssita_components.dart';
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

class _GoToIntent extends Intent {
  const _GoToIntent(this.index);
  final int index;
}

class _ShellContent extends StatelessWidget {
  const _ShellContent({
    required this.userName,
    required this.role,
    required this.roleLabel,
    required this.date,
    required this.isDark,
    required this.onSettingsTap,
    required this.onThemeToggle,
    required this.child,
  });
  final Widget child;
  final String userName, roleLabel, date;
  final AppRole role;
  final bool isDark;
  final VoidCallback onSettingsTap, onThemeToggle;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _TopBar(
        date: date,
        userName: userName,
        role: role,
        roleLabel: roleLabel,
        isDark: isDark,
        onSettingsTap: onSettingsTap,
        onThemeToggle: onThemeToggle,
      ),
      Expanded(
        child: SafeArea(
          top: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1280),
              child: SizedBox(width: double.infinity, child: child),
            ),
          ),
        ),
      ),
    ],
  );
}

class _BrandRail extends StatelessWidget {
  const _BrandRail({required this.currentIndex, required this.onTap});
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) => SafeArea(
    right: false,
    child: SizedBox(
      key: const ValueKey('brand-rail'),
      width: 88,
      child: ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Text('E', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Expanded(
              child: _NavItems(
                currentIndex: currentIndex,
                onTap: onTap,
                vertical: true,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _BrandSidebar extends StatelessWidget {
  const _BrandSidebar({
    required this.currentIndex,
    required this.userName,
    required this.roleLabel,
    required this.date,
    required this.onTap,
    required this.onSettingsTap,
  });
  final int currentIndex;
  final String userName, roleLabel, date;
  final ValueChanged<int> onTap;
  final VoidCallback onSettingsTap;

  @override
  Widget build(BuildContext context) => SafeArea(
    right: false,
    child: SizedBox(
      key: const ValueKey('brand-sidebar'),
      width: 264,
      child: ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('EXQUISSITA', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(date, style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 20),
              Expanded(child: _NavItems(currentIndex: currentIndex, onTap: onTap)),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(child: Icon(Icons.person_outline)),
                title: Text(userName, overflow: TextOverflow.ellipsis),
                subtitle: Text(roleLabel),
              ),
              IconButton(
                key: const ValueKey('sidebar-settings'),
                tooltip: 'Configuración',
                onPressed: onSettingsTap,
                icon: const Icon(Icons.settings_outlined),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _NavItems extends StatelessWidget {
  const _NavItems({required this.currentIndex, required this.onTap, this.vertical = false});
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool vertical;
  static const _labels = ['Mesas', 'Menú', 'QR', 'Equipo', 'Promos'];
  static const _icons = [
    Icons.table_restaurant_outlined,
    Icons.menu_book_outlined,
    Icons.qr_code_scanner_rounded,
    Icons.people_outline_rounded,
    Icons.star_outline_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final items = List.generate(_labels.length, (index) {
      final selected = currentIndex == index;
      return Semantics(
        button: true,
        selected: selected,
        label: _labels[index],
        child: FocusableActionDetector(
          shortcuts: const <ShortcutActivator, Intent>{},
          child: InkWell(
            key: ValueKey('nav-${_labels[index].toLowerCase()}'),
            onTap: () => onTap(index),
            child: Container(
              constraints: const BoxConstraints(minHeight: 52, minWidth: 52),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? Theme.of(context).colorScheme.secondaryContainer : null,
                borderRadius: BorderRadius.circular(14),
              ),
              child: vertical
                  ? Column(mainAxisSize: MainAxisSize.min, children: [Icon(_icons[index]), Text(_labels[index], style: Theme.of(context).textTheme.labelSmall)])
                  : Row(children: [Icon(_icons[index]), const SizedBox(width: 12), Text(_labels[index])]),
            ),
          ),
        ),
      );
    });
    return vertical ? ListView(children: items) : ListView(children: items);
  }
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
    final location = GoRouter.maybeOf(context)?.state.matchedLocation ?? '';
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

    void themeToggle() {
      final current = ref.read(themeModeProvider);
      ref.read(themeModeProvider.notifier).state =
          current == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    }
    final index = _currentIndex(context);
    return Shortcuts(
      shortcuts: <ShortcutActivator, Intent>{
        const SingleActivator(LogicalKeyboardKey.digit1): const _GoToIntent(0),
        const SingleActivator(LogicalKeyboardKey.digit2): const _GoToIntent(1),
        const SingleActivator(LogicalKeyboardKey.digit3): const _GoToIntent(2),
        const SingleActivator(LogicalKeyboardKey.digit4): const _GoToIntent(3),
        const SingleActivator(LogicalKeyboardKey.digit5): const _GoToIntent(4),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _GoToIntent: CallbackAction<_GoToIntent>(
            onInvoke: (intent) {
              _onTabTap(intent.index, context);
              return null;
            },
          ),
        },
        child: FocusTraversalGroup(
          policy: ReadingOrderTraversalPolicy(),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final content = _ShellContent(
                userName: userName,
                role: currentRole,
                roleLabel: roleLabel,
                date: _formattedDate,
                isDark: isDark,
                onSettingsTap: () => _showSettings(context),
                onThemeToggle: themeToggle,
                child: widget.child,
              );
              if (width < 600) {
                return Scaffold(
                  body: content,
                  bottomNavigationBar: _PillNavBar(
                    currentIndex: index,
                    isDark: isDark,
                    onTap: (i) => _onTabTap(i, context),
                  ),
                );
              }
              if (width < 840) {
                return Scaffold(
                  body: Row(
                    children: [
                      _BrandRail(
                        currentIndex: index,
                        onTap: (i) => _onTabTap(i, context),
                      ),
                      Expanded(child: content),
                    ],
                  ),
                );
              }
              return Scaffold(
                body: Row(
                  children: [
                    _BrandSidebar(
                      currentIndex: index,
                      userName: userName,
                      roleLabel: roleLabel,
                      date: _formattedDate,
                      onTap: (i) => _onTabTap(i, context),
                      onSettingsTap: () => _showSettings(context),
                    ),
                    Expanded(child: content),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showSettings(BuildContext context) {
    showExquisssitaSheet(
      context: context,
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
  final String date, userName, roleLabel;
  final AppRole role;
  final bool isDark;
  final VoidCallback onSettingsTap, onThemeToggle;
  @override
  Widget build(BuildContext context) {
    final t = context.exq;
    final m = t.metrics;
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: m.spaceXl,
          vertical: m.spaceS,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(date, style: t.caption),
                  SizedBox(height: m.spaceXxs),
                  Text('Hola, $userName', style: t.label),
                  SizedBox(height: m.spaceXxs),
                  Text(roleLabel, style: t.caption),
                ],
              ),
            ),
            ExquisssitaIconAction(
              label: isDark ? 'Activar tema claro' : 'Activar tema oscuro',
              icon: isDark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
              onPressed: onThemeToggle,
            ),
            SizedBox(width: m.spaceXs),
            ExquisssitaIconAction(
              key: const Key('settings_button'),
              label: 'Más opciones',
              icon: Icons.settings_outlined,
              onPressed: onSettingsTap,
            ),
          ],
        ),
      ),
    );
  }
}

/// Intrinsic height follows the selected text scale instead of clipping labels.
class _PillNavBar extends StatelessWidget {
  const _PillNavBar({
    required this.currentIndex,
    required this.isDark,
    required this.onTap,
  });
  final int currentIndex;
  final bool isDark;
  final ValueChanged<int> onTap;
  static const _labels = ['Mesas', 'Menú', 'QR', 'Equipo', 'Promos'];
  static const _icons = [
    Icons.table_restaurant_outlined,
    Icons.menu_book_outlined,
    Icons.qr_code_scanner_outlined,
    Icons.people_outline,
    Icons.local_offer_outlined,
  ];
  @override
  Widget build(BuildContext context) {
    final t = context.exq;
    final m = t.metrics;
    return SafeArea(
      top: false,
      minimum: EdgeInsets.all(m.spaceS),
      child: Container(
        decoration: BoxDecoration(
          color: t.card,
          borderRadius: BorderRadius.circular(m.radiusNav),
          boxShadow: t.navShadow,
          border: Border.all(color: t.border, width: m.hairline),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: List.generate(
              _labels.length,
              (i) => Expanded(
                child: ExquisssitaPressable(
                  key: i == 2 ? const ValueKey('nav-qr') : null,
                  label: i == 2 ? 'Escanear QR' : _labels[i],
                  selected: i == currentIndex,
                  onPressed: () => onTap(i),
                  child: Container(
                    constraints: BoxConstraints(minHeight: m.navMinHeight),
                    padding: EdgeInsets.symmetric(
                      vertical: m.spaceS,
                      horizontal: m.spaceXxs,
                    ),
                    decoration: BoxDecoration(
                      color: i == currentIndex && i != 2
                          ? t.secondary
                          : t.transparent,
                      borderRadius: BorderRadius.circular(m.radiusNav),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (i == 2)
                          Container(
                            width: m.qrAction,
                            height: m.qrAction,
                            decoration: BoxDecoration(
                              color: i == currentIndex ? t.accent : t.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _icons[i],
                              color: i == currentIndex
                                  ? t.onAccent
                                  : t.onPrimary,
                              size: m.icon,
                            ),
                          )
                        else
                          Icon(_icons[i], color: t.foreground, size: m.icon),
                        SizedBox(height: m.spaceXs),
                        Text(
                          _labels[i],
                          style: t.caption,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
