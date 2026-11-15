import 'package:cupertino_ui/cupertino_ui.dart';

import 'package:investnotes_app_sample1/core/widgets/bone.dart';
import 'package:investnotes_app_sample1/core/widgets/skeleton_list.dart';

/// Education while it loads: the search band, the segmented control, and
/// the first films.
class EducationSkeleton extends StatelessWidget {
  const EducationSkeleton({super.key});

  @override
  Widget build(BuildContext context) => const SkeletonList(
    padding: EdgeInsets.fromLTRB(20, 20, 20, 32),
    children: [
      Bone(width: double.infinity, height: 150, radius: 24),
      SizedBox(height: 22),
      Bone(width: double.infinity, height: 32, radius: 9),
      SizedBox(height: 22),
      _FilmSkeleton(titleFactor: 0.7),
      _FilmSkeleton(titleFactor: 0.5),
    ],
  );
}

class _FilmSkeleton extends StatelessWidget {
  const _FilmSkeleton({required this.titleFactor});

  final double titleFactor;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 26),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AspectRatio(
          aspectRatio: 16 / 10,
          child: Bone(
            width: double.infinity,
            height: double.infinity,
            radius: 22,
          ),
        ),
        const SizedBox(height: 14),
        Bone.text(size: 19, widthFactor: titleFactor),
      ],
    ),
  );
}
