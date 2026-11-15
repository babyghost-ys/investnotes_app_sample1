import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:investnotes_app_sample1/data/models/biometric_kind.dart';
import 'package:investnotes_app_sample1/data/repositories/biometric_repository.dart';

part 'biometric_event.dart';
part 'biometric_state.dart';

/// Whether this device signs an account in with Face ID or Touch ID.
class BiometricBloc extends Bloc<BiometricEvent, BiometricState> {
  BiometricBloc(this._repository) : super(const BiometricState()) {
    on<BiometricStarted>(_started);
    on<BiometricToggled>(_toggled);
    on<BiometricAccountSignedIn>(_accountSignedIn);
  }

  final BiometricRepository _repository;

  Future<void> _started(
    BiometricStarted event,
    Emitter<BiometricState> emit,
  ) async {
    final kind = await _repository.kind();
    final name = kind == null ? null : await _repository.enrolledName();
    emit(BiometricState(kind: kind, name: name));
  }

  Future<void> _toggled(
    BiometricToggled event,
    Emitter<BiometricState> emit,
  ) async {
    final kind = state.kind;
    if (kind == null || state.checking) return;
    if (!event.on) {
      await _repository.clear();
      emit(BiometricState(kind: kind));
      return;
    }
    // The switch turns on only once the face or finger has been seen.
    emit(BiometricState(kind: kind, checking: true));
    // The prompt rises once the switch has settled and the touch is over.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final matched = await _repository.authenticate(event.reason);
    if (matched) await _repository.enrol(event.name);
    emit(BiometricState(kind: kind, name: matched ? event.name : null));
  }

  /// Someone else signing in with a password ends the biometric sign-in of
  /// the account that set it up.
  Future<void> _accountSignedIn(
    BiometricAccountSignedIn event,
    Emitter<BiometricState> emit,
  ) async {
    final name = state.name;
    if (name == null || name == event.name) return;
    await _repository.clear();
    emit(BiometricState(kind: state.kind));
  }
}
