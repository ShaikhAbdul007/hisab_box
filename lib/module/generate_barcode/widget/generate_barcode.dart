import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:intl/intl.dart';
import 'package:inventory/common_widget/common_padding.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/helper/set_format_date.dart';
import '../../../common_widget/colors.dart';
import '../../../common_widget/common_button.dart';
import '../../../common_widget/common_calender.dart';
import '../../../common_widget/common_dropdown.dart';
import '../../../common_widget/common_progressbar.dart';
import '../../../common_widget/common_switch.dart';
import '../../../common_widget/textfiled.dart';
import '../../../helper/app_message.dart';
import '../../../helper/helper.dart';
import '../../product_details/widget/inventory_bottomsheep_component_text.dart';
import '../controller/generate_barcode_controller.dart';

class GenerateBarcodeComponent extends StatelessWidget {
  final GenerateBarcodeController controller;
  const GenerateBarcodeComponent({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return CustomPadding(
      paddingOption: SymmetricPadding(horizontal: 10.0),
      child: SingleChildScrollView(
        child: Form(
          key: controller.inventoryScanKey,
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
                                //   errorText: emptyCategory,
                                listItems: controller.categoryList,
                                hintText: 'Add Category First',
                                notifyParent: (val) {
                                  controller.category.text = val.id;
                                },
                              )
                              : CustomDropDown(
                                // errorText: emptyCategory,
                                listItems: controller.categoryList,
                                hintText: 'Category',
                                notifyParent: (val) {
                                  controller.category.text = val.id;
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
                                // errorText: emptyCategory,
                                listItems: controller.animalTypeList,
                                hintText: 'Add Animal Category',
                                notifyParent: (val) {
                                  controller.category.text = val.id;
                                },
                              )
                              : CustomDropDown(
                                // errorText: emptyAnimalCategory,
                                hintText: 'Animal Category',
                                listItems: controller.animalTypeList,
                                notifyParent: (val) {
                                  controller.animalType.text = val.id;
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
                    child: CustomDropDown(
                      // isModelValueEnabled: false,
                      // errorText: 'Please select',
                      // enabled: controller.dropDownReadOnly.value,
                      selectedDropDownItem: controller.isLoose,
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
              InventoryBottomsheetComponentText(
                inputLength1: 2,
                keyboardType1: TextInputType.number,
                hintText2: 'Level',
                label2: 'Level',
                controller2: controller.level,
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
                    child: CustomDropDown(
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
              Row(
                children: [
                  Flexible(
                    child: CommonTextField(
                      readOnly: true,
                      suffixIcon: CustomPadding(
                        paddingOption: OnlyPadding(right: 10),
                        child: InkWell(
                          onTap: () async {
                            var res = await customDatePicker(
                              lastDate: DateTime(2040),
                              context: context,
                              selectedDate: DateTime.now(),
                              controller: controller.dayDate,
                            );
                            if (res.isNotEmpty) {
                              controller.purchaseDate.text = res;
                            }
                          },
                          child: Icon(CupertinoIcons.calendar_today, size: 20),
                        ),
                      ),
                      validator: (purchase) {
                        if (purchase!.isEmpty) {
                          return emptyPurchase;
                        } else {
                          return null;
                        }
                      },
                      contentPadding:
                          SymmetricPadding(
                            vertical: 5,
                            horizontal: 5,
                          ).getPadding(),
                      hintText: 'dd-MM-yyyy',
                      label: 'Purchase Date',
                      controller: controller.purchaseDate,
                    ),
                  ),
                  Flexible(
                    child: CommonTextField(
                      readOnly: true,
                      suffixIcon: CustomPadding(
                        paddingOption: OnlyPadding(right: 10),
                        child: InkWell(
                          onTap: () async {
                            var res = await customDatePicker(
                              lastDate: DateTime(2040),
                              context: context,
                              selectedDate: DateTime.now(),
                              controller: controller.dayDate,
                            );
                            if (res.isNotEmpty) {
                              controller.exprieDate.text = res;
                            }
                          },
                          child: Icon(CupertinoIcons.calendar_today, size: 20),
                        ),
                      ),
                      validator: (expire) {
                        if (expire!.isEmpty) {
                          return emptyExpire;
                        } else {
                          return null;
                        }
                      },
                      contentPadding:
                          SymmetricPadding(
                            vertical: 5,
                            horizontal: 5,
                          ).getPadding(),

                      hintText: 'dd-MM-yyyy',
                      label: 'Expire Date',
                      controller: controller.exprieDate,
                    ),
                  ),
                ],
              ),
              Obx(
                () =>
                    controller.isFlavorAndWeightNotRequired.value
                        ? InventoryBottomsheetComponentText(
                          hintText1: 'Enter flavor',
                          label1: 'Flavor',
                          controller1: controller.flavor,
                          validator1: (flavor) {
                            if (flavor!.isEmpty) {
                              return emptyflavor;
                            } else {
                              return null;
                            }
                          },
                          hintText2: 'Enter weight',
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
                () => CustomPadding(
                  paddingOption: SymmetricPadding(horizontal: 15.0),
                  child: CommonSwitch(
                    labelSize: 12,
                    label: "Flavor & Weight Required",
                    value: controller.isFlavorAndWeightNotRequired.value,
                    onChanged: (fw) {
                      controller.isFlavorAndWeightNotRequired.value =
                          !controller.isFlavorAndWeightNotRequired.value;
                    },
                  ),
                ),
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
                      print(body.toString());
                      await controller.saveNewProduct(body: body);
                      //await controller.saveNewProduct(body: body);
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
