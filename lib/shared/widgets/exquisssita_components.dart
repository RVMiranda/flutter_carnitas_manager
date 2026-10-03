import 'package:flutter/material.dart';
import '../../app/theme/exquisssita_tokens.dart';
import 'exquisssita_pressable.dart';
export 'exquisssita_pressable.dart';

class ExquisssitaAction extends StatelessWidget {
  const ExquisssitaAction({
    super.key,
    required this.label,
    required this.onPressed,
    this.primary = true,
    this.icon,
    this.busy = false,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool primary, busy;
  final IconData? icon;
  @override
  Widget build(BuildContext context) {
    final t = context.exq;
    final m = t.metrics;
    final fg = primary ? t.actionForeground : t.foreground;
    return ExquisssitaPressable(
      label: busy ? '$label, procesando' : label,
      onPressed: busy ? null : onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: m.spaceL, vertical: m.spaceM),
        decoration: BoxDecoration(
          color: primary ? t.actionBackground : t.secondary,
          borderRadius: BorderRadius.circular(m.radiusButton),
          border: Border.all(
            color: primary ? t.transparent : t.border,
            width: m.hairline,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null || busy) ...[
              Icon(
                busy ? Icons.hourglass_top_outlined : icon,
                color: fg,
                size: m.icon,
              ),
              SizedBox(width: m.spaceS),
            ],
            Flexible(
              child: Text(
                busy ? '$label…' : label,
                textAlign: TextAlign.center,
                style: primary ? t.button : t.label,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ExquisssitaIconAction extends StatelessWidget {
  const ExquisssitaIconAction({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) => Tooltip(
    message: label,
    excludeFromSemantics: true,
    child: ExquisssitaPressable(
      label: label,
      onPressed: onPressed,
      child: Container(
        alignment: Alignment.center,
        constraints: BoxConstraints(
          minWidth: context.exq.metrics.target,
          minHeight: context.exq.metrics.target,
        ),
        decoration: BoxDecoration(
          color: context.exq.card,
          borderRadius: BorderRadius.circular(context.exq.metrics.radiusSmall),
        ),
        child: Icon(
          icon,
          color: context.exq.foreground,
          size: context.exq.metrics.icon,
        ),
      ),
    ),
  );
}

class ExquisssitaSurface extends StatelessWidget {
  const ExquisssitaSurface({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(context.exq.metrics.spaceL),
    decoration: BoxDecoration(
      color: context.exq.card,
      borderRadius: BorderRadius.circular(context.exq.metrics.radiusCard),
      border: Border.all(
        color: context.exq.border,
        width: context.exq.metrics.hairline,
      ),
      boxShadow: context.exq.cardShadow,
    ),
    child: child,
  );
}

class ExquisssitaPageHeader extends StatelessWidget {
  const ExquisssitaPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
  });
  final String title;
  final String? subtitle;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.all(context.exq.metrics.spaceXl),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(header: true, child: Text(title, style: context.exq.heading)),
        if (subtitle != null) ...[
          SizedBox(height: context.exq.metrics.spaceS),
          Text(subtitle!, style: context.exq.body),
        ],
        if (action != null) ...[
          SizedBox(height: context.exq.metrics.spaceM),
          action!,
        ],
      ],
    ),
  );
}

class ExquisssitaStatusBadge extends StatelessWidget {
  const ExquisssitaStatusBadge({
    super.key,
    required this.label,
    this.icon = Icons.info_outline,
  });
  final String label;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(
      horizontal: context.exq.metrics.spaceM,
      vertical: context.exq.metrics.spaceS,
    ),
    decoration: BoxDecoration(
      color: context.exq.secondary,
      borderRadius: BorderRadius.circular(context.exq.metrics.radiusChip),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ExcludeSemantics(
          child: Icon(
            icon,
            size: context.exq.metrics.iconSmall,
            color: context.exq.foreground,
          ),
        ),
        SizedBox(width: context.exq.metrics.spaceS),
        Flexible(child: Text(label, style: context.exq.label)),
      ],
    ),
  );
}

class ExquisssitaEmptyState extends StatelessWidget {
  const ExquisssitaEmptyState({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.action,
  });
  final String message;
  final IconData icon;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.all(context.exq.metrics.spaceXxl),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ExcludeSemantics(
          child: Icon(
            icon,
            size: context.exq.metrics.iconLarge,
            color: context.exq.foreground,
          ),
        ),
        SizedBox(height: context.exq.metrics.spaceM),
        Text(message, style: context.exq.body, textAlign: TextAlign.center),
        if (action != null) ...[
          SizedBox(height: context.exq.metrics.spaceL),
          action!,
        ],
      ],
    ),
  );
}

class ExquisssitaErrorState extends StatelessWidget {
  const ExquisssitaErrorState({
    super.key,
    this.message = 'No fue posible cargar la información. Intenta de nuevo.',
    this.onRetry,
  });

