import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/common_widget/common_button.dart';
import 'package:inventory/common_widget/common_padding.dart';
import 'package:inventory/common_widget/common_progressbar.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/common_widget/textfiled.dart';
import 'package:inventory/keys/keys.dart';
import 'package:inventory/module/user_profile/controller/user_profile_controller.dart';
import 'package:inventory/module/user_profile/widget/user_profile_widget.dart';

class UserProfileView extends GetView<UserProfileController> {
  const UserProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonAppbar(
      appBarLabel: 'User Profile',
      firstActionChild: IconButton(
        onPressed: () => controller.readOnly.toggle(), // Toggle edit mode
        icon: Obx(
          () => Icon(
            CupertinoIcons.square_pencil_fill,
            color:
                controller.readOnly.value
                    ? AppColors.blackColor
                    : AppColors.redColor,
          ),
        ),
      ),
      backgroundColor: AppColors.whiteColor,
      body: Obx(() {
        if (controller.isDataLoading.value) {
          return Center(child: CommonProgressBar(color: AppColors.blackColor));
        }
        return CustomPadding(
          paddingOption: SymmetricPadding(horizontal: 12.0),
          child: Form(
            key: userProfile,
            child: ListView(
              children: [
                setHeight(height: 20),

                // 📸 PROFILE IMAGE SECTION
                Center(
                  child: Obx(() {
                    final bool isEditing = !controller.readOnly.value;
                    return Stack(
                      children: [
                        // Avatar — same size as SettingView (radius 50)
                        _buildProfileAvatar(),
                        // Camera icon — only in edit mode
                        if (isEditing)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () => controller.pickImage(),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.blackColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  }),
                ),
                setHeight(height: 10),
                UserProfileWidget(
                  readOnly: true,
                  controller: controller.shopNameController,
                  controller2: controller.shopType,
                  label: 'Shop Name',
                  label2: 'shop Type',
                ),
                setHeight(height: 10),
                CommonTextField(
                  readOnly: true,
                  label: 'Email',
                  hintText: 'Email',
                  controller: controller.emailController,
                ),
                setHeight(height: 10),
                UserProfileWidget(
                  readOnly: controller.readOnly.value,
                  controller: controller.mobileController,
                  controller2: controller.alternativeMobileController,
                  label: 'Mobile No',
                  label2: 'Alternative No',
                ),
                setHeight(height: 10),
                CommonTextField(
                  readOnly: controller.readOnly.value,
                  label: 'Address',
                  hintText: 'Full Address',
                  controller: controller.addressController,
                ),
                setHeight(height: 10),
                CommonTextField(
                  readOnly: controller.readOnly.value,
                  label: 'State',
                  hintText: 'State',
                  controller: controller.stateController,
                ),
                setHeight(height: 10),
                UserProfileWidget(
                  readOnly: controller.readOnly.value,
                  controller: controller.cityController,
                  controller2: controller.pincodeController,
                  label: 'City',
                  label2: 'Pincode',
                ),

                setHeight(height: 20),

                // 💾 SAVE BUTTON
                if (!controller.readOnly.value)
                  CustomPadding(
                    paddingOption: SymmetricPadding(horizontal: 20.0),
                    child: CommonButton(
                      isLoading: controller.isLoading.value,
                      label: 'Save',
                      onTap: () => controller.updateUserDetails(),
                    ),
                  ),
                setHeight(height: 20),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ── Profile avatar — same logic as SettingView ──────────────────────────
  Widget _buildProfileAvatar() {
    return Obx(() {
      final file = controller.profileImage.value;
      final url = controller.profileImageUrl.value.trim();
      final name = controller.shopNameController.text;
      final initials = name.isNotEmpty ? name[0].toUpperCase() : 'HB';

      // 1. Local picked file
      if (file != null && file.existsSync()) {
        return CircleAvatar(
          radius: 50,
          backgroundImage: FileImage(file),
          key: ValueKey(file.path),
        );
      }

      // 2. Network image from API
      if (url.isNotEmpty) {
        return CircleAvatar(
          radius: 50,
          backgroundColor: AppColors.blackColor,
          child: ClipOval(
            child: Image.network(
              url,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              loadingBuilder:
                  (context, child, progress) =>
                      progress == null
                          ? child
                          : const CupertinoActivityIndicator(),
              errorBuilder:
                  (_, __, ___) => Text(
                    initials,
                    style: const TextStyle(
                      fontSize: 40,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            ),
          ),
        );
      }

      // 3. Fallback — initials
      return CircleAvatar(
        radius: 50,
        backgroundColor: AppColors.blackColor,
        child: Text(
          initials,
          style: const TextStyle(
            fontSize: 40,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    });
  }
}
