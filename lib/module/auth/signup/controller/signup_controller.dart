import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:inventory/routes/routes.dart';
import '../../../../helper/app_message.dart';
import '../../../../helper/helper.dart';

class SignupController extends GetxController {
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
  RxBool signUpLoading = false.obs;
  RxBool obscureTextValue = true.obs;
  RxInt currentStepperIndex = 0.obs;

  setobscureTextValue() {
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
      final String formatCreatedAt = DateFormat(
        'dd/MM/yyyy',
      ).format(DateTime.now());

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        "name": name.text,
        "email": email.text,
        'password': password.text,
        'address': address.text,
        'city': city.text,
        'pincode': pincode.text,
        'state': state.text,
        'mobileNo': mobileNo.text,
        'alternateMobileNo': alternateMobileNo.text,
        "createdAt": formatCreatedAt,
      });
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
