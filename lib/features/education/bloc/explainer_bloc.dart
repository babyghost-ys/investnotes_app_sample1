import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'explainer_event.dart';
part 'explainer_state.dart';

/// Whether an explainer film is playing, paused, or has reached its end.
/// The frame-by-frame position stays with the player's animation.
class ExplainerBloc extends Bloc<ExplainerEvent, ExplainerState> {
  ExplainerBloc() : super(const ExplainerState()) {
    on<ExplainerPlayed>(
      (event, emit) => emit(const ExplainerState(phase: PlaybackPhase.playing)),
    );
    on<ExplainerPaused>(
      (event, emit) => emit(const ExplainerState(phase: PlaybackPhase.paused)),
    );
    on<ExplainerFinished>(
      (event, emit) => emit(const ExplainerState(phase: PlaybackPhase.ended)),
    );
  }
}
