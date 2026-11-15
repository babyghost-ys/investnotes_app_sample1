import 'package:cupertino_ui/cupertino_ui.dart';

import 'package:investnotes_app_sample1/core/widgets/bone.dart';
import 'package:investnotes_app_sample1/core/widgets/skeleton_list.dart';

/// Search while it loads: the field, where the cursor will wait.
class SearchSkeleton extends StatelessWidget {
  const SearchSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.paddingOf(context);
    return SkeletonList(
      padding: EdgeInsets.fromLTRB(16 + insets.left, 16, 16 + insets.right, 40),
      children: const [Bone(width: double.infinity, height: 56, radius: 16)],
    );
  }
}
