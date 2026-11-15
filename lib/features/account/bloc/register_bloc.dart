import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:investnotes_app_sample1/domain/models/credentials.dart';

part 'register_event.dart';
part 'register_state.dart';

/// Opening a Keel account: who you are, your sign-in details, then the code
/// emailed to you. This sample has no server, so any six digits verify.
class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc() : super(const RegisterState()) {
    on<RegisterRoleAnswered>(
      (e, emit) => emit(state.copyWith(adviser: e.adviser, advised: e.advised)),
    );
    on<RegisterUsernameChanged>(
      (e, emit) => emit(state.copyWith(username: e.value)),
    );
    on<RegisterEmailChanged>((e, emit) => emit(state.copyWith(email: e.value)));
    on<RegisterPasswordChanged>(
      (e, emit) => emit(state.copyWith(password: e.value)),
    );
    on<RegisterConfirmChanged>(
      (e, emit) => emit(state.copyWith(confirm: e.value)),
    );
    on<RegisterRevealToggled>(
      (e, emit) => emit(state.copyWith(reveal: !state.reveal)),
    );
    on<RegisterCodeChanged>((e, emit) => emit(state.copyWith(code: e.value)));
    on<RegisterCodeResent>((e, emit) async {
      emit(state.copyWith(code: '', resent: true));
      await Future<void>.delayed(const Duration(seconds: 2));
      emit(state.copyWith(resent: false));
    });
    on<RegisterAdvanced>((e, emit) {
      if (!state.canAdvance) return;
      emit(state.copyWith(step: RegisterStep.values[state.step.index + 1]));
    });
    on<RegisterStepBack>((e, emit) {
      if (state.step == RegisterStep.start || state.step == RegisterStep.done) {
        return;
      }
      emit(
        state.copyWith(
          step: RegisterStep.values[state.step.index - 1],
          code: '',
        ),
      );
    });
  }
}
