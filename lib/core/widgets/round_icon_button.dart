import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart' show Tooltip;

/// An icon-only control. [label] is its accessible name, never shown.
class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.foreground,
    this.background,
    this.size = 44,
    this.iconSize = 20,
    this.child,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final Color foreground;
  final Color? background;
  final double size;
  final double iconSize;

  /// Drawn beside the icon, for a count on an apply control.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      child: Tooltip(
        message: label,
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          minimumSize: Size.square(size),
          onPressed: onPressed == null
              ? null
              : () {
                  HapticFeedback.lightImpact();
                  onPressed!();
                },
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 150),
            opacity: enabled ? 1 : 0.35,
            child: Container(
              height: size,
              constraints: BoxConstraints(minWidth: size),
              padding: child == null
                  ? EdgeInsets.zero
                  : const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(size / 2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: iconSize, color: foreground),
                  if (child != null) ...[const SizedBox(width: 8), child!],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
