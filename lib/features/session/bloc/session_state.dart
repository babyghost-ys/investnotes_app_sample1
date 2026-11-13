part of 'session_bloc.dart';

final class SessionState extends Equatable {
  const SessionState({this.name});

  /// Who is signed in on this device; null when no one is.
  final String? name;

  bool get signedIn => name != null;

  @override
  List<Object?> get props => [name];
}
