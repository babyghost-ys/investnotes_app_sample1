part of 'search_bloc.dart';

final class SearchState extends Equatable {
  const SearchState({
    this.query = '',
    this.offerings = const [],
    this.issued = const [],
  });

  final String query;
  final List<Offering> offerings;
  final List<IssuedNote> issued;

  bool get empty => offerings.isEmpty && issued.isEmpty;

  @override
  List<Object?> get props => [query, offerings, issued];
}
