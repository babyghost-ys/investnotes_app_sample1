import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:keel_localisation/keel_localisation.dart';

import 'package:investnotes_app_sample1/core/l10n/generated/locales.dart';
import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';

/// A tick at the end of a field once what is in it will do.
class ValidMark extends StatelessWidget implements LocalisationConsumer {
  const ValidMark({super.key, required this.valid});

  final bool valid;

  @override
  List<String> get namespaces => const [Locales.account];

  @override
  Widget build(BuildContext context) => LocalisedBuilder(
    consumer: this,
    builder: (context, locale) => _build(context, locale[0] as AccountLocale),
  );

  Widget _build(BuildContext context, AccountLocale account) =>
      AnimatedSwitcher(
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
                  semanticLabel: account.semantics.looksRight,
                ),
              )
            : const SizedBox.shrink(),
      );
}
