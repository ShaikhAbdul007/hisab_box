import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/state_manager.dart';
import 'package:inventory/common_widget/common_padding.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/helper/textstyle.dart';
import 'package:inventory/keys/keys.dart';
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
          key: inventoryScanKey,
          child: Column(
            spacing: 10,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 50.r,
                    backgroundColor: AppColors.whiteColor,
                    child: Icon(CupertinoIcons.cube, size: 50.r),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        CommonTextField(
                          validator: (quantity) {
                            if (quantity!.isEmpty) {
                              return emptyBarcode;
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
                          hintText: 'Enter Barcode',
                          label: 'Enter Barcode',
                          controller: controller.barcode,
                        ),
                        CustomPadding(
                          paddingOption: OnlyPadding(right: 15.0, top: 5),
                          child: InkWell(
                            onTap: () {
                              // controller.
                            },
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                'Auto Generate Barcode',
                                style: CustomTextStyle.customPoppin(
                                  fontSize: 10,
                                  color: AppColors.deepPurple,
                                ),
                              ),
                            ),
                          ),
                        ),
                        CommonTextField(
                          validator: (quantity) {
                            if (quantity!.isEmpty) {
                              return emptyProductName;
                            } else {
                              return null;
                            }
                          },
                          contentPadding:
                              SymmetricPadding(
                                vertical: 5,
                                horizontal: 5,
                              ).getPadding(),
                          hintText: 'Enter product name',
                          label: 'Product Name',
                          controller: controller.productName,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Flexible(
                    child: Obx(
                      () =>
                          controller.categoryList.isEmpty
                              ? Center(
                                child: CommonProgressbar(
                                  color: AppColors.blackColor,
                                ),
                              )
                              : CommonDropDown(
                                errorText: emptyCategory,
                                listItems: controller.categoryList,
                                hintText: 'Select Category',
                                notifyParent: (val) {
                                  controller.category.text = val.id;
                                },
                              ),
                    ),
                  ),
                  Flexible(
                    child: Obx(
                      () =>
                          controller.animalTypeList.isEmpty
                              ? Center(
                                child: CommonProgressbar(
                                  color: AppColors.blackColor,
                                ),
                              )
                              : CommonDropDown(
                                errorText: emptyAnimalCategory,
                                hintText: 'Animal Type',
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
                    child: CommonDropDown(
                      isModelValueEnabled: false,
                      errorText: 'Please select',
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
                hintText2: 'Location',
                label2: 'Location',
                controller2: controller.location,
                validator2: (location) {
                  if (location!.isEmpty) {
                    return emptyLocation;
                  } else {
                    return null;
                  }
                },
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
                      readOnly: true,
                      suffixIcon: InkWell(
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
                      suffixIcon: InkWell(
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
                  label: saveAndPrintButton,
                  onTap: () async {
                    if (inventoryScanKey.currentState!.validate()) {
                      unfocus();
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
