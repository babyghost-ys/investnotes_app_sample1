part of 'my_notes_bloc.dart';

final class MyNotesState extends Equatable {
  const MyNotesState({this.holdings = const []});

  final List<Holding> holdings;

  double get invested => holdings.fold(0, (sum, h) => sum + h.principal);

  double get value => holdings.fold(0, (sum, h) => sum + h.value);

  /// Return on everything held, since issue.
  double get change => invested == 0 ? 0 : value / invested - 1;

  @override
  List<Object?> get props => [holdings];
}
