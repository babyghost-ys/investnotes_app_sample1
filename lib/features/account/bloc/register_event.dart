part of 'register_bloc.dart';

sealed class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object?> get props => [];
}

/// One of the opening questions was answered.
final class RegisterRoleAnswered extends RegisterEvent {
  const RegisterRoleAnswered({this.adviser, this.advised});

  final bool? adviser;
  final bool? advised;

  @override
  List<Object?> get props => [adviser, advised];
}

final class RegisterUsernameChanged extends RegisterEvent {
  const RegisterUsernameChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

final class RegisterEmailChanged extends RegisterEvent {
  const RegisterEmailChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

final class RegisterPasswordChanged extends RegisterEvent {
  const RegisterPasswordChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

final class RegisterConfirmChanged extends RegisterEvent {
  const RegisterConfirmChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

final class RegisterRevealToggled extends RegisterEvent {
  const RegisterRevealToggled();
}

final class RegisterCodeChanged extends RegisterEvent {
  const RegisterCodeChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

/// Asked for a fresh code to be emailed.
final class RegisterCodeResent extends RegisterEvent {
  const RegisterCodeResent();
}

/// Moved on from the current step once it is complete.
final class RegisterAdvanced extends RegisterEvent {
  const RegisterAdvanced();
}

/// Went back one step.
final class RegisterStepBack extends RegisterEvent {
  const RegisterStepBack();
}
