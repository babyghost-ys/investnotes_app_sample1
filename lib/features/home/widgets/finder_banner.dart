import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/services.dart';
import 'package:keel_localisation/keel_localisation.dart';

import 'package:investnotes_app_sample1/core/l10n/generated/locales.dart';
import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';

/// The way into "find my note": five steps drawn as a rising path of dots.
class FinderBanner extends StatelessWidget implements LocalisationConsumer {
  const FinderBanner({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  List<String> get namespaces => const [Locales.home];

  @override
  Widget build(BuildContext context) => LocalisedBuilder(
    consumer: this,
    builder: (context, locale) => _build(context, locale[0] as HomeLocale),
  );

  Widget _build(BuildContext context, HomeLocale home) => Semantics(
    button: true,
    label: home.labels.findMyNote,
    excludeSemantics: true,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        constraints: const BoxConstraints(minHeight: 112),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [KeelColors.azure.of(context), KeelColors.tide.of(context)],
          ),
        ),
        child: Row(
          children: [
            const Icon(
              CupertinoIcons.wand_stars,
              color: CupertinoColors.white,
              size: 30,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                home.labels.findMyNote,
                style: const TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            const SizedBox(
              width: 92,
              height: 64,
              child: CustomPaint(painter: _StepsPainter()),
            ),
          ],
        ),
      ),
    ),
  );
}

class _StepsPainter extends CustomPainter {
  const _StepsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final points = [
      for (var i = 0; i < 5; i++)
        Offset(
          6 + i * (size.width - 12) / 4,
          size.height - 8 - (i * i) / 16 * (size.height - 16),
        ),
    ];
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = KeelColors.foam.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    for (var i = 0; i < points.length; i++) {
      canvas.drawCircle(
        points[i],
        i == points.length - 1 ? 6 : 4,
        Paint()..color = CupertinoColors.white,
      );
    }
  }

  @override
  bool shouldRepaint(_StepsPainter old) => false;
}
