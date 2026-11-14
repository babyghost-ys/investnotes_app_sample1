part of 'search_bloc.dart';

final class SearchState extends Equatable {
  const SearchState({this.query = '', this.results = const [], this.expanded});

  final String query;
  final List<Product> results;

  /// The result showing its terms, if any.
  final String? expanded;

  bool get empty => results.isEmpty;

  @override
  List<Object?> get props => [query, results, expanded];
}
