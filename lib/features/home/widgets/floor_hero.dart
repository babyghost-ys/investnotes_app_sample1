import 'dart:math' as math;

import 'package:cupertino_ui/cupertino_ui.dart';

import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';

/// Home's hero: a market path that dips and recovers, with a note's path
/// riding above it, never falling through its floor. Draws itself once.
class FloorHero extends StatefulWidget {
  const FloorHero({super.key, required this.topInset, this.banner});

  /// Space taken by the status and navigation bars above the band.
  final double topInset;

  /// Shown above the headline, such as the account banner.
  final Widget? banner;

  @override
  State<FloorHero> createState() => _FloorHeroState();
}

class _FloorHeroState extends State<FloorHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _draw = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  @override
  void initState() {
    super.initState();
    _draw.forward();
  }

  @override
  void dispose() {
    _draw.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    if (reduce) _draw.value = 1;
    final tide = KeelColors.tide.of(context);
    final deep = KeelColors.tideDeep.of(context);
    final top = widget.topInset;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [tide, deep],
        ),
      ),
      padding: EdgeInsets.fromLTRB(24, top + 18, 24, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.banner != null) ...[
            widget.banner!,
            const SizedBox(height: 24),
          ],
          const Text(
            'Upside, with a floor.',
            style: TextStyle(
              color: CupertinoColors.white,
              fontSize: 32,
              height: 1.1,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            height: 150,
            width: double.infinity,
            child: AnimatedBuilder(
              animation: _draw,
              builder: (context, _) => CustomPaint(
                painter: _HeroPainter(
                  Curves.easeInOutCubic.transform(_draw.value),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroPainter extends CustomPainter {
  _HeroPainter(this.t);

  final double t;

  /// A fixed market path: a slide, a trough, a recovery past the start.
  static final List<double> _market = () {
    const n = 90;
    final r = math.Random(7);
    var noise = 0.0;
    return [
      for (var i = 0; i < n; i++)
        () {
          final x = i / (n - 1);
          noise = noise * 0.6 + (r.nextDouble() - 0.5) * 0.05;
          final trend = -0.32 * math.sin(x * math.pi * 1.15) + 0.38 * x * x;
          return trend + (i == 0 ? 0 : noise);
        }(),
    ];
  }();

  @override
  void paint(Canvas canvas, Size size) {
    const lo = -0.45, hi = 0.42;
    double y(double v) => (1 - (v - lo) / (hi - lo)) * size.height;
    double x(int i) => i / (_market.length - 1) * size.width;
    final shown = (t * (_market.length - 1)).floor();

    // The floor: principal, dashed across the full width.
    final floorPaint = Paint()
      ..color = KeelColors.foam.withValues(alpha: 0.55)
      ..strokeWidth = 1.2;
    for (double dx = 0; dx < size.width; dx += 9) {
      canvas.drawLine(Offset(dx, y(0)), Offset(dx + 5, y(0)), floorPaint);
    }

    if (shown < 1) return;
    final market = Path()..moveTo(x(0), y(_market[0]));
    final note = Path()..moveTo(x(0), y(0));
    for (var i = 1; i <= shown; i++) {
      market.lineTo(x(i), y(_market[i]));
      note.lineTo(x(i), y(math.max(0, _market[i] * 0.9)));
    }
    canvas.drawPath(
      market,
      Paint()
        ..color = KeelColors.foam.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeJoin = StrokeJoin.round,
    );
    final glow = Paint()
      ..color = const Color(0xFF7FB2FF).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawPath(note, glow);
    canvas.drawPath(
      note,
      Paint()
        ..color = CupertinoColors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    final end = Offset(x(shown), y(math.max(0, _market[shown] * 0.9)));
    canvas.drawCircle(end, 5.5, Paint()..color = CupertinoColors.white);
  }

  @override
  bool shouldRepaint(_HeroPainter old) => old.t != t;
}
