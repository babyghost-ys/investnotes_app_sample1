import 'package:cupertino_ui/cupertino_ui.dart';

import 'package:investnotes_app_sample1/core/widgets/bone.dart';
import 'package:investnotes_app_sample1/core/widgets/skeleton_list.dart';

/// An article while it loads: its title, the payoff to try, and its
/// paragraphs.
class ArticleSkeleton extends StatelessWidget {
  const ArticleSkeleton({super.key});

  @override
  Widget build(BuildContext context) => const SkeletonList(
    padding: EdgeInsets.fromLTRB(24, 20, 24, 48),
    children: [
      Bone.text(size: 28, widthFactor: 0.9),
      SizedBox(height: 11),
      Bone.text(size: 28, widthFactor: 0.55),
      SizedBox(height: 24),
      Bone(width: double.infinity, height: 280, radius: 20),
      SizedBox(height: 28),
      _ParagraphSkeleton(lines: 4, last: 0.6),
      _ParagraphSkeleton(lines: 3, last: 0.4),
      _ParagraphSkeleton(lines: 4, last: 0.75),
    ],
  );
}

class _ParagraphSkeleton extends StatelessWidget {
  const _ParagraphSkeleton({required this.lines, required this.last});

  final int lines;

  /// How far the last line runs.
  final double last;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 26),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < lines; i++) ...[
          if (i > 0) const SizedBox(height: 13),
          Bone.text(size: 17, widthFactor: i == lines - 1 ? last : 1),
        ],
      ],
    ),
  );
}
