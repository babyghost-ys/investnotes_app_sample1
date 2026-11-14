import 'package:cupertino_ui/cupertino_ui.dart';

import 'package:investnotes_app_sample1/core/formatting/formats.dart';
import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/data/models/product.dart';

/// Where the note stands now: its indicative price per 100 of principal,
/// the change since issue, and how far through its term it is.
class ValueSection extends StatelessWidget {
  const ValueSection({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final p = product;
    final ink = KeelColors.ink.of(context);
    final muted = KeelColors.muted.of(context);
    final azure = KeelColors.azure.of(context);
    final changeColor = p.change < 0 ? KeelColors.loss.of(context) : azure;
    final end = p.calledOn ?? p.maturity;
    final today = DateTime.now();
    final total = end.difference(p.issueDate).inDays;
    final done = today.difference(p.issueDate).inDays.clamp(0, total);
    final progress = total == 0 ? 1.0 : done / total;
    final figures = const [FontFeature.tabularFigures()];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              p.price!.toStringAsFixed(2),
              semanticsLabel:
                  'Indicative price ${p.price!.toStringAsFixed(2)} per 100',
              style: TextStyle(
                color: ink,
                fontSize: 56,
                height: 1,
                fontWeight: FontWeight.w700,
                letterSpacing: -1.8,
                fontFeatures: figures,
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Text(
                '/ 100',
                style: TextStyle(color: muted, fontSize: 17),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                Formats.percent(p.change, signed: true),
                style: TextStyle(
                  color: changeColor,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  fontFeatures: figures,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Semantics(
          label:
              '${(progress * 100).round()}% of the term gone, ${Formats.fullDate(p.issueDate)} to ${Formats.fullDate(end)}',
          excludeSemantics: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LayoutBuilder(
                builder: (context, box) => Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: KeelColors.mist.of(context),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    Container(
                      height: 10,
                      width: box.maxWidth * progress,
                      decoration: BoxDecoration(
                        color: azure,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(CupertinoIcons.flag, size: 15, color: muted),
                  const SizedBox(width: 6),
                  Text(
                    Formats.fullDate(p.issueDate),
                    style: TextStyle(color: muted, fontSize: 13),
                  ),
                  const Spacer(),
                  Text(
                    Formats.fullDate(end),
                    style: TextStyle(color: muted, fontSize: 13),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    p.calledOn == null
                        ? CupertinoIcons.flag_circle
                        : CupertinoIcons.bell,
                    size: 15,
                    color: muted,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
