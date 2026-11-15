part of 'my_notes_bloc.dart';

final class MyNotesState extends Equatable implements Loadable {
  const MyNotesState({
    this.holdings = const [],
    this.phase = LoadingPhase.loading,
  });

  final List<Holding> holdings;
  @override
  final LoadingPhase phase;

  double get invested => holdings.fold(0, (sum, h) => sum + h.principal);

  double get value => holdings.fold(0, (sum, h) => sum + h.value);

  /// Return on everything held, since issue.
  double get change => invested == 0 ? 0 : value / invested - 1;

  @override
  List<Object?> get props => [holdings, phase];
}
