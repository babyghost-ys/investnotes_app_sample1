part of 'probe_bloc.dart';

final class ProbeState extends Equatable {
  const ProbeState({this.move = 0.2});

  final double move;

  @override
  List<Object?> get props => [move];
}
