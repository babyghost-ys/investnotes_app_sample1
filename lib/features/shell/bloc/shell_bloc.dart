import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'shell_event.dart';
part 'shell_state.dart';

/// Which tab of the app is showing.
class ShellBloc extends Bloc<ShellEvent, ShellState> {
  ShellBloc() : super(const ShellState()) {
    on<ShellTabSelected>((event, emit) => emit(ShellState(tab: event.tab)));
  }
}
