import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'session_event.dart';
part 'session_state.dart';

/// The local sign-in of this sample. There is no server: the name entered
/// on the sign-in sheet is kept for the session.
class SessionBloc extends Bloc<SessionEvent, SessionState> {
  SessionBloc() : super(const SessionState()) {
    on<SessionSignedIn>((event, emit) => emit(SessionState(name: event.name)));
    on<SessionSignedOut>((event, emit) => emit(const SessionState()));
  }
}
