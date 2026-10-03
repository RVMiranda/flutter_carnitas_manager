import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';
import '../../app/theme/exquisssita_tokens.dart';
import 'exquisssita_components.dart';

/// Mounted only by the authenticated debug route. No backend dependency.
class DesignGalleryView extends StatefulWidget {
  const DesignGalleryView({super.key});
  @override
  State<DesignGalleryView> createState() => _DesignGalleryViewState();
}

class _DesignGalleryViewState extends State<DesignGalleryView> {
  bool? _dark;
  bool _contrast = false;
  @override
  Widget build(BuildContext context) {
    final dark = _dark ?? Theme.of(context).brightness == Brightness.dark;
    return Theme(
      data: _contrast
          ? dark
                ? AppTheme.highContrastDarkTheme
                : AppTheme.highContrastLightTheme
          : dark
          ? AppTheme.darkTheme
          : AppTheme.lightTheme,
      child: Builder(
        builder: (context) => Scaffold(
          body: ExquisssitaGallery(
            controls: Wrap(
              spacing: context.exq.metrics.spaceS,
              runSpacing: context.exq.metrics.spaceS,
              children: [
                ExquisssitaAction(
                  primary: false,
                  label: 'Volver',
                  icon: Icons.arrow_back_outlined,
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                ExquisssitaAction(
                  primary: false,
                  label: dark ? 'Tema claro' : 'Tema oscuro',
                  onPressed: () => setState(() => _dark = !dark),
                ),
                ExquisssitaAction(
                  primary: false,
                  label: _contrast ? 'Contraste estándar' : 'Contraste alto',
                  onPressed: () => setState(() => _contrast = !_contrast),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ExquisssitaGallery extends StatelessWidget {
  const ExquisssitaGallery({super.key, this.controls});
  final Widget? controls;
  @override
  Widget build(BuildContext context) {
    final t = context.exq;
    final m = t.metrics;
    return ListView(
      padding: EdgeInsets.all(m.spaceXl),
      children: [
        const ExquisssitaPageHeader(
          title: 'Hecho para el turno',
          subtitle: 'Outfit · Fraunces · Exquisssita',
        ),
        if (controls != null) ...[controls!, SizedBox(height: m.spaceL)],
        ExquisssitaSurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Acciones', style: t.heading),
              SizedBox(height: m.spaceM),
              ExquisssitaAction(
                label: 'Registrar operación',
                icon: Icons.check_outlined,
                onPressed: () {},
              ),
              SizedBox(height: m.spaceS),
              ExquisssitaAction(
                label: 'Revisar detalles',
                primary: false,
                onPressed: () {},
              ),
              SizedBox(height: m.spaceS),
              const ExquisssitaAction(
                label: 'Confirmación pendiente',
                onPressed: null,
                busy: true,
              ),
              SizedBox(height: m.spaceM),
              ExquisssitaIconAction(
                label: 'Configuración de ejemplo',
                icon: Icons.settings_outlined,
                onPressed: () {},
              ),
            ],
          ),
        ),
        SizedBox(height: m.spaceL),
        const ExquisssitaSyncStatus(
          label: 'Sin conexión',
          pending: 3,
          failed: 1,
          onPressed: _noOp,
        ),
        SizedBox(height: m.spaceL),
        ExquisssitaSurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Estados y formulario', style: t.heading),
              SizedBox(height: m.spaceM),
              Wrap(
                spacing: m.spaceS,
                runSpacing: m.spaceS,
                children: const [
                  ExquisssitaStatusBadge(
                    label: 'Pendiente de confirmación',
                    icon: Icons.schedule_outlined,
                  ),
                  ExquisssitaStatusBadge(
                    label: 'Requiere revisión',
                    icon: Icons.error_outline,
                  ),
                ],
              ),
              SizedBox(height: m.spaceL),
              const ExquisssitaFormField(label: 'Nombre de ejemplo'),
              SizedBox(height: m.spaceL),
              Text('Total pendiente', style: t.label),
              Text(r'$125.00', style: t.currency),
            ],
          ),
        ),
        SizedBox(height: m.spaceL),
        const ExquisssitaEmptyState(
          message: 'Aún no hay operaciones en este ejemplo.',
        ),
        ExquisssitaErrorState(
          message: 'No se pudo cargar este ejemplo.',
          onRetry: () {},
        ),
        const ExquisssitaSkeleton(),
        ExquisssitaAction(
          label: 'Abrir modal',
          primary: false,
          onPressed: () => showExquisssitaModal<void>(
            context: context,
            builder: (context) => ExquisssitaModal(
              title: 'Revisar operación',
              actions: [
                ExquisssitaAction(
                  label: 'Cerrar modal',
                  primary: false,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
              child: Text(
                'Este es un ejemplo visual.',
                style: context.exq.body,
              ),
            ),
          ),
        ),
        SizedBox(height: m.spaceS),
        ExquisssitaAction(
          label: 'Abrir hoja',
          primary: false,
          onPressed: () => showExquisssitaSheet<void>(
            context: context,
            builder: (context) => ExquisssitaSheet(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const ExquisssitaPageHeader(title: 'Opciones del ejemplo'),
                  ExquisssitaAction(
                    label: 'Cerrar hoja',
                    primary: false,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  static void _noOp() {}
}
