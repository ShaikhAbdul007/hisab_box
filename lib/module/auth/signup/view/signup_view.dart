import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/common_padding.dart';
import 'package:inventory/module/auth/signup/widget/shop_address_widget.dart';
import 'package:inventory/routes/routes.dart';
import '../../../../common_widget/colors.dart';
import '../../../../common_widget/commom_aminatedtext.dart';
import '../../../../common_widget/common_button.dart';
import '../../../../common_widget/size.dart';
import '../../../../helper/app_message.dart';
import '../../../../helper/textstyle.dart';
import '../../../../keys/keys.dart';
import '../../../../routes/route_name.dart';
import '../controller/signup_controller.dart';
import '../widget/shop_details_widget.dart';

class SignupView extends GetView<SignupController> {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyColorShade100,
      body: CustomPadding(
        paddingOption: SymmetricPadding(horizontal: 20, vertical: 40),
        child: Obx(
          () => ListView(
            children: [
              Row(
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
                  setWidth(width: 15),
                  CommomAminatedtext(
                    label: 'Create Account',
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                  ),
                ],
              ),
              setHeight(height: 10),
              Text(
                createAccountSubtitle,
                style: CustomTextStyle.customOpenSans(
                  color: AppColors.greyColor,
                ),
              ),
              setHeight(height: 10),
              Form(
                key: shopAddress,
                child:
                    controller.isShopDetailFilled.value
                        ? Obx(
                          () => ShopAddress(
                            notifyParent: (v) {
                              controller.shopType.text = v;
                            },
                            profileImage:
                                controller.profileImage.value ??
                                File(controller.profileImage.value?.path ?? ''),
                            onPressed: () => controller.pickImage(),
                            shopName: controller.name,
                            address: controller.address,
                            city: controller.city,
                            state: controller.state,
                            pincode: controller.pincode,
                          ),
                        )
                        : ShopDetails(
                          password: controller.password,
                          confirmpassword: controller.confirmpassword,
                          mobileNo: controller.mobileNo,
                          email: controller.email,
                          alternateMobileNo: controller.alternateMobileNo,
                          obscureText: controller.obscureTextValue.value,
                          onTap: () {
                            controller.setobscureTextValue();
                          },
                        ),
              ),
              setHeight(height: 20),
              Obx(
                () =>
                    !controller.isShopDetailFilled.value
                        ? CommonButton(
                          isLoading: controller.signUpLoading.value,
                          label:
                              controller.isShopDetailFilled.value
                                  ? 'Save'
                                  : 'Continue',
                          onTap: () async {
                            if (shopAddress.currentState!.validate()) {
                              controller.isShopDetailFilled.value = true;
                            }
                          },
                        )
                        : CommonButton(
                          isLoading: controller.signUpLoading.value,
                          label: 'Save',
                          onTap: () async {
                            if (shopAddress.currentState!.validate()) {
                              await controller.signUpUser();
                            }
                          },
                        ),
              ),
              setHeight(height: 5),
              InkWell(
                onTap: () {
                  AppRoutes.navigateRoutes(routeName: AppRouteName.login);
                },
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: alreadyHaveAccount,
                    style: CustomTextStyle.customOpenSans(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: questionMark,
                        style: CustomTextStyle.customOpenSans(
                          fontSize: 16,
                          color: AppColors.greyColor,
                        ),
                      ),
                      TextSpan(
                        text: login,
                        style: CustomTextStyle.customOpenSans(
                          fontSize: 18,
                          color: AppColors.blackColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              setHeight(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
