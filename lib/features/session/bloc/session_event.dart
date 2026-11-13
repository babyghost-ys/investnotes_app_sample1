part of 'session_bloc.dart';

sealed class SessionEvent extends Equatable {
  const SessionEvent();

  @override
  List<Object?> get props => [];
}

final class SessionSignedIn extends SessionEvent {
  const SessionSignedIn(this.name);

  final String name;

  @override
  List<Object?> get props => [name];
}

final class SessionSignedOut extends SessionEvent {
  const SessionSignedOut();
}
