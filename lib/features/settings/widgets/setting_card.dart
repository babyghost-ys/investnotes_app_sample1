import 'package:cupertino_ui/cupertino_ui.dart';

import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';

/// One setting: its name in the bar's blue, a line on what it does, and
/// its control at the trailing end.
class SettingCard extends StatelessWidget {
  const SettingCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.control,
  });

  final String title;
  final String subtitle;
  final Widget control;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
    decoration: BoxDecoration(
      color: KeelColors.raised.of(context),
      borderRadius: BorderRadius.circular(22),
      boxShadow: [
        BoxShadow(
          color: const Color(0x1A000000),
          blurRadius: 14,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.toUpperCase(),
                semanticsLabel: title,
                style: TextStyle(
                  color: KeelColors.tideInk.of(context),
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: KeelColors.muted.of(context),
                  fontSize: 13,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        control,
      ],
    ),
  );
}
