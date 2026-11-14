part of 'reset_bloc.dart';

sealed class ResetEvent extends Equatable {
  const ResetEvent();

  @override
  List<Object?> get props => [];
}

final class ResetUsernameChanged extends ResetEvent {
  const ResetUsernameChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

final class ResetEmailChanged extends ResetEvent {
  const ResetEmailChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

final class ResetCodeChanged extends ResetEvent {
  const ResetCodeChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

final class ResetPasswordChanged extends ResetEvent {
  const ResetPasswordChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

final class ResetConfirmChanged extends ResetEvent {
  const ResetConfirmChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

final class ResetRevealToggled extends ResetEvent {
  const ResetRevealToggled();
}

final class ResetCodeResent extends ResetEvent {
  const ResetCodeResent();
}

final class ResetAdvanced extends ResetEvent {
  const ResetAdvanced();
}

final class ResetStepBack extends ResetEvent {
  const ResetStepBack();
}
