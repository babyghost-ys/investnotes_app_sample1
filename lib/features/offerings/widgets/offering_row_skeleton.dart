import 'package:cupertino_ui/cupertino_ui.dart';

import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/core/widgets/bone.dart';

/// An [OfferingRow] still loading: its tile, its name and index, and its
/// headline number, each at its place and size.
class OfferingRowSkeleton extends StatelessWidget {
  const OfferingRowSkeleton({super.key, this.nameFactor = 0.8});

  /// How far the name runs, so a list of them does not read as a grid.
  final double nameFactor;

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
        const Bone(width: 56, height: 56, radius: 14),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Bone.text(size: 16, widthFactor: nameFactor),
              const SizedBox(height: 9),
              const Bone.text(size: 13, widthFactor: 0.5),
            ],
          ),
        ),
        const SizedBox(width: 12),
        const Bone.text(size: 22, width: 50),
      ],
    ),
  );
}
