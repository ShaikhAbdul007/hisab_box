import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/common_widget/common_bottom_sheet.dart';
import 'package:inventory/common_widget/common_container.dart';
import 'package:inventory/common_widget/common_nodatafound.dart';
import 'package:inventory/module/category/controller/category_controller.dart';
import '../../../common_widget/common_button.dart';
import '../../../common_widget/common_progressbar.dart';
import '../../../common_widget/size.dart';
import '../../../common_widget/textfiled.dart';
import '../../../helper/app_message.dart';
import '../../../helper/textstyle.dart';

class Category extends GetView<CategoryController> {
  const Category({super.key});

  @override
  Widget build(BuildContext context) {
    final categoryKey = GlobalKey<FormState>();
    return CommonAppbar(
      firstActionChild: CommonContainer(
        height: 40,
        width: 50,
        radius: 10,
        color: AppColors.whiteColor,
        child: InkWell(
          onTap: () {
            addNewCategory(keys: categoryKey);
          },
          child: Icon(CupertinoIcons.add),
        ),
      ),
      appBarLabel: 'Category',
      body: Obx(
        () =>
            controller.isFetchCategory.value
                ? CommonProgressbar(color: AppColors.blackColor, size: 30)
                : controller.categoryList.isNotEmpty
                ? Stack(
                  children: [
                    ListView.builder(
                      itemCount: controller.categoryList.length,
                      itemBuilder: (context, index) {
                        var list = controller.categoryList[index];
                        return ListTile(
                          title: Text(
                            list.name,
                            style: CustomTextStyle.customNato(
                              fontSize: 18,
                              color: AppColors.blackColor,
                            ),
                          ),
                          subtitle: Row(
                            children: [
                              Text(
                                list.createdAt,
                                style: CustomTextStyle.customNato(),
                              ),
                              setWidth(width: 25),
                              Text(
                                list.time,
                                style: CustomTextStyle.customNato(),
                              ),
                            ],
                          ),
                          trailing: Obx(
                            () => InkWell(
                              onTap:
                                  controller.isDeleteCategory.value
                                      ? null
                                      : () async {
                                        await controller.deleteCategory(
                                          list.id,
                                        );
                                      },
                              child: CommonContainer(
                                height: 40,
                                width: 50,
                                radius: 5,
                                color: AppColors.blackColor,
                                child: Icon(
                                  CupertinoIcons.delete,
                                  size: 18,
                                  color: AppColors.whiteColor,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    Obx(
                      () =>
                          controller.isDeleteCategory.value
                              ? BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                child: CommonProgressbar(
                                  color: AppColors.blackColor,
                                  size: 50,
                                ),
                              )
                              : Container(),
                    ),
                  ],
                )
                : CommonNodatafound(message: 'No category found'),
      ),
    );
  }

  void addNewCategory({required GlobalKey<FormState> keys}) {
    commonBottomSheet(
      label: 'Set Category',
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
              hintText: 'Category',
              label: 'Category',
              contentPadding: EdgeInsets.symmetric(horizontal: 10),
              controller: controller.category,
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
                    await controller.addAnimalCategory(
                      controller.category.text,
                    );
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
