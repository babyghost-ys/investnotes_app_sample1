import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart' show Material, MaterialType;

import 'package:investnotes_app_sample1/app/keel_routes.dart';
import 'package:investnotes_app_sample1/core/draft/draft_bloc.dart';
import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/core/widgets/keel_field.dart';
import 'package:investnotes_app_sample1/core/widgets/keel_mark.dart';
import 'package:investnotes_app_sample1/core/widgets/round_icon_button.dart';
import 'package:investnotes_app_sample1/core/widgets/text_link.dart';
import 'package:investnotes_app_sample1/features/account/widgets/flow_page.dart';
import 'package:investnotes_app_sample1/features/session/bloc/session_bloc.dart';

typedef SignInForm = ({String name, String password, bool reveal});

/// Sign-in: the brand band under the bar, two fields and one go control,
/// then the ways in for a forgotten username or password and a new account.
class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
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
        final insets = MediaQuery.paddingOf(context);
        final keyboard = MediaQuery.viewInsetsOf(context).bottom;

        void submit() {
          if (!ready) return;
          context.read<SessionBloc>().add(SessionSignedIn(form.name.trim()));
          context.pop();
        }

        Future<void> resetPassword() async {
          final name = await context.push<String>(
            KeelRoutes.resetPassword(form.name.trim()),
          );
          if (name == null || !mounted) return;
          _name.text = name;
          draft.change((name: name, password: '', reveal: false));
          _passwordFocus.requestFocus();
        }

        final muted = KeelColors.muted.of(context);
        final ink = KeelColors.ink.of(context);
        final hairline = Expanded(
          child: Container(height: 1, color: KeelColors.hairline.of(context)),
        );

        return Material(
          type: MaterialType.transparency,
          child: ColoredBox(
            color: KeelColors.raised.of(context),
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              removeBottom: true,
              child: ListView(
                // Room for the keyboard, so the links below stay reachable.
                padding: EdgeInsets.only(bottom: insets.bottom + keyboard + 24),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                children: [
                  // Continues the bar's tide blue down into the brand.
                  Container(
                    padding: EdgeInsets.fromLTRB(24, insets.top + 28, 24, 36),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          KeelColors.tide.of(context),
                          const Color(0xFF1E6FE0),
                        ],
                      ),
                    ),
                    child: Align(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: FlowPage.measure - 48,
                        ),
                        child: const Row(
                          children: [
                            KeelMark(color: CupertinoColors.white, size: 56),
                            SizedBox(width: 14),
                            Text(
                              'Keel',
                              style: TextStyle(
                                color: CupertinoColors.white,
                                fontSize: 36,
                                height: 1,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Align(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: FlowPage.measure,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
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
                                foreground: muted,
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
                                  color: ink,
                                  onPressed: () => context.push<void>(
                                    KeelRoutes.findUsername,
                                  ),
                                ),
                                TextLink(
                                  label: 'Forgot password?',
                                  color: ink,
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
                                    style: TextStyle(
                                      color: muted,
                                      fontSize: 14,
                                    ),
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
                                  onPressed: () =>
                                      context.push<void>(KeelRoutes.register),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
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
