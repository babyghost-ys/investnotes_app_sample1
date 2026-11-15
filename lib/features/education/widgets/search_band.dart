import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/services.dart';

import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/core/widgets/payoff_glyph.dart';
import 'package:investnotes_app_sample1/data/models/note_enums.dart';
import 'package:investnotes_app_sample1/features/home/widgets/type_tile.dart';

/// Education's hero and its way into search: every note family's payoff
/// laid along the band, and a search mark at its end. The whole band is
/// the control; [label] is its accessible name and never drawn.
class SearchBand extends StatelessWidget {
  const SearchBand({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    excludeSemantics: true,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        height: 150,
        padding: const EdgeInsets.fromLTRB(22, 22, 20, 22),
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
        child: Row(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, box) {
                  final size = (box.maxWidth / NoteType.values.length - 8)
                      .clamp(36.0, 84.0);
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (final (i, type) in NoteType.values.indexed)
                        Opacity(
                          opacity: 0.55 + i * 0.15,
                          child: PayoffGlyph(
                            payoff: TypeTile.shapeOf(type),
                            color: CupertinoColors.white,
                            baseline: KeelColors.foam.withValues(alpha: 0.3),
                            size: size,
                            strokeWidth: 3,
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(width: 18),
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: CupertinoColors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.search,
                size: 28,
                color: KeelColors.tide.of(context),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
