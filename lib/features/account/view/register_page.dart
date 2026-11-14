import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:investnotes_app_sample1/app/keel_routes.dart';

import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/core/widgets/keel_field.dart';
import 'package:investnotes_app_sample1/core/widgets/round_icon_button.dart';
import 'package:investnotes_app_sample1/data/models/credentials.dart';
import 'package:investnotes_app_sample1/features/account/bloc/register_bloc.dart';
import 'package:investnotes_app_sample1/features/account/widgets/advance_button.dart';
import 'package:investnotes_app_sample1/features/account/widgets/code_field.dart';
import 'package:investnotes_app_sample1/features/account/widgets/code_sent_header.dart';
import 'package:investnotes_app_sample1/features/account/widgets/flow_body.dart';
import 'package:investnotes_app_sample1/features/account/widgets/flow_done.dart';
import 'package:investnotes_app_sample1/features/account/widgets/flow_page.dart';
import 'package:investnotes_app_sample1/features/account/widgets/password_checks.dart';
import 'package:investnotes_app_sample1/features/account/widgets/question_row.dart';
import 'package:investnotes_app_sample1/features/account/widgets/step_switcher.dart';
import 'package:investnotes_app_sample1/features/account/widgets/step_tabs.dart';
import 'package:investnotes_app_sample1/features/account/widgets/valid_mark.dart';
import 'package:investnotes_app_sample1/features/session/bloc/session_bloc.dart';

/// Opening an account in three steps. Once the emailed code checks out the
/// new account is signed in and the app returns home.
class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => RegisterBloc(),
    child: BlocBuilder<RegisterBloc, RegisterState>(
      builder: (context, state) {
        final bloc = context.read<RegisterBloc>();
        return FlowPage(
          header: state.step == RegisterStep.done
              ? null
              : StepTabs(
                  titles: [
                    RegisterStep.start.title,
                    RegisterStep.account.title,
                    RegisterStep.verify.title,
                  ],
                  current: state.step.index,
                  onBack: () => bloc.add(const RegisterStepBack()),
                ),
          child: StepSwitcher(
            step: state.step,
            child: switch (state.step) {
              RegisterStep.start => _start(context, state, bloc),
              RegisterStep.account => _account(context, state, bloc),
              RegisterStep.verify => _verify(state, bloc),
              RegisterStep.done => FlowDone(
                title: 'Account ready',
                detail: state.username.trim(),
                actionLabel: 'Continue signed in',
                onAction: () {
                  context.read<SessionBloc>().add(
                    SessionSignedIn(state.username.trim()),
                  );
                  context.go(KeelRoutes.home);
                },
              ),
            },
          ),
        );
      },
    ),
  );

  Widget _start(BuildContext context, RegisterState state, RegisterBloc bloc) {
    final hairline = Container(
      height: 1,
      color: KeelColors.hairline.of(context),
    );
    return FlowBody(
      children: [
        QuestionRow(
          question: 'Are you a financial adviser?',
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
                      question: 'Do you invest through an adviser?',
                      value: state.advised,
                      onChanged: (v) =>
                          bloc.add(RegisterRoleAnswered(advised: v)),
                    ),
                  ],
                ),
        ),
        const SizedBox(height: 28),
        AdvanceButton(
          label: 'Next',
          onPressed: () => bloc.add(const RegisterAdvanced()),
        ),
      ],
    );
  }

  Widget _account(
    BuildContext context,
    RegisterState state,
    RegisterBloc bloc,
  ) {
    void advance() => bloc.add(const RegisterAdvanced());
    return FlowBody(
      children: [
        KeelField(
          icon: CupertinoIcons.person,
          placeholder: 'Username',
          initialValue: state.username,
          autofocus: state.username.isEmpty,
          onChanged: (v) => bloc.add(RegisterUsernameChanged(v)),
          trailing: ValidMark(valid: Credentials.username(state.username)),
        ),
        const SizedBox(height: 12),
        KeelField(
          icon: CupertinoIcons.envelope,
          placeholder: 'Email',
          initialValue: state.email,
          keyboard: TextInputType.emailAddress,
          onChanged: (v) => bloc.add(RegisterEmailChanged(v)),
          trailing: ValidMark(valid: Credentials.email(state.email)),
        ),
        const SizedBox(height: 12),
        KeelField(
          icon: CupertinoIcons.lock,
          placeholder: 'Password',
          initialValue: state.password,
          obscure: !state.reveal,
          onChanged: (v) => bloc.add(RegisterPasswordChanged(v)),
          trailing: RoundIconButton(
            icon: state.reveal ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
            label: state.reveal ? 'Hide passwords' : 'Show passwords',
            foreground: KeelColors.muted.of(context),
            size: 40,
            iconSize: 18,
            onPressed: () => bloc.add(const RegisterRevealToggled()),
          ),
        ),
        const SizedBox(height: 12),
        KeelField(
          icon: CupertinoIcons.lock_rotation,
          placeholder: 'Confirm password',
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
          label: 'Send code',
          onPressed: state.accountReady ? advance : null,
        ),
      ],
    );
  }

  Widget _verify(RegisterState state, RegisterBloc bloc) => FlowBody(
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
        label: 'Verify',
        icon: CupertinoIcons.checkmark_alt,
        onPressed: state.canAdvance
            ? () => bloc.add(const RegisterAdvanced())
            : null,
      ),
    ],
  );
}
