import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keel_localisation/keel_localisation.dart';
import 'package:material_ui/material_ui.dart' show Material, MaterialType;

import 'package:investnotes_app_sample1/core/l10n/generated/locales.dart';
import 'package:investnotes_app_sample1/core/draft/draft_bloc.dart';
import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/core/widgets/bar_strip.dart';
import 'package:investnotes_app_sample1/core/widgets/keel_field.dart';
import 'package:investnotes_app_sample1/core/widgets/keel_mark.dart';
import 'package:investnotes_app_sample1/core/widgets/round_icon_button.dart';
import 'package:investnotes_app_sample1/core/widgets/text_link.dart';
import 'package:investnotes_app_sample1/features/account/widgets/flow_page.dart';
import 'package:investnotes_app_sample1/features/session/view/sign_in_scope.dart';

typedef SignInForm = ({String name, String password, bool reveal});

/// Sign-in: the brand band under the bar, two fields and one go control,
/// then the ways in for a forgotten username or password and a new account.
class SignInPage extends StatefulWidget implements LocalisationConsumer {
  @override
  List<String> get namespaces => const [Locales.session];

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
  Widget build(BuildContext context) => LocalisedBuilder(
    consumer: widget,
    builder: (context, locale) => _build(context, locale[0] as SessionLocale),
  );

  Widget _build(BuildContext context, SessionLocale session) => BlocProvider(
    create: (_) =>
        DraftBloc<SignInForm>((name: '', password: '', reveal: false)),
    child: BlocBuilder<DraftBloc<SignInForm>, DraftState<SignInForm>>(
      builder: (context, state) {
        final draft = context.read<DraftBloc<SignInForm>>();
        final form = state.value;
        final ready = form.name.trim().isNotEmpty && form.password.isNotEmpty;
        final insets = MediaQuery.paddingOf(context);
        final keyboard = MediaQuery.viewInsetsOf(context).bottom;

        final scope = SignInScope.of(context);

        void submit() {
          if (ready) scope.onSignedIn(form.name.trim());
        }

        Future<void> resetPassword() async {
          final name = await scope.push<String>(
            context,
            scope.resetPassword(form.name.trim()),
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

        return BarStrip(
          child: Material(
            type: MaterialType.transparency,
            child: ColoredBox(
              color: KeelColors.raised.of(context),
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                removeBottom: true,
                child: ListView(
                  // Room for the keyboard, so the links below stay reachable.
                  padding: EdgeInsets.only(
                    bottom: insets.bottom + keyboard + 24,
                  ),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  children: [
                    // The bar's tide blue, carried on down to hold the brand.
                    Container(
                      // The band runs edge to edge; its content keeps clear of
                      // a side strip such as the iPhone Duo's status cluster.
                      padding: EdgeInsets.fromLTRB(
                        24 + insets.left,
                        insets.top + 28,
                        24 + insets.right,
                        36,
                      ),
                      color: KeelColors.tide.of(context),
                      child: Align(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: FlowPage.measure - 48,
                          ),
                          child: Row(
                            children: [
                              const KeelMark(
                                color: CupertinoColors.white,
                                size: 56,
                                excludeFromSemantics: true,
                              ),
                              const SizedBox(width: 14),
                              Text(
                                session.labels.brand,
                                style: const TextStyle(
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
                          padding: EdgeInsets.fromLTRB(
                            24 + insets.left,
                            32,
                            24 + insets.right,
                            0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              KeelField(
                                controller: _name,
                                icon: CupertinoIcons.person,
                                placeholder: session.labels.username,
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
                                placeholder: session.labels.password,
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
                                      ? session.semantics.hidePassword
                                      : session.semantics.showPassword,
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
                                label: session.semantics.signIn,
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
                                    label: session.labels.forgotUsername,
                                    color: ink,
                                    onPressed: () => scope.push<void>(
                                      context,
                                      scope.findUsername,
                                    ),
                                  ),
                                  TextLink(
                                    label: session.labels.forgotPassword,
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
                                      session.labels.or,
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
                                    session.labels.newToKeel,
                                    style: TextStyle(
                                      color: muted,
                                      fontSize: 15,
                                    ),
                                  ),
                                  TextLink(
                                    label: session.labels.register,
                                    color: KeelColors.azure.of(context),
                                    weight: FontWeight.w600,
                                    onPressed: () => scope.push<void>(
                                      context,
                                      scope.register,
                                    ),
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
          ),
        );
      },
    ),
  );
}
