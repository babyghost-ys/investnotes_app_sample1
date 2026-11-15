import 'package:cupertino_ui/cupertino_ui.dart';

import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/core/widgets/bone.dart';

/// A [ClosingCard] still loading, the same width and shape.
class ClosingCardSkeleton extends StatelessWidget {
  const ClosingCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) => Container(
    width: 236,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: KeelColors.raised.of(context),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: KeelColors.hairline.of(context)),
    ),
    child: const Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Bone(width: 46, height: 26, radius: 6),
            Spacer(),
            Bone(width: 62, height: 22),
          ],
        ),
        SizedBox(height: 26),
        Bone.text(size: 30, width: 72),
        SizedBox(height: 12),
        Bone.text(size: 14, widthFactor: 0.9),
        SizedBox(height: 7),
        Bone.text(size: 14, widthFactor: 0.55),
      ],
    ),
  );
}
