import 'package:cupertino_ui/cupertino_ui.dart';

import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/core/widgets/bone.dart';
import 'package:investnotes_app_sample1/core/widgets/skeleton_list.dart';

/// My Notes while it loads: the total, its return and split bar, and the
/// holdings below.
class MyNotesSkeleton extends StatelessWidget {
  const MyNotesSkeleton({super.key});

  @override
  Widget build(BuildContext context) => const SkeletonList(
    padding: EdgeInsets.fromLTRB(20, 20, 20, 40),
    children: [
      Bone.text(size: 44, width: 196),
      SizedBox(height: 14),
      Bone.text(size: 17, width: 76),
      SizedBox(height: 26),
      Bone(width: double.infinity, height: 10, radius: 5),
      SizedBox(height: 18),
      _HoldingSkeleton(nameFactor: 0.85),
      _HoldingSkeleton(nameFactor: 0.65),
      _HoldingSkeleton(nameFactor: 0.75),
      _HoldingSkeleton(nameFactor: 0.6),
    ],
  );
}

class _HoldingSkeleton extends StatelessWidget {
  const _HoldingSkeleton({required this.nameFactor});

  final double nameFactor;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 16),
    decoration: BoxDecoration(
      border: Border(
        bottom: BorderSide(color: KeelColors.hairline.of(context)),
      ),
    ),
    child: Row(
      children: [
        const Bone.circle(10),
        const SizedBox(width: 14),
        const Bone(width: 64, height: 36),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Bone.text(size: 16, widthFactor: nameFactor),
              const SizedBox(height: 9),
              const Bone.text(size: 14, width: 72),
            ],
          ),
        ),
        const SizedBox(width: 12),
        const Bone.text(size: 18, width: 54),
      ],
    ),
  );
}
