import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_native_widgets/flutter_native_widgets.dart'
    show NativeSheetBarAction;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keel_localisation/keel_localisation.dart';

import 'package:investnotes_app_sample1/core/l10n/generated/locales.dart';
import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/core/widgets/keel_field.dart';
import 'package:investnotes_app_sample1/core/widgets/round_icon_button.dart';
import 'package:investnotes_app_sample1/data/models/credentials.dart';
import 'package:investnotes_app_sample1/features/account/bloc/register_bloc.dart';
import 'package:investnotes_app_sample1/features/account/widgets/advance_button.dart';
import 'package:investnotes_app_sample1/features/account/widgets/code_field.dart';
import 'package:investnotes_app_sample1/features/account/widgets/code_sent_header.dart';
import 'package:investnotes_app_sample1/features/account/widgets/flow_bar_action_binder.dart';
import 'package:investnotes_app_sample1/features/account/widgets/flow_body.dart';
import 'package:investnotes_app_sample1/features/account/widgets/flow_done.dart';
import 'package:investnotes_app_sample1/features/account/widgets/flow_page.dart';
import 'package:investnotes_app_sample1/features/account/widgets/password_checks.dart';
import 'package:investnotes_app_sample1/features/account/widgets/question_row.dart';
import 'package:investnotes_app_sample1/features/account/widgets/step_switcher.dart';
import 'package:investnotes_app_sample1/features/account/widgets/step_tabs.dart';
import 'package:investnotes_app_sample1/features/account/widgets/valid_mark.dart';
import 'package:investnotes_app_sample1/features/session/view/sign_in_scope.dart';

/// Opening an account in three steps. Once the emailed code checks out the
/// new account is signed in and the sign-in flow ends.
class RegisterPage extends StatelessWidget implements LocalisationConsumer {
  const RegisterPage({super.key});

  @override
  List<String> get namespaces => const [Locales.account];

  @override
  Widget build(BuildContext context) => LocalisedBuilder(
    consumer: this,
    builder: (context, locale) => _build(context, locale[0] as AccountLocale),
  );

  Widget _build(BuildContext context, AccountLocale account) => BlocProvider(
    create: (_) => RegisterBloc(),
    child: BlocBuilder<RegisterBloc, RegisterState>(
      builder: (context, state) {
        final bloc = context.read<RegisterBloc>();
        // Past the first step, and until the code checks out, the bar
        // carries a way back to the step before.
        final hasPrevious =
            state.step != RegisterStep.start && state.step != RegisterStep.done;
        return FlowBarActionBinder(
          action: hasPrevious
              ? NativeSheetBarAction(
                  sfSymbol: 'backward',
                  label: account.semantics.previousStep,
                  onPressed: () => bloc.add(const RegisterStepBack()),
                )
              : null,
          child: FlowPage(
            header: state.step == RegisterStep.done
                ? null
                : StepTabs(
                    titles: [
                      account.labels.stepStart,
                      account.labels.stepAccount,
                      account.labels.stepVerify,
                    ],
                    current: state.step.index,
                    onBack: () => bloc.add(const RegisterStepBack()),
                  ),
            child: StepSwitcher(
              step: state.step,
              child: switch (state.step) {
                RegisterStep.start => _start(context, state, bloc, account),
                RegisterStep.account => _account(context, state, bloc, account),
                RegisterStep.verify => _verify(state, bloc, account),
                RegisterStep.done => FlowDone(
                  title: account.labels.accountReady,
                  detail: state.username.trim(),
                  actionLabel: account.semantics.continueSignedIn,
                  onAction: () =>
                      SignInScope.of(context).onSignedIn(state.username.trim()),
                ),
              },
            ),
          ),
        );
      },
    ),
  );

  Widget _start(
    BuildContext context,
    RegisterState state,
    RegisterBloc bloc,
    AccountLocale account,
  ) {
    final hairline = Container(
      height: 1,
      color: KeelColors.hairline.of(context),
    );
    return FlowBody(
      children: [
        QuestionRow(
          question: account.labels.adviserQuestion,
          value: state.adviser,
          onChanged: (v) => bloc.add(RegisterRoleAnswered(adviser: v)),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: state.adviser
              ? const SizedBox(width: double.infinity)
              : Column(
                  children: [
                    hairline,
                    QuestionRow(
                      question: account.labels.advisedQuestion,
                      value: state.advised,
                      onChanged: (v) =>
                          bloc.add(RegisterRoleAnswered(advised: v)),
                    ),
                  ],
                ),
        ),
        const SizedBox(height: 28),
        AdvanceButton(
          label: account.semantics.next,
          onPressed: () => bloc.add(const RegisterAdvanced()),
        ),
      ],
    );
  }

  Widget _account(
    BuildContext context,
    RegisterState state,
    RegisterBloc bloc,
    AccountLocale account,
  ) {
    void advance() => bloc.add(const RegisterAdvanced());
    return FlowBody(
      children: [
        KeelField(
          icon: CupertinoIcons.person,
          placeholder: account.labels.username,
          initialValue: state.username,
          autofocus: state.username.isEmpty,
          onChanged: (v) => bloc.add(RegisterUsernameChanged(v)),
          trailing: ValidMark(valid: Credentials.username(state.username)),
        ),
        const SizedBox(height: 12),
        KeelField(
          icon: CupertinoIcons.envelope,
          placeholder: account.labels.email,
          initialValue: state.email,
          keyboard: TextInputType.emailAddress,
          onChanged: (v) => bloc.add(RegisterEmailChanged(v)),
          trailing: ValidMark(valid: Credentials.email(state.email)),
        ),
        const SizedBox(height: 12),
        KeelField(
          icon: CupertinoIcons.lock,
          placeholder: account.labels.password,
          initialValue: state.password,
          obscure: !state.reveal,
          onChanged: (v) => bloc.add(RegisterPasswordChanged(v)),
          trailing: RoundIconButton(
            icon: state.reveal ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
            label: state.reveal
                ? account.semantics.hidePasswords
                : account.semantics.showPasswords,
            foreground: KeelColors.muted.of(context),
            size: 40,
            iconSize: 18,
            onPressed: () => bloc.add(const RegisterRevealToggled()),
          ),
        ),
        const SizedBox(height: 12),
        KeelField(
          icon: CupertinoIcons.lock_rotation,
          placeholder: account.labels.confirmPassword,
          initialValue: state.confirm,
          obscure: !state.reveal,
          action: TextInputAction.go,
          onChanged: (v) => bloc.add(RegisterConfirmChanged(v)),
          onSubmitted: (_) => advance(),
          trailing: ValidMark(valid: state.matches),
        ),
        const SizedBox(height: 18),
        PasswordChecks(password: state.password, confirm: state.confirm),
        const SizedBox(height: 28),
        AdvanceButton(
          label: account.semantics.sendCode,
          onPressed: state.accountReady ? advance : null,
        ),
      ],
    );
  }

  Widget _verify(
    RegisterState state,
    RegisterBloc bloc,
    AccountLocale account,
  ) => FlowBody(
    children: [
      CodeSentHeader(
        email: state.email,
        resent: state.resent,
        onResend: () => bloc.add(const RegisterCodeResent()),
      ),
      const SizedBox(height: 28),
      CodeField(
        value: state.code,
        onChanged: (v) => bloc.add(RegisterCodeChanged(v)),
      ),
      const SizedBox(height: 32),
      AdvanceButton(
        label: account.semantics.verify,
        icon: CupertinoIcons.checkmark_alt,
        onPressed: state.canAdvance
            ? () => bloc.add(const RegisterAdvanced())
            : null,
      ),
    ],
  );
}
