part of 'finder_bloc.dart';

sealed class FinderEvent extends Equatable {
  const FinderEvent();

  @override
  List<Object?> get props => [];
}

final class FinderOptionToggled extends FinderEvent {
  const FinderOptionToggled(this.question, this.option);

  final int question;
  final int option;

  @override
  List<Object?> get props => [question, option];
}

final class FinderRestarted extends FinderEvent {
  const FinderRestarted();
}
