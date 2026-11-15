import 'dart:math' as math;

import 'package:cupertino_ui/cupertino_ui.dart';

import 'package:investnotes_app_sample1/domain/models/biometric_kind.dart';

/// The Face ID or Touch ID glyph, drawn in one even stroke.
class BiometricGlyph extends StatelessWidget {
  const BiometricGlyph({
    super.key,
    required this.kind,
    required this.color,
    this.size = 24,
  });

  final BiometricKind kind;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: CustomPaint(
      painter: switch (kind) {
        BiometricKind.face => _FacePainter(color),
        BiometricKind.fingerprint => _FingerprintPainter(color),
      },
    ),
  );
}

Paint _stroke(Color color, double width) => Paint()
  ..color = color
  ..style = PaintingStyle.stroke
  ..strokeWidth = width
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round;

/// Four corner brackets around two eyes, a nose and a smile.
class _FacePainter extends CustomPainter {
  _FacePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size s) {
    final u = s.width / 24;
    final paint = _stroke(color, 1.7 * u);
    final inset = 1.6 * u, arm = 5.2 * u, r = 3.2 * u;
    final w = s.width, h = s.height;

    // Each corner: an arm along one edge, a rounded turn, an arm down the
    // other.
    void corner(Offset at, double dx, double dy) {
      final path = Path()
        ..moveTo(at.dx + dx * arm, at.dy)
        ..lineTo(at.dx + dx * r, at.dy)
        ..quadraticBezierTo(at.dx, at.dy, at.dx, at.dy + dy * r)
        ..lineTo(at.dx, at.dy + dy * arm);
      canvas.drawPath(path, paint);
    }

    corner(Offset(inset, inset), 1, 1);
    corner(Offset(w - inset, inset), -1, 1);
    corner(Offset(inset, h - inset), 1, -1);
    corner(Offset(w - inset, h - inset), -1, -1);

    // Eyes.
    canvas.drawLine(Offset(8.4 * u, 8.6 * u), Offset(8.4 * u, 10.4 * u), paint);
    canvas.drawLine(
      Offset(15.6 * u, 8.6 * u),
      Offset(15.6 * u, 10.4 * u),
      paint,
    );
    // Nose.
    canvas.drawPath(
      Path()
        ..moveTo(12.4 * u, 8.6 * u)
        ..lineTo(12.4 * u, 13 * u)
        ..lineTo(11.2 * u, 13 * u),
      paint,
    );
    // Smile.
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(12 * u, 13.4 * u),
        width: 7.6 * u,
        height: 5.4 * u,
      ),
      math.pi * 0.2,
      math.pi * 0.6,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_FacePainter old) => old.color != color;
}

/// Ridges of a fingertip: nested arcs open at the bottom, the inner ones
/// broken as real ridges are.
class _FingerprintPainter extends CustomPainter {
  _FingerprintPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size s) {
    final u = s.width / 24;
    final paint = _stroke(color, 1.6 * u);
    final centre = Offset(12 * u, 13 * u);
    const ridges = [
      (9.6, 0.92, 0.0),
      (7.4, 1.0, 0.18),
      (5.2, 1.1, 0.0),
      (3.0, 1.25, 0.3),
    ];
    for (final (radius, sweep, gap) in ridges) {
      final rect = Rect.fromCircle(center: centre, radius: radius * u);
      final start = math.pi * (1.5 - sweep / 2);
      final total = math.pi * sweep;
      if (gap == 0) {
        canvas.drawArc(rect, start, total, false, paint);
      } else {
        final cut = total * gap;
        canvas.drawArc(rect, start, total * 0.45, false, paint);
        canvas.drawArc(
          rect,
          start + total * 0.45 + cut,
          total * 0.55 - cut,
          false,
          paint,
        );
      }
    }
    canvas.drawLine(centre, Offset(centre.dx, 19 * u), paint);
  }

  @override
  bool shouldRepaint(_FingerprintPainter old) => old.color != color;
}
