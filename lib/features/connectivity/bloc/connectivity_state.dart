part of 'connectivity_bloc.dart';

final class ConnectivityState extends Equatable {
  const ConnectivityState({this.status = NetworkStatus.unknown});

  final NetworkStatus status;

  bool get offline => status == NetworkStatus.offline;

  @override
  List<Object?> get props => [status];
}
