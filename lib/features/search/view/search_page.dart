import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keel_localisation/keel_localisation.dart';

import 'package:investnotes_app_sample1/core/l10n/generated/locales.dart';
import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/core/widgets/empty_state.dart';
import 'package:investnotes_app_sample1/core/widgets/keel_field.dart';
import 'package:investnotes_app_sample1/core/widgets/responsive_master_detail.dart';
import 'package:investnotes_app_sample1/core/widgets/round_icon_button.dart';
import 'package:investnotes_app_sample1/domain/models/loading_phase.dart';
import 'package:investnotes_app_sample1/domain/models/product.dart';
import 'package:investnotes_app_sample1/domain/repositories/notes_repository.dart';
import 'package:investnotes_app_sample1/features/product/view/product_page.dart';
import 'package:investnotes_app_sample1/features/product/widgets/product_loader.dart';
import 'package:investnotes_app_sample1/features/product/widgets/product_scope.dart';
import 'package:investnotes_app_sample1/features/search/bloc/search_bloc.dart';
import 'package:investnotes_app_sample1/features/search/widgets/search_result_card.dart';

/// Searches every offering and issued note as you type.
///
/// On a single pane each result opens in place to its order terms, and from
/// there to the note's page. In a split window, such as an unfolded iPhone
/// Duo, the results sit on one side of the hinge and a tapped result's note
/// opens on the other. Folding with a note open keeps it on screen in the
/// results' place, and Back brings them back.
class SearchPage extends StatelessWidget implements LocalisationConsumer {
  const SearchPage({super.key});

  @override
  List<String> get namespaces => const [Locales.search, Locales.general];

  @override
  Widget build(BuildContext context) => LocalisedBuilder(
    consumer: this,
    builder: (context, locale) =>
        _build(context, locale[0] as SearchLocale, locale[1] as GeneralLocale),
  );

  Widget _build(
    BuildContext context,
    SearchLocale search,
    GeneralLocale general,
  ) => BlocProvider(
    create: (context) =>
        SearchBloc(context.read<NotesRepository>(), general)
          ..add(const SearchRequested()),
    child: BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) => _split(context, state, search, general),
    ),
  );

  /// Shows [p] beside the results in a split window, or pushes its page.
  void _open(BuildContext context, Product p) {
    FocusManager.instance.primaryFocus?.unfocus();
    final bloc = context.read<SearchBloc>();
    void select() => bloc.add(SearchResultSelected(p.id));
    ResponsiveMasterDetail.open(
      context,
      select: select,
      push: () => openProduct(context, p, select: select),
    );
  }

  Widget _split(
    BuildContext context,
    SearchState state,
    SearchLocale search,
    GeneralLocale general,
  ) {
    final detail = state.detail;
    return ResponsiveMasterDetail(
      master: Builder(
        builder: (context) => _list(context, state, search, general),
      ),
      // Fetched as it is chosen; a new choice starts its own fetch.
      detail: detail == null
          ? null
          : ColoredBox(
              key: ValueKey(detail.id),
              color: KeelColors.page.of(context),
              child: ProductScope(id: detail.id, child: const ProductLoader()),
            ),
      onClose: () =>
          context.read<SearchBloc>().add(const SearchResultSelected(null)),
    );
  }

  Widget _list(
    BuildContext context,
    SearchState state,
    SearchLocale search,
    GeneralLocale general,
  ) {
    final insets = MediaQuery.paddingOf(context);
    final split = ResponsiveMasterDetail.isSplit(context);
    return ColoredBox(
      color: KeelColors.page.of(context),
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        removeBottom: true,
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
            16 + insets.left,
            insets.top + 16,
            16 + insets.right,
            insets.bottom + 40,
          ),
          children: [
            KeelField(
              icon: CupertinoIcons.search,
              placeholder: search.labels.placeholder,
              autofocus: true,
              action: TextInputAction.search,
              onChanged: (q) =>
                  context.read<SearchBloc>().add(SearchQueryChanged(q)),
            ),
            const SizedBox(height: 16),
            for (final p in state.results)
              SearchResultCard(
                key: ValueKey(p.id),
                product: p,
                unfolds: !split,
                expanded: state.expanded == p.id,
                selected: split && state.selectedId == p.id,
                onToggle: split
                    ? () => _open(context, p)
                    : () => context.read<SearchBloc>().add(
                        SearchRowToggled(p.id),
                      ),
                onOpen: () => _open(context, p),
              ),
            // The notes may still be on their way when typing starts.
            if (state.typed)
              switch (state.phase) {
                LoadingPhase.loading => const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: CupertinoActivityIndicator(),
                ),
                LoadingPhase.failed => EmptyState(
                  icon: CupertinoIcons.exclamationmark_circle,
                  semanticLabel: general.semantics.didntLoad,
                  action: RoundIconButton(
                    icon: CupertinoIcons.arrow_clockwise,
                    label: general.semantics.tryAgain,
                    foreground: KeelColors.azure.of(context),
                    background: KeelColors.mist.of(context),
                    onPressed: () =>
                        context.read<SearchBloc>().add(const SearchRequested()),
                  ),
                ),
                LoadingPhase.loaded when state.empty => EmptyState(
                  icon: CupertinoIcons.search,
                  text: search.labels.nothingFound,
                ),
                LoadingPhase.loaded => const SizedBox.shrink(),
              },
          ],
        ),
      ),
    );
  }
}
