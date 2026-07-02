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
import 'package:inventory/module/category/controller/animaltype_controller.dart';
import 'package:inventory/responsive_layout/dimension.dart';
import '../../../common_widget/common_button.dart';
import '../../../common_widget/common_progressbar.dart';
import '../../../common_widget/size.dart';
import '../../../common_widget/textfiled.dart';
import '../../../helper/app_message.dart';
import '../../../helper/textstyle.dart';
import '../../../keys/keys.dart';

/// Shared info banner
class _SheetInfoBanner extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String message;
  const _SheetInfoBanner({
    required this.icon,
    required this.iconColor,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final bool desktop = isDesktop(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(desktop ? 10 : 10.r),
        border: Border.all(color: iconColor.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Icon(icon, size: desktop ? 18 : 18.sp, color: iconColor),
          desktop ? const SizedBox(width: 10) : setWidth(width: 10),
          Expanded(
            child: Text(
              message,
              style: CustomTextStyle.customOpenSans(
                fontSize: 12,
                color: iconColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimalCategoryCard extends StatelessWidget {
  final String name;
  final String createdAt;
  final VoidCallback onDelete;
  final RxBool isDeleting;
  final Color accentColor;

  const _AnimalCategoryCard({
    required this.name,
    required this.createdAt,
    required this.onDelete,
    required this.isDeleting,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool desktop = isDesktop(context);
    return Container(
      margin: desktop 
          ? const EdgeInsets.symmetric(horizontal: 12, vertical: 5)
          : SymmetricPadding(horizontal: 12, vertical: 5).getPadding(),
      padding: desktop
          ? const EdgeInsets.symmetric(horizontal: 12, vertical: 10)
          : SymmetricPadding(horizontal: 12, vertical: 10).getPadding(),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(desktop ? 12 : 12.r),
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
            width: desktop ? 44 : 44.w,
            height: desktop ? 44 : 44.h,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(desktop ? 10 : 10.r),
            ),
            child: Icon(
              CupertinoIcons.tag_fill,
              color: accentColor,
              size: desktop ? 22 : 22.sp,
            ),
          ),
          desktop ? const SizedBox(width: 10) : setWidth(width: 10),
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
                desktop ? const SizedBox(height: 3) : setHeight(height: 3),
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.calendar,
                      size: desktop ? 11 : 11.sp,
                      color: AppColors.greyColor,
                    ),
                    desktop ? const SizedBox(width: 3) : setWidth(width: 3),
                    Text(
                      formatDateTime(createdAt),
                      style: CustomTextStyle.customOpenSans(
                        fontSize: 11,
                        color: AppColors.greyColor,
                      ),
                    ),
                    desktop ? const SizedBox(width: 6) : setWidth(width: 6),
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
              borderRadius: BorderRadius.circular(desktop ? 8 : 8.r),
              child: Container(
                width: desktop ? 36 : 36.w,
                height: desktop ? 36 : 36.h,
                decoration: BoxDecoration(
                  color: AppColors.redColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(desktop ? 8 : 8.r),
                ),
                child: Icon(
                  CupertinoIcons.delete,
                  size: desktop ? 18 : 18.sp,
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

class AnimalCategory extends GetView<AnimalTypeController> {
  const AnimalCategory({super.key});

  @override
  Widget build(BuildContext context) {
    if (isDesktop(context)) {
      final config = controller.shopTypeEnum.config;
      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: Text(
            config.categoryLabel,
            style: CustomTextStyle.customNato(fontSize: 16),
          ),
          leading: IconButton(
            icon: const Icon(CupertinoIcons.back),
            onPressed: () => Get.back(),
          ),
          surfaceTintColor: AppColors.greyColorShade100,
          backgroundColor: AppColors.greyColorShade100,
        ),
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left pane: list
            Expanded(
              flex: 3,
              child: Container(
                margin: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Obx(
                  () => controller.isFetchAnimalCategory.value
                      ? Center(
                          child: CommonProgressBar(
                            color: AppColors.blackColor,
                            size: 30,
                          ),
                        )
                      : controller.animalTypeList.isNotEmpty
                          ? Stack(
                              children: [
                                ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: controller.animalTypeList.length,
                                  itemBuilder: (context, index) {
                                    var list = controller.animalTypeList[index];
                                    return _AnimalCategoryCard(
                                      name: list.name ?? '',
                                      createdAt: list.createdAt ?? '',
                                      accentColor: Colors.orange,
                                      onDelete: () async {
                                        await controller.deleteAnimalCategory(list.id ?? '');
                                      },
                                      isDeleting: controller.isDeleteAnimalCategory,
                                    );
                                  },
                                ),
                                Obx(
                                  () => controller.isDeleteAnimalCategory.value
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
                          : CommonNoDataFound(message: config.categoryEmptyMsg),
                ),
              ),
            ),
            
            // Right pane: add form
            Expanded(
              flex: 2,
              child: Container(
                margin: const EdgeInsets.only(top: 24, bottom: 24, right: 24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Form(
                  key: categoryKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        config.categoryAddLabel,
                        style: CustomTextStyle.customPoppin(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.blackColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _SheetInfoBanner(
                        icon: CupertinoIcons.tag_fill,
                        iconColor: Colors.orange,
                        message: 'Enter a name for the new ${config.categoryLabel.toLowerCase()}',
                      ),
                      const SizedBox(height: 20),
                      CommonTextField(
                        hintText: config.categoryHintText,
                        label: config.categoryLabel,
                        controller: controller.animalCategory,
                        validator: (val) {
                          if (val!.isEmpty) return config.categoryValidationMsg;
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      Obx(
                        () => CommonButton(
                          isLoading: controller.isSaveLoading.value,
                          label: saveButton,
                          onTap: () async {
                            if (categoryKey.currentState!.validate()) {
                              await controller.addAnimalCategory(controller.animalCategory.text);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return CommonAppbar(
      firstActionChild: AppBarAddButton(
        tooltip: 'Add ${controller.shopTypeEnum.config.categoryLabel}',
        onTap: () => addNewCategory(keys: categoryKey),
      ),
      appBarLabel: controller.shopTypeEnum.config.categoryLabel,
      body: Obx(
        () =>
            controller.isFetchAnimalCategory.value
                ? CommonProgressBar(color: AppColors.blackColor, size: 30)
                : controller.animalTypeList.isNotEmpty
                ? Stack(
                  children: [
                    ListView.builder(
                      itemCount: controller.animalTypeList.length,
                      itemBuilder: (context, index) {
                        var list = controller.animalTypeList[index];
                        return _AnimalCategoryCard(
                          name: list.name ?? '',
                          createdAt: list.createdAt ?? '',
                          accentColor: Colors.orange,
                          onDelete: () async {
                            await controller.deleteAnimalCategory(
                              list.id ?? '',
                            );
                          },
                          isDeleting: controller.isDeleteAnimalCategory,
                        );
                      },
                    ),
                    Obx(
                      () =>
                          controller.isDeleteAnimalCategory.value
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
                : CommonNoDataFound(
                  message: controller.shopTypeEnum.config.categoryEmptyMsg,
                ),
      ),
    );
  }

  void addNewCategory({required GlobalKey<FormState> keys}) {
    final config = controller.shopTypeEnum.config;
    commonBottomSheet(
      label: config.categoryAddLabel,
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
              _SheetInfoBanner(
                icon: CupertinoIcons.tag_fill,
                iconColor: Colors.orange,
                message:
                    'Enter a name for the new ${config.categoryLabel.toLowerCase()}',
              ),
              setHeight(height: 14),
              CommonTextField(
                hintText: config.categoryHintText,
                label: config.categoryLabel,
                contentPadding: SymmetricPadding(horizontal: 10).getPadding(),
                controller: controller.animalCategory,
                validator: (val) {
                  if (val!.isEmpty) return config.categoryValidationMsg;
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
                      await controller.addAnimalCategory(
                        controller.animalCategory.text,
                      );
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
