import 'package:flutter_native_widgets/flutter_native_widgets.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keel_localisation/keel_localisation.dart';

import 'package:investnotes_app_sample1/data/mappers/notes_mapper.dart';
import 'package:investnotes_app_sample1/core/l10n/terms.dart';
import 'package:investnotes_app_sample1/core/l10n/generated/locales.dart';
import 'package:investnotes_app_sample1/app/sheet_arguments.dart';
import 'package:investnotes_app_sample1/core/draft/draft_bloc.dart';
import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/core/widgets/filter_sheet_layout.dart';
import 'package:investnotes_app_sample1/core/widgets/note_icons.dart';
import 'package:investnotes_app_sample1/core/widgets/option_chip.dart';
import 'package:investnotes_app_sample1/domain/models/issued_filter.dart';
import 'package:investnotes_app_sample1/domain/models/issued_note.dart';
import 'package:investnotes_app_sample1/domain/models/note_enums.dart';
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
  // The sheet runs in its own engine: the notes go with it as JSON.
  arguments: SheetArguments.wrap(context, {
    'filter': current.encode(),
    'notes': NotesJson.fromIssued(notes),
  }),
  decodeResult: IssuedFilter.decode,
  backgroundColor: KeelColors.page.of(context),
  builder: (_) => IssuedFilterSheet(initial: current, notes: notes),
);

class IssuedFilterSheet extends StatelessWidget
    implements LocalisationConsumer {
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
    IssuedLocale issued,
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
            semantics: issued.semantics.from,
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
            semantics: issued.semantics.to,
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
  List<String> get namespaces => const [Locales.issued, Locales.general];

  @override
  Widget build(BuildContext context) => LocalisedBuilder(
    consumer: this,
    builder: (context, locale) =>
        _build(context, locale[0] as IssuedLocale, locale[1] as GeneralLocale),
  );

  Widget _build(
    BuildContext context,
    IssuedLocale issued,
    GeneralLocale general,
  ) => BlocProvider(
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
                    text: s.title(general),
                    group: issued.semantics.status,
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
                    group: general.semantics.noteType,
                    semanticLabel: t.title(general),
                    selected: f.types.contains(t),
                    onTap: () =>
                        draft.change(f.copyWith(types: _flip(f.types, t))),
                  ),
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                NativeSegmentedControl(
                  labels: [
                    for (final p in IssuedPeriod.values) p.label(issued),
                  ],
                  semanticLabels: [
                    for (final p in IssuedPeriod.values) p.spoken(issued),
                  ],
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
                          child: _range(context, draft, f, issued),
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
