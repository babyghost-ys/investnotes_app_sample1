import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:investnotes_app_sample1/data/models/loading_phase.dart';

part 'page_load_event.dart';
part 'page_load_state.dart';

/// Loads one page and says which [LoadingPhase] it is in.
class PageLoadBloc extends Bloc<PageLoadEvent, PageLoadState> {
  PageLoadBloc() : super(const PageLoadState()) {
    on<PageLoadStarted>((event, emit) async {
      emit(const PageLoadState());
      // TEMPORARY: a fixed delay stands in for the page's real fetch until
      // each page has a data source of its own. Replace it with that call,
      // and emit LoadingPhase.failed when the call fails.
      await Future<void>.delayed(placeholderDelay);
      emit(const PageLoadState(phase: LoadingPhase.loaded));
    });
  }

  /// TEMPORARY: how long the stand-in load takes. Remove with the delay.
  static const placeholderDelay = Duration(milliseconds: 900);
}
