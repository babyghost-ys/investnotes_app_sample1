import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/services.dart';
import 'package:keel_localisation/keel_localisation.dart';

import 'package:investnotes_app_sample1/core/l10n/terms.dart';
import 'package:investnotes_app_sample1/core/l10n/generated/locales.dart';
import 'package:investnotes_app_sample1/core/formatting/formats.dart';
import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/core/widgets/note_icons.dart';
import 'package:investnotes_app_sample1/core/widgets/payoff_glyph.dart';
import 'package:investnotes_app_sample1/core/widgets/round_icon_button.dart';
import 'package:investnotes_app_sample1/domain/models/note_enums.dart';
import 'package:investnotes_app_sample1/domain/models/product.dart';

/// A search result. Closed, it shows the note's shape, name and standing;
/// tapped, its header turns the bar's blue and its order terms unfold,
/// with a control to the note's page.
class SearchResultCard extends StatelessWidget implements LocalisationConsumer {
  const SearchResultCard({
    super.key,
    required this.product,
    required this.expanded,
    required this.onToggle,
    required this.onOpen,
  });

  final Product product;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onOpen;

  static const _duration = Duration(milliseconds: 280);
  static const _curve = Curves.easeOutCubic;

  List<(String, String)> _terms(SearchLocale search, GeneralLocale general) {
    final p = product;
    final f = Formats(general);
    final words = search.labels;
    return [
      (words.fundserv, p.fundserv),
      (words.noteType, p.type.title(general)),
      (words.underlying, p.underlying),
      (words.currency, p.currency.code),
      (
        p.isOffering ? words.closes : words.issued,
        f.fullDate(p.closes ?? p.issueDate),
      ),
      if (p.calledOn != null)
        (words.called, f.fullDate(p.calledOn!))
      else
        (words.matures, f.fullDate(p.maturity)),
      if (p.price != null) (words.price, f.fixed(p.price!)),
    ];
  }

  @override
  List<String> get namespaces => const [Locales.search, Locales.general];

  @override
  Widget build(BuildContext context) => LocalisedBuilder(
    consumer: this,
    builder: (context, locale) =>
        _build(context, locale[0] as SearchLocale, locale[1] as GeneralLocale),
  );

  Widget _build(
    BuildContext context,
    SearchLocale search,
    GeneralLocale general,
  ) {
    final p = product;
    final raised = KeelColors.raised.of(context);
    final ink = KeelColors.ink.of(context);
    final muted = KeelColors.muted.of(context);
    final azure = KeelColors.azure.of(context);
    final tide = KeelColors.tide.of(context);
    final tideDeep = KeelColors.tideDeep.of(context);
    final status = p.status;
    final live = status == null || status == IssuedStatus.active;
    final standing = status == null
        ? Formats(general).until(p.closes!)
        : status.title(general);
    final accent = expanded ? KeelColors.foam : (live ? azure : muted);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AnimatedContainer(
        duration: _duration,
        curve: _curve,
        decoration: BoxDecoration(
          color: raised,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: expanded ? tide : KeelColors.hairline.of(context),
          ),
          boxShadow: expanded
              ? [
                  BoxShadow(
                    color: tide.withValues(alpha: 0.18),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ]
              : const [],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Semantics(
              button: true,
              expanded: expanded,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onToggle();
                },
                child: AnimatedContainer(
                  duration: _duration,
                  curve: _curve,
                  padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: expanded ? [tide, tideDeep] : [raised, raised],
                    ),
                  ),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: _duration,
                        curve: _curve,
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: expanded
                              ? CupertinoColors.white.withValues(alpha: 0.14)
                              : KeelColors.mist.of(context),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        alignment: Alignment.center,
                        child: PayoffGlyph(
                          payoff: p.payoff,
                          color: expanded ? CupertinoColors.white : azure,
                          size: 34,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedDefaultTextStyle(
                              duration: _duration,
                              style: TextStyle(
                                color: expanded ? CupertinoColors.white : ink,
                                fontSize: 16,
                                height: 1.25,
                                fontWeight: FontWeight.w600,
                              ),
                              child: Text(p.name),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  status == null
                                      ? CupertinoIcons.lock_open
                                      : NoteIcons.status(status),
                                  size: 13,
                                  color: accent,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  standing,
                                  semanticsLabel: status == null
                                      ? search.semantics.openUntil(
                                          date: standing,
                                        )
                                      : null,
                                  style: TextStyle(
                                    color: accent,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      AnimatedRotation(
                        turns: expanded ? 0.5 : 0,
                        duration: _duration,
                        curve: _curve,
                        child: Icon(
                          CupertinoIcons.chevron_down,
                          size: 17,
                          color: expanded ? CupertinoColors.white : muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            AnimatedSize(
              duration: _duration,
              curve: _curve,
              alignment: Alignment.topCenter,
              child: expanded
                  ? _Terms(
                      terms: _terms(search, general),
                      onOpen: onOpen,
                      openLabel: general.semantics.openItem(name: p.name),
                    )
                  : const SizedBox(width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }
}

/// The order terms as a two-column table on alternate bands, then the
/// control to the note's page at its foot.
class _Terms extends StatelessWidget {
  const _Terms({
    required this.terms,
    required this.onOpen,
    required this.openLabel,
  });

  final List<(String, String)> terms;
  final VoidCallback onOpen;
  final String openLabel;

  @override
  Widget build(BuildContext context) {
    final band = KeelColors.mist.of(context).withValues(alpha: 0.55);
    final key = KeelColors.azure.of(context);
    final ink = KeelColors.ink.of(context);
    return Column(
      children: [
        for (var i = 0; i < terms.length; i++)
          Container(
            color: i.isOdd ? band : null,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  terms[i].$1,
                  style: TextStyle(
                    color: key,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    terms[i].$2,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: ink,
                      fontSize: 15,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 12, 12),
          child: Align(
            alignment: Alignment.centerRight,
            child: RoundIconButton(
              icon: CupertinoIcons.arrow_right,
              label: openLabel,
              foreground: CupertinoColors.white,
              background: KeelColors.tide.of(context),
              size: 48,
              iconSize: 20,
              onPressed: onOpen,
            ),
          ),
        ),
      ],
    );
  }
}
