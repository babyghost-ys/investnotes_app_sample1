import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/services.dart';

import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/data/models/explainer.dart';
import 'package:investnotes_app_sample1/features/education/widgets/explainer_stage.dart';
import 'package:investnotes_app_sample1/features/education/widgets/play_glyph.dart';

/// A film in the Videos list: its whole story as the poster, a play mark,
/// and its title.
class ExplainerCard extends StatelessWidget {
  const ExplainerCard({
    super.key,
    required this.explainer,
    required this.onTap,
  });

  final Explainer explainer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: explainer.title,
    excludeSemantics: true,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 26),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 16 / 10,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ExplainerStage(explainer: explainer, progress: 1),
                  const Center(child: PlayGlyph(size: 58)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              explainer.title,
              style: TextStyle(
                color: KeelColors.ink.of(context),
                fontSize: 19,
                height: 1.2,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
