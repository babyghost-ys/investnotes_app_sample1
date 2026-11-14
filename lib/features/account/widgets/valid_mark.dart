import 'package:cupertino_ui/cupertino_ui.dart';

import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';

/// A tick at the end of a field once what is in it will do.
class ValidMark extends StatelessWidget {
  const ValidMark({super.key, required this.valid});

  final bool valid;

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
    duration: const Duration(milliseconds: 200),
    transitionBuilder: (child, animation) =>
        ScaleTransition(scale: animation, child: child),
    child: valid
        ? Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Icon(
              CupertinoIcons.checkmark_circle_fill,
              size: 20,
              color: KeelColors.azure.of(context),
            ),
          )
        : const SizedBox.shrink(),
  );
}
