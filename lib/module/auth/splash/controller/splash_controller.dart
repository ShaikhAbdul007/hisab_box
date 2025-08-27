import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/routes/routes.dart';

class SplashController extends GetxController with CacheManager {
  movetoNextScreen() {
    Future.delayed(Duration(seconds: 2), () async {
      bool isLoggedIn = await retrieveIsLoggedIn();
      if (isLoggedIn == true) {
        AppRoutes.navigateRoutes(routeName: AppRouteName.bottomNavigation);
      } else {
        AppRoutes.navigateRoutes(routeName: AppRouteName.login);
      }
    });
  }
}
