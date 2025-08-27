import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/routes/routes.dart';
import '../../../../helper/app_message.dart';
import '../../../../helper/helper.dart';

class SignupController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmpassword = TextEditingController();
  TextEditingController name = TextEditingController();
  RxBool signUpLoading = false.obs;
  RxBool obscureTextValue = true.obs;

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

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        "name": name.text,
        "email": email.text,
        'password': password.text,
        "createdAt": DateTime.now(),
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
