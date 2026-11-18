import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:keel_localisation/keel_localisation.dart';

import 'package:investnotes_app_sample1/app/keel_routes.dart';
import 'package:investnotes_app_sample1/core/l10n/generated/locales.dart';
import 'package:investnotes_app_sample1/core/formatting/formats.dart';
import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/core/widgets/empty_state.dart';
import 'package:investnotes_app_sample1/core/widgets/filter_icon_button.dart';
import 'package:investnotes_app_sample1/core/widgets/responsive_master_detail.dart';
import 'package:investnotes_app_sample1/core/widgets/round_icon_button.dart';
import 'package:investnotes_app_sample1/domain/models/issued_filter.dart';
import 'package:investnotes_app_sample1/domain/models/issued_note.dart';
import 'package:investnotes_app_sample1/domain/models/note_enums.dart';
import 'package:investnotes_app_sample1/features/issued/bloc/issued_bloc.dart';
import 'package:investnotes_app_sample1/features/issued/view/issued_filter_sheet.dart';
import 'package:investnotes_app_sample1/features/issued/widgets/issued_row.dart';
import 'package:investnotes_app_sample1/features/product/widgets/product_loader.dart';
import 'package:investnotes_app_sample1/features/product/widgets/product_scope.dart';

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

  /// Shows [note] beside the list in a split window, or pushes its page.
  void _open(BuildContext context, IssuedNote note, {bool inPlace = false}) {
    final bloc = context.read<IssuedBloc>();
    void select() => bloc.add(IssuedNoteSelected(note.id));
    ResponsiveMasterDetail.open(
      context,
      inPlace: inPlace,
      select: select,
      push: ({required inPlace}) => context.push<void>(
        KeelRoutes.note(note.id),
        extra: (type: note.type, select: select, inPlace: inPlace),
      ),
      onClosed: () => bloc.add(const IssuedNoteSelected(null)),
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
  ) => BlocBuilder<IssuedBloc, IssuedState>(
    builder: (context, state) {
      final detail = state.detail;
      return ResponsiveMasterDetail(
        master: Builder(
          builder: (context) => _list(context, state, issued, general),
        ),
        // Fetched as it is chosen; a new choice starts its own fetch.
        detail: detail == null
            ? null
            : ColoredBox(
                key: ValueKey(detail.id),
                color: KeelColors.page.of(context),
                child: ProductScope(
                  id: detail.id,
                  child: const ProductLoader(),
                ),
              ),
        opened: detail != null && detail.id == state.selectedId,
        // Folded with a note open: it carries on as its own page.
        onCollapse: detail == null
            ? null
            : () => _open(context, detail, inPlace: true),
      );
    },
  );

  Widget _list(
    BuildContext context,
    IssuedState state,
    IssuedLocale issued,
    GeneralLocale general,
  ) {
    final split = ResponsiveMasterDetail.isSplit(context);
    // The item beside the list; on a single pane, the item whose own page is
    // open over the list, highlighted until the person comes back, as an
    // iOS list does.
    final shown = split ? state.detail?.id : state.selectedId;
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
            20 + insets.left,
            insets.top + 20,
            20 + insets.right,
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
                            fontFeatures: const [FontFeature.tabularFigures()],
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
                onOpen: () => _open(context, n),
                onSelect: split ? () => _open(context, n) : null,
                selected: n.id == shown,
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
  }
}
