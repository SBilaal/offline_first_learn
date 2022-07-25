import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class NetworkChecker {
  final _connectivityResult = Connectivity().checkConnectivity();
  Future<bool> get isConnected async {
    if (await _connectivityResult == ConnectivityResult.none) {
      return false;
    }
    return InternetConnectionChecker().hasConnection;
  }
}
