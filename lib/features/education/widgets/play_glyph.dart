import 'package:cupertino_ui/cupertino_ui.dart';

/// A solid white disc with a play triangle cut in tide blue: the film mark
/// on a poster. Not a control on its own; the poster is.
class PlayGlyph extends StatelessWidget {
  const PlayGlyph({super.key, this.size = 56});

  final double size;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: const CustomPaint(painter: _PlayPainter()),
  );
}

class _PlayPainter extends CustomPainter {
  const _PlayPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.shortestSide / 2;
    final c = size.center(Offset.zero);
    canvas.drawCircle(
      c,
      r,
      Paint()..color = CupertinoColors.white.withValues(alpha: 0.94),
    );
    // Optically centred: a triangle's weight sits left of its box centre.
    final s = r * 0.78;
    final ox = c.dx + s * 0.12;
    final tri = Path()
      ..moveTo(ox - s * 0.42, c.dy - s * 0.5)
      ..lineTo(ox + s * 0.5, c.dy)
      ..lineTo(ox - s * 0.42, c.dy + s * 0.5)
      ..close();
    canvas.drawPath(
      tri,
      Paint()
        ..color = const Color(0xFF0B3D91)
        ..style = PaintingStyle.fill
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_PlayPainter old) => false;
}
