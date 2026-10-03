import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:exquisssita_manager/app/router/app_router.dart';
import 'package:flutter/foundation.dart';
import 'package:exquisssita_manager/app/theme/exquisssita_tokens.dart';
import 'package:exquisssita_manager/shared/widgets/exquisssita_components.dart';
import 'package:exquisssita_manager/features/auth/presentation/view_models/auth_vm.dart';

/// Bottom sheet de opciones secundarias (configuración, gráficas, corte de caja, etc.)
///
/// Se abre desde el botón de ajustes en la top bar.
class SettingsBottomSheet extends ConsumerWidget {
  const SettingsBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.exq;

    final options = [
      _SettingsOption(
        icon: Icons.bar_chart_outlined,
        label: 'Gráficas de ventas',
        subtitle: 'Resumen del día y semana',
        onTap: () {
          Navigator.of(context).pop();
          // TODO: Navegar a gráficas (Fase 8)
        },
      ),
      _SettingsOption(
        icon: Icons.receipt_long_outlined,
        label: 'Cierre de caja',
        subtitle: 'Corte al final del turno',
        onTap: () {
          Navigator.of(context).pop();
          context.push(AppRoutes.cashRegister);
        },
      ),
      _SettingsOption(
        icon: Icons.settings_outlined,
        label: 'Configuración',
        subtitle: 'Preferencias del sistema',
        onTap: () {
          Navigator.of(context).pop();
          // TODO: Navegar a configuración (Fase 10)
        },
      ),
      _SettingsOption(
        icon: Icons.notifications_outlined,
        label: 'Notificaciones',
        subtitle: 'Alertas y avisos',
        onTap: () => Navigator.of(context).pop(),
      ),
      _SettingsOption(
        icon: Icons.logout_outlined,
        label: 'Cerrar sesión',
        subtitle: 'Salir de la cuenta actual',
        isDestructive: true,
        onTap: () async {
          Navigator.of(context).pop();
          await ref.read(authViewModelProvider.notifier).signOut();
        },
      ),
    ];

    if (kDebugMode) {
      options.insert(
        0,
        _SettingsOption(
          icon: Icons.palette_outlined,
          label: 'Galería Exquisssita',
          subtitle: 'Componentes y accesibilidad',
          onTap: () {
            Navigator.of(context).pop();
            context.push(AppRoutes.designGallery);
          },
        ),
      );
    }
    return ExquisssitaSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text('Más opciones', style: t.heading),
          ),
          SizedBox(height: t.metrics.spaceL),
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
  final IconData icon;
  final String label, subtitle;
  final VoidCallback onTap;
  final bool isDestructive;
}

class _SettingsOptionTile extends StatelessWidget {
  const _SettingsOptionTile({required this.option});
  final _SettingsOption option;
  @override
  Widget build(BuildContext context) {
    final t = context.exq;
    final m = t.metrics;
    return ExquisssitaPressable(
      label: '${option.label}. ${option.subtitle}',
      onPressed: option.onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: m.spaceM),
        child: Row(
          children: [
            Icon(option.icon, color: t.foreground, size: m.icon),
            SizedBox(width: m.spaceM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(option.label, style: t.label),
                  Text(option.subtitle, style: t.caption),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_outlined,
              color: t.foreground,
              size: m.iconSmall,
            ),
          ],
        ),
      ),
    );
  }
}
