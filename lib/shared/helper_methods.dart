import 'package:connectivity_plus/connectivity_plus.dart';

class HelperMethods {
  static Future<bool> checkInternet() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi)) {
      return true; // İnternet var
    } else {
      return false; // İnternet yok
    }
  }
}
