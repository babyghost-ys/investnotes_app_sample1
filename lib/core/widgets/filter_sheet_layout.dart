import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart' show Material, MaterialType;

import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/core/widgets/round_icon_button.dart';

/// The frame of a filter sheet: reset at the leading edge, the groups of
/// options, and one apply control that shows how many results it will give.
class FilterSheetLayout extends StatelessWidget {
  const FilterSheetLayout({
    super.key,
    required this.groups,
    required this.resultCount,
    required this.onApply,
    required this.onReset,
  });

  final List<Widget> groups;
  final int resultCount;
  final VoidCallback onApply;

  /// Null when nothing differs from the default.
  final VoidCallback? onReset;

  @override
  Widget build(BuildContext context) {
    final ink = KeelColors.ink.of(context);
    final hairline = KeelColors.hairline.of(context);
    return Material(
      type: MaterialType.transparency,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                RoundIconButton(
                  icon: CupertinoIcons.arrow_counterclockwise,
                  label: 'Reset',
                  foreground: ink,
                  onPressed: onReset,
                ),
                const Spacer(),
                RoundIconButton(
                  icon: CupertinoIcons.xmark,
                  label: 'Close',
                  foreground: ink,
                  onPressed: () => AdaptiveNativeSheet.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 6),
            for (var i = 0; i < groups.length; i++) ...[
              if (i > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Container(height: 1, color: hairline),
                ),
              groups[i],
            ],
            const SizedBox(height: 24),
            Center(
              child: RoundIconButton(
                icon: CupertinoIcons.checkmark,
                label: 'Show $resultCount results',
                foreground: CupertinoColors.white,
                background: KeelColors.azure.of(context),
                size: 54,
                iconSize: 22,
                onPressed: resultCount == 0 ? null : onApply,
                child: Text(
                  '$resultCount',
                  style: const TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
