import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:investnotes_app_sample1/data/models/issued_note.dart';
import 'package:investnotes_app_sample1/data/models/offering.dart';
import 'package:investnotes_app_sample1/data/repositories/notes_repository.dart';

part 'search_event.dart';
part 'search_state.dart';

/// Searches open offerings and issued notes by name, underlying, type,
/// region, asset class and currency. Every word must match somewhere.
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc(this._repository) : super(const SearchState()) {
    on<SearchQueryChanged>((event, emit) {
      final words = event.query
          .toLowerCase()
          .split(RegExp(r'\s+'))
          .where((w) => w.isNotEmpty)
          .toList();
      if (words.isEmpty) {
        emit(SearchState(query: event.query));
        return;
      }
      bool hit(String haystack) => words.every(haystack.contains);
      emit(
        SearchState(
          query: event.query,
          offerings: _repository.offerings
              .where(
                (o) => hit(
                  [
                    o.name,
                    o.underlying,
                    o.type.code,
                    o.type.title,
                    o.region.title,
                    o.assetClass.title,
                    o.currency.name,
                  ].join(' ').toLowerCase(),
                ),
              )
              .toList(),
          issued: _repository.issued
              .where(
                (n) => hit(
                  [
                    n.name,
                    n.type.code,
                    n.type.title,
                    n.status.title,
                    n.currency.name,
                  ].join(' ').toLowerCase(),
                ),
              )
              .toList(),
        ),
      );
    });
  }

  final NotesRepository _repository;
}
