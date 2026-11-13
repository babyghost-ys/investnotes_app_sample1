import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/services.dart';

import 'package:investnotes_app_sample1/core/formatting/formats.dart';
import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/core/widgets/payoff_glyph.dart';
import 'package:investnotes_app_sample1/data/models/offering.dart';

/// An offering about to close, as a wide card on Home.
class ClosingCard extends StatelessWidget {
  const ClosingCard({super.key, required this.offering, required this.onTap});

  final Offering offering;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final o = offering;
    final ink = KeelColors.ink.of(context);
    final azure = KeelColors.azure.of(context);
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Container(
          width: 236,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: KeelColors.raised.of(context),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: KeelColors.hairline.of(context)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PayoffGlyph(payoff: o.payoff, color: azure, size: 46),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: azure,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      Formats.until(o.closes),
                      style: const TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Text(
                o.headlineIsRate
                    ? Formats.percent(o.headline)
                    : Formats.times(o.headline),
                style: TextStyle(
                  color: ink,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.8,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                o.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: ink, fontSize: 14, height: 1.25),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
