import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inventory/routes/routes.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../helper/app_message.dart';
import '../../../helper/helper.dart';
import '../../../routes/route_name.dart';
import '../model/user_model.dart';

class SettingController extends GetxController with CacheManager {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  RxString storeName = ''.obs;
  RxString email = ''.obs;
  RxString shoptype = ''.obs;
  RxBool isUserlogout = false.obs;
  RxBool discountPerProduct = false.obs;

  @override
  void onInit() {
    getUserName();
    super.onInit();
  }

  Future<void> getUserName() async {
    final uid = _auth.currentUser!.uid;
    try {
      var user = retrieveUserDetail();
      if (user.name != null && user.name!.isNotEmpty) {
        storeName.value = user.name ?? '';
        email.value = user.email ?? '';
        shoptype.value = user.shoptype ?? '';
        discountPerProduct.value = user.discountPerProduct ?? false;
      } else {
        DocumentSnapshot doc =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();
        if (doc.exists) {
          var data = doc.data() as Map<String, dynamic>;
          final userDatas = UserModel.fromJson(data);
          storeName.value = userDatas.name ?? '';
          email.value = userDatas.email ?? '';
          shoptype.value = userDatas.shoptype ?? '';
          discountPerProduct.value = userDatas.discountPerProduct ?? false;
          saveUserData(userDatas);
        } else {}
      }
    } on FirebaseAuthException catch (e) {
      showMessage(message: e.message ?? '');
    }
  }

  Future<void> userlogout() async {
    isUserlogout.value = true;
    try {
      await _auth.signOut();
      removeBox();
      Get.back();
      showMessage(message: logout);
      AppRoutes.navigateRoutes(routeName: AppRouteName.login);
    } on FirebaseException catch (e) {
      showMessage(message: e.message ?? '');
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
