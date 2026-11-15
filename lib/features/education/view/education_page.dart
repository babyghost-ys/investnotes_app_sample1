import 'package:flutter_native_widgets/flutter_native_widgets.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:keel_localisation/keel_localisation.dart';
import 'package:material_ui/material_ui.dart' show Icons;

import 'package:investnotes_app_sample1/app/keel_routes.dart';
import 'package:investnotes_app_sample1/core/l10n/generated/locales.dart';
import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/features/education/bloc/education_bloc.dart';
import 'package:investnotes_app_sample1/features/education/view/article_page.dart';
import 'package:investnotes_app_sample1/features/education/view/article_pdf_page.dart';
import 'package:investnotes_app_sample1/features/downloads/bloc/downloads_bloc.dart';
import 'package:investnotes_app_sample1/domain/models/note_enums.dart';
import 'package:investnotes_app_sample1/features/education/widgets/article_group.dart';
import 'package:investnotes_app_sample1/features/education/widgets/explainer_card.dart';
import 'package:investnotes_app_sample1/features/education/widgets/film_card.dart';
import 'package:investnotes_app_sample1/features/education/widgets/search_band.dart';

/// Education: the way into search, then films or articles.
class EducationPage extends StatelessWidget implements LocalisationConsumer {
  const EducationPage({super.key});

  @override
  List<String> get namespaces => const [Locales.education, Locales.general];

  @override
  Widget build(BuildContext context) => LocalisedBuilder(
    consumer: this,
    builder: (context, locale) => _build(
      context,
      locale[0] as EducationLocale,
      locale[1] as GeneralLocale,
    ),
  );

  Widget _build(
    BuildContext context,
    EducationLocale words,
    GeneralLocale general,
  ) {
    final insets = MediaQuery.paddingOf(context);
    return ColoredBox(
      color: KeelColors.page.of(context),
      child: BlocBuilder<EducationBloc, EducationState>(
        builder: (context, state) {
          final articles = state.articles;
          return MediaQuery.removePadding(
            context: context,
            removeTop: true,
            removeBottom: true,
            child: ListView(
              key: const PageStorageKey('education'),
              padding: EdgeInsets.fromLTRB(
                20 + insets.left,
                insets.top + 20,
                20 + insets.right,
                insets.bottom + 32,
              ),
              children: [
                SearchBand(
                  label: words.semantics.searchNotes,
                  onTap: () => context.push<void>(KeelRoutes.educationSearch),
                ),
                const SizedBox(height: 22),
                NativeSegmentedControl(
                  labels: [words.semantics.videos, words.semantics.articles],
                  semanticLabels: [
                    words.semantics.videos,
                    words.semantics.articles,
                  ],
                  icons: const [
                    NativeIcon(
                      sfSymbol: 'play.rectangle.fill',
                      icon: Icons.smart_display,
                    ),
                    NativeIcon(sfSymbol: 'doc.text.fill', icon: Icons.article),
                  ],
                  selectedIndex: state.segment.index,
                  onValueChanged: (i) => context.read<EducationBloc>().add(
                    EducationSegmentSelected(EducationSegment.values[i]),
                  ),
                ),
                const SizedBox(height: 22),
                ...switch (state.segment) {
                  EducationSegment.videos => [
                    for (final film in state.films)
                      // The recorded film leads, at the list's full width.
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 760),
                          child: FilmCard(film: film),
                        ),
                      ),
                    // One film per row on a phone; side by side once the
                    // window is wide (an unfolded device, a tablet).
                    LayoutBuilder(
                      builder: (context, box) {
                        final columns = box.maxWidth >= 960
                            ? 3
                            : box.maxWidth >= 560
                            ? 2
                            : 1;
                        const gap = 18.0;
                        final width =
                            (box.maxWidth - gap * (columns - 1)) / columns;
                        return Wrap(
                          spacing: gap,
                          children: [
                            for (final e in state.explainers)
                              SizedBox(
                                width: width,
                                child: ExplainerCard(
                                  explainer: e,
                                  onTap: () => context.push<void>(
                                    KeelRoutes.explainer(e.id),
                                    extra: e,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                  // Grouped by family, in the order the families are
                  // offered.
                  EducationSegment.articles => [
                    for (final type in NoteType.values)
                      if (articles.where((a) => a.type == type).toList()
                          case final group when group.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 30),
                          child: ArticleGroup(
                            type: type,
                            articles: group,
                            words: words.semantics,
                            general: general,
                            // A downloaded article opens as its PDF.
                            onOpen: (a) =>
                                context.read<DownloadsBloc>().state.isKept(a.id)
                                ? openArticlePdf(context, a)
                                : openArticle(context, a),
                          ),
                        ),
                  ],
                },
              ],
            ),
          );
        },
      ),
    );
  }
}
