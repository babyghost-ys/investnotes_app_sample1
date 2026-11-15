import 'package:cupertino_ui/cupertino_ui.dart';

import 'package:investnotes_app_sample1/core/widgets/bone.dart';
import 'package:investnotes_app_sample1/core/widgets/skeleton_list.dart';
import 'package:investnotes_app_sample1/features/offerings/widgets/offering_row_skeleton.dart';

/// The finder's results while they load: the verdict, then the offerings.
class FinderResultsSkeleton extends StatelessWidget {
  const FinderResultsSkeleton({super.key});

  @override
  Widget build(BuildContext context) => const SkeletonList(
    padding: EdgeInsets.fromLTRB(20, 18, 20, 40),
    children: [
      Row(
        children: [
          Bone.circle(30),
          SizedBox(width: 12),
          Bone.text(size: 28, width: 112),
        ],
      ),
      SizedBox(height: 8),
      OfferingRowSkeleton(nameFactor: 0.85),
      OfferingRowSkeleton(nameFactor: 0.65),
      OfferingRowSkeleton(nameFactor: 0.75),
    ],
  );
}
