import 'package:flutter/widgets.dart';
import 'package:get/state_manager.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/product_details/widget/inventory_bottomsheep_component_text.dart';

import '../../../common_widget/common_button.dart';
import '../../../common_widget/common_dropdown.dart';
import '../../../common_widget/common_switch.dart';
import '../../../common_widget/textfiled.dart';
import '../../../helper/app_message.dart';
import '../controller/generate_barcode_controller.dart';

class GenerateBarcodeComponent extends StatelessWidget {
  final List animalTypeList;
  final List categoryList;
  final GenerateBarcodeController controller;
  const GenerateBarcodeComponent({
    super.key,
    required this.animalTypeList,
    required this.categoryList,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        InventoryBottomsheetComponentText(
          readOnly1: true,
          controller1: controller.barcode,
          controller2: controller.productName,
          label1: 'Barcode',
          hintText1: 'Enter barcode',
          hintText2: 'Enter product name',
          label2: 'Product name',
          validator2: (name) {
            if (name!.isEmpty) {
              return emptyProductName;
            } else {
              return null;
            }
          },
        ),
        Row(
          children: [
            Flexible(
              child: Obx(
                () => CommonDropDown(
                  listItems: controller.categoryList.value,
                  hintText: 'Select Category',
                  notifyParent: (val) {
                    controller.category.text = val;
                  },
                ),
              ),
            ),
            Flexible(
              child: Obx(
                () => CommonDropDown(
                  hintText: 'Select Animal Type',
                  listItems: controller.animalTypeList.value,
                  notifyParent: (val) {
                    controller.animalType.text = val;
                  },
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Flexible(
              child: CommonTextField(
                validator: (quantity) {
                  if (quantity!.isEmpty) {
                    return emptyProductQuantity;
                  } else {
                    return null;
                  }
                },
                contentPadding: EdgeInsets.symmetric(
                  vertical: 5,
                  horizontal: 5,
                ),
                inputLength: 5,
                keyboardType: TextInputType.number,
                hintText: 'Enter quantity',
                label: 'Quantity',
                controller: controller.quantity,
              ),
            ),
            Flexible(
              child: CustomDropDown(
                listItems: [true, false],
                hintText: 'Select isLoose',
                notifyParent: (val) {
                  controller.isLoose = val;
                },
              ),
            ),
          ],
        ),
        InventoryBottomsheetComponentText(
          inputLength1: 10,
          keyboardType1: TextInputType.number,
          hintText2: 'Purcashe Price (mrp)',
          label2: 'Purcashe Price (₹)',
          controller2: controller.purchasePrice,
          validator2: (purchasePrice) {
            if (purchasePrice!.isEmpty) {
              return emptyProductPurchasePrice;
            } else {
              return null;
            }
          },
          inputLength2: 10,
          keyboardType2: TextInputType.number,
          hintText1: 'Selling Price (sp)',
          label1: 'Selling Price (₹)',
          controller1: controller.sellingPrice,
          validator1: (sellingPrice) {
            if (sellingPrice!.isEmpty) {
              return emptyProductSellingPrice;
            } else {
              return null;
            }
          },
          onChanged1: (v) {
            controller.calculatePurchasePrice();
          },
        ),
        Obx(
          () =>
              controller.isFlavorAndWeightNotRequired.value
                  ? InventoryBottomsheetComponentText(
                    hintText1: 'Flavor',
                    label1: 'Flavor',
                    controller1: controller.flavor,
                    validator1: (flavor) {
                      if (flavor!.isEmpty) {
                        return emptyflavor;
                      } else {
                        return null;
                      }
                    },
                    hintText2: 'Weight',
                    label2: 'Weight',
                    controller2: controller.weight,
                    validator2: (weight) {
                      if (weight!.isEmpty) {
                        return emptyWeight;
                      } else {
                        return null;
                      }
                    },
                  )
                  : Container(),
        ),
        Obx(
          () => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: CommonSwitch(
              labelSize: 12,
              label: "Flavor & Weight Required",
              value: controller.isFlavorAndWeightNotRequired.value,

              onChanged: (fw) {
                // controller.isFlavorAndWeightNotRequired.value =
                //     !controller.isFlavorAndWeightNotRequired.value;
              },
            ),
          ),
        ),
        setHeight(height: 25),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Obx(
              () => CommonButton(
                width: 150,
                isLoading: controller.isSaveLoading.value,
                label: saveButton,
                onTap: () async {
                  // if (formkeys.currentState!.validate()) {
                  //   unfocus();
                  //   controller.saveNewProduct(
                  //     barcode: controller.barcodeValue.value,
                  //   );
                  // }
                },
              ),
            ),
            Obx(
              () => CommonButton(
                isLoading: controller.isSaveLoading.value,
                label: saveButton,
                width: 150,
                onTap: () async {
                  // if (formkeys.currentState!.validate()) {
                  //   unfocus();
                  //   controller.saveNewProduct(
                  //     barcode: controller.barcodeValue.value,
                  //   );
                  // }
                },
              ),
            ),
          ],
        ),
        setHeight(height: 50),
      ],
    );
  }
}
