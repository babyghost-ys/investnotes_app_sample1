import 'package:cupertino_ui/cupertino_ui.dart';

/// Keel's mark: a hull on the waterline with its keel below, the one
/// shape that stays steady whatever the water does.
class KeelMark extends StatelessWidget {
  const KeelMark({super.key, required this.color, this.size = 32});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Keel',
    image: true,
    child: SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _KeelPainter(color)),
    ),
  );
}

class _KeelPainter extends CustomPainter {
  _KeelPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width, h = s.height;
    final fill = Paint()
      ..color = color
      ..isAntiAlias = true;
    // Hull: a shallow crescent sitting on the waterline.
    final hull = Path()
      ..moveTo(w * 0.06, h * 0.42)
      ..lineTo(w * 0.94, h * 0.42)
      ..cubicTo(w * 0.86, h * 0.62, w * 0.68, h * 0.66, w * 0.5, h * 0.66)
      ..cubicTo(w * 0.32, h * 0.66, w * 0.14, h * 0.62, w * 0.06, h * 0.42)
      ..close();
    canvas.drawPath(hull, fill);
    // Keel fin, tapering to a rounded foot.
    final fin = Path()
      ..moveTo(w * 0.44, h * 0.6)
      ..lineTo(w * 0.56, h * 0.6)
      ..lineTo(w * 0.535, h * 0.9)
      ..quadraticBezierTo(w * 0.5, h * 0.95, w * 0.465, h * 0.9)
      ..close();
    canvas.drawPath(fin, fill);
    // Mast and sail: a rising line, the upside.
    final sail = Path()
      ..moveTo(w * 0.52, h * 0.06)
      ..lineTo(w * 0.52, h * 0.36)
      ..lineTo(w * 0.8, h * 0.36)
      ..close();
    canvas.drawPath(sail, fill);
    final jib = Path()
      ..moveTo(w * 0.47, h * 0.14)
      ..lineTo(w * 0.47, h * 0.36)
      ..lineTo(w * 0.27, h * 0.36)
      ..close();
    canvas.drawPath(jib, fill..color = color.withValues(alpha: 0.6));
  }

  @override
  bool shouldRepaint(_KeelPainter old) => old.color != color;
}
