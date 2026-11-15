import 'package:cupertino_ui/cupertino_ui.dart';

import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/features/account/widgets/advance_button.dart';

/// The end of a flow: a mark that lands, what happened, and the way on.
class FlowDone extends StatelessWidget {
  const FlowDone({
    super.key,
    required this.title,
    required this.detail,
    required this.actionLabel,
    required this.onAction,
    this.icon = CupertinoIcons.checkmark_alt,
    this.spokenDetail,
  });

  final String title;
  final String detail;
  final String actionLabel;
  final VoidCallback onAction;
  final IconData icon;

  /// Said in place of [detail], such as a masked address. Never drawn.
  final String? spokenDetail;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      24,
      56,
      24,
      32 + MediaQuery.paddingOf(context).bottom,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.4, end: 1),
          duration: const Duration(milliseconds: 520),
          curve: Curves.elasticOut,
          builder: (context, scale, child) =>
              Transform.scale(scale: scale, child: child),
          child: Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: KeelColors.azure.of(context),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: CupertinoColors.white, size: 42),
          ),
        ),
        const SizedBox(height: 28),
        // Said as the flow lands here, so the outcome is heard.
        Semantics(
          liveRegion: true,
          header: true,
          child: Text(
            title,
            style: TextStyle(
              color: KeelColors.ink.of(context),
              fontSize: 30,
              height: 1.1,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.6,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          detail,
          semanticsLabel: spokenDetail,
          style: TextStyle(color: KeelColors.muted.of(context), fontSize: 17),
        ),
        const Spacer(),
        AdvanceButton(label: actionLabel, onPressed: onAction),
      ],
    ),
  );
}
