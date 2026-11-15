import 'package:cupertino_ui/cupertino_ui.dart';

import 'package:investnotes_app_sample1/data/models/payoff.dart';

/// A note's payoff against the market's own move, with a marker at [move].
///
/// The dashed diagonal is holding the underlying directly; the solid line is
/// the note. Where the solid line sits above the dashed one, the note did
/// better.
class PayoffChart extends StatelessWidget {
  const PayoffChart({
    super.key,
    required this.payoff,
    required this.move,
    required this.lineColor,
    required this.marketColor,
    required this.gridColor,
    required this.labelColor,
    required this.tickLabel,
    this.height = 240,
  });

  static const minMove = -0.5, maxMove = 0.6;

  final Payoff payoff;
  final double move;
  final Color lineColor;
  final Color marketColor;
  final Color gridColor;
  final Color labelColor;

  /// A tick's market move as the language writes it, such as "+20%".
  final String Function(double move) tickLabel;
  final double height;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    width: double.infinity,
    child: CustomPaint(
      painter: _ChartPainter(
        payoff: payoff,
        move: move,
        line: lineColor,
        market: marketColor,
        grid: gridColor,
        label: labelColor,
        tickLabel: tickLabel,
        textScaler: MediaQuery.textScalerOf(context),
      ),
    ),
  );
}

class _ChartPainter extends CustomPainter {
  _ChartPainter({
    required this.payoff,
    required this.move,
    required this.line,
    required this.market,
    required this.grid,
    required this.label,
    required this.tickLabel,
    required this.textScaler,
  });

  final Payoff payoff;
  final double move;
  final Color line, market, grid, label;
  final String Function(double move) tickLabel;
  final TextScaler textScaler;

  static const _minY = -0.5, _maxY = 0.65;

  @override
  void paint(Canvas canvas, Size size) {
    const labelBand = 22.0;
    final h = size.height - labelBand;
    final w = size.width;
    Offset map(double x, double y) => Offset(
      (x - PayoffChart.minMove) /
          (PayoffChart.maxMove - PayoffChart.minMove) *
          w,
      (1 - (y - _minY) / (_maxY - _minY)) * h,
    );

    final gridPaint = Paint()
      ..color = grid
      ..strokeWidth = 1;
    // Zero axes.
    canvas.drawLine(
      map(PayoffChart.minMove, 0),
      map(PayoffChart.maxMove, 0),
      gridPaint,
    );
    canvas.drawLine(map(0, _minY), map(0, _maxY), gridPaint);

    // Market: dashed diagonal.
    final marketPaint = Paint()
      ..color = market
      ..strokeWidth = 1.5;
    const dashes = 60;
    for (var i = 0; i < dashes; i += 2) {
      final a =
          PayoffChart.minMove +
          (PayoffChart.maxMove - PayoffChart.minMove) * i / dashes;
      final b =
          PayoffChart.minMove +
          (PayoffChart.maxMove - PayoffChart.minMove) * (i + 1) / dashes;
      canvas.drawLine(
        map(a, a.clamp(_minY, _maxY)),
        map(b, b.clamp(_minY, _maxY)),
        marketPaint,
      );
    }

    // Note payoff with a soft fill to the zero line.
    final path = Path();
    final fill = Path()..moveTo(map(PayoffChart.minMove, 0).dx, map(0, 0).dy);
    const steps = 220;
    for (var i = 0; i <= steps; i++) {
      final x =
          PayoffChart.minMove +
          (PayoffChart.maxMove - PayoffChart.minMove) * i / steps;
      final p = map(x, payoff.at(x).clamp(_minY, _maxY));
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
      fill.lineTo(p.dx, p.dy);
    }
    fill
      ..lineTo(map(PayoffChart.maxMove, 0).dx, map(0, 0).dy)
      ..close();
    canvas.drawPath(fill, Paint()..color = line.withValues(alpha: 0.12));
    canvas.drawPath(
      path,
      Paint()
        ..color = line
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Marker at the chosen move.
    final at = map(move, payoff.at(move).clamp(_minY, _maxY));
    final onMarket = map(move, move.clamp(_minY, _maxY));
    canvas.drawLine(
      Offset(at.dx, 0),
      Offset(at.dx, h),
      Paint()
        ..color = line.withValues(alpha: 0.35)
        ..strokeWidth = 1,
    );
    canvas.drawCircle(onMarket, 4, Paint()..color = market);
    canvas.drawCircle(at, 8, Paint()..color = line.withValues(alpha: 0.25));
    canvas.drawCircle(at, 5, Paint()..color = line);

    // Move ticks under the chart.
    for (final tick in const [-0.4, -0.2, 0.0, 0.2, 0.4]) {
      final text = tickLabel(tick);
      final painter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: label,
            fontSize: 11,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        textDirection: TextDirection.ltr,
        textScaler: textScaler,
      )..layout();
      final x = map(tick, 0).dx - painter.width / 2;
      painter.paint(canvas, Offset(x, h + 6));
    }
  }

  @override
  bool shouldRepaint(_ChartPainter old) =>
      old.payoff != payoff ||
      old.move != move ||
      old.line != line ||
      old.market != market ||
      old.grid != grid ||
      old.label != label ||
      old.tickLabel(0.2) != tickLabel(0.2);
}
