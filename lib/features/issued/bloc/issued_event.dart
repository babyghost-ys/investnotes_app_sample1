part of 'issued_bloc.dart';

sealed class IssuedEvent extends Equatable {
  const IssuedEvent();

  @override
  List<Object?> get props => [];
}

final class IssuedFilterChanged extends IssuedEvent {
  const IssuedFilterChanged(this.filter);

  final IssuedFilter filter;

  @override
  List<Object?> get props => [filter];
}

/// A row was opened or closed to show its performance.
final class IssuedRowToggled extends IssuedEvent {
  const IssuedRowToggled(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}
