import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keel_localisation/keel_localisation.dart';

import 'package:investnotes_app_sample1/core/l10n/generated/locales.dart';
import 'package:investnotes_app_sample1/core/formatting/formats.dart';
import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/core/widgets/empty_state.dart';
import 'package:investnotes_app_sample1/core/widgets/filter_icon_button.dart';
import 'package:investnotes_app_sample1/core/widgets/round_icon_button.dart';
import 'package:investnotes_app_sample1/data/models/issued_filter.dart';
import 'package:investnotes_app_sample1/data/models/note_enums.dart';
import 'package:investnotes_app_sample1/features/issued/bloc/issued_bloc.dart';
import 'package:investnotes_app_sample1/features/issued/view/issued_filter_sheet.dart';
import 'package:investnotes_app_sample1/features/issued/widgets/issued_row.dart';
import 'package:investnotes_app_sample1/features/product/view/product_page.dart';

class IssuedPage extends StatelessWidget implements LocalisationConsumer {
  const IssuedPage({super.key});

  Future<void> _filter(BuildContext context, IssuedState state) async {
    final bloc = context.read<IssuedBloc>();
    final result = await showIssuedFilter(
      context,
      current: state.filter,
      notes: state.all,
    );
    if (result != null) bloc.add(IssuedFilterChanged(result));
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
  ) => BlocBuilder<IssuedBloc, IssuedState>(
    builder: (context, state) {
      final formats = Formats(general);
      final insets = MediaQuery.paddingOf(context);
      final visible = state.visible;
      final live = state.all.where((n) => n.status == IssuedStatus.active);
      final average = live.isEmpty
          ? 0.0
          : live.map((n) => n.change).reduce((a, b) => a + b) / live.length;
      return ColoredBox(
        color: KeelColors.page.of(context),
        child: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          removeBottom: true,
          child: ListView(
            key: const PageStorageKey('issued'),
            padding: EdgeInsets.fromLTRB(
              20,
              insets.top + 20,
              20,
              insets.bottom + 32,
            ),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Semantics(
                      label: issued.semantics.average(
                        value: formats.percent(average, signed: true),
                      ),
                      excludeSemantics: true,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            formats.percent(average, signed: true),
                            style: TextStyle(
                              color: KeelColors.azure.of(context),
                              fontSize: 44,
                              height: 1,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -1.4,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Icon(
                              CupertinoIcons.waveform_path_ecg,
                              size: 20,
                              color: KeelColors.muted.of(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  FilterIconButton(
                    activeCount: state.filter.activeCount,
                    onPressed: () => _filter(context, state),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              for (final n in visible)
                IssuedRow(
                  note: n,
                  expanded: state.expanded.contains(n.id),
                  onToggle: () =>
                      context.read<IssuedBloc>().add(IssuedRowToggled(n.id)),
                  onOpen: () => openNote(context, n),
                ),
              if (visible.isEmpty)
                EmptyState(
                  icon: CupertinoIcons.line_horizontal_3_decrease,
                  text: general.labels.noMatches,
                  action: RoundIconButton(
                    icon: CupertinoIcons.arrow_counterclockwise,
                    label: general.semantics.clearFilters,
                    foreground: KeelColors.azure.of(context),
                    background: KeelColors.mist.of(context),
                    onPressed: () => context.read<IssuedBloc>().add(
                      const IssuedFilterChanged(IssuedFilter()),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}
