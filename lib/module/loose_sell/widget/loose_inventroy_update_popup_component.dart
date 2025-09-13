import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/helper/helper.dart';
import 'package:inventory/module/loose_sell/controller/loose_controller.dart';
import '../../../common_widget/colors.dart';
import '../../../common_widget/common_button.dart';
import '../../../common_widget/common_popup_appbar.dart';
import '../../../common_widget/size.dart';
import '../../../common_widget/textfiled.dart';
import '../../../helper/app_message.dart';
import '../../../helper/textstyle.dart';

class LooseInventoryUpdatePopupComponent extends StatelessWidget {
  final LooseController controller;
  final int index;
  const LooseInventoryUpdatePopupComponent({
    super.key,
    required this.controller,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> formkeys = GlobalKey<FormState>();
    return Column(
      children: [
        CommonPopupAppbar(
          label: 'Update Info',
          onPressed: () {
            Get.back();
          },
        ),
        Divider(),
        Row(
          children: [
            Flexible(
              child: CommonTextField(
                readOnly: true,
                label: 'Selling Price',
                inputLength: 5,
                keyboardType: TextInputType.numberWithOptions(
                  signed: false,
                  decimal: false,
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 5,
                  horizontal: 5,
                ),
                hintText: 'Selling Price (sp)',
                controller: controller.sellingPrice,
                validator: (sellingPrice) {
                  if (sellingPrice!.isEmpty) {
                    return emptyProductSellingPrice;
                  } else {
                    return null;
                  }
                },
              ),
            ),
            Flexible(
              child: CommonTextField(
                readOnly: true,
                label: 'Quantity',
                contentPadding: EdgeInsets.symmetric(
                  vertical: 5,
                  horizontal: 5,
                ),
                inputLength: 5,
                keyboardType: TextInputType.numberWithOptions(
                  signed: false,
                  decimal: false,
                ),
                hintText: 'Enter quantity',
                controller: controller.updateQuantity,
                validator: (quantity) {
                  if (quantity!.isEmpty) {
                    return emptyProductQuantity;
                  } else {
                    return null;
                  }
                },
              ),
            ),
            setWidth(width: 5),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CommonButton(
                  height: 20,
                  width: 40,
                  bgColor: AppColors.greenColorShade100,
                  label: '+',
                  radius: 4,
                  isbgReq: false,
                  onTap: () {
                    Get.back();
                    updateDataDialog(add: true, formkeys: formkeys);
                  },
                ),
                setHeight(height: 5),
                CommonButton(
                  height: 20,
                  width: 40,
                  bgColor: AppColors.buttonRedColor,
                  label: '-',
                  isbgReq: false,
                  radius: 4,
                  onTap: () {
                    Get.back();
                    updateDataDialog(add: false, formkeys: formkeys);
                  },
                ),
              ],
            ),
            setWidth(width: 15),
          ],
        ),
        setHeight(height: 10),
        Row(children: [
           
          ],
        ),
        setHeight(height: 10),

        // setHeight(height: 10),
        // Obx(
        //   () => CommonButton(
        //     isLoading: controller.isSaveLoading.value,
        //     label: saveButton,
        //     onTap: () {},
        //   ),
        // ),
        setHeight(height: 10),
      ],
    );
  }

  void updateDataDialog({
    required bool add,
    required GlobalKey<FormState> formkeys,
  }) {
    Get.defaultDialog(
      title: '',
      titleStyle: CustomTextStyle.customNato(fontSize: 0),
      titlePadding: EdgeInsets.zero,
      barrierDismissible: false,
      content: Form(
        key: formkeys,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CommonPopupAppbar(
                label: add ? 'Add Qauntity' : 'Subtract Qauntity',
                onPressed: () {
                  Get.back();
                  controller.qtyClear();
                },
              ),
              Divider(),
              Flexible(
                child: CommonTextField(
                  label: 'Qauntity',
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 5,
                  ),
                  hintText: 'Qauntity',
                  controller: controller.addSubtractQty,
                  validator: (flavor) {
                    if (flavor!.isEmpty) {
                      return emptyProductQuantity;
                    } else {
                      return null;
                    }
                  },
                ),
              ),
              setHeight(height: 10),
              Flexible(
                child: CommonTextField(
                  label: 'Selling Price',
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 5,
                  ),
                  hintText: 'Selling Price',
                  controller: controller.sellingPrice,
                  validator: (flavor) {
                    if (flavor!.isEmpty) {
                      return emptyProductQuantity;
                    } else {
                      return null;
                    }
                  },
                ),
              ),
              setHeight(height: 10),
              Obx(
                () => CommonButton(
                  isLoading: controller.isSaveLoading.value,
                  label: saveButton,
                  onTap: () {
                    if (formkeys.currentState!.validate()) {
                      unfocus();
                      controller.updateProductQuantity(
                        barcode: controller.productList[index].barcode ?? '',
                        add: add,
                      );
                    }
                  },
                ),
              ),
              setHeight(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
