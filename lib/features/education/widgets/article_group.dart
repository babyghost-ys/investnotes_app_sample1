import 'package:cupertino_ui/cupertino_ui.dart';

import 'package:investnotes_app_sample1/core/l10n/generated/locales.dart';
import 'package:investnotes_app_sample1/core/l10n/terms.dart';
import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/core/widgets/payoff_glyph.dart';
import 'package:investnotes_app_sample1/data/models/article.dart';
import 'package:investnotes_app_sample1/data/models/note_enums.dart';
import 'package:investnotes_app_sample1/features/education/widgets/article_card.dart';
import 'package:investnotes_app_sample1/features/home/widgets/type_tile.dart';

/// One family's articles: its payoff and code, then its articles in a grid
/// whose cards in a row share one height.
class ArticleGroup extends StatelessWidget {
  const ArticleGroup({
    super.key,
    required this.type,
    required this.articles,
    required this.words,
    required this.general,
    required this.onOpen,
  });

  final NoteType type;
  final List<Article> articles;
  final EducationSemantics words;
  final GeneralLocale general;
  final void Function(Article) onOpen;

  static const _gap = 12.0;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Semantics(
        header: true,
        label: type.title(general),
        excludeSemantics: true,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
          child: Row(
            children: [
              PayoffGlyph(
                payoff: TypeTile.shapeOf(type),
                color: KeelColors.azure.of(context),
                baseline: KeelColors.hairline.of(context),
                size: 30,
                strokeWidth: 2.5,
              ),
              const SizedBox(width: 10),
              Text(
                type.code,
                style: TextStyle(
                  color: KeelColors.ink.of(context),
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),
        ),
      ),
      LayoutBuilder(
        builder: (context, box) {
          // Two columns on a phone, three once the window is wide.
          final columns = box.maxWidth >= 900 ? 3 : 2;
          final column = (box.maxWidth - _gap * (columns - 1)) / columns;
          return Column(
            children: [
              for (var i = 0; i < articles.length; i += columns)
                () {
                  final row = articles.skip(i).take(columns).toList();
                  // A short row's cards widen to fill it; their controls
                  // keep one column's width, aligned with the rows above.
                  final pill = row.length < columns
                      ? column - ArticleCard.padding * 2
                      : null;
                  return Padding(
                    padding: EdgeInsets.only(top: i == 0 ? 0 : _gap),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final (j, a) in row.indexed) ...[
                            if (j > 0) const SizedBox(width: _gap),
                            Expanded(
                              child: ArticleCard(
                                article: a,
                                words: words,
                                pillWidth: pill,
                                onOpen: () => onOpen(a),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }(),
            ],
          );
        },
      ),
    ],
  );
}
