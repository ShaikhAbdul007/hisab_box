import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/helper/set_format_date.dart';
import 'package:inventory/routes/routes.dart';
import '../../../../helper/app_message.dart';
import '../../../../helper/helper.dart';
import '../../../../routes/route_name.dart';
import '../../../setting/model/user_model.dart';

class SignupController extends GetxController with CacheManager {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmpassword = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController pincode = TextEditingController();
  TextEditingController state = TextEditingController();
  TextEditingController mobileNo = TextEditingController();
  TextEditingController alternateMobileNo = TextEditingController();
  TextEditingController shopType = TextEditingController();
  RxBool signUpLoading = false.obs;
  RxBool obscureTextValue = true.obs;
  RxBool isShopDetailFilled = false.obs;

  Rx<File?> profileImage = Rx<File?>(null);
  final ImagePicker picker = ImagePicker();

  Future pickImage() async {
    final img = await picker.pickImage(source: ImageSource.gallery);
    if (img != null) profileImage.value = File(img.path);
  }

  void setobscureTextValue() {
    obscureTextValue.value = !obscureTextValue.value;
  }

  Future<void> signUpUser() async {
    unfocus();
    signUpLoading.value = true;
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: email.text,
            password: password.text,
          );
      String uid = userCredential.user!.uid;
      final String formatCreatedAt = setFormateDate();

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        "name": name.text,
        "email": email.text,
        'password': password.text,
        'address': address.text,
        'city': city.text,
        'pincode': pincode.text,
        'state': state.text,
        'mobileNo': mobileNo.text,
        'shoptype': shopType.text,
        'alternateMobileNo': alternateMobileNo.text,
        "createdAt": formatCreatedAt,
        "profileImage":
            profileImage.value != null ? profileImage.value!.path : '',
      });
      final newDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (newDoc.exists) {
        final data = newDoc.data() as Map<String, dynamic>;
        final userDatas = InventoryUserModel.fromJson(data);
        saveUserData(userDatas);
      }
      showMessage(message: singUpSuccessFul);
      signUpLoading.value = false;
      AppRoutes.navigateRoutes(routeName: AppRouteName.login);
    } on FirebaseAuthException catch (e) {
      signUpLoading.value = false;
      showMessage(message: e.message ?? '');
    } catch (e) {
      signUpLoading.value = false;
      showMessage(message: somethingWentMessage);
    }
  }
}
