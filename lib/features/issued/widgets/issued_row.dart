import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/services.dart';

import 'package:investnotes_app_sample1/core/formatting/formats.dart';
import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/core/widgets/note_icons.dart';
import 'package:investnotes_app_sample1/core/widgets/sparkline.dart';
import 'package:investnotes_app_sample1/data/models/issued_note.dart';
import 'package:investnotes_app_sample1/data/models/note_enums.dart';

/// An issued note: its status, name and return. Opens to show its path.
class IssuedRow extends StatelessWidget {
  const IssuedRow({
    super.key,
    required this.note,
    required this.expanded,
    required this.onToggle,
  });

  final IssuedNote note;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final n = note;
    final ink = KeelColors.ink.of(context);
    final muted = KeelColors.muted.of(context);
    final azure = KeelColors.azure.of(context);
    final changeColor = n.change < 0 ? KeelColors.loss.of(context) : azure;
    final live = n.status == IssuedStatus.active;
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: KeelColors.hairline.of(context)),
        ),
      ),
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
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: live ? KeelColors.mist.of(context) : null,
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
                        semanticLabel: n.status.title,
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
                      Formats.percent(n.change, signed: true),
                      style: TextStyle(
                        color: changeColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
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
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: expanded
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
                              text: Formats.shortDate(n.issued),
                              semantics: 'Issued',
                            ),
                            _Fact(
                              icon: CupertinoIcons.flag_circle,
                              text: Formats.shortDate(n.matures),
                              semantics: 'Matures',
                            ),
                            _Fact(
                              icon: CupertinoIcons.tag,
                              text: '${n.type.code} · ${n.currency.code}',
                              semantics: 'Type and currency',
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
  });

  final IconData icon;
  final String text;
  final String semantics;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Semantics(
      label: '$semantics $text',
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
