import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/data/repositories/notes_repository.dart';
import 'package:investnotes_app_sample1/features/finder/view/finder_page.dart';
import 'package:investnotes_app_sample1/features/home/widgets/finder_banner.dart';
import 'package:investnotes_app_sample1/features/learn/view/article_page.dart';
import 'package:investnotes_app_sample1/features/learn/widgets/article_row.dart';
import 'package:investnotes_app_sample1/features/learn/widgets/lead_article_card.dart';

class LearnPage extends StatelessWidget {
  const LearnPage({super.key});

  @override
  Widget build(BuildContext context) {
    final articles = context.read<NotesRepository>().articles;
    final insets = MediaQuery.paddingOf(context);
    return ColoredBox(
      color: KeelColors.page.of(context),
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        removeBottom: true,
        child: ListView(
          key: const PageStorageKey('learn'),
          padding: EdgeInsets.fromLTRB(
            20,
            insets.top + 20,
            20,
            insets.bottom + 32,
          ),
          children: [
            LeadArticleCard(
              article: articles.first,
              onTap: () => openArticle(context, articles.first),
            ),
            const SizedBox(height: 8),
            for (final a in articles.skip(1))
              ArticleRow(article: a, onTap: () => openArticle(context, a)),
            const SizedBox(height: 28),
            FinderBanner(onTap: () => startFinder(context)),
          ],
        ),
      ),
    );
  }
}
