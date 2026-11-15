import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:investnotes_app_sample1/data/models/article.dart';
import 'package:investnotes_app_sample1/data/repositories/downloads_repository.dart';

part 'downloads_event.dart';
part 'downloads_state.dart';

/// The articles on this device and those still arriving. Held above the
/// pages, so a download keeps going while the reader moves around the app.
class DownloadsBloc extends Bloc<DownloadsEvent, DownloadsState> {
  DownloadsBloc(this._repository) : super(const DownloadsState()) {
    on<DownloadsStarted>(_onStarted);
    on<DownloadRequested>(_onRequested);
    on<DownloadCancelled>(_onCancelled);
    on<DownloadRemoved>(_onRemoved);
  }

  final DownloadsRepository _repository;

  /// The transfer running for each article. A cancelled transfer loses its
  /// entry, and a new one for the same article gets a new token, so a late
  /// chunk from the old one is never counted.
  final _runs = <String, Object>{};

  Future<void> _onStarted(
    DownloadsStarted event,
    Emitter<DownloadsState> emit,
  ) async {
    final kept = await _repository.kept();
    emit(state.copyWith(kept: kept));
  }

  Future<void> _onRequested(
    DownloadRequested event,
    Emitter<DownloadsState> emit,
  ) async {
    final id = event.article.id;
    if (state.isKept(id) || _runs.containsKey(id)) return;
    final token = Object();
    _runs[id] = token;
    bool current() => identical(_runs[id], token);

    await emit.onEach<double>(
      _repository.fetch(event.article).takeWhile((_) => current()),
      onData: (received) =>
          emit(state.copyWith(progress: {...state.progress, id: received})),
    );
    if (!current()) return;
    _runs.remove(id);
    final kept = [id, ...state.kept.where((k) => k != id)];
    emit(
      state.copyWith(kept: kept, progress: Map.of(state.progress)..remove(id)),
    );
    await _repository.keep(kept);
  }

  void _onCancelled(DownloadCancelled event, Emitter<DownloadsState> emit) {
    _runs.remove(event.id);
    emit(state.copyWith(progress: Map.of(state.progress)..remove(event.id)));
  }

  Future<void> _onRemoved(
    DownloadRemoved event,
    Emitter<DownloadsState> emit,
  ) async {
    final kept = state.kept.where((k) => k != event.id).toList();
    emit(state.copyWith(kept: kept));
    await _repository.keep(kept);
  }
}
