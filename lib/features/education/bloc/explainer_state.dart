part of 'explainer_bloc.dart';

enum PlaybackPhase { playing, paused, ended }

final class ExplainerState extends Equatable {
  const ExplainerState({this.phase = PlaybackPhase.playing});

  final PlaybackPhase phase;

  bool get playing => phase == PlaybackPhase.playing;

  @override
  List<Object?> get props => [phase];
}
