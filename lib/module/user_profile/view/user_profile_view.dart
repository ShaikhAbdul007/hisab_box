import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/common_widget/common_button.dart';
import 'package:inventory/common_widget/common_progressbar.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/common_widget/textfiled.dart';
import 'package:inventory/module/user_profile/controller/user_profile_controller.dart';
import '../../../helper/textstyle.dart';
import '../../../keys/keys.dart';

class UserProfileView extends GetView<UserProfileController> {
  const UserProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonAppbar(
      appBarLabel: 'User Profile',
      firstActionChild: CommonButton(
        width: 80,
        label: 'Edit',
        onTap: () {
          controller.readOnly.value = !controller.readOnly.value;
        },
      ),
      backgroundColor: AppColors.whiteColor,
      body: Obx(
        () => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child:
              controller.isDataLoading.value
                  ? CommonProgressbar(color: AppColors.blackColor)
                  : Form(
                    key: userProfile,
                    child: ListView(
                      children: [
                        setHeight(height: 20),
                        Stack(
                          alignment: AlignmentGeometry.center,
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.blackColor,
                              radius: 75,
                              child: Text(
                                "H",
                                style: CustomTextStyle.customRaleway(
                                  fontSize: 40,
                                  color: AppColors.whiteColor,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 100,
                              left: 240,
                              child: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.greyColorShade100,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: IconButton(
                                  onPressed: () {},
                                  icon: Icon(
                                    Icons.edit,
                                    color: AppColors.blackColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        setHeight(height: 30),
                        UserProfileWidget(
                          readOnly: controller.readOnly.value,
                          controller2: controller.emailController,
                          controller: controller.shopNameController,
                          label2: 'Email',
                          label: 'Shop Name',
                        ),
                        setHeight(height: 15),
                        UserProfileWidget(
                          readOnly: controller.readOnly.value,
                          controller2: controller.alternativeMobileController,
                          controller: controller.mobileController,
                          label2: 'Alternative No',
                          label: 'Mobile No',
                        ),
                        setHeight(height: 15),
                        CommonTextField(
                          readOnly: controller.readOnly.value,
                          label: 'Address',
                          hintText: 'Address',
                          controller: controller.addressController,
                        ),
                        setHeight(height: 15),
                        CommonTextField(
                          readOnly: controller.readOnly.value,
                          label: 'State',
                          hintText: 'State',
                          controller: controller.stateController,
                        ),
                        setHeight(height: 15),
                        UserProfileWidget(
                          readOnly: controller.readOnly.value,
                          controller2: controller.pincodeController,
                          controller: controller.cityController,
                          label2: 'Pincode',
                          label: 'City',
                        ),
                        setHeight(height: 35),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 28.0),
                          child: Obx(
                            () =>
                                controller.readOnly.value
                                    ? Container()
                                    : CommonButton(
                                      isLoading: controller.isLoading.value,
                                      label: 'Save',
                                      onTap: () {
                                        controller.updateUserDetails();
                                      },
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
        ),
      ),
    );
  }
}

class UserProfileWidget extends StatelessWidget {
  final String label;
  final String label2;
  final bool readOnly;
  final TextEditingController controller;
  final TextEditingController controller2;
  const UserProfileWidget({
    super.key,
    required this.label,
    this.readOnly = true,
    required this.label2,
    required this.controller,
    required this.controller2,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CommonTextField(
            readOnly: readOnly,
            label: label,
            hintText: label,
            controller: controller,
          ),
        ),
        Expanded(
          child: CommonTextField(
            readOnly: readOnly,
            label: label2,
            hintText: label2,
            controller: controller2,
          ),
        ),
      ],
    );
  }
}
