import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:exquisssita_manager/app/router/app_router.dart';
import 'package:exquisssita_manager/app/theme/app_text_styles.dart';
import 'package:exquisssita_manager/app/theme/app_theme.dart';
import 'package:exquisssita_manager/features/auth/presentation/view_models/auth_vm.dart';

/// Bottom sheet de opciones secundarias (configuración, gráficas, corte de caja, etc.)
///
/// Se abre desde el botón de ajustes en la top bar.
class SettingsBottomSheet extends ConsumerWidget {
  const SettingsBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final options = [
      _SettingsOption(
        icon: '📊',
        label: 'Gráficas de ventas',
        subtitle: 'Resumen del día y semana',
        onTap: () {
          Navigator.of(context).pop();
          // TODO: Navegar a gráficas (Fase 8)
        },
      ),
      _SettingsOption(
        icon: '🧾',
        label: 'Cierre de caja',
        subtitle: 'Corte al final del turno',
        onTap: () {
          Navigator.of(context).pop();
          context.push(AppRoutes.cashRegister);
        },
      ),
      _SettingsOption(
        icon: '⚙️',
        label: 'Configuración',
        subtitle: 'Preferencias del sistema',
        onTap: () {
          Navigator.of(context).pop();
          // TODO: Navegar a configuración (Fase 10)
        },
      ),
      _SettingsOption(
        icon: '🔔',
        label: 'Notificaciones',
        subtitle: 'Alertas y avisos',
        onTap: () => Navigator.of(context).pop(),
      ),
      _SettingsOption(
        icon: '🚪',
        label: 'Cerrar sesión',
        subtitle: 'Salir de la cuenta actual',
        isDestructive: true,
        onTap: () async {
          Navigator.of(context).pop();
          await ref.read(authViewModelProvider.notifier).signOut();
        },
      ),
    ];

    return Container(
      margin: const EdgeInsets.only(top: 48),
      padding: EdgeInsets.only(
        bottom: MediaQuery.paddingOf(context).bottom + AppTheme.spacingL,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusBottomSheet),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Handle ────────────────────────────────────────────────────────
          Container(
            margin: const EdgeInsets.only(top: AppTheme.spacingM),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withAlpha(80),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: AppTheme.spacingL),

          // ── Título ────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXl),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Más opciones',
                style: AppTextStyles.displaySmall.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),

          const SizedBox(height: AppTheme.spacingM),

          // ── Opciones ──────────────────────────────────────────────────────
          ...options.map((opt) => _SettingsOptionTile(option: opt)),
        ],
      ),
    );
  }
}

class _SettingsOption {
  const _SettingsOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  final String icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;
}

class _SettingsOptionTile extends StatelessWidget {
  const _SettingsOptionTile({required this.option});
  final _SettingsOption option;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelColor = option.isDestructive
        ? theme.colorScheme.error
        : theme.colorScheme.onSurface;

    return InkWell(
      onTap: option.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingXl,
          vertical: AppTheme.spacingM,
        ),
        child: Row(
          children: [
            // ── Ícono ──────────────────────────────────────────────────────
            SizedBox(
              width: 32,
              child: Text(
                option.icon,
                style: const TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(width: AppTheme.spacingM),

            // ── Labels ─────────────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.label,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                      color: labelColor,
                    ),
                  ),
                  Text(
                    option.subtitle,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(100),
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: theme.colorScheme.outline,
            ),
          ],
        ),
      ),
    );
  }
}
