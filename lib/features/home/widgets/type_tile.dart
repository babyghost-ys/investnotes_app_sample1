import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/services.dart';
import 'package:keel_localisation/keel_localisation.dart';

import 'package:investnotes_app_sample1/core/l10n/terms.dart';
import 'package:investnotes_app_sample1/core/l10n/generated/locales.dart';
import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/core/widgets/payoff_glyph.dart';
import 'package:investnotes_app_sample1/domain/models/note_enums.dart';
import 'package:investnotes_app_sample1/domain/models/payoff.dart';

/// A note family on Home: its payoff shape, its code and its name.
class TypeTile extends StatelessWidget implements LocalisationConsumer {
  const TypeTile({super.key, required this.type, required this.onTap});

  final NoteType type;
  final VoidCallback onTap;

  static Payoff shapeOf(NoteType type) => switch (type) {
    NoteType.mld => const Payoff(type: NoteType.mld, cap: 0.3),
    NoteType.ppn => const Payoff(type: NoteType.ppn, participation: 1.4),
    NoteType.par => const Payoff(
      type: NoteType.par,
      participation: 1.6,
      cap: 0.45,
      buffer: 0.2,
    ),
    NoteType.auto => const Payoff(
      type: NoteType.auto,
      coupon: 0.25,
      barrier: -0.3,
    ),
  };

  @override
  List<String> get namespaces => const [Locales.general];

  @override
  Widget build(BuildContext context) => LocalisedBuilder(
    consumer: this,
    builder: (context, locale) => _build(context, locale[0] as GeneralLocale),
  );

  Widget _build(BuildContext context, GeneralLocale general) {
    final azure = KeelColors.azure.of(context);
    return Semantics(
      button: true,
      label: type.title(general),
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
          decoration: BoxDecoration(
            color: KeelColors.raised.of(context),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: KeelColors.hairline.of(context)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PayoffGlyph(
                payoff: shapeOf(type),
                color: azure,
                baseline: KeelColors.hairline.of(context),
                size: 44,
                strokeWidth: 3,
              ),
              const SizedBox(height: 18),
              Text(
                type.code,
                style: TextStyle(
                  color: KeelColors.ink.of(context),
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                type.title(general),
                maxLines: 2,
                style: TextStyle(
                  color: KeelColors.muted.of(context),
                  fontSize: 13,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
