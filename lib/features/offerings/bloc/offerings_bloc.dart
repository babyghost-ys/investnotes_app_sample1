import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:investnotes_app_sample1/data/models/load_status.dart';
import 'package:investnotes_app_sample1/data/models/note_enums.dart';
import 'package:investnotes_app_sample1/data/models/offering.dart';
import 'package:investnotes_app_sample1/data/models/offering_filter.dart';
import 'package:investnotes_app_sample1/data/repositories/notes_repository.dart';

part 'offerings_event.dart';
part 'offerings_state.dart';

/// Open offerings: loading them, the selected note type, the filter, and
/// saved notes. A failed load tries again on its own every few seconds.
class OfferingsBloc extends Bloc<OfferingsEvent, OfferingsState> {
  OfferingsBloc(this._repository) : super(const OfferingsState()) {
    on<OfferingsRequested>((event, emit) async {
      _retry?.cancel();
      // A quiet retry leaves the failure on screen until it succeeds.
      if (!event.quiet) emit(state.copyWith(status: LoadStatus.loading));
      try {
        final all = await _repository.fetchOfferings();
        emit(state.copyWith(all: all, status: LoadStatus.ready));
      } on OfferingsUnavailable {
        emit(state.copyWith(status: LoadStatus.failed));
        _retry = Timer(
          _retryAfter,
          () => add(const OfferingsRequested(quiet: true)),
        );
      }
    });
    on<OfferingsTypeSelected>(
      (event, emit) => emit(state.copyWith(type: event.type)),
    );
    on<OfferingsFilterChanged>(
      (event, emit) => emit(state.copyWith(filter: event.filter)),
    );
    on<OfferingSaveToggled>((event, emit) {
      final saved = {...state.saved};
      if (!saved.remove(event.id)) saved.add(event.id);
      emit(state.copyWith(saved: saved));
    });
  }

  static const _retryAfter = Duration(seconds: 4);

  final NotesRepository _repository;
  Timer? _retry;

  @override
  Future<void> close() {
    _retry?.cancel();
    return super.close();
  }
}
