import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/services.dart';

import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';

/// One answer to a finder question. The whole row selects it.
class AnswerRow extends StatelessWidget {
  const AnswerRow({
    super.key,
    required this.icon,
    required this.text,
    required this.selected,
    required this.multiple,
    required this.onTap,
  });

  final IconData? icon;
  final String text;
  final bool selected;
  final bool multiple;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final azure = KeelColors.azure.of(context);
    final ink = KeelColors.ink.of(context);
    return Semantics(
      container: true,
      checked: selected,
      inMutuallyExclusiveGroup: !multiple,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          decoration: BoxDecoration(
            color: selected
                ? KeelColors.mist.of(context)
                : KeelColors.raised.of(context),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? azure : KeelColors.hairline.of(context),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: azure, size: 24),
                const SizedBox(width: 16),
              ],
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    color: ink,
                    fontSize: 17,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
              Icon(
                selected
                    ? (multiple
                          ? CupertinoIcons.checkmark_square_fill
                          : CupertinoIcons.checkmark_circle_fill)
                    : (multiple
                          ? CupertinoIcons.square
                          : CupertinoIcons.circle),
                color: selected ? azure : KeelColors.hairline.of(context),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
