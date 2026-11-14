import 'package:flutter_native_widgets/flutter_native_widgets.dart';
import 'package:cupertino_ui/cupertino_ui.dart';

import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';

/// A yes-or-no question with its answer beside it.
class QuestionRow extends StatelessWidget {
  const QuestionRow({
    super.key,
    required this.question,
    required this.value,
    required this.onChanged,
  });

  final String question;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 18),
    child: Row(
      children: [
        Expanded(
          child: Text(
            question,
            style: TextStyle(
              color: KeelColors.ink.of(context),
              fontSize: 17,
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(
          width: 112,
          child: NativeSegmentedControl(
            labels: const ['Yes', 'No'],
            icons: const [
              NativeIcon(sfSymbol: 'checkmark', icon: CupertinoIcons.checkmark),
              NativeIcon(sfSymbol: 'xmark', icon: CupertinoIcons.xmark),
            ],
            selectedIndex: value ? 0 : 1,
            onValueChanged: (i) => onChanged(i == 0),
          ),
        ),
      ],
    ),
  );
}
