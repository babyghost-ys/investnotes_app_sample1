import 'package:flutter_native_widgets/flutter_native_widgets.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart' show Material, MaterialType;

import 'package:investnotes_app_sample1/core/draft/draft_bloc.dart';
import 'package:investnotes_app_sample1/core/formatting/formats.dart';
import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/core/widgets/round_icon_button.dart';

/// Opens a calendar in a sheet above the current one; completes with the
/// chosen day, or null when closed.
Future<DateTime?> showDatePick(
  BuildContext context, {
  required DateTime date,
  required DateTime first,
  required DateTime last,
  required bool end,
}) => NativeSheet.show<DateTime>(
  context: context,
  route: 'datePick',
  arguments: {
    'date': date.toIso8601String(),
    'first': first.toIso8601String(),
    'last': last.toIso8601String(),
    'end': end,
  },
  decodeResult: (value) => DateTime.parse(value as String),
  backgroundColor: KeelColors.page.of(context),
  builder: (_) => DatePickSheet(date: date, first: first, last: last, end: end),
);

class DatePickSheet extends StatelessWidget {
  const DatePickSheet({
    super.key,
    required this.date,
    required this.first,
    required this.last,
    required this.end,
  });

  final DateTime date;
  final DateTime first;
  final DateTime last;

  /// Whether this is the end of the range (a filled flag) or its start.
  final bool end;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => DraftBloc<DateTime>(date),
    child: BlocBuilder<DraftBloc<DateTime>, DraftState<DateTime>>(
      builder: (context, state) {
        final ink = KeelColors.ink.of(context);
        final azure = KeelColors.azure.of(context);
        final draft = context.read<DraftBloc<DateTime>>();

        final title = Row(
          children: [
            Icon(
              end ? CupertinoIcons.flag_fill : CupertinoIcons.flag,
              color: azure,
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                Formats.shortDate(state.value),
                style: TextStyle(
                  color: ink,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        );
        final close = RoundIconButton(
          icon: CupertinoIcons.xmark,
          label: 'Close',
          foreground: ink,
          onPressed: () => NativeSheet.pop(context),
        );
        final use = RoundIconButton(
          icon: CupertinoIcons.checkmark,
          label: 'Use this date',
          foreground: CupertinoColors.white,
          background: azure,
          size: 54,
          iconSize: 22,
          onPressed: () => NativeSheet.pop(context, state.value),
        );
        Widget calendar(double height) => SizedBox(
          height: height,
          child: NativeInlineDatePicker(
            initialDate: date,
            firstDate: first,
            lastDate: last,
            style: NativeDatePickerStyle.inline,
            tintColor: azure,
            onDateChanged: (d) =>
                draft.change(DateTime(d.year, d.month, d.day)),
          ),
        );

        // A screen held on its side (a phone turned, a folded Duo turned)
        // has no room for the calendar with the date above it and the
        // confirm below: they sit beside it instead, all in reach. The
        // display reports its size held upright, so a sheet wider than the
        // display's short side means the screen is turned. The media query
        // rebuilds this on a turn.
        final view = View.of(context);
        final sheetWidth =
            MediaQuery.sizeOf(context).width * view.devicePixelRatio;
        final wide = sheetWidth > view.display.size.shortestSide * 1.05;

        return Material(
          type: MaterialType.transparency,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
              child: wide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: calendar(326)),
                        const SizedBox(width: 20),
                        SizedBox(
                          width: 220,
                          height: 326,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Expanded(child: title),
                                  close,
                                ],
                              ),
                              const Spacer(),
                              Center(child: use),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(child: title),
                            close,
                          ],
                        ),
                        const SizedBox(height: 8),
                        calendar(340),
                        const SizedBox(height: 12),
                        Center(child: use),
                      ],
                    ),
            ),
          ),
        );
      },
    ),
  );
}
