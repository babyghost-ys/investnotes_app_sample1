import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';

import 'package:investnotes_app_sample1/core/l10n/generated/locales.dart';
import 'package:investnotes_app_sample1/core/l10n/terms.dart';
import 'package:investnotes_app_sample1/data/models/loading_phase.dart';
import 'package:investnotes_app_sample1/data/models/note_enums.dart';
import 'package:investnotes_app_sample1/data/models/product.dart';
import 'package:investnotes_app_sample1/data/repositories/notes_repository.dart';

part 'search_event.dart';
part 'search_state.dart';

/// Searches open offerings and issued notes by name, code, underlying,
/// type, region, asset class, currency and status. Every word must match
/// somewhere. Results open one at a time in place.
///
/// The notes are fetched as the page opens, while the person types; what
/// they typed is matched as soon as the notes arrive.
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  /// Words such as a type's name match in [general]'s language, the one
  /// the page shows.
  SearchBloc(this._repository, this._general) : super(const SearchState()) {
    on<SearchRequested>(transformer: droppable(), (event, emit) async {
      emit(state.copyWith(phase: LoadingPhase.loading));
      try {
        final all = await _repository.fetchProducts();
        emit(
          state.copyWith(
            all: all,
            phase: LoadingPhase.loaded,
            results: _match(all, state.query),
          ),
        );
      } on NotesUnavailable {
        emit(state.copyWith(phase: LoadingPhase.failed));
      }
    });
    on<SearchQueryChanged>(
      (event, emit) => emit(
        state.copyWith(
          query: event.query,
          results: _match(state.all, event.query),
        ),
      ),
    );
    on<SearchRowToggled>(
      (event, emit) => emit(
        state.copyWith(
          expanded: () => state.expanded == event.id ? null : event.id,
        ),
      ),
    );
  }

  final NotesRepository _repository;
  final GeneralLocale _general;

  List<Product> _match(List<Product> all, String query) {
    final words = query
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) return const [];
    return all.where((p) => words.every(_haystack(p).contains)).toList();
  }

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
