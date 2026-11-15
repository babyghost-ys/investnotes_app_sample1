import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/services.dart';

import 'package:investnotes_app_sample1/core/l10n/generated/locales.dart';
import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/data/models/article.dart';
import 'package:investnotes_app_sample1/features/education/widgets/download_pill.dart';

/// An article in its family's grid: its title, which opens it, and its
/// download control beneath.
class ArticleCard extends StatelessWidget {
  const ArticleCard({
    super.key,
    required this.article,
    required this.words,
    required this.onOpen,
    this.pillWidth,
  });

  final Article article;
  final EducationSemantics words;
  final VoidCallback onOpen;

  /// The control's width when the card is wider than one column, so
  /// controls line up across the grid. Null fills the card.
  final double? pillWidth;

  static const padding = 12.0;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(padding),
    decoration: BoxDecoration(
      color: KeelColors.raised.of(context),
      // Concentric with the control inside it.
      borderRadius: BorderRadius.circular(DownloadPill.radius + padding),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // The title's area opens the article; the control below is apart.
        Expanded(
          child: Semantics(
            button: true,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                HapticFeedback.selectionClick();
                onOpen();
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 4, 18),
                child: Text(
                  article.title,
                  style: TextStyle(
                    color: KeelColors.tideInk.of(context),
                    fontSize: 17,
                    height: 1.28,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
            width: pillWidth ?? double.infinity,
            child: DownloadPill(article: article, words: words, onOpen: onOpen),
          ),
        ),
      ],
    ),
  );
}
