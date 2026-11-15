import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:keel_localisation/keel_localisation.dart';

import 'package:investnotes_app_sample1/core/l10n/generated/locales.dart';
import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/data/models/credentials.dart';

/// What a new password still needs, ticked off as it is typed.
class PasswordChecks extends StatelessWidget implements LocalisationConsumer {
  const PasswordChecks({
    super.key,
    required this.password,
    required this.confirm,
  });

  final String password;
  final String confirm;

  @override
  List<String> get namespaces => const [Locales.account];

  @override
  Widget build(BuildContext context) => LocalisedBuilder(
    consumer: this,
    builder: (context, locale) => _build(context, locale[0] as AccountLocale),
  );

  Widget _build(BuildContext context, AccountLocale account) {
    final checks = [
      (account.labels.checkLength, Credentials.longEnough(password)),
      (account.labels.checkMix, Credentials.lettersAndDigits(password)),
      (account.labels.checkMatch, confirm.isNotEmpty && confirm == password),
    ];
    final azure = KeelColors.azure.of(context);
    final muted = KeelColors.muted.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (text, met) in checks)
          Semantics(
            label: met
                ? account.semantics.checkMet(check: text)
                : account.semantics.checkUnmet(check: text),
            excludeSemantics: true,
            child: Padding(
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
          ),
      ],
    );
  }
}
