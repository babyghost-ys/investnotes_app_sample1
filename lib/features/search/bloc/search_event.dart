part of 'search_bloc.dart';

sealed class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

/// Fetches the notes to search: on opening the page, and on trying again.
final class SearchRequested extends SearchEvent {
  const SearchRequested();
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

/// Opens a result's note: beside the results in a split window, or as its
/// own page on a single pane. Its card stays open on returning. Null
/// closes it.
final class SearchResultSelected extends SearchEvent {
  const SearchResultSelected(this.id);

  final String? id;

  @override
  List<Object?> get props => [id];
}
