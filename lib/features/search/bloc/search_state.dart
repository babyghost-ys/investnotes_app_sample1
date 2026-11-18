part of 'search_bloc.dart';

final class SearchState extends Equatable {
  const SearchState({
    this.all = const [],
    this.phase = LoadingPhase.loading,
    this.query = '',
    this.results = const [],
    this.expanded,
    this.selectedId,
  });

  /// Every note that can be found, once fetched.
  final List<Product> all;
  final LoadingPhase phase;
  final String query;
  final List<Product> results;

  /// The result showing its terms, if any.
  final String? expanded;

  /// The note open beside the results in a split window, or on its own
  /// page pushed from them on a single pane.
  final String? selectedId;

  Product? get detail {
    if (selectedId == null) return null;
    for (final p in all) {
      if (p.id == selectedId) return p;
    }
    return null;
  }

  bool get typed => query.trim().isNotEmpty;

  bool get empty => results.isEmpty;

  SearchState copyWith({
    List<Product>? all,
    LoadingPhase? phase,
    String? query,
    List<Product>? results,
    String? Function()? expanded,
    String? Function()? selectedId,
  }) => SearchState(
    all: all ?? this.all,
    phase: phase ?? this.phase,
    query: query ?? this.query,
    results: results ?? this.results,
    expanded: expanded != null ? expanded() : this.expanded,
    selectedId: selectedId != null ? selectedId() : this.selectedId,
  );

  @override
  List<Object?> get props => [all, phase, query, results, expanded, selectedId];
}
