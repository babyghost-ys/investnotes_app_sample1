import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:investnotes_app_sample1/core/draft/draft_bloc.dart';
import 'package:investnotes_app_sample1/core/widgets/keel_field.dart';
import 'package:investnotes_app_sample1/data/models/credentials.dart';
import 'package:investnotes_app_sample1/features/account/widgets/advance_button.dart';
import 'package:investnotes_app_sample1/features/account/widgets/flow_body.dart';
import 'package:investnotes_app_sample1/features/account/widgets/flow_done.dart';
import 'package:investnotes_app_sample1/features/account/widgets/flow_page.dart';
import 'package:investnotes_app_sample1/features/account/widgets/step_switcher.dart';
import 'package:investnotes_app_sample1/features/account/widgets/valid_mark.dart';

typedef UsernameRequest = ({String email, bool sent});

/// A forgotten username, emailed to the address on the account.
class FindUsernamePage extends StatelessWidget {
  const FindUsernamePage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => DraftBloc<UsernameRequest>((email: '', sent: false)),
    child:
        BlocBuilder<DraftBloc<UsernameRequest>, DraftState<UsernameRequest>>(
          builder: (context, state) {
            final draft = context.read<DraftBloc<UsernameRequest>>();
            final request = state.value;
            final ready = Credentials.email(request.email);
            void send() {
              if (ready) draft.change((email: request.email, sent: true));
            }

            return FlowPage(
              title: 'Find username',
              child: StepSwitcher(
                step: request.sent,
                child: request.sent
                    ? FlowDone(
                        icon: CupertinoIcons.envelope_fill,
                        title: 'Username sent',
                        detail: Credentials.masked(request.email),
                        actionLabel: 'Back to sign in',
                        onAction: () => Navigator.of(context).pop(),
                      )
                    : FlowBody(
                        children: [
                          KeelField(
                            icon: CupertinoIcons.envelope,
                            placeholder: 'Email',
                            initialValue: request.email,
                            autofocus: true,
                            keyboard: TextInputType.emailAddress,
                            action: TextInputAction.send,
                            onChanged: (v) =>
                                draft.change((email: v, sent: false)),
                            onSubmitted: (_) => send(),
                            trailing: ValidMark(valid: ready),
                          ),
                          const SizedBox(height: 28),
                          AdvanceButton(
                            label: 'Send username',
                            icon: CupertinoIcons.paperplane,
                            onPressed: ready ? send : null,
                          ),
                        ],
                      ),
              ),
            );
          },
        ),
  );
}
