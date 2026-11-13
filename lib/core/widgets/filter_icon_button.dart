import 'package:cupertino_ui/cupertino_ui.dart';

import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/core/widgets/round_icon_button.dart';

/// Opens a filter sheet. Tinted, with a dot, while any filter is on.
class FilterIconButton extends StatelessWidget {
  const FilterIconButton({
    super.key,
    required this.activeCount,
    required this.onPressed,
  });

  final int activeCount;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final active = activeCount > 0;
    final azure = KeelColors.azure.of(context);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        RoundIconButton(
          icon: CupertinoIcons.slider_horizontal_3,
          label: active ? 'Filters, $activeCount on' : 'Filters',
          foreground: active
              ? CupertinoColors.white
              : KeelColors.ink.of(context),
          background: active ? azure : KeelColors.mist.of(context),
          onPressed: onPressed,
        ),
        if (active)
          Positioned(
            right: -2,
            top: -2,
            child: IgnorePointer(
              child: Container(
                width: 18,
                height: 18,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: KeelColors.page.of(context),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$activeCount',
                  style: TextStyle(
                    color: azure,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
