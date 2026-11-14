part of 'search_bloc.dart';

sealed class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

final class SearchQueryChanged extends SearchEvent {
  const SearchQueryChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

/// Opens a result's terms in place, closing any other; closes it when it
/// is already open.
final class SearchRowToggled extends SearchEvent {
  const SearchRowToggled(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}
