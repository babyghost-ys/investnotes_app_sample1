import 'package:cupertino_ui/cupertino_ui.dart';

import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/data/models/credentials.dart';

/// What a new password still needs, ticked off as it is typed.
class PasswordChecks extends StatelessWidget {
  const PasswordChecks({
    super.key,
    required this.password,
    required this.confirm,
  });

  final String password;
  final String confirm;

  @override
  Widget build(BuildContext context) {
    final checks = [
      ('8 or more characters', Credentials.longEnough(password)),
      ('Letters and numbers', Credentials.lettersAndDigits(password)),
      ('Passwords match', confirm.isNotEmpty && confirm == password),
    ];
    final azure = KeelColors.azure.of(context);
    final muted = KeelColors.muted.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (text, met) in checks)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
                  child: Icon(
                    met
                        ? CupertinoIcons.checkmark_circle_fill
                        : CupertinoIcons.circle,
                    key: ValueKey(met),
                    size: 18,
                    color: met ? azure : muted.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 14,
                    color: met ? KeelColors.ink.of(context) : muted,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
