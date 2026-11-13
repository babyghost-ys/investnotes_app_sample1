import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:investnotes_app_sample1/core/draft/draft_bloc.dart';
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
}) => AdaptiveNativeSheet.show<OfferingFilter>(
  context: context,
  route: 'offeringsFilter',
  arguments: {'filter': current.encode(), 'type': type.name},
  decodeResult: OfferingFilter.decode,
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
          resultCount: count,
          onReset: f == const OfferingFilter()
              ? null
              : () => draft.add(const DraftReset()),
          onApply: () => AdaptiveNativeSheet.pop(context, f),
          groups: [
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
            _closesBy(context, draft, f),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: AdaptiveSegmentedControl(
                    labels: const ['Closing', 'Headline', 'Term'],
                    icons: const [
                      AdaptiveIcon(
                        sfSymbol: 'calendar.badge.clock',
                        icon: CupertinoIcons.calendar,
                      ),
                      AdaptiveIcon(
                        sfSymbol: 'chart.line.uptrend.xyaxis',
                        icon: CupertinoIcons.graph_square,
                      ),
                      AdaptiveIcon(
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
                  child: AdaptiveSegmentedControl(
                    labels: const ['Ascending', 'Descending'],
                    icons: const [
                      AdaptiveIcon(
                        sfSymbol: 'arrow.up',
                        icon: CupertinoIcons.arrow_up,
                      ),
                      AdaptiveIcon(
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
