import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/common_widget/common_bottom_sheet.dart';
import 'package:inventory/common_widget/common_button.dart';
import 'package:inventory/common_widget/common_container.dart';
import 'package:inventory/common_widget/common_progressbar.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/common_widget/textfiled.dart';
import 'package:inventory/helper/app_message.dart';
import 'package:inventory/module/loose_category/widget/loose_category_component.dart';
import '../../../helper/textstyle.dart';
import '../controller/loose_category_controller.dart';

class LooseCategory extends GetView<LooseCategoryController> {
  const LooseCategory({super.key});

  @override
  Widget build(BuildContext context) {
    final disountKey = GlobalKey<FormState>();
    return CommonAppbar(
      appBarLabel: 'Loose Sell Category',
      firstActionChild: InkWell(
        onTap: () {
          addNewDiscount(disountKey);
        },
        child: CommonContainer(
          height: 50,
          width: 50,
          radius: 15,
          color: AppColors.whiteColor,
          child: Icon(CupertinoIcons.plus),
        ),
      ),
      body: Obx(
        () =>
            controller.isFetchDiscount.value
                ? CommonProgressbar(color: AppColors.blackColor, size: 30)
                : controller.looseCategoryModelList.isNotEmpty
                ? Stack(
                  children: [
                    ListView.builder(
                      itemCount: controller.looseCategoryModelList.length,
                      itemBuilder: (context, index) {
                        var list = controller.looseCategoryModelList[index];
                        return LooseCategoryComponent(
                          looseCategoryModel: list,
                          onTap:
                              controller.isDeleteDiscount.value
                                  ? null
                                  : () async {
                                    await controller.deleteLooseCategory(
                                      list.id,
                                    );
                                  },
                        );
                      },
                    ),
                    Obx(
                      () =>
                          controller.isDeleteDiscount.value
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
                : Center(
                  child: Text(
                    'No Discount Found',
                    style: CustomTextStyle.customRaleway(fontSize: 20),
                  ),
                ),
      ),
    );
  }

  void addNewDiscount(GlobalKey<FormState> disountKey) {
    commonBottomSheet(
      label: 'Set Loose Category',
      onPressed: () {
        Get.back();
        controller.clear();
      },
      child: Form(
        key: disountKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CommonTextField(
              hintText: 'Item Name',
              label: 'Item Name',
              contentPadding: EdgeInsets.symmetric(horizontal: 10),
              controller: controller.name,
              validator: (val) {
                if (val!.isEmpty) {
                  return emptyLooseCatagoryName;
                } else {
                  return null;
                }
              },
            ),
            setHeight(height: 10),
            Row(
              children: [
                Flexible(
                  child: CommonTextField(
                    hintText: 'Unit',
                    label: 'Unit',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    controller: controller.unit,
                    validator: (val) {
                      if (val!.isEmpty) {
                        return emptyLooseCatagoryUnit;
                      } else {
                        return null;
                      }
                    },
                  ),
                ),
                Flexible(
                  child: CommonTextField(
                    keyboardType: TextInputType.number,
                    hintText: 'Price',
                    label: 'Price',
                    inputLength: 5,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    controller: controller.price,
                    validator: (val) {
                      if (val!.isEmpty) {
                        return emptyLooseCatagoryPrice;
                      } else {
                        return null;
                      }
                    },
                  ),
                ),
              ],
            ),
            setHeight(height: 30),
            Obx(
              () => CommonButton(
                isLoading: controller.isSaveLoading.value,
                label: saveButton,
                onTap: () async {
                  if (disountKey.currentState!.validate()) {
                    await controller.addDiscount();
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
