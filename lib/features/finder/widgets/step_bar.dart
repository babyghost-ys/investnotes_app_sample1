import 'package:cupertino_ui/cupertino_ui.dart';

import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';

/// Where the finder is: one segment per question, filled up to [step].
class StepBar extends StatelessWidget {
  const StepBar({super.key, required this.step, required this.count});

  final int step;
  final int count;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Step ${step + 1} of $count',
    child: Row(
      children: [
        for (var i = 0; i < count; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(
            child: Container(
              height: 5,
              decoration: BoxDecoration(
                color: i <= step
                    ? KeelColors.azure.of(context)
                    : KeelColors.hairline.of(context),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ],
      ],
    ),
  );
}
