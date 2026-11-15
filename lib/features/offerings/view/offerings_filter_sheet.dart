import 'package:flutter_native_widgets/flutter_native_widgets.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keel_localisation/keel_localisation.dart';

import 'package:investnotes_app_sample1/core/l10n/generated/locales.dart';
import 'package:investnotes_app_sample1/core/l10n/terms.dart';
import 'package:investnotes_app_sample1/app/sheet_arguments.dart';
import 'package:investnotes_app_sample1/core/draft/draft_bloc.dart';
import 'package:investnotes_app_sample1/core/formatting/formats.dart';
import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/core/widgets/filter_sheet_layout.dart';
import 'package:investnotes_app_sample1/core/widgets/note_icons.dart';
import 'package:investnotes_app_sample1/core/widgets/option_chip.dart';
import 'package:investnotes_app_sample1/core/widgets/round_icon_button.dart';
import 'package:investnotes_app_sample1/data/models/note_enums.dart';
import 'package:investnotes_app_sample1/data/models/offering.dart';
import 'package:investnotes_app_sample1/data/models/offering_filter.dart';
import 'package:investnotes_app_sample1/features/issued/view/date_pick_sheet.dart';
import 'package:investnotes_app_sample1/features/issued/widgets/range_button.dart';

/// Opens the offerings filter as a native sheet; completes with the applied
/// filter, or null when the sheet was closed.
Future<OfferingFilter?> showOfferingsFilter(
  BuildContext context, {
  required OfferingFilter current,
  required NoteType type,
  required List<Offering> offerings,
}) => NativeSheet.show<OfferingFilter>(
  context: context,
  route: 'offeringsFilter',
  arguments: SheetArguments.wrap(context, {
    'filter': current.encode(),
    'type': type.name,
  }),
  decodeResult: OfferingFilter.decode,
  detents: NativeFilterDetents.full,
  // The grabber shows, and a swipe down closes it; UIKit hands the drag to
  // the sheet once its list is scrolled to the top.
  backgroundColor: KeelColors.page.of(context),
  builder: (_) =>
      OfferingsFilterSheet(initial: current, type: type, offerings: offerings),
);

