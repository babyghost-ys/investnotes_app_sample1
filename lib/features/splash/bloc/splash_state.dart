part of 'splash_bloc.dart';

final class SplashState extends Equatable {
  const SplashState({this.done = false});

  /// The opening screen has had its time; the app takes over.
  final bool done;

  @override
  List<Object?> get props => [done];
}
