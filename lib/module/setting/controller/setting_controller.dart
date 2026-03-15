import 'dart:io';

import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/local_db/local_db_service.dart';
import 'package:inventory/routes/routes.dart';
import 'package:inventory/supabase_db/supabase_client.dart';
import 'package:inventory/supabase_db/supabase_error_handler.dart';
import 'package:inventory/supabase_db/storage_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../helper/app_message.dart';
import '../../../helper/helper.dart';
import '../../../routes/route_name.dart';
import '../model/user_model.dart';

class SettingController extends GetxController with CacheManager {
  // 🔥 FIREBASE REMOVED
  // final FirebaseAuth _auth = FirebaseAuth.instance;

  RxString storeName = ''.obs;
  RxString email = ''.obs;
  RxString shoptype = ''.obs;
  RxBool isUserlogout = false.obs;
  RxBool discountPerProduct = false.obs;
  Rx<File?> profileImage = Rx<File?>(null);
  RxString profileImageUrl = ''.obs;

  File? _safeProfileFile(String path) {
    final file = File(path);
    return file.existsSync() ? file : null;
  }

  bool _hasRenderableImage(String? imageValue) {
    final value = (imageValue ?? '').trim();
    if (value.isEmpty) return false;
    if (StorageService.isNetworkImage(value)) return true;
    return File(value).existsSync();
  }

  void _setProfileSource(String? imageValue) {
    final value = (imageValue ?? '').trim();
    if (StorageService.isNetworkImage(value)) {
      profileImageUrl.value = value;
      profileImage.value = null;
      return;
    }
    profileImageUrl.value = '';
    if (value.isEmpty) {
      profileImage.value = null;
      return;
    }
    profileImage.value = _safeProfileFile(value);
  }

  @override
  void onInit() {
    getUserName();
    super.onInit();
  }

  // ================================
  // 🔥 GET USER PROFILE (SUPABASE)
  // ================================
  Future<void> getUserName() async {
    final userId = resolveUserId(isUserlogout.value);
    if (userId == null) return;

    try {
      // 1️⃣ TRY LOCAL CACHE FIRST
      final user = retrieveUserDetail();

      if (user.name != null && user.name!.isNotEmpty) {
        storeName.value = user.name ?? '';
        email.value = user.email ?? '';
        shoptype.value = user.shoptype ?? '';
        discountPerProduct.value = user.discountPerProduct ?? false;
        _setProfileSource(user.image);
        if (_hasRenderableImage(user.image)) {
          return;
        }
      }

      // 2️⃣ FETCH FROM SUPABASE
      final response =
          await SupabaseConfig.from(
            'users',
          ).select().eq('id', userId).maybeSingle();

      if (response != null) {
        final userDatas = UserModel.fromJson(response);

        storeName.value = userDatas.name ?? '';
        email.value = userDatas.email ?? '';
        shoptype.value = userDatas.shoptype ?? '';
        discountPerProduct.value = userDatas.discountPerProduct ?? false;
        _setProfileSource(userDatas.image);
        // 🔥 SAVE TO CACHE
        saveUserData(userDatas);
      }
    } catch (e) {
      showMessage(message: SupabaseErrorHandler.getMessage(e));
    }
  }

  // ================================
  // 🔥 LOGOUT (SUPABASE)
  // ================================
  Future<void> userlogout() async {
    isUserlogout.value = true;
    try {
      await SupabaseConfig.auth.signOut();
      removeBox();
      LocalService.clearAllCache();
      Get.back();
      showMessage(message: logout);
      AppRoutes.navigateRoutes(routeName: AppRouteName.login);
    } catch (e) {
      showMessage(message: SupabaseErrorHandler.getMessage(e));
    } finally {
      isUserlogout.value = false;
    }
  }

  // ================================
  // 🔥 SUPPORT EMAIL
  // ================================
  void emailLauncher() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: customerCareEmail,
      queryParameters: {'subject': 'Problem With the Hisab Box App'},
    );
    await launchUrl(emailLaunchUri, mode: LaunchMode.externalApplication);
  }

  // ================================
  // 🔥 SUPPORT CALL
  // ================================
  void phoneluancher() async {
    var url = Uri.parse("tel:$customerCareNumber");
    await launchUrl(url, mode: LaunchMode.externalApplication);
    Get.back();
  }
}

// class SettingController extends GetxController with CacheManager {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   RxString storeName = ''.obs;
//   RxString email = ''.obs;
//   RxString shoptype = ''.obs;
//   RxBool isUserlogout = false.obs;
//   RxBool discountPerProduct = false.obs;

//   @override
//   void onInit() {
//     getUserName();
//     super.onInit();
//   }

//   Future<void> getUserName() async {
//     final uid = _auth.currentUser!.uid;
//     try {
//       var user = retrieveUserDetail();
//       if (user.name != null && user.name!.isNotEmpty) {
//         storeName.value = user.name ?? '';
//         email.value = user.email ?? '';
//         shoptype.value = user.shoptype ?? '';
//         discountPerProduct.value = user.discountPerProduct ?? false;
//       } else {
//         DocumentSnapshot doc =
//             await FirebaseFirestore.instance.collection('users').doc(uid).get();
//         if (doc.exists) {
//           var data = doc.data() as Map<String, dynamic>;
//           final userDatas = UserModel.fromJson(data);
//           storeName.value = userDatas.name ?? '';
//           email.value = userDatas.email ?? '';
//           shoptype.value = userDatas.shoptype ?? '';
//           discountPerProduct.value = userDatas.discountPerProduct ?? false;
//           saveUserData(userDatas);
//         } else {}
//       }
//     } on FirebaseAuthException catch (e) {
//       showMessage(message: e.message ?? '');
//     }
//   }

//   Future<void> userlogout() async {
//     isUserlogout.value = true;
//     try {
//       await _auth.signOut();
//       removeBox();
//       Get.back();
//       showMessage(message: logout);
//       AppRoutes.navigateRoutes(routeName: AppRouteName.login);
//     } on FirebaseException catch (e) {
//       showMessage(message: e.message ?? '');
//     } finally {
//       isUserlogout.value = false;
//     }
//   }

//   void emailLauncher() async {
//     final Uri emailLaunchUri = Uri(
//       scheme: 'mailto',
//       path: customerCareEmail,
//       queryParameters: {'subject': 'Problem With the Hisab Box App'},
//     );
//     await launchUrl(emailLaunchUri, mode: LaunchMode.externalApplication);
//   }

//   void phoneluancher() async {
//     var url = Uri.parse("tel:$customerCareNumber");
//     await launchUrl(url, mode: LaunchMode.externalApplication);
//     Get.back();
//   }
// }
