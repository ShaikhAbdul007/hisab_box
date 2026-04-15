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
          return Center(child: CommonProgressbar(color: AppColors.blackColor));
        }
        return CustomPadding(
          paddingOption: SymmetricPadding(horizontal: 12.0),
          child: Form(
            key: userProfile,
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                setHeight(height: 20),

                // 📸 PROFILE IMAGE SECTION
                Center(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.blackColor,
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: _buildProfileImage(), // Clean helper function
                        ),
                      ),
                      // Edit Button - Only show when not in ReadOnly mode
                      if (!controller.readOnly.value)
                        GestureDetector(
                          onTap: () => controller.pickImage(),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.blackColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                setHeight(height: 30),

                // 📝 FORM FIELDS
                UserProfileWidget(
                  readOnly: controller.readOnly.value,
                  controller: controller.shopNameController,
                  controller2: controller.emailController,
                  label: 'Shop Name',
                  label2: 'Email',
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

                setHeight(height: 40),

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

  // Helper to handle Image Logic
  Widget _buildProfileImage() {
    return Obx(() {
      final file = controller.profileImage.value;
      final url = controller.profileImageUrl.value;

      // 1. Agar user ne abhi gallery se photo pick ki hai (Local File)
      if (file != null && file.existsSync()) {
        return Image.file(
          file,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
          // Key add karne se Flutter ko pata chalta hai ki image change hui hai
          key: ValueKey(file.path),
        );
      }

      // 2. Agar koi local file nahi hai, toh check karo Supabase ka URL hai?
      if (url.isNotEmpty && url.startsWith('http') ||
          url.isNotEmpty && url.startsWith('https')) {
        return Image.network(
          url,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: CupertinoActivityIndicator());
          },
          errorBuilder: (context, error, stack) => _buildPlaceholder(),
        );
      }

      // 3. Agar kuch bhi nahi hai, toh default placeholder
      return _buildPlaceholder();
    });
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Text(
        controller.shopNameController.text.isNotEmpty
            ? controller.shopNameController.text[0].toUpperCase()
            : "👤",
        style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
      ),
    );
  }
}
