import 'dart:math' as math;

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:keel_localisation/keel_localisation.dart';

import 'package:investnotes_app_sample1/core/l10n/generated/locales.dart';
import 'package:investnotes_app_sample1/core/formatting/formats.dart';
import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/data/models/payoff.dart';

/// What the note pays at maturity for a ladder of market moves, the
/// market's move drawn as a thin line under the note's bar.
class ScenariosSection extends StatelessWidget implements LocalisationConsumer {
  const ScenariosSection({super.key, required this.payoff});

  final Payoff payoff;

  static const moves = [
    0.6,
    0.4,
    0.3,
    0.2,
    0.1,
    0.0,
    -0.1,
    -0.2,
    -0.3,
    -0.4,
    -0.5,
  ];

  @override
  List<String> get namespaces => const [Locales.product, Locales.general];

  @override
  Widget build(BuildContext context) => LocalisedBuilder(
    consumer: this,
    builder: (context, locale) =>
        _build(context, locale[0] as ProductLocale, locale[1] as GeneralLocale),
  );

  Widget _build(
    BuildContext context,
    ProductLocale words,
    GeneralLocale general,
  ) {
    final reach = moves
        .map((m) => math.max(m.abs(), payoff.at(m).abs()))
        .reduce(math.max);
    final muted = KeelColors.muted.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // A key to the bars; each row below says its own figures.
        ExcludeSemantics(
          child: Row(
            children: [
              Container(width: 18, height: 2, color: muted),
              const SizedBox(width: 6),
              Text(
                words.labels.market,
                style: TextStyle(color: muted, fontSize: 13),
              ),
              const SizedBox(width: 18),
              Container(
                width: 18,
                height: 8,
                decoration: BoxDecoration(
                  color: KeelColors.azure.of(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                words.labels.note,
                style: TextStyle(color: muted, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        for (final m in moves)
          _Row(
            move: m,
            result: payoff.at(m),
            reach: reach,
            words: words,
            formats: Formats(general),
          ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.move,
    required this.result,
    required this.reach,
    required this.words,
    required this.formats,
  });

  final double move;
  final double result;
  final double reach;
  final ProductLocale words;
  final Formats formats;

  @override
  Widget build(BuildContext context) {
    final azure = KeelColors.azure.of(context);
    final loss = KeelColors.loss.of(context);
    final muted = KeelColors.muted.of(context);
    final color = result < 0 ? loss : azure;
    final figures = const [FontFeature.tabularFigures()];
    return Semantics(
      label: words.semantics.scenario(
        move: formats.percent(move, signed: true),
        result: formats.percent(result, signed: true),
      ),
      excludeSemantics: true,
      child: SizedBox(
        height: 40,
        child: Row(
          children: [
            SizedBox(
              width: 52,
              child: Text(
                formats.percent(move, signed: true),
                style: TextStyle(
                  color: muted,
                  fontSize: 14,
                  fontFeatures: figures,
                ),
              ),
            ),
            Expanded(
              child: CustomPaint(
                painter: _BarPainter(
                  move: move / reach,
                  result: result / reach,
                  color: color,
                  market: muted,
                  axis: KeelColors.hairline.of(context),
                ),
                child: const SizedBox.expand(),
              ),
            ),
            SizedBox(
              width: 64,
              child: Text(
                formats.percent(result, signed: true),
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFeatures: figures,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BarPainter extends CustomPainter {
  _BarPainter({
    required this.move,
    required this.result,
    required this.color,
    required this.market,
    required this.axis,
  });

  /// Both as fractions of the widest value, -1 to 1.
  final double move;
  final double result;
  final Color color;
  final Color market;
  final Color axis;

  @override
  void paint(Canvas canvas, Size size) {
    final mid = size.width / 2;
    final half = size.width / 2 - 6;
    final y = size.height / 2;
    canvas.drawLine(
      Offset(mid, 4),
      Offset(mid, size.height - 4),
      Paint()
        ..color = axis
        ..strokeWidth = 1,
    );
    if (result != 0) {
      final end = mid + result * half;
      canvas.drawRRect(
        RRect.fromLTRBR(
          math.min(mid, end),
          y - 7,
          math.max(mid, end),
          y + 7,
          const Radius.circular(3),
        ),
        Paint()..color = color,
      );
    }
    if (move != 0) {
      canvas.drawLine(
        Offset(mid, y),
        Offset(mid + move * half, y),
        Paint()
          ..color = market
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_BarPainter old) =>
      old.move != move || old.result != result || old.color != color;
}
