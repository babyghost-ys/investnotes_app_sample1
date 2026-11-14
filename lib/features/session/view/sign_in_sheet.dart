import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart' show Material, MaterialType;

import 'package:investnotes_app_sample1/app/push_flow.dart';
import 'package:investnotes_app_sample1/core/draft/draft_bloc.dart';
import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/core/widgets/keel_mark.dart';
import 'package:investnotes_app_sample1/core/widgets/round_icon_button.dart';
import 'package:investnotes_app_sample1/core/widgets/keel_field.dart';
import 'package:investnotes_app_sample1/core/widgets/text_link.dart';
import 'package:investnotes_app_sample1/features/account/view/find_username_page.dart';
import 'package:investnotes_app_sample1/features/account/view/register_page.dart';
import 'package:investnotes_app_sample1/features/account/view/reset_password_page.dart';

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

/// Sign-in: the brand band on top, two fields and one go control below,
/// then the ways in for a forgotten username or password and a new account.
class SignInSheet extends StatefulWidget {
  const SignInSheet({super.key});

  @override
  State<SignInSheet> createState() => _SignInSheetState();
}

class _SignInSheetState extends State<SignInSheet> {
  final _name = TextEditingController();
  final _passwordFocus = FocusNode();

  @override
  void dispose() {
    _name.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

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

        Future<void> register() async {
          final name = await pushFlow<String>(
            context,
            (_) => const RegisterPage(),
          );
          if (name != null && context.mounted) {
            await AdaptiveNativeSheet.pop(context, name);
          }
        }

        Future<void> resetPassword() async {
          final name = await pushFlow<String>(
            context,
            (_) => ResetPasswordPage(username: form.name.trim()),
          );
          if (name == null || !mounted) return;
          _name.text = name;
          draft.change((name: name, password: '', reveal: false));
          _passwordFocus.requestFocus();
        }

        final muted = KeelColors.muted.of(context);
        final hairline = Expanded(
          child: Container(height: 1, color: KeelColors.hairline.of(context)),
        );

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Material(
            type: MaterialType.transparency,
            child: ColoredBox(
              color: KeelColors.raised.of(context),
              child: ListView(
                // Room for the keyboard, so the links below stay reachable.
                padding: EdgeInsets.only(
                  bottom: MediaQuery.viewInsetsOf(context).bottom,
                ),
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
                          controller: _name,
                          icon: CupertinoIcons.person,
                          placeholder: 'Username',
                          autofill: AutofillHints.username,
                          onChanged: (v) => draft.change((
                            name: v,
                            password: form.password,
                            reveal: form.reveal,
                          )),
                        ),
                        const SizedBox(height: 12),
                        KeelField(
                          focusNode: _passwordFocus,
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
                        const SizedBox(height: 12),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 12,
                          children: [
                            TextLink(
                              label: 'Forgot username?',
                              color: KeelColors.ink.of(context),
                              onPressed: () => pushFlow<void>(
                                context,
                                (_) => const FindUsernamePage(),
                              ),
                            ),
                            TextLink(
                              label: 'Forgot password?',
                              color: KeelColors.ink.of(context),
                              onPressed: resetPassword,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            hairline,
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              child: Text(
                                'or',
                                style: TextStyle(color: muted, fontSize: 14),
                              ),
                            ),
                            hairline,
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'New to Keel?',
                              style: TextStyle(color: muted, fontSize: 15),
                            ),
                            TextLink(
                              label: 'Register',
                              color: KeelColors.azure.of(context),
                              weight: FontWeight.w600,
                              onPressed: register,
                            ),
                          ],
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
