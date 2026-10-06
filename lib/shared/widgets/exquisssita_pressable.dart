import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/theme/exquisssita_tokens.dart';

/// One activation path for touch, mouse, keyboard and assistive technology.
/// The hit region never shrinks with the painted press feedback.
class ExquisssitaPressable extends StatefulWidget {
  const ExquisssitaPressable({
    super.key,
    required this.child,
    required this.label,
    required this.onPressed,
    this.selected,
    this.focusNode,
    this.autofocus = false,
  });
  final Widget child;
  final String label;
  final VoidCallback? onPressed;
  final bool? selected;
  final FocusNode? focusNode;
  final bool autofocus;
  @override
  State<ExquisssitaPressable> createState() => _ExquisssitaPressableState();
}

class _ExquisssitaPressableState extends State<ExquisssitaPressable>
    with WidgetsBindingObserver {
  bool _pressed = false, _focused = false, _hasFocus = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAccessibilityFeatures() {
    if (mounted) setState(() {});
  }

  void _press(bool value) {
    if (widget.onPressed != null && _pressed != value) {
      setState(() => _pressed = value);
    }
  }

  @override
  void didUpdateWidget(covariant ExquisssitaPressable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.onPressed == null) _pressed = false;
  }

  @override
  Widget build(BuildContext context) {
    final t = context.exq;
    final m = t.metrics;
    final reduced = exquisssitaReducedMotion(context);
    return Semantics(
      button: true,
      enabled: widget.onPressed != null,
      focusable: widget.onPressed != null,
      focused: widget.onPressed != null && _hasFocus,
      selected: widget.selected,
      label: widget.label,
      onTap: widget.onPressed,
      excludeSemantics: true,
      child: FocusableActionDetector(
        enabled: widget.onPressed != null,
        autofocus: widget.autofocus,
        focusNode: widget.focusNode,
        mouseCursor: widget.onPressed == null
            ? SystemMouseCursors.basic
            : SystemMouseCursors.click,
        onShowFocusHighlight: (value) => setState(() => _focused = value),
        onFocusChange: (value) => setState(() => _hasFocus = value),
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.enter, includeRepeats: false):
              ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space, includeRepeats: false):
              ActivateIntent(),
        },
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              _press(true);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) _press(false);
              });
              widget.onPressed?.call();
              return null;
            },
          ),
        },
        child: Listener(
          onPointerDown: (_) => _press(true),
          onPointerUp: (_) => _press(false),
          onPointerCancel: (_) => _press(false),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            excludeFromSemantics: true,
            onTap: widget.onPressed,
            onTapCancel: () => _press(false),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: m.target,
                minHeight: m.target,
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(m.radiusButton),
                  border: Border.all(
                    color: _focused ? t.focus : t.transparent,
                    width: m.focusWidth,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(m.focusWidth),
                  child: AnimatedScale(
                    scale: _pressed && !reduced ? m.pressedScale : 1,
                    duration: reduced
                        ? Duration.zero
                        : _pressed
                        ? m.press
                        : m.release,
                    curve: m.easing,
                    child: Opacity(
                      opacity: widget.onPressed == null
                          ? m.disabledOpacity
                          : _pressed
                          ? m.pressedOpacity
                          : 1,
                      child: widget.child,
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