  /// Must be a presentation message, never an exception or a remote payload.
  final String message;
  final VoidCallback? onRetry;
  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: ExquisssitaEmptyState(
      message: message,
      icon: Icons.error_outline,
      action: onRetry == null
          ? null
          : ExquisssitaAction(
              label: 'Reintentar',
              onPressed: onRetry,
              primary: false,
            ),
    ),
  );
}

/// Static by design: loading remains legible with all motion settings.
class ExquisssitaSkeleton extends StatelessWidget {
  const ExquisssitaSkeleton({super.key});
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Cargando información',
    liveRegion: true,
    child: ExcludeSemantics(
      child: Padding(
        padding: EdgeInsets.all(context.exq.metrics.spaceXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            3,
            (_) => Padding(
              padding: EdgeInsets.only(bottom: context.exq.metrics.spaceM),
              child: Container(
                height: context.exq.metrics.skeletonHeight,
                decoration: BoxDecoration(
                  color: context.exq.secondary,
                  borderRadius: BorderRadius.circular(
                    context.exq.metrics.radiusSmall,
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

class ExquisssitaFormField extends StatelessWidget {
  const ExquisssitaFormField({
    super.key,
    required this.label,
    this.controller,
    this.validator,
    this.obscureText = false,
    this.enabled = true,
    this.keyboardType,
    this.textInputAction,
    this.onFieldSubmitted,
    this.suffix,
    this.maxLines = 1,
  });
  final String label;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool obscureText, enabled;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final Widget? suffix;
  final int maxLines;
  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    validator: validator,
    enabled: enabled,
    obscureText: obscureText,
    keyboardType: keyboardType,
    textInputAction: textInputAction,
    onFieldSubmitted: onFieldSubmitted,
    autocorrect: !obscureText && keyboardType != TextInputType.emailAddress,
    maxLines: maxLines,
    style: context.exq.body,
    decoration: InputDecoration(
      labelText: label,
      suffixIcon: suffix,
      constraints: BoxConstraints(minHeight: context.exq.metrics.target),
    ),
  );
}

class ExquisssitaModal extends StatelessWidget {
  const ExquisssitaModal({
    super.key,
    required this.title,
    required this.child,
    this.actions = const [],
  });
  final String title;
  final Widget child;
  final List<Widget> actions;
  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: context.exq.card,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(context.exq.metrics.radiusSheet),
    ),
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: context.exq.metrics.dialogMax),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(context.exq.metrics.spaceXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              namesRoute: true,
              header: true,
              child: Text(title, style: context.exq.heading),
            ),
            SizedBox(height: context.exq.metrics.spaceL),
            child,
            if (actions.isNotEmpty) ...[
              SizedBox(height: context.exq.metrics.spaceL),
              Wrap(
                alignment: WrapAlignment.end,
                spacing: context.exq.metrics.spaceS,
                runSpacing: context.exq.metrics.spaceS,
                children: actions,
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

Future<T?> showExquisssitaModal<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) => showGeneralDialog<T>(
  context: context,
  barrierDismissible: true,
  barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
  barrierColor: context.exq.scrim,
  transitionDuration: exquisssitaReducedMotion(context)
      ? Duration.zero
      : context.exq.metrics.transition,
  pageBuilder: (context, _, _) => builder(context),
  transitionBuilder: (context, animation, _, child) =>
      FadeTransition(opacity: animation, child: child),
);

class ExquisssitaSheet extends StatelessWidget {
  const ExquisssitaSheet({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: SingleChildScrollView(
      padding: EdgeInsets.all(context.exq.metrics.spaceXl),
      child: child,
    ),
  );
}

Future<T?> showExquisssitaSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) => showModalBottomSheet<T>(
  context: context,
  isScrollControlled: true,
  barrierColor: context.exq.scrim,
  sheetAnimationStyle: exquisssitaReducedMotion(context)
      ? AnimationStyle.noAnimation
      : AnimationStyle(
          duration: context.exq.metrics.transition,
          reverseDuration: context.exq.metrics.release,
        ),
  builder: builder,
);

class ExquisssitaSyncStatus extends StatelessWidget {
  const ExquisssitaSyncStatus({
    super.key,
    required this.label,
    required this.pending,
    required this.failed,
    required this.onPressed,
  });
  final String label;
  final int pending, failed;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => ColoredBox(
    color: context.exq.secondary,
    child: SafeArea(
      bottom: false,
      child: ExquisssitaPressable(
        label:
            '$label · $pending pendientes · $failed fallidas. Ver operaciones',
        onPressed: onPressed,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.exq.metrics.spaceL,
            vertical: context.exq.metrics.spaceS,
          ),
          child: Row(
            children: [
              Icon(
                Icons.sync_outlined,
                color: context.exq.foreground,
                size: context.exq.metrics.iconSmall,
              ),
              SizedBox(width: context.exq.metrics.spaceS),
              Expanded(
                child: Text(
                  '$label · $pending pendientes · $failed fallidas',
                  style: context.exq.caption,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
