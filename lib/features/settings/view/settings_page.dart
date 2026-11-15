import 'package:flutter_native_widgets/flutter_native_widgets.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keel_localisation/keel_localisation.dart';

import 'package:investnotes_app_sample1/core/l10n/generated/locales.dart';
import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/data/models/app_language.dart';
import 'package:investnotes_app_sample1/features/settings/bloc/settings_bloc.dart';
import 'package:investnotes_app_sample1/features/settings/widgets/setting_card.dart';

/// Keel's settings: the language it runs in, and its haptic feedback.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocProvider(create: (_) => SettingsBloc(), child: const _SettingsView());
}

class _SettingsView extends StatelessWidget implements LocalisationConsumer {
  const _SettingsView();

  @override
  List<String> get namespaces => const [Locales.settings];

  @override
  Widget build(BuildContext context) => LocalisedBuilder(
    consumer: this,
    builder: (context, locale) {
      final words = locale[0] as SettingsLocale;
      final haptics = context.watch<SettingsBloc>().state.haptics;
      // The language changes for the whole app the moment it is picked,
      // this page included.
      final language = AppLanguage.of(
        context.select<LocalisationBloc, String?>((b) => b.state.choice),
      );
      final insets = MediaQuery.paddingOf(context);
      final tide = KeelColors.tideInk.of(context);
      return ColoredBox(
        color: KeelColors.page.of(context),
        child: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          removeBottom: true,
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              16 + insets.left,
              insets.top + 16,
              16 + insets.right,
              insets.bottom + 32,
            ),
            children: [
              SettingCard(
                title: words.labels.languageTitle,
                subtitle: words.labels.languageDetail,
                control: SizedBox(
                  width: 150,
                  child: NativeSegmentedControl(
                    labels: [
                      for (final l in AppLanguage.values) _code(words, l),
                    ],
                    semanticLabels: [
                      for (final l in AppLanguage.values) _spoken(words, l),
                    ],
                    selectedIndex: language.index,
                    color: tide,
                    onValueChanged: (i) => context.read<LocalisationBloc>().add(
                      LocalisationChoiceChanged(AppLanguage.values[i].language),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SettingCard(
                title: words.labels.haptics,
                subtitle: words.labels.hapticsDetail,
                control: NativeSwitch(
                  value: haptics,
                  activeColor: tide,
                  semanticLabel: words.semantics.haptics,
                  onChanged: (on) => context.read<SettingsBloc>().add(
                    SettingsHapticsToggled(on: on),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

  static String _code(SettingsLocale words, AppLanguage language) =>
      switch (language) {
        AppLanguage.system => words.labels.system,
        AppLanguage.english => words.labels.english,
        AppLanguage.french => words.labels.french,
      };

  static String _spoken(SettingsLocale words, AppLanguage language) =>
      switch (language) {
        AppLanguage.system => words.semantics.system,
        AppLanguage.english => words.semantics.english,
        AppLanguage.french => words.semantics.french,
      };
}