class OfferingsFilterSheet extends StatelessWidget
    implements LocalisationConsumer {
  const OfferingsFilterSheet({
    super.key,
    required this.initial,
    required this.type,
    required this.offerings,
  });

  final OfferingFilter initial;
  final NoteType type;
  final List<Offering> offerings;

  @override
  List<String> get namespaces => const [Locales.offerings, Locales.general];

  static Set<T> _flip<T>(Set<T> set, T value) {
    final next = {...set};
    if (!next.remove(value)) next.add(value);
    return next;
  }

  Widget _minHeadline(
    BuildContext context,
    DraftBloc<OfferingFilter> draft,
    OfferingFilter f,
    OfferingsLocale words,
    GeneralLocale general,
  ) {
    final formats = Formats(general);
    final azure = KeelColors.azure.of(context);
    final any = f.minHeadline <= 0;
    // The slider says what it sets and its value; the figure beside it
    // shows the same value, so it stays silent.
    return Row(
      children: [
        Icon(CupertinoIcons.arrow_up_to_line, size: 20, color: azure),
        const SizedBox(width: 8),
        Expanded(
          child: NativeSlider(
            value: f.minHeadline,
            min: 0,
            max: OfferingFilter.headlineCeiling,
            activeColor: azure,
            semanticLabel: words.semantics.lowestHeadline,
            semanticValue: any
                ? general.labels.any
                : words.semantics.atLeast(
                    value: formats.percent(f.minHeadline),
                  ),
            onChanged: (v) => draft.change(
              draft.state.value.copyWith(
                minHeadline: (v * 20).roundToDouble() / 20,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        ExcludeSemantics(
          child: Text(
            any
                ? general.labels.any
                : words.labels.atLeast(value: formats.percent(f.minHeadline)),
            style: TextStyle(
              color: KeelColors.ink.of(context),
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ],
    );
  }

  Widget _closesBy(
    BuildContext context,
    DraftBloc<OfferingFilter> draft,
    OfferingFilter f,
    OfferingsLocale words,
  ) {
    final today = DateTime.now();
    final day = DateTime(today.year, today.month, today.day);
    final last = offerings
        .map((o) => o.closes)
        .reduce((a, b) => a.isAfter(b) ? a : b);
    return Row(
      children: [
        Expanded(
          child: RangeButton(
            icon: CupertinoIcons.calendar_badge_minus,
            date: f.closesBy,
            semantics: words.semantics.closesBy,
            onTap: () async {
              final picked = await showDatePick(
                context,
                date: f.closesBy ?? day.add(const Duration(days: 14)),
                first: day,
                last: DateTime(last.year, last.month, last.day),
                end: true,
              );
              if (picked != null) {
                draft.change(draft.state.value.copyWith(closesBy: picked));
              }
            },
          ),
        ),
        if (f.closesBy != null) ...[
          const SizedBox(width: 8),
          RoundIconButton(
            icon: CupertinoIcons.xmark_circle_fill,
            label: words.semantics.anyClosingDate,
            foreground: KeelColors.muted.of(context),
            onPressed: () =>
                draft.change(draft.state.value.copyWith(clearClosesBy: true)),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) =>
        DraftBloc<OfferingFilter>(initial, reset: const OfferingFilter()),
    child: LocalisedBuilder(
      consumer: this,
      builder: (context, locale) => _sheet(
        context,
        locale[0] as OfferingsLocale,
        locale[1] as GeneralLocale,
      ),
    ),
  );

  Widget _sheet(
    BuildContext context,
    OfferingsLocale words,
    GeneralLocale general,
  ) => BlocBuilder<DraftBloc<OfferingFilter>, DraftState<OfferingFilter>>(
    builder: (context, state) {
      final draft = context.read<DraftBloc<OfferingFilter>>();
      final f = state.value;
      final count = f.apply(offerings.where((o) => o.type == type)).length;
      return FilterSheetLayout(
        scrolls: true,
        resultCount: count,
        onReset: f == const OfferingFilter()
            ? null
            : () => draft.add(const DraftReset()),
        onApply: () => NativeSheet.pop(context, f),
        groups: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final c in ShareClass.values)
                OptionChip(
                  text: c.title(general),
                  group: words.semantics.shareClass,
                  selected: f.classes.contains(c),
                  onTap: () =>
                      draft.change(f.copyWith(classes: _flip(f.classes, c))),
                ),
            ],
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final g in NoteGoal.values)
                OptionChip(
                  text: g.title(general),
                  group: words.semantics.goal,
                  icon: switch (g) {
                    NoteGoal.income => CupertinoIcons.arrow_2_circlepath,
                    NoteGoal.growth => CupertinoIcons.arrow_up_right,
                    NoteGoal.both => CupertinoIcons.chart_pie,
                  },
                  selected: f.goals.contains(g),
                  onTap: () =>
                      draft.change(f.copyWith(goals: _flip(f.goals, g))),
                ),
            ],
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final p in Payout.values)
                OptionChip(
                  text: p.title(general),
                  group: words.semantics.payout,
                  icon: switch (p) {
                    Payout.maturity => CupertinoIcons.flag_fill,
                    Payout.annual => CupertinoIcons.calendar,
                    Payout.quarterly => CupertinoIcons.calendar_today,
                  },
                  selected: f.payouts.contains(p),
                  onTap: () =>
                      draft.change(f.copyWith(payouts: _flip(f.payouts, p))),
                ),
            ],
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final c in Currency.values)
                OptionChip(
                  text: c.code,
                  group: general.semantics.currency,
                  selected: f.currencies.contains(c),
                  onTap: () => draft.change(
                    f.copyWith(currencies: _flip(f.currencies, c)),
                  ),
                ),
            ],
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final r in Region.values)
                OptionChip(
                  text: r.title(general),
                  group: general.semantics.region,
                  selected: f.regions.contains(r),
                  onTap: () =>
                      draft.change(f.copyWith(regions: _flip(f.regions, r))),
                ),
            ],
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final a in AssetClass.values)
                OptionChip(
                  text: a.title(general),
                  group: general.semantics.assetClass,
                  icon: NoteIcons.assetClass(a),
                  selected: f.assetClasses.contains(a),
                  onTap: () => draft.change(
                    f.copyWith(assetClasses: _flip(f.assetClasses, a)),
                  ),
                ),
            ],
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in TermBand.values)
                OptionChip(
                  text: t.title(general),
                  group: words.semantics.term,
                  icon: CupertinoIcons.hourglass,
                  selected: f.terms.contains(t),
                  onTap: () =>
                      draft.change(f.copyWith(terms: _flip(f.terms, t))),
                ),
            ],
          ),
          _minHeadline(context, draft, f, words, general),
          _closesBy(context, draft, f, words),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: NativeSegmentedControl(
                  labels: [
                    words.labels.sortClosing,
                    words.labels.sortHeadline,
                    words.labels.sortTerm,
                  ],
                  semanticLabels: [
                    words.semantics.sortClosing,
                    words.semantics.sortHeadline,
                    words.semantics.sortTerm,
                  ],
                  icons: const [
                    NativeIcon(
                      sfSymbol: 'calendar.badge.clock',
                      icon: CupertinoIcons.calendar,
                    ),
                    NativeIcon(
                      sfSymbol: 'chart.line.uptrend.xyaxis',
                      icon: CupertinoIcons.graph_square,
                    ),
                    NativeIcon(
                      sfSymbol: 'hourglass',
                      icon: CupertinoIcons.hourglass,
                    ),
                  ],
                  selectedIndex: f.sort.index,
                  onValueChanged: (i) =>
                      draft.change(f.copyWith(sort: OfferingSort.values[i])),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: NativeSegmentedControl(
                  labels: [words.labels.ascending, words.labels.descending],
                  semanticLabels: [
                    words.semantics.ascending,
                    words.semantics.descending,
                  ],
                  icons: const [
                    NativeIcon(
                      sfSymbol: 'arrow.up',
                      icon: CupertinoIcons.arrow_up,
                    ),
                    NativeIcon(
                      sfSymbol: 'arrow.down',
                      icon: CupertinoIcons.arrow_down,
                    ),
                  ],
                  selectedIndex: f.descending ? 1 : 0,
                  onValueChanged: (i) =>
                      draft.change(f.copyWith(descending: i == 1)),
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}
