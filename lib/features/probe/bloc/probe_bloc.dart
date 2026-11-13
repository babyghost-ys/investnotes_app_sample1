import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'probe_event.dart';
part 'probe_state.dart';

/// The "what if the market moves by…" value of one payoff chart.
class ProbeBloc extends Bloc<ProbeEvent, ProbeState> {
  ProbeBloc() : super(const ProbeState()) {
    on<ProbeMoved>((event, emit) => emit(ProbeState(move: event.move)));
  }
}
