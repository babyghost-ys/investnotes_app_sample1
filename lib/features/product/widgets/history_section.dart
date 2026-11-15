import 'dart:math' as math;

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:keel_localisation/keel_localisation.dart';

import 'package:investnotes_app_sample1/core/l10n/generated/locales.dart';
import 'package:investnotes_app_sample1/core/formatting/formats.dart';
import 'package:investnotes_app_sample1/core/formatting/spoken.dart';
import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/core/widgets/sparkline.dart';
import 'package:investnotes_app_sample1/domain/models/product.dart';

/// The note's indicative value since issue, against par, with its high
/// and low.
class HistorySection extends StatelessWidget implements LocalisationConsumer {
  const HistorySection({super.key, required this.product});

  final Product product;

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
    final p = product;
    final f = Formats(general);
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
          f.percent(p.change, signed: true),
          semanticsLabel: words.semantics.returnSinceIssue(
            value: f.percent(p.change, signed: true),
          ),
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
          label: words.semantics.valueRange(
            from: f.fullDate(p.issueDate),
            to: f.fullDate(p.calledOn ?? _lastDay(p)),
            change: Spoken(general).change(p.change),
          ),
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
                  Text(f.fullDate(p.issueDate), style: dateStyle),
                  const Spacer(),
                  Text(f.fullDate(p.calledOn ?? _lastDay(p)), style: dateStyle),
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
              value: f.fixed(high),
              semantics: words.semantics.high(value: f.fixed(high)),
            ),
            _Extreme(
              icon: CupertinoIcons.arrow_down_to_line,
              value: f.fixed(low),
              semantics: words.semantics.low(value: f.fixed(low)),
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
  final String value;

  /// Said in place of [value].
  final String semantics;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Semantics(
      label: semantics,
      excludeSemantics: true,
      child: Row(
        children: [
          Icon(icon, size: 18, color: KeelColors.azure.of(context)),
          const SizedBox(width: 10),
          Text(
            value,
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
