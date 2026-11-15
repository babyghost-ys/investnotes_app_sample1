import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:keel_localisation/keel_localisation.dart';

import 'package:investnotes_app_sample1/core/l10n/generated/locales.dart';
import 'package:investnotes_app_sample1/core/formatting/formats.dart';
import 'package:investnotes_app_sample1/core/formatting/spoken.dart';
import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/domain/models/holding.dart';

/// What everything held is worth today, its return since issue, and how it
/// splits across the notes, one segment each in the shades of their rows.
class HoldingsTotal extends StatelessWidget implements LocalisationConsumer {
  const HoldingsTotal({
    super.key,
    required this.holdings,
    required this.value,
    required this.change,
  });

  final List<Holding> holdings;
  final double value;
  final double change;

  /// The shade of the [index]th holding, shared with its row.
  static Color shade(BuildContext context, int index) => KeelColors.azure
      .of(context)
      .withValues(alpha: (1 - index * 0.22).clamp(0.25, 1.0));

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
    final up = change >= 0;
    final f = Formats(general);
    final changeColor = up
        ? KeelColors.azure.of(context)
        : KeelColors.loss.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          f.dollars(value),
          semanticsLabel: myNotes.semantics.totalValue(value: f.dollars(value)),
          style: TextStyle(
            color: KeelColors.ink.of(context),
            fontSize: 44,
            fontWeight: FontWeight.w700,
            letterSpacing: -1.2,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              up
                  ? CupertinoIcons.arrow_up_right
                  : CupertinoIcons.arrow_down_right,
              size: 16,
              color: changeColor,
            ),
            const SizedBox(width: 4),
            Text(
              f.percent(change, signed: true),
              semanticsLabel: Spoken(general).change(change),
              style: TextStyle(
                color: changeColor,
                fontSize: 17,
                fontWeight: FontWeight.w600,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        // How the total splits, by colour; each row says its own worth.
        ExcludeSemantics(
          child: SizedBox(
            height: 10,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < holdings.length; i++) ...[
                  if (i > 0) const SizedBox(width: 3),
                  Expanded(
                    flex: (holdings[i].value / value * 1000).round(),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: shade(context, i),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
