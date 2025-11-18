import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/common_widget/common_button.dart';
import 'package:inventory/common_widget/common_container.dart';
import 'package:inventory/common_widget/common_progressbar.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/common_widget/textfiled.dart';
import 'package:inventory/helper/app_message.dart';
import '../../../common_widget/common_bottom_sheet.dart';
import '../../../helper/textstyle.dart';
import '../../../keys/keys.dart';
import '../controller/discount_controller.dart';

class Discount extends GetView<DiscountController> {
  const Discount({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => CommonAppbar(
        appBarLabel: 'Discount',
        firstActionChild:
            controller.discountList.isEmpty ||
                    controller.discountList.length < 3
                ? InkWell(
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
                )
                : null,
        body: Obx(
          () =>
              controller.isFetchDiscount.value
                  ? CommonProgressbar(color: AppColors.blackColor, size: 30)
                  : controller.discountList.isNotEmpty
                  ? Stack(
                    children: [
                      ListView.builder(
                        itemCount: controller.discountList.length,
                        itemBuilder: (context, index) {
                          var list = controller.discountList[index];
                          return ListTile(
                            title: Text(
                              'Discount ${list.label}%',
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
                                    controller.isDeleteDiscount.value
                                        ? null
                                        : () async {
                                          await controller.deleteDiscount(
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
                            controller.isDeleteDiscount.value
                                ? BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 5,
                                    sigmaY: 5,
                                  ),
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
      ),
    );
  }

  void addNewDiscount(GlobalKey<FormState> disountKey) {
    commonBottomSheet(
      label: 'Set Discount',
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
              keyboardType: TextInputType.number,
              hintText: 'Percentage',
              label: 'Percentage',
              inputLength: 2,
              contentPadding: EdgeInsets.symmetric(horizontal: 10),
              controller: controller.discountPercentage,
              validator: (val) {
                if (val!.isEmpty) {
                  return emptyDiscountPercentage;
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
