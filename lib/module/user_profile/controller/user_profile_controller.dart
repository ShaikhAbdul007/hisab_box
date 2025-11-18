import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/helper/helper.dart';
import 'package:inventory/helper/set_format_date.dart';

import '../../setting/model/user_model.dart';

class UserProfileController extends GetxController with CacheManager {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  RxBool isLoading = false.obs;
  RxBool readOnly = true.obs;
  RxBool isDataLoading = false.obs;
  TextEditingController emailController = TextEditingController();
  TextEditingController shopNameController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController alternativeMobileController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController pincodeController = TextEditingController();
  TextEditingController stateController = TextEditingController();

  @override
  void onInit() {
    setUserDetails();
    super.onInit();
  }

  Future<void> updateUserDetails() async {
    isLoading.value = true;
    final uid = _auth.currentUser!.uid;
    final String formatCreatedAt = setFormateDate();
    try {
      var updatedData = {
        "name": shopNameController.text,
        "email": emailController.text,
        'address': addressController.text,
        'city': cityController.text,
        'pincode': pincodeController.text,
        'state': stateController.text,
        'mobileNo': mobileController.text,
        'alternateMobileNo': alternativeMobileController.text,
        "createdAt": formatCreatedAt,
      };
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update(updatedData);
      final newDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (newDoc.exists) {
        final data = newDoc.data() as Map<String, dynamic>;
        final userDatas = InventoryUserModel.fromJson(data);
        saveUserData(userDatas);
        setUserDetails();
        readOnly.value = true;
        showMessage(message: "Profile Updated Successfully ✅");
      }
    } on FirebaseException catch (e) {
      showMessage(message: e.message ?? 'Something went wrong');
    } finally {
      isLoading.value = false;
    }
  }

  void setUserDetails() async {
    isDataLoading.value = true;
    var user = retrieveUserDetail();
    shopNameController.text = user.name ?? '';
    mobileController.text = user.mobileNo ?? '';
    alternativeMobileController.text = user.alternateMobileNo ?? '';
    pincodeController.text = user.pincode ?? '';
    stateController.text = user.state ?? '';
    addressController.text = user.address ?? '';
    cityController.text = user.city ?? '';
    emailController.text = user.email ?? '';
    Future.delayed(Duration(seconds: 2), () {
      isDataLoading.value = false;
    });
  }
}
