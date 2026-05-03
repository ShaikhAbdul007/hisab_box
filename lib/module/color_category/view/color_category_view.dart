import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/common_widget/common_bottom_sheet.dart';
import 'package:inventory/common_widget/common_button.dart';
import 'package:inventory/common_widget/common_container.dart';
import 'package:inventory/common_widget/common_nodatafound.dart';
import 'package:inventory/common_widget/common_padding.dart';
import 'package:inventory/common_widget/common_progressbar.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/common_widget/textfiled.dart';
import 'package:inventory/helper/app_message.dart';
import 'package:inventory/helper/set_format_date.dart';
import 'package:inventory/helper/textstyle.dart';
import 'package:inventory/keys/keys.dart';
import 'package:inventory/module/color_category/controller/color_category_controller.dart';

class ColorCategoryView extends GetView<ColorCategoryController> {
  const ColorCategoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonAppbar(
      appBarLabel: 'Color Category',
      firstActionChild: CommonContainer(
        height: 30,
        width: 40,
        radius: 5,
        color: AppColors.whiteColor,
        child: InkWell(
          onTap: () => _addColorSheet(keys: categoryKey),
          child: const Icon(CupertinoIcons.add),
        ),
      ),
      body: Obx(
        () =>
            controller.isFetchLoading.value
                ? CommonProgressBar(color: AppColors.blackColor, size: 30)
                : controller.colorList.isNotEmpty
                ? Stack(
                  children: [
                    ListView.builder(
                      controller: controller.scrollController,
                      itemCount: controller.colorList.length + 1,
                      itemBuilder: (context, index) {
                        // Bottom loader
                        if (index == controller.colorList.length) {
                          return Obx(
                            () =>
                                controller.isLoadingMore.value
                                    ? const Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      child: Center(
                                        child: CommonProgressBar(
                                          size: 30,
                                          color: AppColors.blackColor,
                                        ),
                                      ),
                                    )
                                    : const SizedBox(height: 16),
                          );
                        }
                        final item = controller.colorList[index];
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
                              item.name ?? '',
                              style: CustomTextStyle.customNato(
                                fontSize: 18,
                                color: AppColors.blackColor,
                              ),
                            ),
                            subtitle: Row(
                              children: [
                                Text(
                                  formatDateTime(item.createdAt ?? ''),
                                  style: CustomTextStyle.customNato(),
                                ),
                                setWidth(width: 25),
                                Text(
                                  formatDateTime(
                                    item.createdAt ?? '',
                                    showDate: false,
                                    showTime: true,
                                  ),
                                  style: CustomTextStyle.customNato(),
                                ),
                              ],
                            ),
                            trailing: Obx(
                              () => InkWell(
                                onTap:
                                    controller.isDeleteLoading.value
                                        ? null
                                        : () async {
                                          await controller.deleteColor(
                                            item.id ?? '',
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
                          controller.isDeleteLoading.value
                              ? BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                child: CommonProgressBar(
                                  color: AppColors.blackColor,
                                  size: 50,
                                ),
                              )
                              : const SizedBox.shrink(),
                    ),
                  ],
                )
                : CommonNoDataFound(message: 'No color category found'),
      ),
    );
  }

  void _addColorSheet({required GlobalKey<FormState> keys}) {
    commonBottomSheet(
      label: 'Add Color Category',
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
              hintText: 'Enter color name',
              label: 'Color',
              contentPadding: SymmetricPadding(horizontal: 10).getPadding(),
              controller: controller.colorName,
              validator: (val) {
                if (val!.isEmpty) return 'Please enter color name';
                return null;
              },
            ),
            setHeight(height: 30),
            Obx(
              () => CommonButton(
                isLoading: controller.isSaveLoading.value,
                label: saveButton,
                onTap: () async {
                  if (keys.currentState!.validate()) {
                    await controller.addColor(controller.colorName.text);
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
