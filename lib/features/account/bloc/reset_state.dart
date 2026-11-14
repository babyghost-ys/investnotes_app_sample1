part of 'reset_bloc.dart';

enum ResetStep { request, reset, done }

final class ResetState extends Equatable {
  const ResetState({
    this.step = ResetStep.request,
    this.username = '',
    this.email = '',
    this.code = '',
    this.password = '',
    this.confirm = '',
    this.reveal = false,
    this.resent = false,
  });

  final ResetStep step;
  final String username;
  final String email;
  final String code;
  final String password;
  final String confirm;
  final bool reveal;
  final bool resent;

  bool get matches => confirm.isNotEmpty && confirm == password;

  bool get canAdvance => switch (step) {
    ResetStep.request =>
      Credentials.username(username) && Credentials.email(email),
    ResetStep.reset =>
      Credentials.code(code) && Credentials.password(password) && matches,
    ResetStep.done => false,
  };

  ResetState copyWith({
    ResetStep? step,
    String? username,
    String? email,
    String? code,
    String? password,
    String? confirm,
    bool? reveal,
    bool? resent,
  }) => ResetState(
    step: step ?? this.step,
    username: username ?? this.username,
    email: email ?? this.email,
    code: code ?? this.code,
    password: password ?? this.password,
    confirm: confirm ?? this.confirm,
    reveal: reveal ?? this.reveal,
    resent: resent ?? this.resent,
  );

  @override
  List<Object?> get props => [
    step,
    username,
    email,
    code,
    password,
    confirm,
    reveal,
    resent,
  ];
}
