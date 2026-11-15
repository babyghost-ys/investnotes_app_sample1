import 'package:cupertino_ui/cupertino_ui.dart';

import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/core/widgets/bone.dart';
import 'package:investnotes_app_sample1/features/product/widgets/section_strip.dart';

/// A note's page while it loads: the name and shape, the strip of
/// sections, and the overview's summary and facts.
class ProductSkeleton extends StatelessWidget {
  const ProductSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.paddingOf(context);
    final side = EdgeInsets.only(
      left: 20 + insets.left,
      right: 20 + insets.right,
    );
    return ColoredBox(
      color: KeelColors.page.of(context),
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        removeBottom: true,
        child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.only(
            top: insets.top + 20,
            bottom: insets.bottom + 48,
          ),
          children: [
            Padding(
              padding: side,
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Bone.text(size: 26, widthFactor: 0.9),
                        SizedBox(height: 10),
                        Bone.text(size: 26, widthFactor: 0.6),
                        SizedBox(height: 16),
                        Bone.text(size: 14, width: 84),
                      ],
                    ),
                  ),
                  SizedBox(width: 14),
                  Bone(width: 64, height: 64, radius: 16),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: SectionStrip.height,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  12 + insets.left,
                  14,
                  12 + insets.right,
                  10,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < 4; i++)
                      const SizedBox(
                        width: 84,
                        child: Column(
                          children: [
                            Bone.circle(56),
                            SizedBox(height: 12),
                            Bone.text(size: 13, width: 50),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: side,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Bone.text(size: 20, widthFactor: 1),
                  SizedBox(height: 14),
                  Bone.text(size: 20, widthFactor: 0.95),
                  SizedBox(height: 14),
                  Bone.text(size: 20, widthFactor: 0.4),
                  SizedBox(height: 26),
                  Bone(width: double.infinity, height: 48, radius: 12),
                  SizedBox(height: 22),
                  _FactRowSkeleton(),
                  _FactRowSkeleton(),
                  _FactRowSkeleton(),
                  SizedBox(height: 10),
                  _CodeRowSkeleton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Two of the overview's facts side by side, each an icon and a value.
class _FactRowSkeleton extends StatelessWidget {
  const _FactRowSkeleton();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 13),
    child: Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Bone.circle(24),
              SizedBox(width: 18),
              Bone.text(size: 18, width: 70),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Bone.circle(24),
              SizedBox(width: 18),
              Bone.text(size: 18, width: 96),
            ],
          ),
        ),
      ],
    ),
  );
}

/// The note's code under a hairline, with room for its copy control.
class _CodeRowSkeleton extends StatelessWidget {
  const _CodeRowSkeleton();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.only(top: 22),
    decoration: BoxDecoration(
      border: Border(top: BorderSide(color: KeelColors.hairline.of(context))),
    ),
    child: const Row(
      children: [
        Bone(width: 24, height: 20, radius: 4),
        SizedBox(width: 18),
        Bone.text(size: 18, width: 104),
        Spacer(),
        Bone(width: 24, height: 26, radius: 6),
      ],
    ),
  );
}
