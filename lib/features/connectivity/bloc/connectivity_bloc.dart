import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:investnotes_app_sample1/domain/models/network_status.dart';
import 'package:investnotes_app_sample1/data/repositories/connectivity_repository.dart';

part 'connectivity_event.dart';
part 'connectivity_state.dart';

/// Follows the device's network for the whole app.
class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  ConnectivityBloc(this._repository) : super(const ConnectivityState()) {
    on<ConnectivityStarted>((event, emit) async {
      emit(ConnectivityState(status: await _repository.status));
      await emit.forEach<NetworkStatus>(
        _repository.changes,
        onData: (status) => ConnectivityState(status: status),
      );
    });
  }

  final ConnectivityRepository _repository;
}
