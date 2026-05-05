import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/common_widget/common_button.dart';
import 'package:inventory/common_widget/common_padding.dart';
import 'package:inventory/common_widget/common_progressbar.dart';
import 'package:inventory/common_widget/edit_mode_banner.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/common_widget/textfiled.dart';
import 'package:inventory/helper/textstyle.dart';
import 'package:inventory/keys/keys.dart';
import 'package:inventory/module/user_profile/controller/user_profile_controller.dart';

class UserProfileView extends GetView<UserProfileController> {
  const UserProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonAppbar(
      appBarLabel: 'Profile',
      firstActionChild: Obx(
        () => InkWell(
          onTap: () => controller.readOnly.toggle(),
          borderRadius: BorderRadius.circular(8.r),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color:
                  controller.readOnly.value
                      ? Colors.grey.shade100
                      : AppColors.blackColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              controller.readOnly.value
                  ? CupertinoIcons.pencil
                  : CupertinoIcons.checkmark_alt,
              size: 20.sp,
              color:
                  controller.readOnly.value
                      ? AppColors.greyColor
                      : AppColors.blackColor,
            ),
          ),
        ),
      ),
      backgroundColor: AppColors.whiteColor,
      body: Obx(() {
        if (controller.isDataLoading.value) {
          return const Center(
            child: CommonProgressBar(color: AppColors.blackColor),
          );
        }
        return Form(
          key: userProfile,
          child: ListView(
            padding: SymmetricPadding(horizontal: 16, vertical: 0).getPadding(),
            children: [
              // ── Hero header ──────────────────────────────────────────
              _ProfileHeader(controller: controller),
              setHeight(height: 16),

              // ── Edit mode banner ─────────────────────────────────────
              EditModeBanner(
                readOnly: controller.readOnly,
                readOnlyMessage:
                    'Tap the edit icon (top right) to update your profile.',
                editingMessage:
                    'You are in edit mode. Make changes and tap Save.',
              ),
              setHeight(height: 16),

              // ── Shop info card ───────────────────────────────────────
              _FormCard(
                icon: CupertinoIcons.building_2_fill,
                iconColor: const Color(0xFF1565C0),
                title: 'Shop Information',
                children: [
                  CommonTextField(
                    readOnly: true,
                    label: 'Shop Name',
                    hintText: 'Shop Name',
                    controller: controller.shopNameController,
                  ),
                  setHeight(height: 8),
                  CommonTextField(
                    readOnly: true,
                    label: 'Shop Type',
                    hintText: 'Shop Type',
                    controller: controller.shopType,
                  ),
                  setHeight(height: 8),
                  CommonTextField(
                    readOnly: true,
                    label: 'Email',
                    hintText: 'Email',
                    controller: controller.emailController,
                  ),
                ],
              ),
              setHeight(height: 16),

              // ── Contact card ─────────────────────────────────────────
              Obx(
                () => _FormCard(
                  icon: CupertinoIcons.phone_fill,
                  iconColor: const Color(0xFF2E7D32),
                  title: 'Contact',
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: CommonTextField(
                            readOnly: controller.readOnly.value,
                            label: 'Mobile No',
                            hintText: 'Mobile No',
                            controller: controller.mobileController,
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                        setWidth(width: 10),
                        Expanded(
                          child: CommonTextField(
                            readOnly: controller.readOnly.value,
                            label: 'Alternative No',
                            hintText: 'Alternative No',
                            controller: controller.alternativeMobileController,
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              setHeight(height: 16),

              // ── Address card ─────────────────────────────────────────
              Obx(
                () => _FormCard(
                  icon: CupertinoIcons.map_pin,
                  iconColor: const Color(0xFFE65100),
                  title: 'Address',
                  children: [
                    CommonTextField(
                      readOnly: controller.readOnly.value,
                      label: 'Address',
                      hintText: 'Full Address',
                      controller: controller.addressController,
                    ),
                    setHeight(height: 8),
                    CommonTextField(
                      readOnly: controller.readOnly.value,
                      label: 'State',
                      hintText: 'State',
                      controller: controller.stateController,
                    ),
                    setHeight(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: CommonTextField(
                            readOnly: controller.readOnly.value,
                            label: 'City',
                            hintText: 'City',
                            controller: controller.cityController,
                          ),
                        ),
                        setWidth(width: 10),
                        Expanded(
                          child: CommonTextField(
                            readOnly: controller.readOnly.value,
                            label: 'Pincode',
                            hintText: 'Pincode',
                            controller: controller.pincodeController,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              setHeight(height: 24),

              // ── Save button ──────────────────────────────────────────
              Obx(
                () =>
                    controller.readOnly.value
                        ? const SizedBox.shrink()
                        : CustomPadding(
                          paddingOption: SymmetricPadding(horizontal: 20),
                          child: CommonButton(
                            isLoading: controller.isLoading.value,
                            label: 'Save Changes',
                            onTap: () => controller.updateUserDetails(),
                          ),
                        ),
              ),
              setHeight(height: 30),
            ],
          ),
        );
      }),
    );
  }
}

// ── Profile Header ────────────────────────────────────────────────────────────
class _ProfileHeader extends StatelessWidget {
  final UserProfileController controller;
  const _ProfileHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.blackColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        children: [
          // Avatar
          Obx(() {
            final bool isEditing = !controller.readOnly.value;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                _buildAvatar(),
                if (isEditing)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => controller.pickImage(),
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.blackColor,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Icon(
                          CupertinoIcons.camera_fill,
                          color: AppColors.blackColor,
                          size: 16.sp,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }),
          setHeight(height: 14),

          // Name
          Text(
            controller.shopNameController.text.isNotEmpty
                ? controller.shopNameController.text
                : 'Your Shop',
            style: CustomTextStyle.customPoppin(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          setHeight(height: 4),

          // Email
          Text(
            controller.emailController.text,
            style: CustomTextStyle.customOpenSans(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.65),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          setHeight(height: 10),

          // Shop type badge
          if (controller.shopType.text.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
              ),
              child: Text(
                controller.shopType.text,
                style: CustomTextStyle.customOpenSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Obx(() {
      final file = controller.profileImage.value;
      final url = controller.profileImageUrl.value.trim();
      final name = controller.shopNameController.text;
      final initials = name.isNotEmpty ? name[0].toUpperCase() : 'HB';

      if (file != null && file.existsSync()) {
        return CircleAvatar(
          radius: 52.r,
          backgroundImage: FileImage(file),
          key: ValueKey(file.path),
        );
      }

      if (url.isNotEmpty) {
        return CircleAvatar(
          radius: 52.r,
          backgroundColor: Colors.white.withValues(alpha: 0.2),
          child: ClipOval(
            child: Image.network(
              url,
              width: 104.w,
              height: 104.h,
              fit: BoxFit.cover,
              loadingBuilder:
                  (context, child, progress) =>
                      progress == null
                          ? child
                          : const CupertinoActivityIndicator(
                            color: Colors.white,
                          ),
              errorBuilder:
                  (_, __, ___) => Text(
                    initials,
                    style: TextStyle(
                      fontSize: 38.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            ),
          ),
        );
      }

      return CircleAvatar(
        radius: 52.r,
        backgroundColor: Colors.white.withValues(alpha: 0.2),
        child: Text(
          initials,
          style: TextStyle(
            fontSize: 38.sp,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    });
  }
}

// ── Form Card ─────────────────────────────────────────────────────────────────
class _FormCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final List<Widget> children;

  const _FormCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36.w,
                height: 36.h,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, color: iconColor, size: 18.sp),
              ),
              setWidth(width: 10),
              Text(
                title,
                style: CustomTextStyle.customPoppin(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          setHeight(height: 14),
          ...children,
        ],
      ),
    );
  }
}
