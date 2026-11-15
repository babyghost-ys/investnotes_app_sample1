import 'package:cupertino_ui/cupertino_ui.dart';

import 'package:investnotes_app_sample1/domain/models/payoff.dart';

/// A note's payoff drawn as a single line: the shape that tells one note
/// family from another at a glance.
class PayoffGlyph extends StatelessWidget {
  const PayoffGlyph({
    super.key,
    required this.payoff,
    required this.color,
    this.baseline,
    this.strokeWidth = 2.4,
    this.size = 44,
  });

  final Payoff payoff;
  final Color color;

  /// Colour of the zero line; null hides it.
  final Color? baseline;
  final double strokeWidth;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: CustomPaint(
      painter: _GlyphPainter(payoff, color, baseline, strokeWidth),
    ),
  );
}

class _GlyphPainter extends CustomPainter {
  _GlyphPainter(this.payoff, this.color, this.baseline, this.strokeWidth);

  final Payoff payoff;
  final Color color;
  final Color? baseline;
  final double strokeWidth;

  static const _minX = -0.6, _maxX = 0.6, _minY = -0.5, _maxY = 0.6;

  @override
  void paint(Canvas canvas, Size size) {
    final inset = strokeWidth;
    final w = size.width - inset * 2, h = size.height - inset * 2;
    Offset map(double x, double y) => Offset(
      inset + (x - _minX) / (_maxX - _minX) * w,
      inset + (1 - (y - _minY) / (_maxY - _minY)) * h,
    );
    if (baseline != null) {
      canvas.drawLine(
        map(_minX, 0),
        map(_maxX, 0),
        Paint()
          ..color = baseline!
          ..strokeWidth = 1,
      );
    }
    // A glyph reads the shape, not the scale: stretch the payoff so caps and
    // coupons sit in view.
    final path = Path();
    const steps = 120;
    for (var i = 0; i <= steps; i++) {
      final x = _minX + (_maxX - _minX) * i / steps;
      final y = (payoff.at(x) * 1.15).clamp(_minY, _maxY);
      final p = map(x, y);
      // The autocall's jump at the barrier is a step, not a slope.
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_GlyphPainter old) =>
      old.payoff != payoff ||
      old.color != color ||
      old.baseline != baseline ||
      old.strokeWidth != strokeWidth;
}
