import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:keel_localisation/keel_localisation.dart';

import 'package:investnotes_app_sample1/core/l10n/generated/locales.dart';
import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/core/widgets/round_icon_button.dart';
import 'package:investnotes_app_sample1/data/models/credentials.dart';

/// Where the code went, with a control to send another.
class CodeSentHeader extends StatelessWidget implements LocalisationConsumer {
  const CodeSentHeader({
    super.key,
    required this.email,
    required this.resent,
    required this.onResend,
  });

  final String email;

  /// A fresh code went out a moment ago.
  final bool resent;
  final VoidCallback onResend;

  @override
  List<String> get namespaces => const [Locales.account];

  @override
  Widget build(BuildContext context) => LocalisedBuilder(
    consumer: this,
    builder: (context, locale) => _build(context, locale[0] as AccountLocale),
  );

  Widget _build(BuildContext context, AccountLocale account) {
    final azure = KeelColors.azure.of(context);
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: KeelColors.mist.of(context),
            shape: BoxShape.circle,
          ),
          child: Icon(CupertinoIcons.envelope_open, color: azure, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                account.labels.codeSentTo,
                style: TextStyle(
                  color: KeelColors.muted.of(context),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                Credentials.masked(email),
                semanticsLabel: Credentials.spokenMasked(email, account),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: KeelColors.ink.of(context),
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: RoundIconButton(
            key: ValueKey(resent),
            icon: resent
                ? CupertinoIcons.checkmark
                : CupertinoIcons.arrow_clockwise,
            label: resent
                ? account.semantics.newCodeSent
                : account.semantics.sendNewCode,
            foreground: azure,
            background: KeelColors.mist.of(context),
            onPressed: resent ? null : onResend,
          ),
        ),
      ],
    );
  }
}
