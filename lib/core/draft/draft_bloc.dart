import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'draft_event.dart';
part 'draft_state.dart';

/// A value edited on a sheet before it is applied: a filter, a form.
class DraftBloc<T> extends Bloc<DraftEvent<T>, DraftState<T>> {
  DraftBloc(T initial, {T? reset})
    : _reset = reset ?? initial,
      super(DraftState(initial)) {
    on<DraftChanged<T>>((event, emit) => emit(DraftState(event.value)));
    on<DraftReset<T>>((event, emit) => emit(DraftState(_reset)));
  }

  final T _reset;

  void change(T value) => add(DraftChanged<T>(value));
}
