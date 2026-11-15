import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:keel_localisation/keel_localisation.dart';

import 'package:investnotes_app_sample1/core/l10n/generated/locales.dart';
import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/core/widgets/round_icon_button.dart';

/// Opens a filter sheet. Tinted, with a dot, while any filter is on.
class FilterIconButton extends StatelessWidget implements LocalisationConsumer {
  const FilterIconButton({
    super.key,
    required this.activeCount,
    required this.onPressed,
  });

  final int activeCount;
  final VoidCallback onPressed;

  @override
  List<String> get namespaces => const [Locales.general];

  @override
  Widget build(BuildContext context) => LocalisedBuilder(
    consumer: this,
    builder: (context, locale) => _build(context, locale[0] as GeneralLocale),
  );

  Widget _build(BuildContext context, GeneralLocale general) {
    final active = activeCount > 0;
    final azure = KeelColors.azure.of(context);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        RoundIconButton(
          icon: CupertinoIcons.slider_horizontal_3,
          label: active
              ? general.semantics.filtersOn(count: activeCount)
              : general.semantics.filters,
          foreground: active
              ? CupertinoColors.white
              : KeelColors.ink.of(context),
          background: active ? azure : KeelColors.mist.of(context),
          onPressed: onPressed,
        ),
        if (active)
          Positioned(
            right: -2,
            top: -2,
            // The button's label already says how many are on.
            child: IgnorePointer(
              child: ExcludeSemantics(
                child: Container(
                  width: 18,
                  height: 18,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: KeelColors.page.of(context),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$activeCount',
                    style: TextStyle(
                      color: azure,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
