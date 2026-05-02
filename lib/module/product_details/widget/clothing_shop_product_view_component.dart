import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_button.dart';
import 'package:inventory/common_widget/common_calender.dart';
import 'package:inventory/common_widget/common_dropdown.dart';
import 'package:inventory/common_widget/common_padding.dart';
import 'package:inventory/common_widget/common_progressbar.dart';
import 'package:inventory/common_widget/common_switch.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/common_widget/textfiled.dart';
import 'package:inventory/helper/app_message.dart';
import 'package:inventory/helper/helper.dart';
import 'package:inventory/helper/set_format_date.dart';
import 'package:inventory/module/product_details/controller/controller.dart';
import 'package:inventory/module/product_details/widget/inventory_bottomsheep_component_text.dart';

class ClothingShopProductViewComponent extends StatelessWidget {
  final ProductController controller;
  final BuildContext context;
  final GlobalKey<FormState> formkeys;
  const ClothingShopProductViewComponent({
    super.key,
    required this.controller,
    required this.context,
    required this.formkeys,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.inventoryScanKey,
      child: CustomPadding(
        paddingOption: SymmetricPadding(horizontal: 10.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 10,
            children: [
              InventoryBottomsheetComponentText(
                readOnly1: true,
                controller1: controller.barcode,
                controller2: controller.productName,
                label1: 'Barcode',
                hintText1: 'Enter barcode',
                hintText2: 'Enter product name',
                label2: 'Product Name',
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
                      () =>
                          controller.categoryListLoading.value
                              ? Center(
                                child: CommonProgressBar(
                                  color: AppColors.blackColor,
                                ),
                              )
                              : controller.categoryList.isEmpty
                              ? CustomDropDown(
                                // errorText: emptyCategory,
                                listItems: controller.categoryList,
                                hintText: 'Category',
                                notifyParent: (val) {
                                  // controller.category.text = val.id;
                                },
                              )
                              : CustomDropDown(
                                // errorText: emptyCategory,
                                listItems: controller.categoryList,
                                hintText: 'Select Category',
                                notifyParent: (val) {
                                  controller.category.text = val;
                                },
                              ),
                    ),
                  ),
                  Flexible(
                    child: Obx(
                      () =>
                          controller.animalCategoryListLoading.value
                              ? Center(
                                child: CommonProgressBar(
                                  color: AppColors.blackColor,
                                ),
                              )
                              : controller.animalTypeList.isEmpty
                              ? CustomDropDown(
                                //  errorText: emptyCategory,
                                listItems: controller.animalTypeList,
                                hintText: 'Size',
                                notifyParent: (val) {
                                  // controller.category.text = val.id;
                                },
                              )
                              : CustomDropDown(
                                // errorText: emptyAnimalCategory,
                                hintText: 'Size',
                                listItems: controller.animalTypeList,
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
                      contentPadding:
                          SymmetricPadding(
                            vertical: 5,
                            horizontal: 5,
                          ).getPadding(),
                      inputLength: 5,
                      keyboardType: TextInputType.number,
                      hintText: 'Enter stock',
                      label: 'Stock',
                      controller: controller.quantity,
                    ),
                  ),
                  Flexible(
                    child: CustomStaticDropDown(
                      // isModelValueEnabled: false,
                      // errorText: 'Please select',
                      listItems: [true, false],
                      hintText: 'Select Type',
                      notifyParent: (val) {
                        controller.isLoose = val;
                        customMessageOrErrorPrint(
                          message: ' controller.isLoose ${controller.isLoose}',
                        );
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
              InventoryBottomsheetComponentText(
                inputLength1: 2,
                keyboardType1: TextInputType.number,
                hintText2: 'Level',
                label2: 'Level',
                controller2: controller.level,
                // validator2: (location) {
                //   if (location!.isEmpty) {
                //     return emptyLocation;
                //   } else {
                //     return null;
                //   }
                // },
                hintText1: 'Enter discount',
                label1: 'Discount (%)',
                controller1: controller.discount,
                validator1: (discount) {
                  if (discount!.isEmpty) {
                    return emptyDiscount;
                  } else {
                    return null;
                  }
                },
              ),
              Row(
                children: [
                  Flexible(
                    child: CommonTextField(
                      // validator: (expire) {
                      //   if (expire!.isEmpty) {
                      //     return emptyExpire;
                      //   } else {
                      //     return null;
                      //   }
                      // },
                      contentPadding:
                          SymmetricPadding(
                            vertical: 5,
                            horizontal: 5,
                          ).getPadding(),

                      hintText: 'Rack',
                      label: 'Rack',
                      controller: controller.rack,
                    ),
                  ),
                  Flexible(
                    child: CustomStaticDropDown(
                      // isModelValueEnabled: false,
                      // errorText: 'Select Location',
                      listItems: ['Shop', 'Godown'],
                      hintText: 'Location',
                      notifyParent: (val) {
                        controller.location.text = val;
                        customMessageOrErrorPrint(
                          message: ' controller.isLoose ${controller.isLoose}',
                        );
                      },
                    ),
                  ),
                ],
              ),
              setHeight(height: 5),
              Obx(
                () => CommonButton(
                  isLoading: controller.isSaveLoading.value,
                  label: saveButton,
                  onTap: () async {
                    var body = {
                      "name": controller.productName.text,
                      "barcodes": controller.barcode.text,
                      "quantity": controller.quantity.text,
                      "selling_price": controller.sellingPrice.text,
                      "purchase_price": controller.purchasePrice.text,
                      "location": controller.location.text.toLowerCase(),
                      "stock_type": "packet",
                      "isloosed": controller.isLoose,
                      "isflavorRequired":
                          controller.isFlavorAndWeightNotRequired.value,
                      "purchase_date": parseAppDate(
                        controller.purchaseDate.text,
                      ),
                      "expiry_date": parseAppDate(controller.exprieDate.text),
                      "category": controller.category.text,
                      "animal_type": controller.animalType.text,
                      "flavour": controller.flavor.text,
                      "level": controller.level.text,
                      "rack": controller.rack.text,
                      "weight": controller.weight.text,
                      "discount": controller.discount.text,
                    };
                    if (controller.inventoryScanKey.currentState!.validate()) {
                      unfocus();
                      controller.saveNewProduct(body: body);
                    }
                  },
                ),
              ),
              setHeight(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
