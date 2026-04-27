import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkHelper {
  // Singleton
  static final NetworkHelper _instance = NetworkHelper._internal();
  factory NetworkHelper() => _instance;
  NetworkHelper._internal();

  // ── Check Connection ───────────────────────────────────────────────────
  static Future<bool> hasInternetConnection() async {
    try {
      final result = await Connectivity().checkConnectivity();
      return result != ConnectivityResult.none;
    } catch (e) {
      return false;
    }
  }

  // ── Stream of Connection Changes ───────────────────────────────────────
  static Stream<bool> get connectionStream {
    return Connectivity().onConnectivityChanged.map(
      (result) => result != ConnectivityResult.none,
    );
  }
}