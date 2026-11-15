import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/services.dart';
import 'package:keel_localisation/keel_localisation.dart';

import 'package:investnotes_app_sample1/core/l10n/generated/locales.dart';
import 'package:investnotes_app_sample1/core/formatting/formats.dart';
import 'package:investnotes_app_sample1/core/formatting/spoken.dart';
import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/core/widgets/sparkline.dart';
import 'package:investnotes_app_sample1/domain/models/holding.dart';

/// A note held: its shade in the split, its path, its name and worth, and
/// its return. Opens the note's page.
class HoldingRow extends StatelessWidget implements LocalisationConsumer {
  const HoldingRow({
    super.key,
    required this.holding,
    required this.shade,
    required this.onTap,
  });

  final Holding holding;
  final Color shade;
  final VoidCallback onTap;

  @override
  List<String> get namespaces => const [Locales.myNotes, Locales.general];

  @override
  Widget build(BuildContext context) => LocalisedBuilder(
    consumer: this,
    builder: (context, locale) =>
        _build(context, locale[0] as MyNotesLocale, locale[1] as GeneralLocale),
  );

  Widget _build(
    BuildContext context,
    MyNotesLocale myNotes,
    GeneralLocale general,
  ) {
    final n = holding.note;
    final f = Formats(general);
    final muted = KeelColors.muted.of(context);
    final changeColor = n.change < 0
        ? KeelColors.loss.of(context)
        : KeelColors.azure.of(context);
    return Semantics(
      container: true,
      button: true,
      label: myNotes.semantics.worth(
        name: n.name,
        value: f.dollars(holding.value),
        change: Spoken(general).change(n.change),
      ),
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: KeelColors.hairline.of(context)),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: shade, shape: BoxShape.circle),
              ),
              const SizedBox(width: 14),
              SizedBox(
                width: 64,
                child: Sparkline(
                  values: n.history,
                  color: changeColor,
                  parColor: KeelColors.hairline.of(context),
                  height: 36,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      n.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: KeelColors.ink.of(context),
                        fontSize: 16,
                        height: 1.25,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      f.dollars(holding.value),
                      style: TextStyle(
                        color: muted,
                        fontSize: 14,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                f.percent(n.change, signed: true),
                style: TextStyle(
                  color: changeColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: 6),
              Icon(CupertinoIcons.chevron_right, size: 15, color: muted),
            ],
          ),
        ),
      ),
    );
  }
}
