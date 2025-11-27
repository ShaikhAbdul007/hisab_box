import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/commom_aminatedtext.dart';
import 'package:inventory/common_widget/common_button.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/common_widget/textfiled.dart';
import 'package:inventory/helper/textstyle.dart';
import 'package:inventory/routes/route_name.dart';
import 'package:inventory/routes/routes.dart';
import '../../../../helper/app_message.dart';
import '../../../../keys/keys.dart';
import '../controller/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: loginkey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          //crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CommomAminatedtext(
                  label: welcomeBack,
                  fontSize: 25,
                  color: AppColors.greyColor,
                  fontWeight: FontWeight.w900,
                ),
                CommomAminatedtext(
                  label: backtoAppName,
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                ),
                setHeight(height: 10),
                Text(
                  loginSubtitle,
                  style: CustomTextStyle.customUbuntu(
                    color: AppColors.greyColor,
                  ),
                ),
              ],
            ),
            setHeight(height: 25),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
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
                  Obx(
                    () => CommonTextField(
                      obscureText: controller.obscureTextValue.value,
                      hintText: 'Password',
                      label: 'Password',
                      controller: controller.password,
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
                        } else {
                          return null;
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            setHeight(height: 15),
            Obx(
              () => CommonButton(
                isLoading: controller.loginLoading.value,
                label: login,
                onTap: () async {
                  if (loginkey.currentState!.validate()) {
                    await controller.loginUser();
                  }
                },
              ),
            ),
            setHeight(height: 20),
            InkWell(
              onTap: () {
                AppRoutes.navigateRoutes(routeName: AppRouteName.signup);
              },
              child: RichText(
                text: TextSpan(
                  text: dontHaveAccount,
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
                      text: createAccount,
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
