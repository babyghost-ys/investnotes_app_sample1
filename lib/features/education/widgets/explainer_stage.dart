import 'dart:math' as math;

import 'package:cupertino_ui/cupertino_ui.dart';

import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/data/models/explainer.dart';
import 'package:investnotes_app_sample1/data/models/note_enums.dart';

/// An explainer film's frame at [progress] (0 at issue, 1 at maturity):
/// the market's path in pale white, the note's return over it in bright
/// blue, and the note's rules (floor, buffer, cap, barrier) as zones and
/// lines behind them. No words: the figures sit outside the frame.
class ExplainerStage extends StatelessWidget {
  const ExplainerStage({
    super.key,
    required this.explainer,
    required this.progress,
    this.radius = 22,
  });

  final Explainer explainer;
  final double progress;
  final double radius;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            KeelColors.tide.of(context),
            KeelColors.tideDeep.of(context),
          ],
        ),
      ),
      child: CustomPaint(
        painter: _StagePainter(explainer, progress),
        child: const SizedBox.expand(),
      ),
    ),
  );
}

class _StagePainter extends CustomPainter {
  _StagePainter(this.explainer, this.progress);

  final Explainer explainer;
  final double progress;

  static const _note = Color(0xFF8CC4FF);
  static const _minY = -0.42, _maxY = 0.5;

  @override
  void paint(Canvas canvas, Size size) {
    final pad = EdgeInsets.fromLTRB(
      size.width * 0.07,
      size.height * 0.12,
      size.width * 0.07,
      size.height * 0.12,
    );
    final w = size.width - pad.horizontal, h = size.height - pad.vertical;
    double yOf(double v) =>
        pad.top + (1 - (v.clamp(_minY, _maxY) - _minY) / (_maxY - _minY)) * h;
    Offset at(double t, double v) => Offset(pad.left + t * w, yOf(v));

    final payoff = explainer.payoff;
    final zone = Paint()..color = KeelColors.foam.withValues(alpha: 0.09);
    final right = size.width;

    // The note's rules, drawn across the whole term.
    switch (payoff.type) {
      case NoteType.mld:
      case NoteType.ppn:
        // Everything below the start is the floor's to absorb.
        canvas.drawRect(Rect.fromLTRB(0, yOf(0), right, size.height), zone);
      case NoteType.par:
        canvas.drawRect(
          Rect.fromLTRB(0, yOf(0), right, yOf(-payoff.buffer)),
          zone,
        );
      case NoteType.auto:
        _dashed(canvas, yOf(payoff.barrier), right, KeelColors.foam, 0.55);
    }
    final cap = payoff.cap;
    if (cap != null) {
      _dashed(
        canvas,
        yOf(cap / payoff.participation),
        right,
        KeelColors.foam,
        0.4,
      );
    }
    canvas.drawLine(
      Offset(0, yOf(0)),
      Offset(right, yOf(0)),
      Paint()
        ..color = KeelColors.foam.withValues(alpha: 0.35)
        ..strokeWidth = 1,
    );

    final t = progress.clamp(0.0, 1.0);
    if (t <= 0) {
      _head(canvas, at(0, 0), CupertinoColors.white, 5);
      return;
    }
    final market = Path(), note = Path();
    const steps = 160;
    final last = (steps * t).ceil();
    for (var i = 0; i <= last; i++) {
      final s = math.min(i / steps, t);
      final move = explainer.moveAt(s);
      final m = at(s, move), n = at(s, payoff.at(move));
      if (i == 0) {
        market.moveTo(m.dx, m.dy);
        note.moveTo(n.dx, n.dy);
      } else {
        market.lineTo(m.dx, m.dy);
        note.lineTo(n.dx, n.dy);
      }
    }
    final stroke = size.shortestSide * 0.012 + 1.2;
    canvas.drawPath(
      _dash(market, stroke * 2.6, stroke * 2.2),
      Paint()
        ..color = CupertinoColors.white.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke * 0.8
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      note,
      Paint()
        ..color = _note
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke * 1.25
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );
    final move = explainer.moveAt(t);
    final dot = stroke * 2.2;
    _head(canvas, at(t, move), CupertinoColors.white, dot * 0.8);
    _head(canvas, at(t, payoff.at(move)), _note, dot);
  }

  /// [path] cut into dashes: the market's line, as on every payoff chart.
  Path _dash(Path path, double on, double off) {
    final out = Path();
    for (final metric in path.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += on + off) {
        out.addPath(metric.extractPath(d, d + on), Offset.zero);
      }
    }
    return out;
  }

  void _dashed(Canvas canvas, double y, double width, Color color, double a) {
    final paint = Paint()
      ..color = color.withValues(alpha: a)
      ..strokeWidth = 1.2;
    for (var x = 0.0; x < width; x += 9) {
      canvas.drawLine(Offset(x, y), Offset(x + 5, y), paint);
    }
  }

  void _head(Canvas canvas, Offset c, Color color, double r) {
    canvas.drawCircle(
      c,
      r * 1.9,
      Paint()..color = color.withValues(alpha: 0.2),
    );
    canvas.drawCircle(c, r, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_StagePainter old) =>
      old.progress != progress || old.explainer != explainer;
}
