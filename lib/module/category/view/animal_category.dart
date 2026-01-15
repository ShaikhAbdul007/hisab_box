import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/common_widget/common_bottom_sheet.dart';
import 'package:inventory/common_widget/common_container.dart';
import 'package:inventory/common_widget/common_nodatafound.dart';
import 'package:inventory/common_widget/common_padding.dart';
import 'package:inventory/module/category/controller/animaltype_controller.dart';
import '../../../common_widget/common_button.dart';
import '../../../common_widget/common_progressbar.dart';
import '../../../common_widget/size.dart';
import '../../../common_widget/textfiled.dart';
import '../../../helper/app_message.dart';
import '../../../helper/textstyle.dart';
import '../../../keys/keys.dart';

class AnimalCategory extends GetView<AnimalTypeController> {
  const AnimalCategory({super.key});

  @override
  Widget build(BuildContext context) {
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
      appBarLabel: 'Animal Category',
      body: Obx(
        () =>
            controller.isFetchAnimalCategory.value
                ? CommonProgressbar(color: AppColors.blackColor, size: 30)
                : controller.animalTypeList.isNotEmpty
                ? Stack(
                  children: [
                    ListView.builder(
                      itemCount: controller.animalTypeList.length,
                      itemBuilder: (context, index) {
                        var list = controller.animalTypeList[index];
                        return ListTile(
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
                                list.createdAt ?? '',
                                style: CustomTextStyle.customNato(),
                              ),
                              setWidth(width: 25),
                              Text(
                                list.time ?? '',
                                style: CustomTextStyle.customNato(),
                              ),
                            ],
                          ),
                          trailing: Obx(
                            () => InkWell(
                              onTap:
                                  controller.isDeleteAnimalCategory.value
                                      ? null
                                      : () async {
                                        await controller.deleteAnimalCategory(
                                          list.id ?? '',
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
                          controller.isDeleteAnimalCategory.value
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
                : CommonNodatafound(message: 'No animal category found'),
      ),
    );
  }

  void addNewCategory({required GlobalKey<FormState> keys}) {
    commonBottomSheet(
      label: 'Set Animal Category',
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
              hintText: 'Animal Category',
              label: 'Animal Category',
              contentPadding: SymmetricPadding(horizontal: 10).getPadding(),
              controller: controller.animalCategory,
              validator: (val) {
                if (val!.isEmpty) {
                  return emptyAnimalCategory;
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
                    await controller.addCategory(
                      controller.animalCategory.text,
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
