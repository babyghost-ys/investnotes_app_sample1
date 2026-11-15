import 'package:cupertino_ui/cupertino_ui.dart';

import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/core/widgets/bone.dart';
import 'package:investnotes_app_sample1/core/widgets/skeleton_list.dart';

/// Learn while it loads: the lead article's card, the articles under it,
/// and the finder.
class LearnSkeleton extends StatelessWidget {
  const LearnSkeleton({super.key});

  @override
  Widget build(BuildContext context) => const SkeletonList(
    padding: EdgeInsets.fromLTRB(20, 20, 20, 32),
    children: [
      Bone(width: double.infinity, height: 260, radius: 24),
      SizedBox(height: 8),
      _ArticleRowSkeleton(titleFactor: 0.7),
      _ArticleRowSkeleton(titleFactor: 0.5),
      _ArticleRowSkeleton(titleFactor: 0.8),
      SizedBox(height: 28),
      Bone(width: double.infinity, height: 112, radius: 22),
    ],
  );
}

class _ArticleRowSkeleton extends StatelessWidget {
  const _ArticleRowSkeleton({required this.titleFactor});

  final double titleFactor;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 14),
    decoration: BoxDecoration(
      border: Border(
        bottom: BorderSide(color: KeelColors.hairline.of(context)),
      ),
    ),
    child: Row(
      children: [
        const Bone(width: 76, height: 76, radius: 16),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Bone.text(size: 18, widthFactor: 0.95),
              const SizedBox(height: 10),
              Bone.text(size: 18, widthFactor: titleFactor),
            ],
          ),
        ),
      ],
    ),
  );
}
