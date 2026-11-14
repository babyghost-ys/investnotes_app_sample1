import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/core/widgets/keel_field.dart';
import 'package:investnotes_app_sample1/core/widgets/round_icon_button.dart';
import 'package:investnotes_app_sample1/data/models/credentials.dart';
import 'package:investnotes_app_sample1/features/account/bloc/reset_bloc.dart';
import 'package:investnotes_app_sample1/features/account/widgets/advance_button.dart';
import 'package:investnotes_app_sample1/features/account/widgets/code_field.dart';
import 'package:investnotes_app_sample1/features/account/widgets/code_sent_header.dart';
import 'package:investnotes_app_sample1/features/account/widgets/flow_body.dart';
import 'package:investnotes_app_sample1/features/account/widgets/flow_done.dart';
import 'package:investnotes_app_sample1/features/account/widgets/flow_page.dart';
import 'package:investnotes_app_sample1/features/account/widgets/password_checks.dart';
import 'package:investnotes_app_sample1/features/account/widgets/step_switcher.dart';
import 'package:investnotes_app_sample1/features/account/widgets/valid_mark.dart';

/// A new password for a forgotten one. Pops with the username, so sign-in
/// can fill it in.
class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({super.key, this.username = ''});

  /// What was already typed on sign-in.
  final String username;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => ResetBloc(username: username),
    child: BlocBuilder<ResetBloc, ResetState>(
      builder: (context, state) {
        final bloc = context.read<ResetBloc>();
        return FlowPage(
          child: StepSwitcher(
            step: state.step,
            child: switch (state.step) {
              ResetStep.request => _request(state, bloc),
              ResetStep.reset => _reset(context, state, bloc),
              ResetStep.done => FlowDone(
                title: 'Password changed',
                detail: state.username.trim(),
                actionLabel: 'Back to sign in',
                onAction: () => context.pop(state.username.trim()),
              ),
            },
          ),
        );
      },
    ),
  );

  Widget _request(ResetState state, ResetBloc bloc) {
    void advance() => bloc.add(const ResetAdvanced());
    return FlowBody(
      children: [
        KeelField(
          icon: CupertinoIcons.person,
          placeholder: 'Username',
          initialValue: state.username,
          autofocus: state.username.isEmpty,
          onChanged: (v) => bloc.add(ResetUsernameChanged(v)),
          trailing: ValidMark(valid: Credentials.username(state.username)),
        ),
        const SizedBox(height: 12),
        KeelField(
          icon: CupertinoIcons.envelope,
          placeholder: 'Email',
          initialValue: state.email,
          autofocus: state.username.isNotEmpty,
          keyboard: TextInputType.emailAddress,
          action: TextInputAction.go,
          onChanged: (v) => bloc.add(ResetEmailChanged(v)),
          onSubmitted: (_) => advance(),
          trailing: ValidMark(valid: Credentials.email(state.email)),
        ),
        const SizedBox(height: 28),
        AdvanceButton(
          label: 'Send code',
          onPressed: state.canAdvance ? advance : null,
        ),
      ],
    );
  }

  Widget _reset(BuildContext context, ResetState state, ResetBloc bloc) {
    void advance() => bloc.add(const ResetAdvanced());
    return FlowBody(
      children: [
        CodeSentHeader(
          email: state.email,
          resent: state.resent,
          onResend: () => bloc.add(const ResetCodeResent()),
        ),
        const SizedBox(height: 24),
        CodeField(
          value: state.code,
          onChanged: (v) => bloc.add(ResetCodeChanged(v)),
          onCompleted: () => FocusScope.of(context).nextFocus(),
        ),
        const SizedBox(height: 28),
        KeelField(
          icon: CupertinoIcons.lock,
          placeholder: 'New password',
          initialValue: state.password,
          obscure: !state.reveal,
          onChanged: (v) => bloc.add(ResetPasswordChanged(v)),
          trailing: RoundIconButton(
            icon: state.reveal ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
            label: state.reveal ? 'Hide passwords' : 'Show passwords',
            foreground: KeelColors.muted.of(context),
            size: 40,
            iconSize: 18,
            onPressed: () => bloc.add(const ResetRevealToggled()),
          ),
        ),
        const SizedBox(height: 12),
        KeelField(
          icon: CupertinoIcons.lock_rotation,
          placeholder: 'Confirm password',
          initialValue: state.confirm,
          obscure: !state.reveal,
          action: TextInputAction.go,
          onChanged: (v) => bloc.add(ResetConfirmChanged(v)),
          onSubmitted: (_) => advance(),
          trailing: ValidMark(valid: state.matches),
        ),
        const SizedBox(height: 18),
        PasswordChecks(password: state.password, confirm: state.confirm),
        const SizedBox(height: 28),
        AdvanceButton(
          label: 'Change password',
          icon: CupertinoIcons.checkmark_alt,
          onPressed: state.canAdvance ? advance : null,
        ),
      ],
    );
  }
}
