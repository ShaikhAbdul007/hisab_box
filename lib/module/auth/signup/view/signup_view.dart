import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
import 'shop_details.dart';

class SignupView extends GetView<SignupController> {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15.0, top: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                    style: CustomTextStyle.customUbuntu(
                      color: AppColors.greyColor,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(
                () => Stepper(
                  type: StepperType.horizontal,
                  elevation: 0,
                  currentStep: controller.currentStepperIndex.value,
                  onStepTapped: (int index) {
                    controller.currentStepperIndex.value = index;
                  },
                  onStepCancel: () {
                    if (controller.currentStepperIndex.value > 0) {
                      controller.currentStepperIndex.value -= 1;
                    }
                  },
                  onStepContinue: () {
                    if (controller.currentStepperIndex.value < 1) {
                      if (shopDetails.currentState!.validate()) {
                        controller.currentStepperIndex.value += 1;
                      }
                    } else {
                      if (shopAddress.currentState!.validate()) {}
                    }
                  },
                  controlsBuilder: (context, details) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          CommonButton(
                            bgColor: AppColors.buttonRedColor,
                            width: 120,
                            label: 'Cancel',
                            onTap: details.onStepCancel!,
                          ),
                          if (controller.currentStepperIndex.value == 1) ...{
                            Obx(
                              () => CommonButton(
                                isLoading: controller.signUpLoading.value,
                                width: 120,
                                label: 'Save',
                                onTap: () {
                                  if (shopAddress.currentState!.validate()) {
                                    controller.signUpUser();
                                  }
                                },
                              ),
                            ),
                          } else ...{
                            CommonButton(
                              width: 120,
                              label: 'Continue',
                              onTap: details.onStepContinue!,
                            ),
                          },
                        ],
                      ),
                    );
                  },
                  steps: [
                    Step(
                      state:
                          controller.currentStepperIndex.value == 0
                              ? StepState.editing
                              : StepState.indexed,
                      isActive: controller.currentStepperIndex.value >= 0,
                      title: Text('Shop Details'),
                      content: Form(
                        key: shopDetails,
                        child: ShopDetails(
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
                    ),
                    Step(
                      state:
                          controller.currentStepperIndex.value == 1
                              ? StepState.editing
                              : StepState.complete,
                      isActive: controller.currentStepperIndex.value >= 1,
                      title: Text('Shop Address'),
                      content: Form(
                        key: shopAddress,
                        child: ShopAddress(
                          address: controller.address,
                          city: controller.city,
                          pincode: controller.pincode,
                          shopName: controller.name,
                          state: controller.state,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
            setHeight(height: 20),
          ],
        ),
      ),
    );
  }
}
