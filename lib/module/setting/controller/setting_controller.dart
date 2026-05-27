import 'dart:io';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/helper/shop_type.dart';
import 'package:inventory/module/setting/model/user_model.dart';
import 'package:inventory/module/setting/repo/logout_repo.dart';
import 'package:inventory/module/user_profile/repo/user_repo.dart';
import 'package:inventory/routes/routes.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../helper/app_message.dart';
import '../../../helper/helper.dart';
import '../../../routes/route_name.dart';

class SettingController extends GetxController with CacheManager {
  LogoutRepo logoutRepo = LogoutRepo();
  UserProfileRepo userRepo = UserProfileRepo();
  RxString storeName = ''.obs;
  RxString email = ''.obs;
  RxString shoptype = ''.obs;

  ShopType get shopTypeEnum => ShopType.fromString(shoptype.value);
  RxBool isUserlogout = false.obs;
  RxBool discountPerProduct = false.obs;
  RxBool isProfileLoading = false.obs;
  Rx<File?> profileImage = Rx<File?>(null);
  RxString profileImageUrl = ''.obs;
  Rx<UserModel> userModel = UserModel().obs;

  @override
  void onInit() {
    getUserName();
    super.onInit();
  }

  // ================================
  // 🔥 GET USER PROFILE (SUPABASE)
  // ================================
  Future<void> getUserName() async {
    isProfileLoading.value = true;
    try {
      final user = retrieveUserDetail();
      if (user.data?.name != null && user.data!.name!.isNotEmpty) {
        storeName.value = user.data?.name ?? '';
        email.value = user.data?.email ?? '';
        shoptype.value = user.data?.shopType ?? 'Pet Shop';
        profileImageUrl.value = user.data?.profilepic ?? '';
      } else {
        await getUserData();
        storeName.value = userModel.value.data?.name ?? '';
        email.value = userModel.value.data?.email ?? '';
        shoptype.value = userModel.value.data?.shopType ?? 'Pet Shop';
        profileImageUrl.value = userModel.value.data?.profilepic ?? '';
      }
    } catch (e) {
      showSnackBar(error: e.toString());
    } finally {
      isProfileLoading.value = false;
    }
  }

  Future<void> getUserData() async {
    try {
      var response = await userRepo.getUserDetails();
      if (response.success == success) {
        userModel.value = response;
        saveUserData(userModel.value);
      } else if (response.success == failed) {
        showSnackBar(error: response.msg ?? somethingWentMessage);
      } else {
        showSnackBar(error: somethingWentMessage);
      }
    } catch (e) {
      showSnackBar(error: e.toString());
    } finally {}
  }

  Future<void> userlogout() async {
    isUserlogout.value = true;
    try {
      var response = await logoutRepo.logout();
      if (response.success == success) {
        removeBox();

        Get.back();
        showSnackBar(error: response.msg ?? logout);
        AppRoutes.navigateRoutes(routeName: AppRouteName.login);
      } else if (response.success == failed) {
        showSnackBar(error: response.msg ?? somethingWentMessage);
      } else {
        showSnackBar(error: somethingWentMessage);
      }
    } catch (e) {
      showSnackBar(error: e.toString());
    } finally {
      isUserlogout.value = false;
    }
  }

  void emailLauncher() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: customerCareEmail,
      queryParameters: {'subject': 'Problem With the Hisab Box App'},
    );
    await launchUrl(emailLaunchUri, mode: LaunchMode.externalApplication);
  }

  void phoneluancher() async {
    var url = Uri.parse("tel:$customerCareNumber");
    await launchUrl(url, mode: LaunchMode.externalApplication);
    Get.back();
  }
}
