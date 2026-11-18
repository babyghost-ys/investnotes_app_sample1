import 'package:flutter_native_widgets/flutter_native_widgets.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:keel_localisation/keel_localisation.dart';

import 'package:investnotes_app_sample1/app/keel_routes.dart';
import 'package:investnotes_app_sample1/core/l10n/generated/locales.dart';
import 'package:investnotes_app_sample1/core/l10n/terms.dart';
import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/core/widgets/empty_state.dart';
import 'package:investnotes_app_sample1/core/widgets/filter_icon_button.dart';
import 'package:investnotes_app_sample1/core/widgets/responsive_master_detail.dart';
import 'package:investnotes_app_sample1/core/widgets/round_icon_button.dart';
import 'package:investnotes_app_sample1/core/widgets/skeleton_pulse.dart';
import 'package:investnotes_app_sample1/domain/models/loading_phase.dart';
import 'package:investnotes_app_sample1/domain/models/note_enums.dart';
import 'package:investnotes_app_sample1/domain/models/offering.dart';
import 'package:investnotes_app_sample1/domain/models/offering_filter.dart';
import 'package:investnotes_app_sample1/features/offerings/bloc/offerings_bloc.dart';
import 'package:investnotes_app_sample1/features/offerings/view/offerings_filter_sheet.dart';
import 'package:investnotes_app_sample1/features/offerings/widgets/load_failure_notice.dart';
import 'package:investnotes_app_sample1/features/offerings/widgets/offering_row.dart';
import 'package:investnotes_app_sample1/features/offerings/widgets/offering_row_skeleton.dart';
import 'package:investnotes_app_sample1/features/product/widgets/product_loader.dart';
import 'package:investnotes_app_sample1/features/product/widgets/product_scope.dart';

class OfferingsPage extends StatelessWidget implements LocalisationConsumer {
  const OfferingsPage({super.key});

  @override
  List<String> get namespaces => const [Locales.offerings, Locales.general];

  Future<void> _filter(BuildContext context, OfferingsState state) async {
    final bloc = context.read<OfferingsBloc>();
    final result = await showOfferingsFilter(
      context,
      current: state.filter,
      type: state.type,
      offerings: state.all,
    );
    if (result != null) bloc.add(OfferingsFilterChanged(result));
  }

  /// Shows [offering] beside the list in a split window, or pushes its page.
  void _open(BuildContext context, Offering offering, {bool inPlace = false}) {
    final bloc = context.read<OfferingsBloc>();
    void select() => bloc.add(OfferingSelected(offering.id));
    ResponsiveMasterDetail.open(
      context,
      inPlace: inPlace,
      select: select,
      push: ({required inPlace}) => context.push<void>(
        KeelRoutes.offering(offering.id),
        extra: (type: offering.type, select: select, inPlace: inPlace),
      ),
      onClosed: () => bloc.add(const OfferingSelected(null)),
    );
  }

  @override
  Widget build(BuildContext context) => LocalisedBuilder(
    consumer: this,
    builder: (context, locale) {
      final offerings = locale[0] as OfferingsLocale;
      final general = locale[1] as GeneralLocale;
      return LoadFailureNotice(
        message: offerings.semantics.didntLoad,
        child: BlocBuilder<OfferingsBloc, OfferingsState>(
          builder: (context, state) =>
              _split(context, state, offerings, general),
        ),
      );
    },
  );

  Widget _split(
    BuildContext context,
    OfferingsState state,
    OfferingsLocale offerings,
    GeneralLocale general,
  ) {
    final detail = state.detail;
    return ResponsiveMasterDetail(
      master: Builder(
        builder: (context) => _list(context, state, offerings, general),
      ),
      // Fetched as it is chosen; a new choice starts its own fetch.
      detail: detail == null
          ? null
          : ColoredBox(
              key: ValueKey(detail.id),
              color: KeelColors.page.of(context),
              child: ProductScope(id: detail.id, child: const ProductLoader()),
            ),
      opened: detail != null && detail.id == state.selectedId,
      // Folded with an offering open: it carries on as its own page.
      onCollapse: detail == null
          ? null
          : () => _open(context, detail, inPlace: true),
    );
  }

  Widget _list(
    BuildContext context,
    OfferingsState state,
    OfferingsLocale offerings,
    GeneralLocale general,
  ) {
    final insets = MediaQuery.paddingOf(context);
    final visible = state.visible;
    final split = ResponsiveMasterDetail.isSplit(context);
    // The item beside the list; on a single pane, the item whose own page is
    // open over the list, highlighted until the person comes back, as an
    // iOS list does.
    final shown = split ? state.detail?.id : state.selectedId;
    return ColoredBox(
      color: KeelColors.page.of(context),
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        removeBottom: true,
        child: ListView(
          key: const PageStorageKey('offerings'),
          padding: EdgeInsets.fromLTRB(
            20 + insets.left,
            insets.top + 16,
            20 + insets.right,
            insets.bottom + 32,
          ),
          children: [
            NativeSegmentedControl(
              labels: [for (final t in NoteType.values) t.code],
              semanticLabels: [
                for (final t in NoteType.values) t.title(general),
              ],
              selectedIndex: state.type.index,
              onValueChanged: (i) => context.read<OfferingsBloc>().add(
                OfferingsTypeSelected(NoteType.values[i]),
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: Text(
                    state.type.title(general),
                    style: TextStyle(
                      color: KeelColors.ink.of(context),
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                FilterIconButton(
                  activeCount: state.filter.activeCount,
                  onPressed: () => _filter(context, state),
                ),
              ],
            ),
            const SizedBox(height: 6),
            for (final o in visible)
              OfferingRow(
                offering: o,
                selected: o.id == shown,
                onTap: () => _open(context, o),
              ),
            // Loaded offerings stay on screen while a reload runs or fails.
            ...switch (state.phase) {
              LoadingPhase.loading when state.all.isEmpty => const [
                SkeletonPulse(
                  child: Column(
                    children: [
                      OfferingRowSkeleton(nameFactor: 0.8),
                      OfferingRowSkeleton(nameFactor: 0.6),
                      OfferingRowSkeleton(nameFactor: 0.9),
                      OfferingRowSkeleton(nameFactor: 0.7),
                      OfferingRowSkeleton(nameFactor: 0.55),
                    ],
                  ),
                ),
              ],
              LoadingPhase.failed when state.all.isEmpty => [
                EmptyState(
                  icon: CupertinoIcons.exclamationmark_circle,
                  semanticLabel: offerings.semantics.didntLoad,
                  action: RoundIconButton(
                    icon: CupertinoIcons.arrow_clockwise,
                    label: general.semantics.tryAgain,
                    foreground: KeelColors.azure.of(context),
                    background: KeelColors.mist.of(context),
                    onPressed: () => context.read<OfferingsBloc>().add(
                      const OfferingsRequested(),
                    ),
                  ),
                ),
              ],
              _ when visible.isEmpty => [
                EmptyState(
                  icon: CupertinoIcons.line_horizontal_3_decrease,
                  text: general.labels.noMatches,
                  action: RoundIconButton(
                    icon: CupertinoIcons.arrow_counterclockwise,
                    label: general.semantics.clearFilters,
                    foreground: KeelColors.azure.of(context),
                    background: KeelColors.mist.of(context),
                    onPressed: () => context.read<OfferingsBloc>().add(
                      const OfferingsFilterChanged(OfferingFilter()),
                    ),
                  ),
                ),
              ],
              _ => const <Widget>[],
            },
          ],
        ),
      ),
    );
  }
}
