import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:investnotes_app_sample1/data/models/credentials.dart';

part 'reset_event.dart';
part 'reset_state.dart';

/// Resetting a forgotten password: name the account, then enter the emailed
/// code with a new password. This sample has no server, so any six digits
/// verify.
class ResetBloc extends Bloc<ResetEvent, ResetState> {
  ResetBloc({String username = ''}) : super(ResetState(username: username)) {
    on<ResetUsernameChanged>(
      (e, emit) => emit(state.copyWith(username: e.value)),
    );
    on<ResetEmailChanged>((e, emit) => emit(state.copyWith(email: e.value)));
    on<ResetCodeChanged>((e, emit) => emit(state.copyWith(code: e.value)));
    on<ResetPasswordChanged>(
      (e, emit) => emit(state.copyWith(password: e.value)),
    );
    on<ResetConfirmChanged>(
      (e, emit) => emit(state.copyWith(confirm: e.value)),
    );
    on<ResetRevealToggled>(
      (e, emit) => emit(state.copyWith(reveal: !state.reveal)),
    );
    on<ResetCodeResent>((e, emit) async {
      emit(state.copyWith(code: '', resent: true));
      await Future<void>.delayed(const Duration(seconds: 2));
      emit(state.copyWith(resent: false));
    });
    on<ResetAdvanced>((e, emit) {
      if (!state.canAdvance) return;
      emit(state.copyWith(step: ResetStep.values[state.step.index + 1]));
    });
    on<ResetStepBack>((e, emit) {
      if (state.step != ResetStep.reset) return;
      emit(state.copyWith(step: ResetStep.request, code: ''));
    });
  }
}
