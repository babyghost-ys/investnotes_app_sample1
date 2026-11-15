import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/services.dart';
import 'package:keel_localisation/keel_localisation.dart';

import 'package:investnotes_app_sample1/core/l10n/terms.dart';
import 'package:investnotes_app_sample1/core/l10n/generated/locales.dart';
import 'package:investnotes_app_sample1/core/formatting/formats.dart';
import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/core/widgets/note_icons.dart';
import 'package:investnotes_app_sample1/core/widgets/round_icon_button.dart';
import 'package:investnotes_app_sample1/domain/models/note_enums.dart';
import 'package:investnotes_app_sample1/domain/models/product.dart';
import 'package:investnotes_app_sample1/features/offerings/widgets/fact_tile.dart';

/// What the note does in one sentence, its terms, and the code to order it.
class OverviewSection extends StatelessWidget implements LocalisationConsumer {
  const OverviewSection({super.key, required this.product});

  final Product product;

  /// The payoff said plainly, from the note's own terms.
  static String summary(Product p, ProductLocale words, GeneralLocale general) {
    final o = p.payoff;
    final f = Formats(general);
    final upside = o.cap == null
        ? words.labels.upside(
            times: f.times(o.participation),
            underlying: p.underlying,
          )
        : words.labels.upsideCapped(
            times: f.times(o.participation),
            underlying: p.underlying,
            cap: f.percent(o.cap!),
          );
    return switch (p.type) {
      NoteType.mld ||
      NoteType.ppn => words.labels.summaryProtected(upside: upside),
      NoteType.par => words.labels.summaryBuffered(
        upside: upside,
        buffer: f.percent(o.buffer),
      ),
      NoteType.auto => words.labels.summaryAuto(
        coupon: f.percent(o.coupon),
        underlying: p.underlying,
        barrier: f.percent(o.barrier),
      ),
    };
  }

  List<FactTile> _facts(ProductLocale words, GeneralLocale general) {
    final p = product;
    final o = p.payoff;
    final f = Formats(general);
    final years = f.years(p.termYears);
    return [
      FactTile(
        icon: CupertinoIcons.hourglass,
        value: years,
        semantics: words.semantics.term(value: years),
      ),
      switch (p.type) {
        NoteType.mld || NoteType.ppn => FactTile(
          icon: CupertinoIcons.shield_fill,
          value: words.labels.fullPrincipal,
          semantics: words.semantics.fullPrincipal,
        ),
        NoteType.par => FactTile(
          icon: CupertinoIcons.shield_lefthalf_fill,
          value: words.labels.buffer(value: f.percent(o.buffer)),
          semantics: words.semantics.buffer(value: f.percent(o.buffer)),
        ),
        NoteType.auto => FactTile(
          icon: CupertinoIcons.arrow_down_to_line,
          value: words.labels.barrier(value: f.percent(o.barrier)),
          semantics: words.semantics.barrier(value: f.percent(o.barrier)),
        ),
      },
      if (p.type == NoteType.auto)
        FactTile(
          icon: CupertinoIcons.gift,
          value: words.labels.coupon(value: f.percent(o.coupon)),
          semantics: words.semantics.coupon(value: f.percent(o.coupon)),
        )
      else
        FactTile(
          icon: CupertinoIcons.arrow_up_right,
          value: o.cap == null
              ? words.labels.uncapped(times: f.times(o.participation))
              : words.labels.capped(
                  times: f.times(o.participation),
                  cap: f.percent(o.cap!),
                ),
          semantics: o.cap == null
              ? words.semantics.uncapped(times: f.times(o.participation))
              : words.semantics.capped(
                  times: f.times(o.participation),
                  cap: f.percent(o.cap!),
                ),
        ),
      FactTile(
        icon: switch (p.currency) {
          Currency.usd => CupertinoIcons.money_dollar,
          Currency.eur => CupertinoIcons.money_euro,
          Currency.gbp => CupertinoIcons.money_pound,
        },
        value: p.currency.code,
        semantics: words.semantics.currency(value: p.currency.code),
      ),
      FactTile(
        icon: NoteIcons.region(p.region),
        value: p.region.title(general),
        semantics: words.semantics.region(value: p.region.title(general)),
      ),
      FactTile(
        icon: NoteIcons.assetClass(p.assetClass),
        value: p.assetClass.title(general),
        semantics: words.semantics.assetClass(
          value: p.assetClass.title(general),
        ),
      ),
    ];
  }

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
    final ink = KeelColors.ink.of(context);
    final facts = _facts(words, general);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          summary(product, words, general),
          style: TextStyle(
            color: ink,
            fontSize: 19,
            height: 1.4,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 18),
        _Underlying(name: product.underlying, words: words),
        const SizedBox(height: 6),
        LayoutBuilder(
          builder: (context, box) {
            final half = (box.maxWidth - 16) / 2;
            return Wrap(
              spacing: 16,
              children: [
                for (final f in facts) SizedBox(width: half, child: f),
              ],
            );
          },
        ),
        const SizedBox(height: 10),
        Container(height: 1, color: KeelColors.hairline.of(context)),
        _Code(code: product.fundserv, words: words),
      ],
    );
  }
}

/// The index or basket the note follows, given its own line: it is the
/// note's subject.
class _Underlying extends StatelessWidget {
  const _Underlying({required this.name, required this.words});

  final String name;
  final ProductLocale words;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: KeelColors.mist.of(context),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Semantics(
      label: words.semantics.underlying(name: name),
      excludeSemantics: true,
      child: Row(
        children: [
          Icon(
            CupertinoIcons.chart_bar_alt_fill,
            size: 18,
            color: KeelColors.azure.of(context),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                color: KeelColors.ink.of(context),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

/// The FundSERV order code, set in figures, with a copy control: advisers
/// paste it straight into an order ticket.
class _Code extends StatelessWidget {
  const _Code({required this.code, required this.words});

  final String code;
  final ProductLocale words;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Row(
      children: [
        Icon(
          CupertinoIcons.barcode,
          size: 20,
          color: KeelColors.azure.of(context),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            code,
            semanticsLabel: words.semantics.fundserv(code: code),
            style: TextStyle(
              color: KeelColors.ink.of(context),
              fontSize: 17,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
        RoundIconButton(
          icon: CupertinoIcons.doc_on_doc,
          label: words.semantics.copyFundserv,
          foreground: KeelColors.azure.of(context),
          onPressed: () => Clipboard.setData(ClipboardData(text: code)),
        ),
      ],
    ),
  );
}
