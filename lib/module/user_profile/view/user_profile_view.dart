import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/common_widget/common_button.dart';
import 'package:inventory/common_widget/common_padding.dart';
import 'package:inventory/common_widget/common_progressbar.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/common_widget/textfiled.dart';
import 'package:inventory/module/user_profile/controller/user_profile_controller.dart';
import '../../../keys/keys.dart';

class UserProfileView extends GetView<UserProfileController> {
  const UserProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonAppbar(
      appBarLabel: 'User Profile',
      firstActionChild: InkWell(
        onTap: () {
          controller.readOnly.value = !controller.readOnly.value;
        },
        child: Icon(
          CupertinoIcons.square_pencil_fill,
          color: AppColors.blackColor,
        ),
      ),
      backgroundColor: AppColors.whiteColor,
      body: Obx(
        () => CustomPadding(
          paddingOption: SymmetricPadding(horizontal: 8.0),
          child:
              controller.isDataLoading.value
                  ? CommonProgressbar(color: AppColors.blackColor)
                  : Form(
                    key: userProfile,
                    child: ListView(
                      children: [
                        setHeight(height: 20),
                        Obx(
                          () => Stack(
                            alignment: Alignment.center,
                            children: [
                              CircleAvatar(
                                radius: 55,
                                backgroundColor: Colors.black,
                                child:
                                    controller.profileImage.value != null
                                        ? ClipOval(
                                          child: Image.file(
                                            controller.profileImage.value!,
                                            width: 110,
                                            height: 110,
                                            fit: BoxFit.cover,
                                            errorBuilder: (
                                              context,
                                              error,
                                              stackTrace,
                                            ) {
                                              print(
                                                '🖼️ Image loading error: $error',
                                              );
                                              return Text(
                                                "HB",
                                                style: TextStyle(
                                                  fontSize: 40,
                                                  color: Colors.white,
                                                ),
                                              );
                                            },
                                          ),
                                        )
                                        : Text(
                                          "HB",
                                          style: TextStyle(
                                            fontSize: 40,
                                            color: Colors.white,
                                          ),
                                        ),
                              ),
                              controller.readOnly.value
                                  ? Container()
                                  : Positioned(
                                    top: 70.h,
                                    left: 200.w,
                                    child: Container(
                                      height: 35,
                                      width: 35,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: IconButton(
                                        onPressed: () => controller.pickImage(),
                                        icon: Icon(
                                          Icons.edit,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                            ],
                          ),
                        ),
                        setHeight(height: 30),
                        UserProfileWidget(
                          readOnly: controller.readOnly.value,
                          controller2: controller.emailController,
                          controller: controller.shopNameController,
                          label2: 'Email',
                          label: 'Shop Name',
                        ),
                        setHeight(height: 5),
                        UserProfileWidget(
                          readOnly: controller.readOnly.value,
                          controller2: controller.alternativeMobileController,
                          controller: controller.mobileController,
                          label2: 'Alternative No',
                          label: 'Mobile No',
                        ),
                        setHeight(height: 5),
                        CommonTextField(
                          readOnly: controller.readOnly.value,
                          label: 'Address',
                          hintText: 'Address',
                          controller: controller.addressController,
                        ),
                        setHeight(height: 5),
                        CommonTextField(
                          readOnly: controller.readOnly.value,
                          label: 'State',
                          hintText: 'State',
                          controller: controller.stateController,
                        ),
                        setHeight(height: 5),
                        UserProfileWidget(
                          readOnly: controller.readOnly.value,
                          controller2: controller.pincodeController,
                          controller: controller.cityController,
                          label2: 'Pincode',
                          label: 'City',
                        ),
                        setHeight(height: 25),
                        CustomPadding(
                          paddingOption: SymmetricPadding(horizontal: 28.0),
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
