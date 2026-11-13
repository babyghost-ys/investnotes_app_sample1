import 'package:cupertino_ui/cupertino_ui.dart';

/// A value path with a soft fill, against a dashed par line at 1.0.
class Sparkline extends StatelessWidget {
  const Sparkline({
    super.key,
    required this.values,
    required this.color,
    required this.parColor,
    this.height = 96,
  });

  final List<double> values;
  final Color color;
  final Color parColor;
  final double height;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    width: double.infinity,
    child: CustomPaint(painter: _SparkPainter(values, color, parColor)),
  );
}

class _SparkPainter extends CustomPainter {
  _SparkPainter(this.values, this.color, this.parColor);

  final List<double> values;
  final Color color;
  final Color parColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    var lo = values.reduce((a, b) => a < b ? a : b);
    var hi = values.reduce((a, b) => a > b ? a : b);
    lo = lo < 1 ? lo : 1;
    hi = hi > 1 ? hi : 1;
    final span = (hi - lo).abs() < 0.0001 ? 0.01 : hi - lo;
    const pad = 4.0;
    double y(double v) => pad + (1 - (v - lo) / span) * (size.height - pad * 2);
    double x(int i) => i / (values.length - 1) * size.width;

    // Par line, dashed.
    final par = Paint()
      ..color = parColor
      ..strokeWidth = 1;
    for (double dx = 0; dx < size.width; dx += 8) {
      canvas.drawLine(Offset(dx, y(1)), Offset(dx + 4, y(1)), par);
    }

    final line = Path()..moveTo(x(0), y(values[0]));
    for (var i = 1; i < values.length; i++) {
      line.lineTo(x(i), y(values[i]));
    }
    final area = Path.from(line)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      area,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: 0.22), color.withValues(alpha: 0)],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      line,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawCircle(
      Offset(x(values.length - 1), y(values.last)),
      3.5,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_SparkPainter old) =>
      old.values != values || old.color != color || old.parColor != parColor;
}
