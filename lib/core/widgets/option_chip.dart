import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/services.dart';

import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';

/// A selectable value: a currency, a region, a status. The text is the
/// value itself, the way a row's title is its content.
class OptionChip extends StatelessWidget {
  const OptionChip({
    super.key,
    required this.text,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String text;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final accent = KeelColors.azure.of(context);
    final fg = selected ? CupertinoColors.white : KeelColors.ink.of(context);
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: EdgeInsets.fromLTRB(icon == null ? 16 : 12, 9, 16, 9),
          decoration: BoxDecoration(
            color: selected ? accent : KeelColors.raised.of(context),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? accent : KeelColors.hairline.of(context),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 17, color: selected ? fg : accent),
                const SizedBox(width: 7),
              ],
              Text(
                text,
                style: TextStyle(
                  color: fg,
                  fontSize: 15,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
