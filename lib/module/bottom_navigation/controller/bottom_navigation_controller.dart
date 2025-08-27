import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:inventory/routes/routes.dart';

class BottomNavigationController extends GetxController {
  RxInt index = 0.obs;
  StreamSubscription? subscription;
  setBottomIndex(int value) {
    index.value = value;
  }

  @override
  void onInit() {
    checkInitialConnectivity();
    subscription = Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) async {
      if (results.isEmpty || results.first == ConnectivityResult.none) {
        return;
      }

      bool internet = await isInternetAvailable();
      if (internet) {
      } else {
        AppRoutes.navigateRoutes(routeName: AppRouteName.nointernateConnection);
      }
    });
    super.onInit();
  }

  Future<void> checkInitialConnectivity() async {
    var result = await Connectivity().checkConnectivity();
    if (result == ConnectivityResult.none) {
      AppRoutes.navigateRoutes(routeName: AppRouteName.nointernateConnection);
    } else {
      bool internet = await isInternetAvailable();
      if (internet) {
      } else {
        AppRoutes.navigateRoutes(routeName: AppRouteName.nointernateConnection);
      }
    }
  }

  Future<bool> isInternetAvailable() async {
    try {
      final response = await InternetAddress.lookup('example.com');
      return response.isNotEmpty && response[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  @override
  void onClose() {
    subscription?.cancel();
    super.onClose();
  }
}
