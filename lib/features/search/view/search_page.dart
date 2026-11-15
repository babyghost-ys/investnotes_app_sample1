import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keel_localisation/keel_localisation.dart';

import 'package:investnotes_app_sample1/core/l10n/generated/locales.dart';
import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/core/widgets/empty_state.dart';
import 'package:investnotes_app_sample1/core/widgets/keel_field.dart';
import 'package:investnotes_app_sample1/data/repositories/notes_repository.dart';
import 'package:investnotes_app_sample1/features/product/view/product_page.dart';
import 'package:investnotes_app_sample1/features/search/bloc/search_bloc.dart';
import 'package:investnotes_app_sample1/features/search/widgets/search_result_card.dart';

/// Searches every offering and issued note as you type. Each result opens
/// in place to its order terms, and from there to the note's page.
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
    create: (context) => SearchBloc(context.read<NotesRepository>(), general),
    child: BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        final insets = MediaQuery.paddingOf(context);
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
                    expanded: state.expanded == p.id,
                    onToggle: () =>
                        context.read<SearchBloc>().add(SearchRowToggled(p.id)),
                    onOpen: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      openProduct(context, p);
                    },
                  ),
                if (state.query.trim().isNotEmpty && state.empty)
                  EmptyState(
                    icon: CupertinoIcons.search,
                    text: search.labels.nothingFound,
                  ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
