import 'package:flutter_native_widgets/flutter_native_widgets.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:investnotes_app_sample1/core/draft/draft_bloc.dart';
import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/core/widgets/filter_sheet_layout.dart';
import 'package:investnotes_app_sample1/core/widgets/note_icons.dart';
import 'package:investnotes_app_sample1/core/widgets/option_chip.dart';
import 'package:investnotes_app_sample1/data/models/issued_filter.dart';
import 'package:investnotes_app_sample1/data/models/issued_note.dart';
import 'package:investnotes_app_sample1/data/models/note_enums.dart';
import 'package:investnotes_app_sample1/features/issued/view/date_pick_sheet.dart';
import 'package:investnotes_app_sample1/features/issued/widgets/range_button.dart';

/// Opens the issued-notes filter as a native sheet.
Future<IssuedFilter?> showIssuedFilter(
  BuildContext context, {
  required IssuedFilter current,
  required List<IssuedNote> notes,
}) => NativeSheet.show<IssuedFilter>(
  context: context,
  route: 'issuedFilter',
  arguments: current.encode(),
  decodeResult: IssuedFilter.decode,
  backgroundColor: KeelColors.page.of(context),
  builder: (_) => IssuedFilterSheet(initial: current, notes: notes),
);

class IssuedFilterSheet extends StatelessWidget {
  const IssuedFilterSheet({
    super.key,
    required this.initial,
    required this.notes,
  });

  final IssuedFilter initial;
  final List<IssuedNote> notes;

  static Set<T> _flip<T>(Set<T> set, T value) {
    final next = {...set};
    if (!next.remove(value)) next.add(value);
    return next;
  }

  static final _earliest = DateTime(2015);

  Widget _range(
    BuildContext context,
    DraftBloc<IssuedFilter> draft,
    IssuedFilter f,
  ) {
    final range = IssuedFilter.defaultRange();
    final from = f.from ?? range.from;
    final to = f.to ?? range.to;
    return Row(
      children: [
        Expanded(
          child: RangeButton(
            icon: CupertinoIcons.flag,
            date: from,
            semantics: 'From',
            onTap: () async {
              final picked = await showDatePick(
                context,
                date: from,
                first: _earliest,
                last: to,
                end: false,
              );
              if (picked != null) {
                draft.change(draft.state.value.copyWith(from: picked));
              }
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Icon(
            CupertinoIcons.arrow_right,
            size: 16,
            color: KeelColors.muted.of(context),
          ),
        ),
        Expanded(
          child: RangeButton(
            icon: CupertinoIcons.flag_fill,
            date: to,
            semantics: 'To',
            onTap: () async {
              final picked = await showDatePick(
                context,
                date: to,
                first: from,
                last: range.to,
                end: true,
              );
              if (picked != null) {
                draft.change(draft.state.value.copyWith(to: picked));
              }
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) =>
        DraftBloc<IssuedFilter>(initial, reset: const IssuedFilter()),
    child: BlocBuilder<DraftBloc<IssuedFilter>, DraftState<IssuedFilter>>(
      builder: (context, state) {
        final draft = context.read<DraftBloc<IssuedFilter>>();
        final f = state.value;
        return FilterSheetLayout(
          resultCount: f.apply(notes).length,
          onReset: f == const IssuedFilter()
              ? null
              : () => draft.add(const DraftReset()),
          onApply: () => NativeSheet.pop(context, f),
          groups: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final s in IssuedStatus.values)
                  OptionChip(
                    text: s.title,
                    icon: NoteIcons.status(s),
                    selected: f.statuses.contains(s),
                    onTap: () => draft.change(
                      f.copyWith(statuses: _flip(f.statuses, s)),
                    ),
                  ),
              ],
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final t in NoteType.values)
                  OptionChip(
                    text: t.code,
                    selected: f.types.contains(t),
                    onTap: () =>
                        draft.change(f.copyWith(types: _flip(f.types, t))),
                  ),
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                NativeSegmentedControl(
                  labels: [for (final p in IssuedPeriod.values) p.label],
                  selectedIndex: f.period.index,
                  onValueChanged: (i) {
                    final period = IssuedPeriod.values[i];
                    final range = IssuedFilter.defaultRange();
                    draft.change(
                      period == IssuedPeriod.custom
                          ? f.copyWith(
                              period: period,
                              from: f.from ?? range.from,
                              to: f.to ?? range.to,
                            )
                          : f.copyWith(period: period),
                    );
                  },
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.topCenter,
                  child: f.period == IssuedPeriod.custom
                      ? Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: _range(context, draft, f),
                        )
                      : const SizedBox(width: double.infinity),
                ),
              ],
            ),
          ],
        );
      },
    ),
  );
}
