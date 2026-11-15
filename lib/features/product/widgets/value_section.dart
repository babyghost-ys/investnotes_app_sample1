import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:keel_localisation/keel_localisation.dart';

import 'package:investnotes_app_sample1/core/l10n/generated/locales.dart';
import 'package:investnotes_app_sample1/core/formatting/formats.dart';
import 'package:investnotes_app_sample1/core/formatting/spoken.dart';
import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/data/models/product.dart';

/// Where the note stands now: its indicative price per 100 of principal,
/// the change since issue, and how far through its term it is.
class ValueSection extends StatelessWidget implements LocalisationConsumer {
  const ValueSection({super.key, required this.product});

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
    final ink = KeelColors.ink.of(context);
    final muted = KeelColors.muted.of(context);
    final azure = KeelColors.azure.of(context);
    final changeColor = p.change < 0 ? KeelColors.loss.of(context) : azure;
    final end = p.calledOn ?? p.maturity;
    final today = DateTime.now();
    final total = end.difference(p.issueDate).inDays;
    final done = today.difference(p.issueDate).inDays.clamp(0, total);
    final progress = total == 0 ? 1.0 : done / total;
    final figures = const [FontFeature.tabularFigures()];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              f.fixed(p.price!),
              semanticsLabel: words.semantics.price(value: f.fixed(p.price!)),
              style: TextStyle(
                color: ink,
                fontSize: 56,
                height: 1,
                fontWeight: FontWeight.w700,
                letterSpacing: -1.8,
                fontFeatures: figures,
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(bottom: 7),
              // The price already says "per 100".
              child: ExcludeSemantics(
                child: Text(
                  words.labels.perHundred,
                  style: TextStyle(color: muted, fontSize: 17),
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                f.percent(p.change, signed: true),
                semanticsLabel: Spoken(general).change(p.change),
                style: TextStyle(
                  color: changeColor,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  fontFeatures: figures,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Semantics(
          label: words.semantics.termGone(
            percent: f.percent((progress * 100).roundToDouble() / 100),
            from: f.fullDate(p.issueDate),
            to: f.fullDate(end),
          ),
          excludeSemantics: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LayoutBuilder(
                builder: (context, box) => Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: KeelColors.mist.of(context),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    Container(
                      height: 10,
                      width: box.maxWidth * progress,
                      decoration: BoxDecoration(
                        color: azure,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(CupertinoIcons.flag, size: 15, color: muted),
                  const SizedBox(width: 6),
                  Text(
                    f.fullDate(p.issueDate),
                    style: TextStyle(color: muted, fontSize: 13),
                  ),
                  const Spacer(),
                  Text(
                    f.fullDate(end),
                    style: TextStyle(color: muted, fontSize: 13),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    p.calledOn == null
                        ? CupertinoIcons.flag_circle
                        : CupertinoIcons.bell,
                    size: 15,
                    color: muted,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
