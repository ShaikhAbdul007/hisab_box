import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/common_bottom_sheet.dart';
import 'package:inventory/helper/textstyle.dart';
import '../../../common_widget/colors.dart';
import '../../../common_widget/common_appbar.dart';
import '../../../common_widget/common_button.dart';
import '../../../common_widget/common_calender.dart';
import '../../../common_widget/common_container.dart';
import '../../../common_widget/common_dropdown.dart';
import '../../../common_widget/common_padding.dart';
import '../../../common_widget/common_progressbar.dart';
import '../../../common_widget/size.dart';
import '../../../common_widget/textfiled.dart';
import '../../../helper/app_message.dart';
import '../../../helper/helper.dart';
import '../../../routes/route_name.dart';
import '../../../routes/routes.dart';
import '../controller/product_details_controller.dart';
import '../widget/inventory_bottomsheep_component_text.dart';

class ProductDetailView extends GetView<ProductDetailsController> {
  const ProductDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    bool isProductLoosed = controller.data['isProductLoosed'];
    return CommonAppbar(
      isleadingButtonRequired: true,
      backgroundColor: AppColors.whiteColor,
      firstActionChild: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () {
              commonBottomSheet(
                label: 'BarCode',
                onPressed: () {
                  Get.back();
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    BarcodeWidget(
                      barcode: Barcode.ean13(),
                      data: controller.barcode.text,
                      height: 50,
                      width: 200,
                      drawText: false,
                    ),
                    setHeight(height: 20),
                    CommonButton(
                      label: 'Generate Barcode',
                      onTap: () {
                        AppRoutes.navigateRoutes(
                          routeName: AppRouteName.barcodePrintView,
                          data: controller.data,
                        );
                      },
                    ),
                    setHeight(height: 100),
                  ],
                ),
              );
            },
            child: CommonContainer(
              width: 30,
              height: 25,
              color: AppColors.blackColor,
              radius: 5,
              child: Icon(
                CupertinoIcons.barcode,
                color: AppColors.whiteColor,
                size: 22.sp,
              ),
            ),
          ),
          setWidth(width: 10),
          InkWell(
            onTap: () {
              controller.readOnly.value = !controller.readOnly.value;
              controller.dropDownReadOnly.value =
                  !controller.dropDownReadOnly.value;
            },
            child: Icon(
              CupertinoIcons.square_pencil_fill,
              color: AppColors.blackColor,
            ),
          ),
        ],
      ),
      appBarLabel: isProductLoosed ? 'Loose Product Detail' : 'Product Detail',
      body: Form(
        key: controller.inventoryScanKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 4.sp,
            children: [
              Container(
                height: 170,
                decoration: BoxDecoration(
                  color: AppColors.greyColorShade100,
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(50),
                    bottomLeft: Radius.circular(50),
                  ),
                ),
                child: ListView(
                  children: [
                    Hero(
                      transitionOnUserGestures: true,
                      tag: 'herotag_${UniqueKey()}',
                      child: Icon(CupertinoIcons.cube_box_fill, size: 70),
                    ),
                    setHeight(height: 8),
                    Text(
                      textAlign: TextAlign.center,
                      controller.productName.text,
                      style: CustomTextStyle.customMontserrat(fontSize: 18),
                    ),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: controller.quantity.text,
                        style: CustomTextStyle.customPoppin(fontSize: 30),
                        children: [
                          TextSpan(
                            text: ' in stock',
                            style: CustomTextStyle.customPoppin(
                              fontSize: 20,
                              color: AppColors.greyColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              CustomPadding(
                paddingOption: SymmetricPadding(horizontal: 5.0),
                child: Column(
                  children: [
                    InventoryBottomsheetComponentText(
                      readOnly1: controller.readOnly.value,
                      readOnly2: controller.readOnly.value,
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
                            () =>
                                controller.categoryList.isEmpty
                                    ? Center(
                                      child: CommonProgressbar(
                                        color: AppColors.blackColor,
                                      ),
                                    )
                                    : CommonDropDown(
                                      errorText: emptyCategory,
                                      enabled:
                                          controller.dropDownReadOnly.value,
                                      selectedDropDownItem: controller
                                          .getSelectedCategory(
                                            categorysId:
                                                controller.category.text,
                                          ),
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
                                      enabled:
                                          controller.dropDownReadOnly.value,
                                      hintText: 'Animal Type',
                                      selectedDropDownItem: controller
                                          .getSelectedCategory(
                                            categorysId:
                                                controller.animalType.text,
                                            categoryType: 'animal',
                                          ),
                                      listItems: controller.animalTypeList,
                                      notifyParent: (val) {
                                        controller.animalType.text = val.id;
                                        customMessageOrErrorPrint(
                                          message: controller.animalType.text,
                                        );
                                      },
                                    ),
                          ),
                        ),
                      ],
                    ),
                    Obx(
                      () => Row(
                        children: [
                          Flexible(
                            child: CommonTextField(
                              readOnly: controller.readOnly.value,
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
                              hintText: 'Enter Stock',
                              label: 'Stock',
                              controller: controller.quantity,
                            ),
                          ),
                          Flexible(
                            child: CommonDropDown(
                              isModelValueEnabled: false,
                              errorText: 'Please select',
                              enabled: controller.dropDownReadOnly.value,
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
                    ),
                    Obx(
                      () => InventoryBottomsheetComponentText(
                        readOnly1: controller.readOnly.value,
                        readOnly2: controller.readOnly.value,
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
                          //controller.calculatePurchasePrice();
                        },
                      ),
                    ),
                    Obx(
                      () => InventoryBottomsheetComponentText(
                        readOnly1: controller.readOnly.value,
                        readOnly2: controller.readOnly.value,
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
                        hintText1: 'Discount',
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
                              child: Icon(
                                CupertinoIcons.calendar_today,
                                size: 20,
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
                            suffixIcon: InkWell(
                              onTap: () async {
                                var res = await customDatePicker(
                                  context: context,
                                  lastDate: DateTime(2040),
                                  selectedDate: DateTime.now(),
                                  controller: controller.dayDate,
                                );
                                if (res.isNotEmpty) {
                                  controller.exprieDate.text = res;
                                }
                              },
                              child: Icon(
                                CupertinoIcons.calendar_today,
                                size: 20,
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
                            inputLength: 5,
                            keyboardType: TextInputType.number,
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
                                readOnly1: controller.readOnly.value,
                                readOnly2: controller.readOnly.value,
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
                    setHeight(height: 20),
                    Obx(
                      () =>
                          controller.readOnly.value
                              ? Container()
                              : CommonButton(
                                isLoading: controller.isSaveLoading.value,
                                label: saveButton,
                                onTap: () async {
                                  if (controller.inventoryScanKey.currentState!
                                      .validate()) {
                                    unfocus();

                                    if (isProductLoosed) {
                                      print('form true${controller.isLoose}');
                                      controller.updateProductQuantity(
                                        barcode: controller.barcode.text,
                                        isLoosed: isProductLoosed,
                                      );
                                    } else {
                                      print(controller.isLoose);
                                      controller.updateProductQuantity(
                                        barcode: controller.barcode.text,
                                        isLoosed: isProductLoosed,
                                      );
                                    }
                                  }
                                },
                              ),
                    ),
                    setHeight(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


  // Obx(
                //   () => Padding(
                //     padding: const EdgeInsets.symmetric(horizontal: 15.0),
                //     child: CommonSwitch(
                //       labelSize: 12,
                //       label: "Flavor & Weight Required",
                //       value: controller.isFlavorAndWeightNotRequired.value,
                //       onChanged: (fw) {
                //         controller.isFlavorAndWeightNotRequired.value =
                //             !controller.isFlavorAndWeightNotRequired.value;
                //       },
                //     ),
                //   ),
                // ),