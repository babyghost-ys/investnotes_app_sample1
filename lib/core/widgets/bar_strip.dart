import 'package:cupertino_ui/cupertino_ui.dart';

import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';

/// Paints a side strip the system keeps clear (the iPhone Duo's vertical
/// bar, with its status cluster and controls) in the bar's tide blue, the
/// way the app's own pages colour it, over [child].
class BarStrip extends StatelessWidget {
  const BarStrip({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final sides = MediaQuery.paddingOf(context);
    final tide = KeelColors.tide.of(context);
    return Stack(
      children: [
        Positioned.fill(child: child),
        if (sides.left > 0)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: sides.left,
            child: IgnorePointer(child: ColoredBox(color: tide)),
          ),
        if (sides.right > 0)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: sides.right,
            child: IgnorePointer(child: ColoredBox(color: tide)),
          ),
      ],
    );
  }
}
