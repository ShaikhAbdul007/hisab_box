import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inventory/routes/routes.dart';
import '../../../helper/app_message.dart';
import '../../../helper/helper.dart';

class SettingController extends GetxController with CacheManager {
  RxBool isUserlogout = false.obs;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  RxString storeName = ''.obs;
  RxString email = ''.obs;

  @override
  void onInit() {
    getUserName();
    super.onInit();
  }

  Future<void> getUserName() async {
    final uid = _auth.currentUser!.uid;
    try {
      DocumentSnapshot doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        var data = doc.data() as Map<String, dynamic>;
        storeName.value = data['name'];
        email.value = data['email'];
      } else {
        print("User not found");
      }
    } catch (e) {
      print("Error: $e");
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
}
