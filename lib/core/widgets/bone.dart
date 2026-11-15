import 'package:cupertino_ui/cupertino_ui.dart';

import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/core/widgets/skeleton_pulse.dart';

/// One placeholder shape in a page's skeleton, standing where a piece of
/// content will be. Breathes with the [SkeletonPulse] above it.
class Bone extends StatelessWidget {
  const Bone({
    super.key,
    this.width,
    this.widthFactor,
    required this.height,
    this.radius = 8,
    this.onBand = false,
  });

  /// A round bone, for icons and discs.
  const Bone.circle(double size, {super.key, this.onBand = false})
    : width = size,
      widthFactor = null,
      height = size,
      radius = size / 2;

  /// A line of text set at [size] points: as tall as its letters, not its
  /// line box.
  const Bone.text({
    super.key,
    this.width,
    this.widthFactor,
    required double size,
    this.onBand = false,
  }) : height = size * 0.78,
       radius = size * 0.3;

  final double? width;

  /// A share of the width available, for lines that run most of the way.
  final double? widthFactor;

  final double height;
  final double radius;

  /// Drawn on the tide band rather than the page.
  final bool onBand;

  @override
  Widget build(BuildContext context) {
    final bone = SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: onBand
              ? const Color(0x24FFFFFF)
              : KeelColors.hairline.of(context),
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
    return FadeTransition(
      opacity: SkeletonPulse.of(context),
      child: widthFactor == null
          ? bone
          : FractionallySizedBox(
              alignment: AlignmentDirectional.centerStart,
              widthFactor: widthFactor,
              child: bone,
            ),
    );
  }
}
