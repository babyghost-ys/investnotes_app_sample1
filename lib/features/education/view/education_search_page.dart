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
import 'package:investnotes_app_sample1/core/widgets/round_icon_button.dart';
import 'package:investnotes_app_sample1/core/widgets/skeleton_pulse.dart';
import 'package:investnotes_app_sample1/data/models/loading_phase.dart';
import 'package:investnotes_app_sample1/data/models/note_enums.dart';
import 'package:investnotes_app_sample1/data/models/offering_filter.dart';
import 'package:investnotes_app_sample1/features/education/bloc/education_search_bloc.dart';
import 'package:investnotes_app_sample1/features/finder/view/finder_page.dart';
import 'package:investnotes_app_sample1/features/home/widgets/finder_banner.dart';
import 'package:investnotes_app_sample1/features/offerings/bloc/offerings_bloc.dart';
import 'package:investnotes_app_sample1/features/offerings/view/offerings_filter_sheet.dart';
import 'package:investnotes_app_sample1/features/offerings/widgets/offering_row.dart';
import 'package:investnotes_app_sample1/features/offerings/widgets/offering_row_skeleton.dart';

/// Education's search: the finder's questions at the top, then every open
/// note by type, to filter by hand.
class EducationSearchPage extends StatelessWidget
    implements LocalisationConsumer {
  const EducationSearchPage({super.key});

  @override
  List<String> get namespaces => const [Locales.offerings, Locales.general];

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => EducationSearchBloc(),
    child: LocalisedBuilder(
      consumer: this,
      builder: (context, locale) => _build(
        context,
        locale[0] as OfferingsLocale,
        locale[1] as GeneralLocale,
      ),
    ),
  );

  Future<void> _filter(
    BuildContext context,
    EducationSearchState search,
    OfferingsState offerings,
  ) async {
    final bloc = context.read<EducationSearchBloc>();
    final result = await showOfferingsFilter(
      context,
      current: search.filter,
      type: search.type,
      offerings: offerings.all,
    );
    if (result != null) bloc.add(EducationSearchFilterChanged(result));
  }

  Widget _build(
    BuildContext context,
    OfferingsLocale words,
    GeneralLocale general,
  ) {
    final insets = MediaQuery.paddingOf(context);
    // A readable column on wide windows: rows stretched across an unfolded
    // device or a tablet lose the eye between name and number.
    final side =
        ((MediaQuery.sizeOf(context).width - insets.horizontal - 720) / 2)
            .clamp(20.0, double.infinity);
    return ColoredBox(
      color: KeelColors.page.of(context),
      child: BlocBuilder<OfferingsBloc, OfferingsState>(
        builder: (context, offerings) =>
            BlocBuilder<EducationSearchBloc, EducationSearchState>(
              builder: (context, search) {
                final visible = search.visible(offerings.all);
                return MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  removeBottom: true,
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(
                      side + insets.left,
                      insets.top + 20,
                      side + insets.right,
                      insets.bottom + 32,
                    ),
                    children: [
                      FinderBanner(onTap: () => startFinder(context)),
                      const SizedBox(height: 26),
                      NativeSegmentedControl(
                        labels: [for (final t in NoteType.values) t.code],
                        semanticLabels: [
                          for (final t in NoteType.values) t.title(general),
                        ],
                        selectedIndex: search.type.index,
                        onValueChanged: (i) =>
                            context.read<EducationSearchBloc>().add(
                              EducationSearchTypeSelected(NoteType.values[i]),
                            ),
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              search.type.title(general),
                              style: TextStyle(
                                color: KeelColors.ink.of(context),
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          FilterIconButton(
                            activeCount: search.filter.activeCount,
                            onPressed: () =>
                                _filter(context, search, offerings),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      for (final o in visible)
                        OfferingRow(
                          offering: o,
                          onTap: () =>
                              context.push<void>(KeelRoutes.offering(o.id)),
                        ),
                      ...switch (offerings.phase) {
                        LoadingPhase.loading when offerings.all.isEmpty =>
                          const [
                            SkeletonPulse(
                              child: Column(
                                children: [
                                  OfferingRowSkeleton(nameFactor: 0.8),
                                  OfferingRowSkeleton(nameFactor: 0.6),
                                  OfferingRowSkeleton(nameFactor: 0.9),
                                  OfferingRowSkeleton(nameFactor: 0.7),
                                ],
                              ),
                            ),
                          ],
                        LoadingPhase.failed when offerings.all.isEmpty => [
                          EmptyState(
                            icon: CupertinoIcons.exclamationmark_circle,
                            semanticLabel: words.semantics.didntLoad,
                            action: RoundIconButton(
                              icon: CupertinoIcons.arrow_clockwise,
                              label: general.semantics.tryAgain,
                              foreground: KeelColors.azure.of(context),
                              background: KeelColors.mist.of(context),
                              onPressed: () => context
                                  .read<OfferingsBloc>()
                                  .add(const OfferingsRequested()),
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
                              onPressed: () =>
                                  context.read<EducationSearchBloc>().add(
                                    const EducationSearchFilterChanged(
                                      OfferingFilter(),
                                    ),
                                  ),
                            ),
                          ),
                        ],
                        _ => const <Widget>[],
                      },
                    ],
                  ),
                );
              },
            ),
      ),
    );
  }
}
