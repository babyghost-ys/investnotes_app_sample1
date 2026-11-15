import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:investnotes_app_sample1/core/l10n/generated/locales.dart';
import 'package:investnotes_app_sample1/core/l10n/terms.dart';
import 'package:investnotes_app_sample1/data/models/note_enums.dart';
import 'package:investnotes_app_sample1/data/models/product.dart';
import 'package:investnotes_app_sample1/data/repositories/notes_repository.dart';

part 'search_event.dart';
part 'search_state.dart';

/// Searches open offerings and issued notes by name, code, underlying,
/// type, region, asset class, currency and status. Every word must match
/// somewhere. Results open one at a time in place.
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  /// Words such as a type's name match in [general]'s language, the one
  /// the page shows.
  SearchBloc(NotesRepository repository, this._general)
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
  final GeneralLocale _general;

  String _haystack(Product p) => [
    p.name,
    p.fundserv,
    p.underlying,
    p.type.code,
    p.type.title(_general),
    p.region.title(_general),
    p.assetClass.title(_general),
    p.currency.code,
    p.status?.title(_general) ?? '',
  ].join(' ').toLowerCase();
}
