import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/services.dart';

import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/core/widgets/payoff_glyph.dart';
import 'package:investnotes_app_sample1/domain/models/article.dart';
import 'package:investnotes_app_sample1/features/home/widgets/type_tile.dart';

/// An article in Education: the payoff it explains, and its title.
class ArticleRow extends StatelessWidget {
  const ArticleRow({super.key, required this.article, required this.onTap});

  final Article article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: KeelColors.hairline.of(context)),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: KeelColors.mist.of(context),
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: PayoffGlyph(
                payoff: TypeTile.shapeOf(article.type),
                color: KeelColors.azure.of(context),
                size: 56,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                article.title,
                style: TextStyle(
                  color: KeelColors.ink.of(context),
                  fontSize: 18,
                  height: 1.25,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
