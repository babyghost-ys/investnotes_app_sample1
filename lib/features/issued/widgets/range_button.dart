import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/services.dart';
import 'package:keel_localisation/keel_localisation.dart';

import 'package:investnotes_app_sample1/core/l10n/generated/locales.dart';
import 'package:investnotes_app_sample1/core/formatting/formats.dart';
import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';

/// One end of a custom date range. Its date is its content; tapping opens
/// a calendar on top.
class RangeButton extends StatelessWidget implements LocalisationConsumer {
  const RangeButton({
    super.key,
    required this.icon,
    required this.date,
    required this.semantics,
    required this.onTap,
  });

  final IconData icon;

  /// Null shows "Any".
  final DateTime? date;
  final String semantics;
  final VoidCallback onTap;

  @override
  List<String> get namespaces => const [Locales.general];

  @override
  Widget build(BuildContext context) => LocalisedBuilder(
    consumer: this,
    builder: (context, locale) => _build(context, locale[0] as GeneralLocale),
  );

  Widget _build(BuildContext context, GeneralLocale general) => Semantics(
    button: true,
    label:
        '$semantics ${date == null ? general.semantics.any : Formats(general).fullDate(date!)}',
    excludeSemantics: true,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: KeelColors.raised.of(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: KeelColors.hairline.of(context)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: KeelColors.azure.of(context)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                date == null
                    ? general.labels.any
                    : Formats(general).fullDate(date!),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: KeelColors.ink.of(context),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
