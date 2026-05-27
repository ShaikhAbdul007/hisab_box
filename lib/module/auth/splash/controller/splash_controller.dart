import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/helper/app_version.dart';
import 'package:inventory/routes/routes.dart';

import '../../../../routes/route_name.dart';

class SplashController extends GetxController with CacheManager {
  bool _navigationScheduled = false;

  @override
  void onInit() {
    super.onInit();
    AppVersion.load();
  }

  /// Safe to call from build() — only schedules navigation once.
  void movetoNextScreen() {
    if (_navigationScheduled) return;
    _navigationScheduled = true;

    Future.delayed(const Duration(seconds: 3), () async {
      final isLoggedIn = await retrieveIsLoggedIn();
      if (isLoggedIn == true) {
        AppRoutes.navigateRoutes(routeName: AppRouteName.bottomNavigation);
      } else {
        saveUserLoggedIn(false);
        AppRoutes.navigateRoutes(routeName: AppRouteName.login);
      }
    });
  }
}
