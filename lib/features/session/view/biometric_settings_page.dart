import 'package:flutter_native_widgets/flutter_native_widgets.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keel_localisation/keel_localisation.dart';

import 'package:investnotes_app_sample1/core/l10n/generated/locales.dart';
import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/core/widgets/biometric_glyph.dart';
import 'package:investnotes_app_sample1/features/session/bloc/biometric_bloc.dart';
import 'package:investnotes_app_sample1/features/session/bloc/session_bloc.dart';

/// Signing the account in with Face ID or Touch ID: the glyph large, lit
/// while it is on, the account it signs in, and the switch. Turning it on
/// asks for the face or finger first.
class BiometricSettingsPage extends StatelessWidget
    implements LocalisationConsumer {
  const BiometricSettingsPage({super.key});

  @override
  List<String> get namespaces => const [Locales.session];

  @override
  Widget build(BuildContext context) => LocalisedBuilder(
    consumer: this,
    builder: (context, locale) => _build(context, locale[0] as SessionLocale),
  );

  Widget _build(BuildContext context, SessionLocale session) {
    final state = context.watch<BiometricBloc>().state;
    final name = context.watch<SessionBloc>().state.name;
    final kind = state.kind;
    if (kind == null || name == null) return const SizedBox.shrink();
    final on = state.name == name;
    final azure = KeelColors.azure.of(context);
    final muted = KeelColors.muted.of(context);

    return ColoredBox(
      color: KeelColors.page.of(context),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  width: 148,
                  height: 148,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: on ? azure : KeelColors.mist.of(context),
                  ),
                  alignment: Alignment.center,
                  child: BiometricGlyph(
                    kind: kind,
                    color: on ? CupertinoColors.white : muted,
                    size: 72,
                  ),
                ),
                const SizedBox(height: 28),
                // The account it signs in.
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CupertinoIcons.person_crop_circle_fill,
                      color: muted,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: KeelColors.ink.of(context),
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                NativeSwitch(
                  value: on,
                  activeColor: azure,
                  semanticLabel: session.semantics.biometric(kind: kind.title),
                  onChanged: state.checking
                      ? null
                      : (value) => context.read<BiometricBloc>().add(
                          BiometricToggled(
                            on: value,
                            name: name,
                            reason: session.semantics.biometricReason(
                              kind: kind.title,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
