import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/appbar_add_button.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/common_widget/common_bottom_sheet.dart';
import 'package:inventory/common_widget/common_nodatafound.dart';
import 'package:inventory/common_widget/common_padding.dart';
import 'package:inventory/helper/set_format_date.dart';
import 'package:inventory/helper/textstyle.dart';
import 'package:inventory/module/add_user/controller/user_role_controller.dart';
import '../../../common_widget/common_button.dart';
import '../../../common_widget/common_progressbar.dart';
import '../../../common_widget/size.dart';
import '../../../common_widget/textfiled.dart';
import '../../../helper/app_message.dart';
import '../../../keys/keys.dart';

class UserRoleView extends GetView<UserRoleController> {
  const UserRoleView({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonAppbar(
      firstActionChild: AppBarAddButton(
        tooltip: 'Add Role',
        onTap: () => addNewCategory(keys: categoryKey),
      ),
      appBarLabel: 'User Roles',
      body: Obx(
        () =>
            controller.isFetchUserRole.value
                ? const CommonProgressBar(color: AppColors.blackColor, size: 30)
                : controller.userRoleList.isNotEmpty
                ? Stack(
                  children: [
                    ListView.builder(
                      padding:
                          SymmetricPadding(
                            horizontal: 12,
                            vertical: 8,
                          ).getPadding(),
                      itemCount: controller.userRoleList.length,
                      itemBuilder: (context, index) {
                        final item = controller.userRoleList[index];
                        return _UserRoleCard(
                          name: item.name ?? '',
                          createdAt: item.createdAt ?? '',
                          isDeleting: controller.isDeleteUserRole,
                          onDelete: () async {
                            await controller.deleteUserRole(item.id ?? '');
                          },
                        );
                      },
                    ),
                    Obx(
                      () =>
                          controller.isDeleteUserRole.value
                              ? BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                child: const CommonProgressBar(
                                  color: AppColors.blackColor,
                                  size: 50,
                                ),
                              )
                              : const SizedBox.shrink(),
                    ),
                  ],
                )
                : CommonNoDataFound(message: 'No roles found'),
      ),
    );
  }

  void addNewCategory({required GlobalKey<FormState> keys}) {
    commonBottomSheet(
      label: 'Add User Role',
      onPressed: () {
        Get.back();
        controller.clear();
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Form(
          key: keys,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF6A1B9A).withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: const Color(0xFF6A1B9A).withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.person_badge_plus_fill,
                      size: 18.sp,
                      color: const Color(0xFF6A1B9A),
                    ),
                    setWidth(width: 10),
                    Expanded(
                      child: Text(
                        'Define a role to assign to staff members',
                        style: CustomTextStyle.customOpenSans(
                          fontSize: 12,
                          color: const Color(0xFF6A1B9A),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              setHeight(height: 14),
              CommonTextField(
                hintText: 'e.g. Manager, Cashier',
                label: 'Role Name',
                contentPadding: SymmetricPadding(horizontal: 10).getPadding(),
                controller: controller.role,
                validator: (val) {
                  if (val!.isEmpty) return emptyCategory;
                  return null;
                },
              ),
              setHeight(height: 20),
              Obx(
                () => CommonButton(
                  isLoading: controller.isSaveLoading.value,
                  label: saveButton,
                  onTap: () async {
                    if (keys.currentState!.validate()) {
                      await controller.addUserRole(controller.role.text);
                    }
                  },
                ),
              ),
              setHeight(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

// ── User Role Card ────────────────────────────────────────────────────────────
class _UserRoleCard extends StatelessWidget {
  final String name;
  final String createdAt;
  final VoidCallback onDelete;
  final RxBool isDeleting;

  const _UserRoleCard({
    required this.name,
    required this.createdAt,
    required this.onDelete,
    required this.isDeleting,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.h,
            decoration: BoxDecoration(
              color: const Color(0xFF6A1B9A).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              CupertinoIcons.person_badge_plus_fill,
              color: const Color(0xFF6A1B9A),
              size: 22.sp,
            ),
          ),
          setWidth(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: CustomTextStyle.customPoppin(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                setHeight(height: 3),
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.calendar,
                      size: 11.sp,
                      color: AppColors.greyColor,
                    ),
                    setWidth(width: 3),
                    Text(
                      formatDateTime(createdAt),
                      style: CustomTextStyle.customOpenSans(
                        fontSize: 11,
                        color: AppColors.greyColor,
                      ),
                    ),
                    setWidth(width: 6),
                    Text(
                      formatDateTime(
                        createdAt,
                        showTime: true,
                        showDate: false,
                      ),
                      style: CustomTextStyle.customOpenSans(
                        fontSize: 11,
                        color: AppColors.greyColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Obx(
            () => InkWell(
              onTap: isDeleting.value ? null : onDelete,
              borderRadius: BorderRadius.circular(8.r),
              child: Container(
                width: 36.w,
                height: 36.h,
                decoration: BoxDecoration(
                  color: AppColors.redColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  CupertinoIcons.delete,
                  size: 18.sp,
                  color: AppColors.redColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
