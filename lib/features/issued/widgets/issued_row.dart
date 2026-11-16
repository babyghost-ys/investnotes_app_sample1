import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/services.dart';
import 'package:keel_localisation/keel_localisation.dart';

import 'package:investnotes_app_sample1/core/l10n/terms.dart';
import 'package:investnotes_app_sample1/core/l10n/generated/locales.dart';
import 'package:investnotes_app_sample1/core/formatting/formats.dart';
import 'package:investnotes_app_sample1/core/formatting/spoken.dart';
import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/core/widgets/note_icons.dart';
import 'package:investnotes_app_sample1/core/widgets/round_icon_button.dart';
import 'package:investnotes_app_sample1/core/widgets/sparkline.dart';
import 'package:investnotes_app_sample1/domain/models/issued_note.dart';
import 'package:investnotes_app_sample1/domain/models/note_enums.dart';

/// An issued note: its status, name and return. Opens to show its path,
/// or, beside a split window's detail pane, picks the note shown there.
class IssuedRow extends StatelessWidget implements LocalisationConsumer {
  const IssuedRow({
    super.key,
    required this.note,
    required this.expanded,
    required this.onToggle,
    this.onOpen,
    this.onSelect,
    this.selected = false,
  });

  final IssuedNote note;
  final bool expanded;
  final VoidCallback onToggle;

  /// Opens the note's page from the unfolded row.
  final VoidCallback? onOpen;

  /// In a split window, shows the note beside the list. The row then picks
  /// rather than unfolds: the pane beside it holds the whole note.
  final VoidCallback? onSelect;

  /// The note shown beside the list.
  final bool selected;

  static const _reach = 12.0;

  @override
  List<String> get namespaces => const [Locales.issued, Locales.general];

  @override
  Widget build(BuildContext context) => LocalisedBuilder(
    consumer: this,
    builder: (context, locale) =>
        _build(context, locale[0] as IssuedLocale, locale[1] as GeneralLocale),
  );

  Widget _build(
    BuildContext context,
    IssuedLocale issued,
    GeneralLocale general,
  ) {
    final n = note;
    final formats = Formats(general);
    final ink = KeelColors.ink.of(context);
    final muted = KeelColors.muted.of(context);
    final azure = KeelColors.azure.of(context);
    final changeColor = n.change < 0 ? KeelColors.loss.of(context) : azure;
    final live = n.status == IssuedStatus.active;
    final picks = onSelect != null;
    final open = expanded && !picks;
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: selected
                ? const Color(0x00000000)
                : KeelColors.hairline.of(context),
          ),
        ),
      ),
      child: Column(
        children: [
          Semantics(
            button: true,
            expanded: picks ? null : expanded,
            selected: picks ? selected : null,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                HapticFeedback.selectionClick();
                (onSelect ?? onToggle)();
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // The highlight reaches past the row's edges, its ends
                  // round like the status disc's.
                  Positioned.fill(
                    left: -_reach,
                    right: -_reach,
                    child: AnimatedOpacity(
                      opacity: selected ? 1 : 0,
                      duration: const Duration(milliseconds: 180),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: KeelColors.mist.of(context),
                          borderRadius: BorderRadius.circular(20 + _reach),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: live
                                ? (selected
                                      ? KeelColors.raised.of(context)
                                      : KeelColors.mist.of(context))
                                : null,
                            border: live
                                ? null
                                : Border.all(
                                    color: KeelColors.hairline.of(context),
                                  ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            NoteIcons.status(n.status),
                            size: 19,
                            color: live ? azure : muted,
                            semanticLabel: n.status.title(general),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            n.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: ink,
                              fontSize: 16,
                              height: 1.25,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          formats.percent(n.change, signed: true),
                          semanticsLabel: Spoken(general).change(n.change),
                          style: TextStyle(
                            color: changeColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        if (!picks) ...[
                          const SizedBox(width: 6),
                          AnimatedRotation(
                            turns: expanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 220),
                            child: Icon(
                              CupertinoIcons.chevron_down,
                              size: 16,
                              color: muted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: open
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: Column(
                      children: [
                        Sparkline(
                          values: n.history,
                          color: changeColor,
                          parColor: KeelColors.hairline.of(context),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _Fact(
                              icon: CupertinoIcons.flag,
                              text: formats.shortDate(n.issued),
                              semantics: issued.semantics.issued,
                            ),
                            _Fact(
                              icon: CupertinoIcons.flag_circle,
                              text: formats.shortDate(n.matures),
                              semantics: issued.semantics.matures,
                            ),
                            _Fact(
                              icon: CupertinoIcons.tag,
                              text: '${n.type.code} · ${n.currency.code}',
                              semantics: issued.semantics.typeAndCurrency,
                              spoken:
                                  '${n.type.title(general)}, ${n.currency.code}',
                            ),
                            if (onOpen != null)
                              RoundIconButton(
                                icon: CupertinoIcons.arrow_right,
                                label: general.semantics.openItem(name: n.name),
                                foreground: CupertinoColors.white,
                                background: KeelColors.tide.of(context),
                                size: 40,
                                iconSize: 18,
                                onPressed: onOpen,
                              ),
                          ],
                        ),
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({
    required this.icon,
    required this.text,
    required this.semantics,
    this.spoken,
  });

  final IconData icon;
  final String text;
  final String semantics;

  /// Said in place of [text] when it is an abbreviation.
  final String? spoken;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Semantics(
      label: '$semantics ${spoken ?? text}',
      excludeSemantics: true,
      child: Row(
        children: [
          Icon(icon, size: 15, color: KeelColors.muted.of(context)),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: KeelColors.ink.of(context),
                fontSize: 13,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
