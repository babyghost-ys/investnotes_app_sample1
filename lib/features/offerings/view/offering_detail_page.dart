import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart' show Icons;

import 'package:investnotes_app_sample1/app/keel_routes.dart';
import 'package:investnotes_app_sample1/core/formatting/formats.dart';
import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/core/widgets/note_icons.dart';
import 'package:investnotes_app_sample1/data/models/note_enums.dart';
import 'package:investnotes_app_sample1/data/models/offering.dart';
import 'package:investnotes_app_sample1/features/offerings/bloc/offerings_bloc.dart';
import 'package:investnotes_app_sample1/features/offerings/widgets/fact_tile.dart';
import 'package:investnotes_app_sample1/features/probe/widgets/payoff_probe.dart';

/// Pushes an offering's page.
Future<void> openOffering(BuildContext context, Offering offering) =>
    context.push<void>(KeelRoutes.offering(offering.id));

class OfferingDetailPage extends StatelessWidget {
  const OfferingDetailPage({super.key, required this.offering});

  final Offering offering;

  List<FactTile> _facts() {
    final o = offering;
    final p = o.payoff;
    return [
      FactTile(
        icon: CupertinoIcons.hourglass,
        value: Formats.years(o.termYears),
        semantics: 'Term ${Formats.years(o.termYears)}',
      ),
      FactTile(
        icon: CupertinoIcons.calendar,
        value: Formats.until(o.closes),
        semantics: 'Closes ${Formats.until(o.closes)}',
      ),
      switch (o.type) {
        NoteType.mld || NoteType.ppn => const FactTile(
          icon: CupertinoIcons.shield_fill,
          value: '100% principal',
          semantics: 'Principal fully protected at maturity',
        ),
        NoteType.par => FactTile(
          icon: CupertinoIcons.shield_lefthalf_fill,
          value: '${Formats.percent(p.buffer)} buffer',
          semantics: 'Losses buffered up to ${Formats.percent(p.buffer)}',
        ),
        NoteType.auto => FactTile(
          icon: CupertinoIcons.arrow_down_to_line,
          value: '${Formats.percent(p.barrier)} barrier',
          semantics: 'Barrier at ${Formats.percent(p.barrier)}',
        ),
      },
      if (o.type == NoteType.auto)
        FactTile(
          icon: CupertinoIcons.gift,
          value: '${Formats.percent(p.coupon)} coupon',
          semantics: 'Coupon ${Formats.percent(p.coupon)} over the term',
        )
      else
        FactTile(
          icon: CupertinoIcons.arrow_up_right,
          value: p.cap == null
              ? '${Formats.times(p.participation)} upside'
              : '${Formats.times(p.participation)} to ${Formats.percent(p.cap!)}',
          semantics: p.cap == null
              ? 'Participation ${Formats.times(p.participation)}, uncapped'
              : 'Participation ${Formats.times(p.participation)}, capped at ${Formats.percent(p.cap!)}',
        ),
      FactTile(
        icon: NoteIcons.region(o.region),
        value: o.region.title,
        semantics: 'Region ${o.region.title}',
      ),
      FactTile(
        icon: NoteIcons.assetClass(o.assetClass),
        value: o.assetClass.title,
        semantics: 'Asset class ${o.assetClass.title}',
      ),
      FactTile(
        icon: switch (o.currency) {
          Currency.usd => CupertinoIcons.money_dollar,
          Currency.eur => CupertinoIcons.money_euro,
          Currency.gbp => CupertinoIcons.money_pound,
        },
        value: o.currency.code,
        semantics: 'Currency ${o.currency.code}',
      ),
      FactTile(
        icon: CupertinoIcons.chart_bar_alt_fill,
        value: o.underlying,
        semantics: 'Underlying ${o.underlying}',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final saved = context.select<OfferingsBloc, bool>(
      (b) => b.state.saved.contains(offering.id),
    );
    final facts = _facts();
    return AdaptiveScaffold(
      extendBody: true,
      backgroundColor: KeelColors.page.of(context),
      appBar: AdaptiveAppBar(
        title: offering.type.code,
        actions: [
          AdaptiveAppBarAction(
            icon: AdaptiveIcon(
              sfSymbol: saved ? 'bookmark.fill' : 'bookmark',
              icon: saved ? Icons.bookmark : Icons.bookmark_border,
            ),
            label: saved ? 'Remove from saved' : 'Save',
            onPressed: () => context.read<OfferingsBloc>().add(
              OfferingSaveToggled(offering.id),
            ),
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          final insets = MediaQuery.paddingOf(context);
          return MediaQuery.removePadding(
            context: context,
            removeTop: true,
            removeBottom: true,
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                20,
                insets.top + 20,
                20,
                insets.bottom + 40,
              ),
              children: [
                Text(
                  offering.name,
                  style: TextStyle(
                    color: KeelColors.ink.of(context),
                    fontSize: 26,
                    height: 1.15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 26),
                PayoffProbe(payoff: offering.payoff),
                const SizedBox(height: 22),
                Container(height: 1, color: KeelColors.hairline.of(context)),
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
              ],
            ),
          );
        },
      ),
    );
  }
}
