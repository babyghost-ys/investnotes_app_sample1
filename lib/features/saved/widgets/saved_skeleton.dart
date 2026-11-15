import 'package:cupertino_ui/cupertino_ui.dart';

import 'package:investnotes_app_sample1/core/widgets/skeleton_list.dart';
import 'package:investnotes_app_sample1/features/offerings/widgets/offering_row_skeleton.dart';

/// Saved offerings while they load.
class SavedSkeleton extends StatelessWidget {
  const SavedSkeleton({super.key});

  @override
  Widget build(BuildContext context) => const SkeletonList(
    padding: EdgeInsets.fromLTRB(20, 8, 20, 40),
    children: [
      OfferingRowSkeleton(nameFactor: 0.8),
      OfferingRowSkeleton(nameFactor: 0.6),
      OfferingRowSkeleton(nameFactor: 0.9),
    ],
  );
}
