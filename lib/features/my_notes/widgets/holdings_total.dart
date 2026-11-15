import 'package:cupertino_ui/cupertino_ui.dart';

import 'package:investnotes_app_sample1/core/formatting/formats.dart';
import 'package:investnotes_app_sample1/core/formatting/spoken.dart';
import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/data/models/holding.dart';

/// What everything held is worth today, its return since issue, and how it
/// splits across the notes, one segment each in the shades of their rows.
class HoldingsTotal extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final up = change >= 0;
    final changeColor = up
        ? KeelColors.azure.of(context)
        : KeelColors.loss.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Formats.dollars(value),
          semanticsLabel: 'Total value ${Formats.dollars(value)}',
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
              Formats.percent(change, signed: true),
              semanticsLabel: Spoken.change(change),
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
