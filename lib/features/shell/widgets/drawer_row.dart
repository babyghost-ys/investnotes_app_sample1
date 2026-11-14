import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/services.dart';

import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';

/// A destination in the menu. Its title is where it goes.
class DrawerRow extends StatelessWidget {
  const DrawerRow({
    super.key,
    this.icon,
    this.glyph,
    required this.title,
    required this.onTap,
    this.selected = false,
  });

  final IconData? icon;

  /// Drawn in place of [icon], for a glyph no icon font has.
  final Widget? glyph;
  final String title;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: selected ? const Color(0x24FFFFFF) : null,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            glyph ??
                Icon(
                  icon,
                  size: 22,
                  color: selected ? CupertinoColors.white : KeelColors.foam,
                ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                color: CupertinoColors.white,
                fontSize: 19,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
