part of 'issued_bloc.dart';

sealed class IssuedEvent extends Equatable {
  const IssuedEvent();

  @override
  List<Object?> get props => [];
}

/// Fetches the issued notes: on first showing the tab, and on trying again.
final class IssuedRequested extends IssuedEvent {
  const IssuedRequested();
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

/// A note opened from the list, or null once it is closed.
final class IssuedNoteSelected extends IssuedEvent {
  const IssuedNoteSelected(this.id);

  final String? id;

  @override
  List<Object?> get props => [id];
}
