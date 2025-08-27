import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/routes/routes.dart';
import '../../../../common_widget/colors.dart';
import '../../../../common_widget/commom_aminatedtext.dart';
import '../../../../common_widget/common_button.dart';
import '../../../../common_widget/size.dart';
import '../../../../common_widget/textfiled.dart';
import '../../../../helper/app_message.dart';
import '../../../../helper/textstyle.dart';
import '../controller/signup_controller.dart';

class SignupView extends GetView<SignupController> {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    final signUpkey = GlobalKey<FormState>();
    return Scaffold(
      body: Form(
        key: signUpkey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonButton(
                    width: 40,
                    height: 40,
                    radius: 60,
                    isIconReq: true,
                    label: '',
                    onTap: () {
                      Get.back();
                    },
                  ),
                  setHeight(height: 20),
                  CommomAminatedtext(
                    label: 'Create Account',
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                  ),
                  setHeight(height: 10),
                  Text(
                    createAccountSubtitle,
                    style: CustomTextStyle.customUbuntu(
                      color: AppColors.greyColor,
                    ),
                  ),
                ],
              ),
            ),
            setHeight(height: 25),
            CommonTextField(
              hintText: 'Shop Name',
              label: 'Shop Name',
              controller: controller.name,
              suffixIcon: Icon(CupertinoIcons.person, size: 18),
              validator: (shopNameValue) {
                if (shopNameValue!.isEmpty) {
                  return emptyShopName;
                } else {
                  return null;
                }
              },
            ),
            setHeight(height: 15),
            CommonTextField(
              hintText: 'Email',
              label: 'Email',
              controller: controller.email,
              suffixIcon: Icon(CupertinoIcons.mail, size: 18),
              validator: (emailValue) {
                if (emailValue!.isEmpty) {
                  return emptyEmail;
                }
                if (!GetUtils.isEmail(emailValue)) {
                  return invalidEmail;
                } else {
                  return null;
                }
              },
            ),
            setHeight(height: 15),
            CommonTextField(
              obscureText: true,
              hintText: 'Password',
              label: 'Password',
              controller: controller.password,
              suffixIcon: Icon(CupertinoIcons.padlock, size: 18),
              validator: (passwordValue) {
                if (passwordValue!.isEmpty) {
                  return emptyPassword;
                } else if (passwordValue.length < 6) {
                  return shortPassword;
                } else {
                  return null;
                }
              },
            ),
            setHeight(height: 15),
            Obx(
              () => CommonTextField(
                obscureText: controller.obscureTextValue.value,
                hintText: 'Password',
                label: 'COnfirm Password',
                controller: controller.confirmpassword,
                suffixIcon: InkWell(
                  onTap: () => controller.setobscureTextValue(),
                  child: Icon(
                    controller.obscureTextValue.value
                        ? CupertinoIcons.padlock
                        : CupertinoIcons.lock_open,
                    size: 18,
                  ),
                ),
                validator: (passwordValue) {
                  if (passwordValue!.isEmpty) {
                    return emptyPassword;
                  } else if (passwordValue.length < 6) {
                    return shortPassword;
                  } else if (controller.password.text !=
                      controller.confirmpassword.text) {
                    return passwordMismatch;
                  } else {
                    return null;
                  }
                },
              ),
            ),
            setHeight(height: 15),
            Obx(
              () => CommonButton(
                isLoading: controller.signUpLoading.value,
                label: signup,
                onTap: () async {
                  if (signUpkey.currentState!.validate()) {
                    await controller.signUpUser();
                  }
                },
              ),
            ),
            setHeight(height: 20),
            InkWell(
              onTap: () {
                AppRoutes.navigateRoutes(routeName: AppRouteName.login);
              },
              child: RichText(
                text: TextSpan(
                  text: alreadyHaveAccount,
                  style: CustomTextStyle.customUbuntu(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: questionMark,
                      style: CustomTextStyle.customUbuntu(
                        fontSize: 16,
                        color: AppColors.greyColor,
                      ),
                    ),
                    TextSpan(
                      text: login,
                      style: CustomTextStyle.customUbuntu(
                        fontSize: 18,
                        color: AppColors.blackColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
