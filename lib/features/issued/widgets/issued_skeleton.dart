import 'package:cupertino_ui/cupertino_ui.dart';

import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/core/widgets/bone.dart';
import 'package:investnotes_app_sample1/core/widgets/skeleton_list.dart';

/// Issued while it loads: the average return beside the filter, then the
/// notes, each a status disc, a name and a return.
class IssuedSkeleton extends StatelessWidget {
  const IssuedSkeleton({super.key});

  @override
  Widget build(BuildContext context) => const SkeletonList(
    padding: EdgeInsets.fromLTRB(20, 20, 20, 32),
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [Bone.text(size: 44, width: 128), Spacer(), Bone.circle(44)],
      ),
      SizedBox(height: 12),
      _IssuedRowSkeleton(nameFactor: 0.8),
      _IssuedRowSkeleton(nameFactor: 0.6),
      _IssuedRowSkeleton(nameFactor: 0.9),
      _IssuedRowSkeleton(nameFactor: 0.7),
      _IssuedRowSkeleton(nameFactor: 0.55),
      _IssuedRowSkeleton(nameFactor: 0.75),
    ],
  );
}

class _IssuedRowSkeleton extends StatelessWidget {
  const _IssuedRowSkeleton({required this.nameFactor});

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
        const Bone.circle(40),
        const SizedBox(width: 14),
        Expanded(child: Bone.text(size: 16, widthFactor: nameFactor)),
        const SizedBox(width: 12),
        const Bone.text(size: 18, width: 54),
        const SizedBox(width: 22),
      ],
    ),
  );
}
