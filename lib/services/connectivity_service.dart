import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  Stream<bool> get isOnline {
    return _connectivity.onConnectivityChanged.map(_hasConnection);
  }

  Future<bool> checkOnline() async {
    return _hasConnection(await _connectivity.checkConnectivity());
  }

  bool _hasConnection(List<ConnectivityResult> results) {
    return results.any((result) => result != ConnectivityResult.none);
  }
}
