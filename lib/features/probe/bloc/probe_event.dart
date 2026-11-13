part of 'probe_bloc.dart';

sealed class ProbeEvent extends Equatable {
  const ProbeEvent();

  @override
  List<Object?> get props => [];
}

/// The market move being tried on a payoff chart changed.
final class ProbeMoved extends ProbeEvent {
  const ProbeMoved(this.move);

  final double move;

  @override
  List<Object?> get props => [move];
}
