import 'package:cupertino_ui/cupertino_ui.dart';

import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/core/widgets/round_icon_button.dart';

/// The control that moves a flow on, at the trailing edge.
class AdvanceButton extends StatelessWidget {
  const AdvanceButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = CupertinoIcons.arrow_right,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerRight,
    child: RoundIconButton(
      icon: icon,
      label: label,
      foreground: CupertinoColors.white,
      background: KeelColors.azure.of(context),
      size: 56,
      iconSize: 24,
      onPressed: onPressed,
    ),
  );
}
