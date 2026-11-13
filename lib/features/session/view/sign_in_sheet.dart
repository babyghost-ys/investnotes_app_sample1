import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart' show Material, MaterialType;

import 'package:investnotes_app_sample1/core/draft/draft_bloc.dart';
import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/core/widgets/keel_mark.dart';
import 'package:investnotes_app_sample1/core/widgets/round_icon_button.dart';
import 'package:investnotes_app_sample1/core/widgets/keel_field.dart';

typedef SignInForm = ({String name, String password, bool reveal});

/// Opens sign-in over the whole screen; completes with the name signed in.
Future<String?> showSignIn(BuildContext context) =>
    AdaptiveNativeSheet.show<String>(
      context: context,
      route: 'signIn',
      fullScreen: true,
      backgroundColor: KeelColors.raised.of(context),
      builder: (_) => const SignInSheet(),
    );

/// Sign-in: the brand band on top, two fields and one go control below.
class SignInSheet extends StatelessWidget {
  const SignInSheet({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) =>
        DraftBloc<SignInForm>((name: '', password: '', reveal: false)),
    child: BlocBuilder<DraftBloc<SignInForm>, DraftState<SignInForm>>(
      builder: (context, state) {
        final draft = context.read<DraftBloc<SignInForm>>();
        final form = state.value;
        final ready = form.name.trim().isNotEmpty && form.password.isNotEmpty;
        final top = MediaQuery.paddingOf(context).top;
        void submit() {
          if (ready) AdaptiveNativeSheet.pop(context, form.name.trim());
        }

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Material(
            type: MaterialType.transparency,
            child: ColoredBox(
              color: KeelColors.raised.of(context),
              child: ListView(
                padding: EdgeInsets.zero,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(24, top + 4, 12, 40),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF1E6FE0), Color(0xFF0B3D91)],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: RoundIconButton(
                            icon: CupertinoIcons.xmark,
                            label: 'Close',
                            foreground: CupertinoColors.white,
                            background: const Color(0x26FFFFFF),
                            size: 40,
                            iconSize: 17,
                            onPressed: () => AdaptiveNativeSheet.pop(context),
                          ),
                        ),
                        const SizedBox(height: 28),
                        const KeelMark(color: CupertinoColors.white, size: 76),
                        const SizedBox(height: 18),
                        const Text(
                          'Keel',
                          style: TextStyle(
                            color: CupertinoColors.white,
                            fontSize: 40,
                            height: 1,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        KeelField(
                          icon: CupertinoIcons.person,
                          placeholder: 'Username',
                          autofocus: true,
                          autofill: AutofillHints.username,
                          onChanged: (v) => draft.change((
                            name: v,
                            password: form.password,
                            reveal: form.reveal,
                          )),
                        ),
                        const SizedBox(height: 12),
                        KeelField(
                          icon: CupertinoIcons.lock,
                          placeholder: 'Password',
                          obscure: !form.reveal,
                          action: TextInputAction.go,
                          autofill: AutofillHints.password,
                          onSubmitted: (_) => submit(),
                          onChanged: (v) => draft.change((
                            name: form.name,
                            password: v,
                            reveal: form.reveal,
                          )),
                          trailing: RoundIconButton(
                            icon: form.reveal
                                ? CupertinoIcons.eye_slash
                                : CupertinoIcons.eye,
                            label: form.reveal
                                ? 'Hide password'
                                : 'Show password',
                            foreground: KeelColors.muted.of(context),
                            size: 40,
                            iconSize: 18,
                            onPressed: () => draft.change((
                              name: form.name,
                              password: form.password,
                              reveal: !form.reveal,
                            )),
                          ),
                        ),
                        const SizedBox(height: 28),
                        RoundIconButton(
                          icon: CupertinoIcons.arrow_right,
                          label: 'Sign in',
                          foreground: CupertinoColors.white,
                          background: KeelColors.azure.of(context),
                          size: 56,
                          iconSize: 24,
                          onPressed: ready ? submit : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}
