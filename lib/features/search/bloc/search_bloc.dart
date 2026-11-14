import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:investnotes_app_sample1/data/models/note_enums.dart';
import 'package:investnotes_app_sample1/data/models/product.dart';
import 'package:investnotes_app_sample1/data/repositories/notes_repository.dart';

part 'search_event.dart';
part 'search_state.dart';

/// Searches open offerings and issued notes by name, code, underlying,
/// type, region, asset class, currency and status. Every word must match
/// somewhere. Results open one at a time in place.
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc(NotesRepository repository)
    : _all = [
        ...repository.offerings.map(repository.productOf),
        ...repository.issued.map(repository.productOfIssued),
      ],
      super(const SearchState()) {
    on<SearchQueryChanged>((event, emit) {
      final words = event.query
          .toLowerCase()
          .split(RegExp(r'\s+'))
          .where((w) => w.isNotEmpty)
          .toList();
      if (words.isEmpty) {
        emit(SearchState(query: event.query, expanded: state.expanded));
        return;
      }
      bool hit(Product p) => words.every(_haystack(p).contains);
      emit(
        SearchState(
          query: event.query,
          results: _all.where(hit).toList(),
          expanded: state.expanded,
        ),
      );
    });
    on<SearchRowToggled>((event, emit) {
      emit(
        SearchState(
          query: state.query,
          results: state.results,
          expanded: state.expanded == event.id ? null : event.id,
        ),
      );
    });
  }

  final List<Product> _all;

  static String _haystack(Product p) => [
    p.name,
    p.fundserv,
    p.underlying,
    p.type.code,
    p.type.title,
    p.region.title,
    p.assetClass.title,
    p.currency.code,
    p.status?.title ?? 'open',
  ].join(' ').toLowerCase();
}
