import 'package:cupertino_ui/cupertino_ui.dart';

import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/core/widgets/bone.dart';
import 'package:investnotes_app_sample1/features/home/widgets/account_banner.dart';
import 'package:investnotes_app_sample1/features/home/widgets/closing_row_skeleton.dart';

/// Home while it loads: the tide band with its floor already drawn, then
/// the four note families, the closing row and the finder, as shapes.
class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.paddingOf(context);
    final page = KeelColors.page.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.5, 0.5],
          colors: [KeelColors.tide.of(context), page],
        ),
      ),
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        removeBottom: true,
        child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    KeelColors.tide.of(context),
                    KeelColors.tideDeep.of(context),
                  ],
                ),
              ),
              padding: EdgeInsets.fromLTRB(24, insets.top + 18, 24, 28),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Bone(
                    width: double.infinity,
                    height: AccountBanner.height,
                    radius: 20,
                    onBand: true,
                  ),
                  SizedBox(height: 24),
                  Bone.text(size: 32, widthFactor: 0.72, onBand: true),
                  SizedBox(height: 22),
                  SizedBox(
                    height: 150,
                    width: double.infinity,
                    child: CustomPaint(painter: _FloorPainter()),
                  ),
                ],
              ),
            ),
            ColoredBox(
              color: page,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: _TileSkeleton(nameFactor: 0.85)),
                            SizedBox(width: 12),
                            Expanded(child: _TileSkeleton(nameFactor: 0.95)),
                          ],
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _TileSkeleton(nameFactor: 0.7)),
                            SizedBox(width: 12),
                            Expanded(child: _TileSkeleton(nameFactor: 0.9)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  const ClosingRowSkeleton(),
                  const SizedBox(height: 28),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Bone(
                      width: double.infinity,
                      height: 112,
                      radius: 22,
                    ),
                  ),
                  SizedBox(height: insets.bottom + 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A note family's tile while it loads.
class _TileSkeleton extends StatelessWidget {
  const _TileSkeleton({required this.nameFactor});

  final double nameFactor;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
    decoration: BoxDecoration(
      color: KeelColors.raised.of(context),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: KeelColors.hairline.of(context)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Bone(width: 44, height: 24, radius: 6),
        const SizedBox(height: 22),
        const Bone.text(size: 24, width: 64),
        const SizedBox(height: 10),
        Bone.text(size: 13, widthFactor: nameFactor),
        const SizedBox(height: 6),
        const Bone.text(size: 13, widthFactor: 0.4),
      ],
    ),
  );
}

/// The hero's floor, dashed at the same height as on the loaded band, so
/// the note's path draws onto a line already there.
class _FloorPainter extends CustomPainter {
  const _FloorPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // The hero maps -0.45..0.42 onto its height; principal sits at zero.
    final y = (1 - 0.45 / 0.87) * size.height;
    final paint = Paint()
      ..color = KeelColors.foam.withValues(alpha: 0.4)
      ..strokeWidth = 1.2;
    for (double dx = 0; dx < size.width; dx += 9) {
      canvas.drawLine(Offset(dx, y), Offset(dx + 5, y), paint);
    }
  }

  @override
  bool shouldRepaint(_FloorPainter old) => false;
}
