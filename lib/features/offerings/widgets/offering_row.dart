import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/services.dart';
import 'package:keel_localisation/keel_localisation.dart';

import 'package:investnotes_app_sample1/core/formatting/formats.dart';
import 'package:investnotes_app_sample1/core/formatting/spoken.dart';
import 'package:investnotes_app_sample1/core/l10n/generated/locales.dart';
import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/core/widgets/payoff_glyph.dart';
import 'package:investnotes_app_sample1/data/models/offering.dart';

/// An offering in a list: its payoff shape, its name, and the number people
/// compare it by. A closing date shows only when it is close.
class OfferingRow extends StatelessWidget implements LocalisationConsumer {
  const OfferingRow({
    super.key,
    required this.offering,
    required this.onTap,
    this.badge,
    this.spokenBadge,
    this.selected = false,
  });

  final Offering offering;
  final VoidCallback onTap;

  /// Overrides the closing badge, e.g. for a partial finder match.
  final String? badge;

  /// What assistive technologies say for [badge], such as "3 of 4 answers
  /// match" for "3/4".
  final String? spokenBadge;

  /// Marks the offering open beside the list in a split window.
  final bool selected;

  @override
  List<String> get namespaces => const [Locales.general];

  @override
  Widget build(BuildContext context) => LocalisedBuilder(
    consumer: this,
    builder: (context, locale) => _build(context, locale[0] as GeneralLocale),
  );

  Widget _build(BuildContext context, GeneralLocale general) {
    final formats = Formats(general);
    final say = Spoken(general);
    final o = offering;
    final ink = KeelColors.ink.of(context);
    final muted = KeelColors.muted.of(context);
    final azure = KeelColors.azure.of(context);
    final soon = o.closes.difference(DateTime.now()).inDays < 7;
    final tag = badge ?? (soon ? formats.until(o.closes) : null);
    final mist = KeelColors.mist.of(context);
    final spoken = [
      o.name,
      o.underlying,
      say.headline(o),
      if (badge != null)
        spokenBadge ?? badge!
      else if (soon)
        say.closes(o.closes),
    ].join(', ');
    return Semantics(
      container: true,
      button: true,
      selected: selected,
      label: spoken,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // The highlight reaches past the row's edges, its corners
            // concentric with the glyph tile's.
            Positioned.fill(
              left: -_reach,
              right: -_reach,
              child: AnimatedOpacity(
                opacity: selected ? 1 : 0,
                duration: const Duration(milliseconds: 180),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: mist,
                    borderRadius: BorderRadius.circular(_tileRadius + _reach),
                  ),
                ),
              ),
            ),
            _row(context, o, ink, muted, azure, tag, formats),
          ],
        ),
      ),
    );
  }

  static const _reach = 12.0;
  static const _tileRadius = 14.0;

  Widget _row(
    BuildContext context,
    Offering o,
    Color ink,
    Color muted,
    Color azure,
    String? tag,
    Formats formats,
  ) => Container(
    padding: const EdgeInsets.symmetric(vertical: 14),
    decoration: BoxDecoration(
      border: Border(
        bottom: BorderSide(
          color: selected
              ? const Color(0x00000000)
              : KeelColors.hairline.of(context),
        ),
      ),
    ),
    child: Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: selected
                ? KeelColors.raised.of(context)
                : KeelColors.mist.of(context),
            borderRadius: BorderRadius.circular(_tileRadius),
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
                  ? formats.percent(o.headline)
                  : formats.times(o.headline),
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: selected
                      ? KeelColors.raised.of(context)
                      : KeelColors.mist.of(context),
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
  );
}
