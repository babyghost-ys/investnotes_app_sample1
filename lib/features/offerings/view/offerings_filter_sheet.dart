import 'package:flutter_native_widgets/flutter_native_widgets.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  arguments: {'filter': current.encode(), 'type': type.name},
  decodeResult: OfferingFilter.decode,
  detents: NativeFilterDetents.full,
  // A long sheet scrolls; dragging belongs to its content, and the close
  // control dismisses it.
  isDismissible: false,
  backgroundColor: KeelColors.page.of(context),
  builder: (_) =>
      OfferingsFilterSheet(initial: current, type: type, offerings: offerings),
);

class OfferingsFilterSheet extends StatelessWidget {
  const OfferingsFilterSheet({
    super.key,
    required this.initial,
    required this.type,
    required this.offerings,
  });

  final OfferingFilter initial;
  final NoteType type;
  final List<Offering> offerings;

  static Set<T> _flip<T>(Set<T> set, T value) {
    final next = {...set};
    if (!next.remove(value)) next.add(value);
    return next;
  }

  Widget _minHeadline(
    BuildContext context,
    DraftBloc<OfferingFilter> draft,
    OfferingFilter f,
  ) {
    final azure = KeelColors.azure.of(context);
    final any = f.minHeadline <= 0;
    return Semantics(
      label: any
          ? 'Any cap or coupon'
          : 'Cap or coupon at least ${Formats.percent(f.minHeadline)}',
      child: Row(
        children: [
          Icon(CupertinoIcons.arrow_up_to_line, size: 20, color: azure),
          const SizedBox(width: 8),
          Expanded(
            child: NativeSlider(
              value: f.minHeadline,
              min: 0,
              max: OfferingFilter.headlineCeiling,
              activeColor: azure,
              onChanged: (v) => draft.change(
                draft.state.value.copyWith(
                  minHeadline: (v * 20).roundToDouble() / 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            any ? 'Any' : '≥ ${Formats.percent(f.minHeadline)}',
            style: TextStyle(
              color: KeelColors.ink.of(context),
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _closesBy(
    BuildContext context,
    DraftBloc<OfferingFilter> draft,
    OfferingFilter f,
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
            semantics: 'Closes by',
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
            label: 'Any closing date',
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
    child: BlocBuilder<DraftBloc<OfferingFilter>, DraftState<OfferingFilter>>(
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
                    text: c.title,
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
                    text: g.title,
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
                    text: p.title,
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
                    text: r.title,
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
                    text: a.title,
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
                    text: t.title,
                    icon: CupertinoIcons.hourglass,
                    selected: f.terms.contains(t),
                    onTap: () =>
                        draft.change(f.copyWith(terms: _flip(f.terms, t))),
                  ),
              ],
            ),
            _minHeadline(context, draft, f),
            _closesBy(context, draft, f),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: NativeSegmentedControl(
                    labels: const ['Closing', 'Headline', 'Term'],
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
                    labels: const ['Ascending', 'Descending'],
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
    ),
  );
}
