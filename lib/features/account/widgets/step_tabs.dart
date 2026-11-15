import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:keel_localisation/keel_localisation.dart';

import 'package:investnotes_app_sample1/core/l10n/generated/locales.dart';
import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';

/// The steps of a flow along the top: the current one in ink with its bar
/// lit, the finished ones lit, the ones ahead faint. A finished step opens
/// again when tapped.
class StepTabs extends StatelessWidget implements LocalisationConsumer {
  const StepTabs({
    super.key,
    required this.titles,
    required this.current,
    required this.onBack,
  });

  final List<String> titles;
  final int current;

  /// Goes back one step.
  final VoidCallback onBack;

  @override
  List<String> get namespaces => const [Locales.account];

  @override
  Widget build(BuildContext context) => LocalisedBuilder(
    consumer: this,
    builder: (context, locale) => _build(context, locale[0] as AccountLocale),
  );

  Widget _build(BuildContext context, AccountLocale account) {
    final azure = KeelColors.azure.of(context);
    final hairline = KeelColors.hairline.of(context);
    return Semantics(
      label: account.semantics.stepOf(
        step: current + 1,
        count: titles.length,
        title: titles[current],
      ),
      onTap: current > 0 ? onBack : null,
      onTapHint: current > 0 ? account.semantics.backStep : null,
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
        child: Row(
          children: [
            for (var i = 0; i < titles.length; i++) ...[
              if (i > 0) const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: i < current
                      ? () {
                          for (var n = current; n > i; n--) {
                            onBack();
                          }
                        }
                      : null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: i == current
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: i == current
                              ? KeelColors.ink.of(context)
                              : i < current
                              ? azure
                              : KeelColors.muted
                                    .of(context)
                                    .withValues(alpha: 0.6),
                        ),
                        child: Text(titles[i]),
                      ),
                      const SizedBox(height: 10),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 240),
                        height: 3,
                        decoration: BoxDecoration(
                          color: i <= current ? azure : hairline,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
