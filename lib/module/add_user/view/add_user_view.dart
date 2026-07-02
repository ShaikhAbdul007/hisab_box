import 'package:flutter/cupertino.dart';
import 'package:inventory/responsive_layout/dimension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/common_widget/common_button.dart';
import 'package:inventory/common_widget/common_dropdown.dart';
import 'package:inventory/common_widget/common_padding.dart';
import 'package:inventory/common_widget/common_progressbar.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/common_widget/textfiled.dart';
import 'package:inventory/helper/app_message.dart';
import 'package:inventory/helper/helper.dart';
import 'package:inventory/helper/textstyle.dart';
import 'package:inventory/keys/keys.dart';
import 'package:inventory/module/add_user/controller/add_user_controller.dart';
import 'package:inventory/module/add_user/widgets/permission_widgets.dart';

class AddUserView extends GetView<AddUserController> {
  const AddUserView({super.key});

  @override
  Widget build(BuildContext context) {
    if (isDesktop(context)) {
      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: const Text('Add User'),
          leading: IconButton(
            icon: const Icon(CupertinoIcons.back),
            onPressed: () => Get.back(),
          ),
          surfaceTintColor: AppColors.greyColorShade100,
          backgroundColor: AppColors.greyColorShade100,
        ),
        body: Form(
          key: inventoryScanKey,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column (flex 3): User Form Details
                Expanded(
                  flex: 3,
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _FormCard(
                        icon: CupertinoIcons.person_fill,
                        iconColor: const Color(0xFF1565C0),
                        title: 'Staff Information',
                        children: [
                          CommonTextField(
                            label: 'Staff Name',
                            hintText: 'e.g. Rahul Sharma',
                            controller: controller.nameController,
                            validator: (v) {
                              if (v!.isEmpty) return emptyName;
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          CommonTextField(
                            textCapitalization: TextCapitalization.none,
                            label: 'Email',
                            hintText: 'e.g. rahul@example.com',
                            controller: controller.emailController,
                            validator: (v) {
                              if (v!.isEmpty) return emptyEmail;
                              if (!GetUtils.isEmail(v)) return invalidEmail;
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          CommonTextField(
                            label: 'Mobile No',
                            hintText: '10-digit mobile number',
                            controller: controller.mobileController,
                            keyboardType: TextInputType.phone,
                            inputLength: 10,
                            validator: (v) {
                              if (v!.isEmpty) return emptyMobileNo;
                              if (v.length < 10) return mobileLength;
                              return null;
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _FormCard(
                        icon: CupertinoIcons.person_badge_plus_fill,
                        iconColor: const Color(0xFF6A1B9A),
                        title: 'Assign Role',
                        children: [
                          Obx(
                            () => controller.isFetchUserRole.value
                                ? const CommonProgressBar()
                                : controller.userRoleList.isEmpty
                                    ? CustomDropDown(
                                        listItems: controller.userRoleList,
                                        hintText: 'Add a user role first in Settings',
                                        notifyParent: (v) {
                                          controller.selectedRole.value = v ?? '';
                                          unfocus();
                                        },
                                      )
                                    : CustomDropDown(
                                        listItems: controller.userRoleList,
                                        hintText: 'Select Role',
                                        notifyParent: (v) {
                                          controller.selectedRole.value = v!;
                                          unfocus();
                                        },
                                      ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Obx(
                        () => CommonButton(
                          isLoading: controller.isSaveLoading.value,
                          label: 'Create User',
                          onTap: () async {
                            if (inventoryScanKey.currentState!.validate()) {
                              final Map<String, dynamic> permissionData = {};
                              controller.permissions.forEach((key, value) {
                                permissionData[key] = value.value;
                              });
                              final Map<String, dynamic> finalData = {
                                'name': controller.nameController.text.trim(),
                                'email': controller.emailController.text.trim(),
                                'mobile_no': controller.mobileController.text.trim(),
                                'password': 'Password@123',
                                'role_id': controller.selectedRole.value,
                                'permissions': permissionData,
                              };
                              await controller.addUserRole(body: finalData);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                // Right Column (flex 2): Permissions Checklist
                Expanded(
                  flex: 2,
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _PermissionsSection(controller: controller),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return CommonAppbar(
      appBarLabel: 'Add User',
      body: Form(
        key: inventoryScanKey,
        child: ListView(
          padding: SymmetricPadding(horizontal: 16, vertical: 16).getPadding(),
          children: [
            // ── Staff Info Card ──────────────────────────────────────────
            _FormCard(
              icon: CupertinoIcons.person_fill,
              iconColor: const Color(0xFF1565C0),
              title: 'Staff Information',
              children: [
                CommonTextField(
                  label: 'Staff Name',
                  hintText: 'e.g. Rahul Sharma',
                  controller: controller.nameController,
                  validator: (v) {
                    if (v!.isEmpty) return emptyName;
                    return null;
                  },
                ),
                setHeight(height: 8),
                CommonTextField(
                  textCapitalization: TextCapitalization.none,
                  label: 'Email',
                  hintText: 'e.g. rahul@example.com',
                  controller: controller.emailController,
                  validator: (v) {
                    if (v!.isEmpty) return emptyEmail;
                    if (!GetUtils.isEmail(v)) return invalidEmail;
                    return null;
                  },
                ),
                setHeight(height: 8),
                CommonTextField(
                  label: 'Mobile No',
                  hintText: '10-digit mobile number',
                  controller: controller.mobileController,
                  keyboardType: TextInputType.phone,
                  inputLength: 10,
                  validator: (v) {
                    if (v!.isEmpty) return emptyMobileNo;
                    if (v.length < 10) return mobileLength;
                    return null;
                  },
                ),
              ],
            ),
            setHeight(height: 16),

            // ── Role Card ────────────────────────────────────────────────
            _FormCard(
              icon: CupertinoIcons.person_badge_plus_fill,
              iconColor: const Color(0xFF6A1B9A),
              title: 'Assign Role',
              children: [
                Obx(
                  () =>
                      controller.isFetchUserRole.value
                          ? const CommonProgressBar()
                          : controller.userRoleList.isEmpty
                          ? CustomDropDown(
                            listItems: controller.userRoleList,
                            hintText: 'Add a user role first in Settings',
                            notifyParent: (v) {
                              controller.selectedRole.value = v ?? '';
                              unfocus();
                            },
                          )
                          : CustomDropDown(
                            listItems: controller.userRoleList,
                            hintText: 'Select Role',
                            notifyParent: (v) {
                              controller.selectedRole.value = v!;
                              unfocus();
                            },
                          ),
                ),
              ],
            ),
            setHeight(height: 16),

            // ── Permissions ──────────────────────────────────────────────
            _PermissionsSection(controller: controller),
            setHeight(height: 24),

            // ── Save Button ──────────────────────────────────────────────
            Obx(
              () => CustomPadding(
                paddingOption: SymmetricPadding(horizontal: 20),
                child: CommonButton(
                  isLoading: controller.isSaveLoading.value,
                  label: 'Create User',
                  onTap: () async {
                    if (inventoryScanKey.currentState!.validate()) {
                      final Map<String, dynamic> permissionData = {};
                      controller.permissions.forEach((key, value) {
                        permissionData[key] = value.value;
                      });
                      final Map<String, dynamic> finalData = {
                        'name': controller.nameController.text.trim(),
                        'email': controller.emailController.text.trim(),
                        'mobile_no': controller.mobileController.text.trim(),
                        'password': 'Password@123',
                        'role_id': controller.selectedRole.value,
                        'permissions': permissionData,
                      };
                      await controller.addUserRole(body: finalData);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
    final bool desktop = isDesktop(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(desktop ? 14 : 14.r),
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
                width: desktop ? 36 : 36.w,
                height: desktop ? 36 : 36.h,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(desktop ? 10 : 10.r),
                ),
                child: Icon(icon, color: iconColor, size: desktop ? 18 : 18.sp),
              ),
              desktop ? const SizedBox(width: 10) : setWidth(width: 10),
              Text(
                title,
                style: CustomTextStyle.customPoppin(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          desktop ? const SizedBox(height: 14) : setHeight(height: 14),
          ...children,
        ],
      ),
    );
  }
}

// ── Permissions Section ───────────────────────────────────────────────────────
class _PermissionsSection extends StatelessWidget {
  final AddUserController controller;
  const _PermissionsSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    final bool desktop = isDesktop(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(desktop ? 14 : 14.r),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Container(
                  width: desktop ? 36 : 36.w,
                  height: desktop ? 36 : 36.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00695C).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(desktop ? 10 : 10.r),
                  ),
                  child: Icon(
                    CupertinoIcons.lock_shield_fill,
                    color: const Color(0xFF00695C),
                    size: desktop ? 18 : 18.sp,
                  ),
                ),
                desktop ? const SizedBox(width: 10) : setWidth(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Permissions',
                      style: CustomTextStyle.customPoppin(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Control what this user can access',
                      style: CustomTextStyle.customOpenSans(
                        fontSize: 12,
                        color: AppColors.greyColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade100),
          PermissionWidgets(
            title: 'Sales & Customers',
            keys: [
              'p_customer_list',
              'p_credit_list',
              'p_reconcile_credit',
              'p_see_today_sale',
              'p_see_today_sale_detail',
            ],
            permissions: controller.permissions,
          ),
          PermissionWidgets(
            title: 'Revenue & Reports',
            keys: [
              'p_see_revenue',
              'p_see_received_cash',
              'p_see_received_credit',
              'p_see_received_card',
              'p_see_received_upi',
              'p_see_report',
            ],
            permissions: controller.permissions,
          ),
          PermissionWidgets(
            title: 'Inventory Management',
            keys: [
              'p_add_product',
              'p_add_manual_product',
              'p_delete_product',
              'p_edit_product_details',
              'p_add_loose_product',
              'p_transfer_godown_to_shop',
            ],
            permissions: controller.permissions,
          ),
          PermissionWidgets(
            title: 'Admin Settings',
            keys: ['p_add_user', 'p_add_bank_details', 'p_edit_profile'],
            permissions: controller.permissions,
          ),
          desktop ? const SizedBox(height: 8) : setHeight(height: 8),
        ],
      ),
    );
  }
}
