part of 'register_bloc.dart';

enum RegisterStep {
  start('Start'),
  account('Account'),
  verify('Verify'),
  done('Done');

  const RegisterStep(this.title);

  final String title;
}

final class RegisterState extends Equatable {
  const RegisterState({
    this.step = RegisterStep.start,
    this.adviser = false,
    this.advised = true,
    this.username = '',
    this.email = '',
    this.password = '',
    this.confirm = '',
    this.reveal = false,
    this.code = '',
    this.resent = false,
  });

  final RegisterStep step;

  /// Registering as a financial adviser.
  final bool adviser;

  /// Investing through an adviser; only asked of investors.
  final bool advised;

  final String username;
  final String email;
  final String password;
  final String confirm;
  final bool reveal;
  final String code;

  /// A fresh code went out a moment ago.
  final bool resent;

  bool get matches => confirm.isNotEmpty && confirm == password;

  bool get accountReady =>
      Credentials.username(username) &&
      Credentials.email(email) &&
      Credentials.password(password) &&
      matches;

  bool get canAdvance => switch (step) {
    RegisterStep.start => true,
    RegisterStep.account => accountReady,
    RegisterStep.verify => Credentials.code(code),
    RegisterStep.done => false,
  };

  RegisterState copyWith({
    RegisterStep? step,
    bool? adviser,
    bool? advised,
    String? username,
    String? email,
    String? password,
    String? confirm,
    bool? reveal,
    String? code,
    bool? resent,
  }) => RegisterState(
    step: step ?? this.step,
    adviser: adviser ?? this.adviser,
    advised: advised ?? this.advised,
    username: username ?? this.username,
    email: email ?? this.email,
    password: password ?? this.password,
    confirm: confirm ?? this.confirm,
    reveal: reveal ?? this.reveal,
    code: code ?? this.code,
    resent: resent ?? this.resent,
  );

  @override
  List<Object?> get props => [
    step,
    adviser,
    advised,
    username,
    email,
    password,
    confirm,
    reveal,
    code,
    resent,
  ];
}
