part of 'explainer_bloc.dart';

sealed class ExplainerEvent extends Equatable {
  const ExplainerEvent();

  @override
  List<Object?> get props => [];
}

final class ExplainerPlayed extends ExplainerEvent {
  const ExplainerPlayed();
}

final class ExplainerPaused extends ExplainerEvent {
  const ExplainerPaused();
}

final class ExplainerFinished extends ExplainerEvent {
  const ExplainerFinished();
}
