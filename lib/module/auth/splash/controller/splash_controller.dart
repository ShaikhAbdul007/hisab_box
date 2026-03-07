import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/routes/routes.dart';
import 'package:inventory/supabase_db/supabase_client.dart';

import '../../../../routes/route_name.dart';

class SplashController extends GetxController with CacheManager {
  void movetoNextScreen() {
    Future.delayed(Duration(seconds: 2), () async {
      bool isLoggedIn = await retrieveIsLoggedIn();
      final hasSession = SupabaseConfig.auth.currentSession != null;

      if (isLoggedIn == true && hasSession) {
        AppRoutes.navigateRoutes(routeName: AppRouteName.bottomNavigation);
      } else {
        saveUserLoggedIn(false);
        AppRoutes.navigateRoutes(routeName: AppRouteName.login);
      }
    });
  }
}
