import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
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

  final ImagePicker picker = ImagePicker();
  Rx<File?> profileImage = Rx<File?>(null);

  @override
  void onInit() {
    setUserDetails();
    super.onInit();
  }

  // ---------------- IMAGE PICK ----------------
  Future<void> pickImage() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      profileImage.value = File(image.path);
      print(profileImage.value?.path);
    }
  }

  // ---------------- UPDATE PROFILE ----------------
  Future<void> updateUserDetails() async {
    isLoading.value = true;
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      isLoading.value = false;
      return;
    }

    final String formatCreatedAt = setFormateDate();

    try {
      final updatedData = {
        "name": shopNameController.text,
        "email": emailController.text,
        "address": addressController.text,
        "city": cityController.text,
        "pincode": pincodeController.text,
        "state": stateController.text,
        "mobileNo": mobileController.text,
        "alternateMobileNo": alternativeMobileController.text,
        "createdAt": formatCreatedAt,
        "profileImage": profileImage.value?.path ?? '',
      };

      // 🔥 FIREBASE WRITE (NO READ AFTER THIS)
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(updatedData, SetOptions(merge: true));

      // 🔥 UPDATE CACHE DIRECTLY
      final updatedUser = UserModel(
        name: shopNameController.text,
        email: emailController.text,
        address: addressController.text,
        city: cityController.text,
        pincode: pincodeController.text,
        state: stateController.text,
        mobileNo: mobileController.text,
        alternateMobileNo: alternativeMobileController.text,
        image: profileImage.value?.path ?? '',
      );

      saveUserData(updatedUser);
      setUserDetails();

      readOnly.value = true;
      showMessage(message: "Profile Updated Successfully ✅");
    } on FirebaseException catch (e) {
      showMessage(message: e.message ?? 'Something went wrong');
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------- LOAD USER FROM CACHE ----------------
  void setUserDetails() async {
    isDataLoading.value = true;

    final user = retrieveUserDetail();

    shopNameController.text = user.name ?? '';
    mobileController.text = user.mobileNo ?? '';
    alternativeMobileController.text = user.alternateMobileNo ?? '';
    pincodeController.text = user.pincode ?? '';
    stateController.text = user.state ?? '';
    addressController.text = user.address ?? '';
    cityController.text = user.city ?? '';
    emailController.text = user.email ?? '';

    // 🔒 SAFE IMAGE LOAD - Handle cache directory access issues
    if (user.image != null && user.image!.isNotEmpty) {
      try {
        final imageFile = File(user.image!);

        // Debug: Print the path being accessed
        print('🖼️ Trying to load image from: ${user.image}');

        // Check if file exists and is readable
        bool fileExists = await imageFile.exists();
        print('📁 File exists: $fileExists');

        if (fileExists) {
          // Try to read file length to verify accessibility
          try {
            int fileLength = await imageFile.length();
            print('📏 File size: $fileLength bytes');
            profileImage.value = imageFile;
          } catch (lengthError) {
            print('❌ Cannot read file length: $lengthError');
            profileImage.value = null;
          }
        } else {
          print('❌ File does not exist at path: ${user.image}');
          profileImage.value = null;
          // Clear invalid image path from cache
          _clearInvalidImageFromCache(user);
        }
      } catch (e) {
        print('❌ Error accessing image file: $e');
        profileImage.value = null;
        // Clear invalid image path from cache on any error
        _clearInvalidImageFromCache(user);
      }
    } else {
      profileImage.value = null;
    }

    Future.delayed(const Duration(milliseconds: 300), () {
      isDataLoading.value = false;
    });
  }

  // Helper method to clear invalid image from cache
  void _clearInvalidImageFromCache(UserModel user) {
    final updatedUser = UserModel(
      name: user.name,
      email: user.email,
      address: user.address,
      city: user.city,
      pincode: user.pincode,
      state: user.state,
      mobileNo: user.mobileNo,
      alternateMobileNo: user.alternateMobileNo,
      image: '', // Clear invalid path
    );
    saveUserData(updatedUser);
    print('🧹 Cleared invalid image path from cache');
  }
}
