import 'dart:math' as math;

import 'package:cupertino_ui/cupertino_ui.dart';

import 'package:investnotes_app_sample1/core/formatting/formats.dart';
import 'package:investnotes_app_sample1/core/formatting/spoken.dart';
import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/core/widgets/sparkline.dart';
import 'package:investnotes_app_sample1/data/models/product.dart';

/// The note's indicative value since issue, against par, with its high
/// and low.
class HistorySection extends StatelessWidget {
  const HistorySection({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final p = product;
    final color = p.change < 0
        ? KeelColors.loss.of(context)
        : KeelColors.azure.of(context);
    final muted = KeelColors.muted.of(context);
    final high = p.history.reduce(math.max) * 100;
    final low = p.history.reduce(math.min) * 100;
    final dateStyle = TextStyle(color: muted, fontSize: 13);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          Formats.percent(p.change, signed: true),
          semanticsLabel:
              'Return since issue ${Formats.percent(p.change, signed: true)}',
          style: TextStyle(
            color: color,
            fontSize: 44,
            height: 1,
            fontWeight: FontWeight.w700,
            letterSpacing: -1.2,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 20),
        Semantics(
          label:
              'Value from ${Formats.fullDate(p.issueDate)} to ${Formats.fullDate(p.calledOn ?? _lastDay(p))}, ${Spoken.change(p.change)}',
          excludeSemantics: true,
          child: Column(
            children: [
              Sparkline(
                values: p.history,
                color: color,
                parColor: KeelColors.hairline.of(context),
                height: 200,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(Formats.fullDate(p.issueDate), style: dateStyle),
                  const Spacer(),
                  Text(
                    Formats.fullDate(p.calledOn ?? _lastDay(p)),
                    style: dateStyle,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            _Extreme(
              icon: CupertinoIcons.arrow_up_to_line,
              value: high,
              semantics: 'High',
            ),
            _Extreme(
              icon: CupertinoIcons.arrow_down_to_line,
              value: low,
              semantics: 'Low',
            ),
          ],
        ),
      ],
    );
  }

  /// The path runs to today, or to maturity once the note has matured.
  static DateTime _lastDay(Product p) {
    final today = DateTime.now();
    return p.maturity.isBefore(today) ? p.maturity : today;
  }
}

class _Extreme extends StatelessWidget {
  const _Extreme({
    required this.icon,
    required this.value,
    required this.semantics,
  });

  final IconData icon;
  final double value;
  final String semantics;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Semantics(
      label: '$semantics ${value.toStringAsFixed(2)}',
      excludeSemantics: true,
      child: Row(
        children: [
          Icon(icon, size: 18, color: KeelColors.azure.of(context)),
          const SizedBox(width: 10),
          Text(
            value.toStringAsFixed(2),
            style: TextStyle(
              color: KeelColors.ink.of(context),
              fontSize: 17,
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    ),
  );
}
