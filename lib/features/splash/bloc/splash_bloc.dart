import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'splash_event.dart';
part 'splash_state.dart';

/// The opening screen: shown for [hold], then the app.
class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc({this.hold = const Duration(milliseconds: 2400)})
    : super(const SplashState()) {
    on<SplashStarted>((event, emit) async {
      await Future<void>.delayed(hold);
      emit(const SplashState(done: true));
    });
    add(const SplashStarted());
  }

  final Duration hold;
}
