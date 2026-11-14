import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart' show Material, MaterialType;

import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/core/widgets/round_icon_button.dart';

/// The frame of a filter sheet: reset, the title and close along the top,
/// the groups of options, and one apply control that shows how many results
/// it will give.
///
/// A [scrolls] layout fills a full-height sheet: the top row and the apply
/// control stay put while the groups scroll between them. Otherwise the
/// layout takes its natural height, for a sheet that fits its content.
class FilterSheetLayout extends StatelessWidget {
  const FilterSheetLayout({
    super.key,
    required this.groups,
    required this.resultCount,
    required this.onApply,
    required this.onReset,
    this.scrolls = false,
  });

  final List<Widget> groups;
  final int resultCount;
  final VoidCallback onApply;

  /// Null when nothing differs from the default.
  final VoidCallback? onReset;
  final bool scrolls;

  @override
  Widget build(BuildContext context) {
    final ink = KeelColors.ink.of(context);
    final hairline = KeelColors.hairline.of(context);

    final header = Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
      child: Row(
        children: [
          RoundIconButton(
            icon: CupertinoIcons.arrow_counterclockwise,
            label: 'Reset',
            foreground: ink,
            onPressed: onReset,
          ),
          Expanded(
            child: Text(
              'Filters',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ink,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          RoundIconButton(
            icon: CupertinoIcons.xmark,
            label: 'Close',
            foreground: ink,
            onPressed: () => AdaptiveNativeSheet.pop(context),
          ),
        ],
      ),
    );

    final body = <Widget>[
      for (var i = 0; i < groups.length; i++) ...[
        if (i > 0)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Container(height: 1, color: hairline),
          ),
        groups[i],
      ],
    ];

    final apply = Center(
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
    );

    if (scrolls) {
      return Material(
        type: MaterialType.transparency,
        child: Column(
          children: [
            header,
            Container(height: 1, color: hairline),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                children: body,
              ),
            ),
            Container(height: 1, color: hairline),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: apply,
              ),
            ),
          ],
        ),
      );
    }

    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            header,
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [...body, const SizedBox(height: 24), apply],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
