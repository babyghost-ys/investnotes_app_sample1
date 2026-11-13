import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/services.dart';

import 'package:investnotes_app_sample1/core/formatting/formats.dart';
import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/core/widgets/payoff_glyph.dart';
import 'package:investnotes_app_sample1/data/models/offering.dart';

/// An offering in a list: its payoff shape, its name, and the number people
/// compare it by. A closing date shows only when it is close.
class OfferingRow extends StatelessWidget {
  const OfferingRow({
    super.key,
    required this.offering,
    required this.onTap,
    this.badge,
  });

  final Offering offering;
  final VoidCallback onTap;

  /// Overrides the closing badge, e.g. for a partial finder match.
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final o = offering;
    final ink = KeelColors.ink.of(context);
    final muted = KeelColors.muted.of(context);
    final azure = KeelColors.azure.of(context);
    final soon = o.closes.difference(DateTime.now()).inDays < 7;
    final tag = badge ?? (soon ? Formats.until(o.closes) : null);
    return Semantics(
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
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: KeelColors.mist.of(context),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: PayoffGlyph(payoff: o.payoff, color: azure, size: 40),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      o.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: ink,
                        fontSize: 16,
                        height: 1.25,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      o.underlying,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: muted, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    o.headlineIsRate
                        ? Formats.percent(o.headline)
                        : Formats.times(o.headline),
                    style: TextStyle(
                      color: ink,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  if (tag != null) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: KeelColors.mist.of(context),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          color: azure,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
