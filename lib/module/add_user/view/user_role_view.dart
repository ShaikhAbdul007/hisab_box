import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/common_widget/common_bottom_sheet.dart';
import 'package:inventory/common_widget/common_container.dart';
import 'package:inventory/common_widget/common_nodatafound.dart';
import 'package:inventory/common_widget/common_padding.dart';
import 'package:inventory/helper/set_format_date.dart';
import 'package:inventory/module/add_user/controller/user_role_controller.dart';
import '../../../common_widget/common_button.dart';
import '../../../common_widget/common_progressbar.dart';
import '../../../common_widget/size.dart';
import '../../../common_widget/textfiled.dart';
import '../../../helper/app_message.dart';
import '../../../helper/textstyle.dart';
import '../../../keys/keys.dart';

class UserRoleView extends GetView<UserRoleController> {
  const UserRoleView({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonAppbar(
      firstActionChild: CommonContainer(
        height: 30,
        width: 40,
        radius: 5,
        color: AppColors.whiteLigthColor,
        child: InkWell(
          onTap: () {
            addNewCategory(keys: categoryKey);
          },
          child: Icon(CupertinoIcons.add),
        ),
      ),
      appBarLabel: 'User Role',
      body: Obx(
        () =>
            controller.isFetchUserRole.value
                ? CommonProgressBar(color: AppColors.blackColor, size: 30)
                : controller.userRoleList.isNotEmpty
                ? Stack(
                  children: [
                    ListView.builder(
                      itemCount: controller.userRoleList.length,
                      itemBuilder: (context, index) {
                        var list = controller.userRoleList[index];

                        return CustomPadding(
                          paddingOption: SymmetricPadding(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadiusGeometry.circular(15.r),
                            ),
                            tileColor: AppColors.whiteLigthColor,
                            title: Text(
                              list.name ?? '',
                              style: CustomTextStyle.customNato(
                                fontSize: 18,
                                color: AppColors.blackColor,
                              ),
                            ),
                            subtitle: Row(
                              children: [
                                Text(
                                  formatDateTime(list.createdAt ?? ''),
                                  style: CustomTextStyle.customNato(),
                                ),
                                setWidth(width: 25),
                                Text(
                                  formatDateTime(
                                    list.createdAt ?? '',
                                    showTime: true,
                                    showDate: false,
                                  ),
                                  style: CustomTextStyle.customNato(),
                                ),
                              ],
                            ),
                            trailing: Obx(
                              () => InkWell(
                                onTap:
                                    controller.isDeleteUserRole.value
                                        ? null
                                        : () async {
                                          await controller.deleteUserRole(
                                            list.id ?? '',
                                          );
                                        },
                                child: CommonContainer(
                                  height: 30,
                                  width: 35,
                                  radius: 5,
                                  color: AppColors.buttonRedColor,
                                  child: Icon(
                                    CupertinoIcons.delete,
                                    size: 18,
                                    color: AppColors.whiteColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    Obx(
                      () =>
                          controller.isDeleteUserRole.value
                              ? BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                child: CommonProgressBar(
                                  color: AppColors.blackColor,
                                  size: 50,
                                ),
                              )
                              : Container(),
                    ),
                  ],
                )
                : CommonNoDataFound(message: 'No category found'),
      ),
    );
  }

  void addNewCategory({required GlobalKey<FormState> keys}) {
    commonBottomSheet(
      label: 'Set Role',
      onPressed: () {
        Get.back();
        controller.clear();
      },
      child: Form(
        key: keys,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CommonTextField(
              hintText: 'Role',
              label: 'Role',
              contentPadding: SymmetricPadding(horizontal: 10).getPadding(),
              controller: controller.role,
              validator: (val) {
                if (val!.isEmpty) {
                  return emptyCategory;
                } else {
                  return null;
                }
              },
            ),
            setHeight(height: 30),
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
            setHeight(height: 80),
          ],
        ),
      ),
    );
  }
}
