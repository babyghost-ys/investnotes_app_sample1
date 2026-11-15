import 'package:flutter_native_widgets/flutter_native_widgets.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SettingsBloc>().state;
    final bloc = context.read<SettingsBloc>();
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
              title: 'Language',
              subtitle: 'Choose the app’s language',
              control: SizedBox(
                width: 150,
                child: NativeSegmentedControl(
                  labels: [for (final l in AppLanguage.values) l.code],
                  semanticLabels: [
                    for (final l in AppLanguage.values) l.spoken,
                  ],
                  selectedIndex: state.language.index,
                  color: tide,
                  onValueChanged: (i) =>
                      bloc.add(SettingsLanguageChanged(AppLanguage.values[i])),
                ),
              ),
            ),
            const SizedBox(height: 14),
            SettingCard(
              title: 'Haptics',
              subtitle: 'Enable or disable haptic feedback',
              control: NativeSwitch(
                value: state.haptics,
                activeColor: tide,
                semanticLabel: 'Haptics',
                onChanged: (on) => bloc.add(SettingsHapticsToggled(on: on)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
