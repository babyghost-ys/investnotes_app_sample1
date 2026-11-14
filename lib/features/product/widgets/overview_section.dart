import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/services.dart';

import 'package:investnotes_app_sample1/core/formatting/formats.dart';
import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/core/widgets/note_icons.dart';
import 'package:investnotes_app_sample1/core/widgets/round_icon_button.dart';
import 'package:investnotes_app_sample1/data/models/note_enums.dart';
import 'package:investnotes_app_sample1/data/models/product.dart';
import 'package:investnotes_app_sample1/features/offerings/widgets/fact_tile.dart';

/// What the note does in one sentence, its terms, and the code to order it.
class OverviewSection extends StatelessWidget {
  const OverviewSection({super.key, required this.product});

  final Product product;

  /// The payoff said plainly, from the note's own terms.
  static String summary(Product p) {
    final o = p.payoff;
    final upside = o.cap == null
        ? '${Formats.times(o.participation)} any rise in ${p.underlying}'
        : '${Formats.times(o.participation)} any rise in ${p.underlying}, '
              'up to ${Formats.percent(o.cap!)}';
    return switch (p.type) {
      NoteType.mld ||
      NoteType.ppn => 'All principal back at maturity, plus $upside.',
      NoteType.par =>
        'Earns $upside. The first ${Formats.percent(o.buffer)} of a fall '
            'costs nothing; beyond it, losses follow the market.',
      NoteType.auto =>
        'Pays ${Formats.percent(o.coupon)} if ${p.underlying} ends no lower '
            'than ${Formats.percent(o.barrier)}. Below that, the note falls '
            'with it.',
    };
  }

  List<FactTile> _facts() {
    final p = product;
    final o = p.payoff;
    return [
      FactTile(
        icon: CupertinoIcons.hourglass,
        value: Formats.years(p.termYears),
        semantics: 'Term ${Formats.years(p.termYears)}',
      ),
      switch (p.type) {
        NoteType.mld || NoteType.ppn => const FactTile(
          icon: CupertinoIcons.shield_fill,
          value: '100% principal',
          semantics: 'Principal fully protected at maturity',
        ),
        NoteType.par => FactTile(
          icon: CupertinoIcons.shield_lefthalf_fill,
          value: '${Formats.percent(o.buffer)} buffer',
          semantics: 'Losses buffered up to ${Formats.percent(o.buffer)}',
        ),
        NoteType.auto => FactTile(
          icon: CupertinoIcons.arrow_down_to_line,
          value: '${Formats.percent(o.barrier)} barrier',
          semantics: 'Barrier at ${Formats.percent(o.barrier)}',
        ),
      },
      if (p.type == NoteType.auto)
        FactTile(
          icon: CupertinoIcons.gift,
          value: '${Formats.percent(o.coupon)} coupon',
          semantics: 'Coupon ${Formats.percent(o.coupon)} over the term',
        )
      else
        FactTile(
          icon: CupertinoIcons.arrow_up_right,
          value: o.cap == null
              ? '${Formats.times(o.participation)} upside'
              : '${Formats.times(o.participation)} to ${Formats.percent(o.cap!)}',
          semantics: o.cap == null
              ? 'Participation ${Formats.times(o.participation)}, uncapped'
              : 'Participation ${Formats.times(o.participation)}, capped at ${Formats.percent(o.cap!)}',
        ),
      FactTile(
        icon: switch (p.currency) {
          Currency.usd => CupertinoIcons.money_dollar,
          Currency.eur => CupertinoIcons.money_euro,
          Currency.gbp => CupertinoIcons.money_pound,
        },
        value: p.currency.code,
        semantics: 'Currency ${p.currency.code}',
      ),
      FactTile(
        icon: NoteIcons.region(p.region),
        value: p.region.title,
        semantics: 'Region ${p.region.title}',
      ),
      FactTile(
        icon: NoteIcons.assetClass(p.assetClass),
        value: p.assetClass.title,
        semantics: 'Asset class ${p.assetClass.title}',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final ink = KeelColors.ink.of(context);
    final facts = _facts();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          summary(product),
          style: TextStyle(
            color: ink,
            fontSize: 19,
            height: 1.4,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 18),
        _Underlying(name: product.underlying),
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
        _Code(code: product.fundserv),
      ],
    );
  }
}

/// The index or basket the note follows, given its own line: it is the
/// note's subject.
class _Underlying extends StatelessWidget {
  const _Underlying({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: KeelColors.mist.of(context),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Semantics(
      label: 'Underlying $name',
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
  const _Code({required this.code});

  final String code;

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
            semanticsLabel: 'FundSERV code $code',
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
          label: 'Copy FundSERV code',
          foreground: KeelColors.azure.of(context),
          onPressed: () => Clipboard.setData(ClipboardData(text: code)),
        ),
      ],
    ),
  );
}
