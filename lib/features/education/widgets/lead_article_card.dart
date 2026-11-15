import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/services.dart';

import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/core/widgets/payoff_glyph.dart';
import 'package:investnotes_app_sample1/data/models/article.dart';
import 'package:investnotes_app_sample1/features/home/widgets/type_tile.dart';

/// The Articles segment's lead, its payoff drawn large on the band.
class LeadArticleCard extends StatelessWidget {
  const LeadArticleCard({
    super.key,
    required this.article,
    required this.onTap,
  });

  final Article article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: article.title,
    excludeSemantics: true,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        height: 260,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              KeelColors.tide.of(context),
              KeelColors.tideDeep.of(context),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              top: 8,
              child: PayoffGlyph(
                payoff: TypeTile.shapeOf(article.type),
                color: CupertinoColors.white,
                baseline: KeelColors.foam.withValues(alpha: 0.35),
                size: 210,
                strokeWidth: 5,
              ),
            ),
            Positioned(
              left: 22,
              right: 22,
              bottom: 22,
              child: Text(
                article.title,
                style: const TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 26,
                  height: 1.15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.6,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
