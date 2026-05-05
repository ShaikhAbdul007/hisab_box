import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/appbar_add_button.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/common_widget/common_bottom_sheet.dart';
import 'package:inventory/common_widget/common_button.dart';
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

class _ColorCategoryCard extends StatelessWidget {
  final String name;
  final String createdAt;
  final VoidCallback onDelete;
  final RxBool isDeleting;

  const _ColorCategoryCard({
    required this.name,
    required this.createdAt,
    required this.onDelete,
    required this.isDeleting,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: SymmetricPadding(horizontal: 12, vertical: 5).getPadding(),
      padding: SymmetricPadding(horizontal: 12, vertical: 10).getPadding(),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
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
              color: Colors.purple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              CupertinoIcons.paintbrush_fill,
              color: Colors.purple,
              size: 22.sp,
            ),
          ),
          setWidth(width: 10),
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
                        showDate: false,
                        showTime: true,
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

class ColorCategoryView extends GetView<ColorCategoryController> {
  const ColorCategoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonAppbar(
      appBarLabel: 'Color Category',
      firstActionChild: AppBarAddButton(
        tooltip: 'Add Color',
        onTap: () => _addColorSheet(keys: categoryKey),
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
                        return _ColorCategoryCard(
                          name: item.name ?? '',
                          createdAt: item.createdAt ?? '',
                          onDelete: () async {
                            await controller.deleteColor(item.id ?? '');
                          },
                          isDeleting: controller.isDeleteLoading,
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
                  color: Colors.purple.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: Colors.purple.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.paintbrush_fill,
                      size: 18.sp,
                      color: Colors.purple,
                    ),
                    setWidth(width: 10),
                    Expanded(
                      child: Text(
                        'Enter a name for the new color',
                        style: CustomTextStyle.customOpenSans(
                          fontSize: 12,
                          color: Colors.purple,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              setHeight(height: 14),
              CommonTextField(
                hintText: 'e.g. Red, Navy Blue, Olive',
                label: 'Color Name',
                contentPadding: SymmetricPadding(horizontal: 10).getPadding(),
                controller: controller.colorName,
                validator: (val) {
                  if (val!.isEmpty) return 'Please enter color name';
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
                      await controller.addColor(controller.colorName.text);
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
