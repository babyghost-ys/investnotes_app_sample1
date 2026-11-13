import 'package:cupertino_ui/cupertino_ui.dart';

import 'package:investnotes_app_sample1/app/push_page.dart';
import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/data/models/article.dart';
import 'package:investnotes_app_sample1/features/home/widgets/type_tile.dart';
import 'package:investnotes_app_sample1/features/probe/widgets/payoff_probe.dart';

Future<void> openArticle(BuildContext context, Article article) =>
    pushPage<void>(
      context,
      title: article.type.code,
      builder: (_) => ArticlePage(article: article),
    );

/// An article, led by a payoff the reader can try for themselves.
class ArticlePage extends StatelessWidget {
  const ArticlePage({super.key, required this.article});

  final Article article;

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.paddingOf(context);
    final ink = KeelColors.ink.of(context);
    return ColoredBox(
      color: KeelColors.page.of(context),
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        removeBottom: true,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            24,
            insets.top + 20,
            24,
            insets.bottom + 48,
          ),
          children: [
            Text(
              article.title,
              style: TextStyle(
                color: ink,
                fontSize: 28,
                height: 1.15,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.7,
              ),
            ),
            const SizedBox(height: 24),
            PayoffProbe(payoff: TypeTile.shapeOf(article.type)),
            const SizedBox(height: 28),
            for (final paragraph in article.paragraphs)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  paragraph,
                  style: TextStyle(color: ink, fontSize: 17, height: 1.55),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
