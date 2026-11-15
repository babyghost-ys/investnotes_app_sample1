import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:investnotes_app_sample1/data/models/network_status.dart';

/// Whether the device has any network to reach the service through.
class ConnectivityRepository {
  final _connectivity = Connectivity();

  static NetworkStatus _status(List<ConnectivityResult> results) =>
      results.any((result) => result != ConnectivityResult.none)
      ? NetworkStatus.online
      : NetworkStatus.offline;

  Future<NetworkStatus> get status async =>
      _status(await _connectivity.checkConnectivity());

  Stream<NetworkStatus> get changes =>
      _connectivity.onConnectivityChanged.map(_status).distinct();
}
