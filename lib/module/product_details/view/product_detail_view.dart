import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/common_bottom_sheet.dart';
import 'package:inventory/common_widget/common_container.dart';
import 'package:inventory/common_widget/common_dialogue.dart';
import 'package:inventory/common_widget/common_popup_appbar.dart';
import 'package:inventory/helper/textstyle.dart';
import 'package:inventory/helper/logger.dart';
import 'package:inventory/keys/keys.dart';
import '../../../common_widget/colors.dart';
import '../../../common_widget/common_appbar.dart';
import '../../../common_widget/common_button.dart';
import '../../../common_widget/common_calender.dart';
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

enum MenuOption { barcode, moveToShop, editProductDetails }

class ProductDetailView extends GetView<ProductDetailsController> {
  const ProductDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    bool isProductLoosed = controller.data['isProductLoosed'];
    bool godown = controller.data['product'].location == 'godown';
    return CommonAppbar(
      isleadingButtonRequired: true,
      backgroundColor: AppColors.whiteColor,
      firstActionChild: PopupMenuButton<MenuOption>(
        enabled: true,
        color: AppColors.whiteColor,
        position: PopupMenuPosition.under,
        borderRadius: BorderRadius.circular(200.r),
        itemBuilder:
            (BuildContext context) => <PopupMenuEntry<MenuOption>>[
              PopupMenuItem<MenuOption>(
                value: MenuOption.editProductDetails,
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.square_pencil_fill,
                      color: AppColors.blackColor,
                    ),
                    setWidth(width: 8),
                    Text('Edit', style: CustomTextStyle.customOpenSans()),
                  ],
                ),
              ),
              PopupMenuItem<MenuOption>(
                value: MenuOption.barcode,
                child: Row(
                  // Example of using a custom child widget
                  children: [
                    Icon(CupertinoIcons.barcode, color: AppColors.blackColor),
                    setWidth(width: 8),
                    Text(
                      'Generate Barcode',
                      style: CustomTextStyle.customOpenSans(),
                    ),
                  ],
                ),
              ),

              godown
                  ? PopupMenuItem<MenuOption>(
                    value: MenuOption.moveToShop,
                    child: Row(
                      children: [
                        Icon(
                          CupertinoIcons.arrow_right_arrow_left,
                          size: 20.sp,
                          color: AppColors.blackColor,
                        ),
                        setWidth(width: 8),
                        Text(
                          'Move to SHOP',
                          style: CustomTextStyle.customOpenSans(),
                        ),
                      ],
                    ),
                  )
                  : PopupMenuItem<MenuOption>(child: SizedBox.shrink()),
            ],
        // 2. onSelected: Handles the action when an item is selected
        onSelected: (MenuOption result) {
          if (result.name == 'barcode') {
            showBarcode(controller.barcodeQytController);
          } else if (result.name == 'moveToShop') {
            commonDialogBox(
              context: context,
              child: Form(
                key: inventoryScanKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CommonPopupAppbar(
                      label: 'Transfer Request',
                      onPressed: () {
                        controller.transferQuantityToShop.clear();
                        Get.back();
                      },
                    ),
                    Divider(),
                    CommonTextField(
                      hintText: 'Enter Quantity',
                      label: 'Qunatity',
                      controller: controller.transferQuantityToShop,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? false) {
                          return 'Enter Quantity';
                        }
                        return null;
                      },
                      inputLength: 5,
                    ),
                    setHeight(height: 10),
                    Obx(
                      () => CommonButton(
                        isLoading: controller.isTransferLoading.value,
                        label: 'Transfer',
                        onTap: () {
                          if (inventoryScanKey.currentState!.validate()) {
                            double tranferQuantity = double.parse(
                              controller.transferQuantityToShop.text,
                            );
                            if (tranferQuantity >
                                controller.data['product'].quantity) {
                              unfocus();
                              showSnackBar(
                                error:
                                    'Quantity must be lower than avaible stock in godown',
                              );
                            } else {
                              controller.requestStockTransfer(
                                product: controller.data['product'],
                                requestedQty: tranferQuantity,
                              );
                            }
                          }
                        },
                      ),
                    ),
                    setHeight(height: 20),
                  ],
                ),
              ),
            );
          } else if (result.name == 'editProductDetails') {
            controller.readOnly.value = !controller.readOnly.value;
            controller.dropDownReadOnly.value =
                !controller.dropDownReadOnly.value;
          } else {
            AppLogger.info(('result.name').toString());
          }
        },
        child: CommonContainer(
          height: 30,
          width: 30,
          radius: 10,
          color: AppColors.whiteColor,
          child: Icon(
            CupertinoIcons.ellipsis_vertical,
            color: AppColors.blackColor,
          ),
        ),
      ),
      appBarLabel:
          isProductLoosed
              ? 'Loose Product Detail'
              : godown
              ? 'Godown Product Detail'
              : 'Shop Product Detail',
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
                      child: Obx(
                        () => Icon(
                          CupertinoIcons.cube_box_fill,
                          size: 70.sp,
                          color:
                              controller.readOnly.value
                                  ? AppColors.blackColor
                                  : AppColors.redColor,
                        ),
                      ),
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
                    Obx(
                      () =>
                          controller.readOnly.value
                              ? InventoryBottomsheetComponentText(
                                readOnly1: controller.readOnly.value,
                                readOnly2: controller.readOnly.value,
                                controller1: controller.category,
                                controller2: controller.animalType,
                                label1: 'Category',
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
                              )
                              : Row(
                                children: [
                                  Flexible(
                                    child: Obx(
                                      () =>
                                          controller.categoryList.isEmpty
                                              ? Center(
                                                child: CommonProgressBar(
                                                  color: AppColors.blackColor,
                                                ),
                                              )
                                              : CustomDropDown(
                                                // isModelValueEnabled: true,
                                                // errorText: emptyCategory,
                                                // enabled:
                                                //     controller.dropDownReadOnly.value,
                                                selectedDropDownItem:
                                                    controller.category.text,
                                                listItems:
                                                    controller.categoryList,
                                                hintText: 'Select Category',
                                                notifyParent: (val) {
                                                  // controller
                                                  //     .selectedCategory
                                                  //     .value = val;
                                                  controller.category.text =
                                                      val.id.toString();
                                                },
                                              ),
                                    ),
                                  ),
                                  Flexible(
                                    child: Obx(
                                      () =>
                                          controller.animalTypeList.isEmpty
                                              ? Center(
                                                child: CommonProgressBar(
                                                  color: AppColors.blackColor,
                                                ),
                                              )
                                              : CustomDropDown(
                                                // isModelValueEnabled: true,
                                                // errorText: emptyAnimalCategory,
                                                // enabled:
                                                //     controller.dropDownReadOnly.value,
                                                hintText: 'Animal Type',
                                                selectedDropDownItem:
                                                    controller.animalType.text,
                                                listItems:
                                                    controller.animalTypeList,
                                                notifyParent: (val) {
                                                  // controller
                                                  //     .selectedAnimalType
                                                  //     .value = val;
                                                  controller.animalType.text =
                                                      val.id.toString();
                                                },
                                              ),
                                    ),
                                  ),
                                ],
                              ),
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
                      () => Row(
                        children: [
                          Flexible(
                            child: CommonTextField(
                              readOnly: controller.readOnly.value,
                              validator: (discount) {
                                if (discount!.isEmpty) {
                                  return emptyDiscount;
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
                              hintText: 'Enter Discount',
                              label: 'Discount (%)',
                              controller: controller.discount,
                            ),
                          ),
                          Flexible(
                            child: CustomDropDown(
                              // enabled: controller.dropDownReadOnly.value,
                              // selectedDropDownItem: controller.location.text,
                              // isModelValueEnabled: false,
                              // errorText: 'Select Location',
                              listItems: ['Shop', 'Godown'],
                              hintText: 'Location',
                              notifyParent: (val) {
                                controller.location.text = val;
                                customMessageOrErrorPrint(
                                  message:
                                      ' controller.isLoose ${controller.isLoose}',
                                );
                              },
                            ),
                          ),
                        ],
                      ),
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
                                child: Icon(
                                  CupertinoIcons.calendar_today,
                                  size: 20,
                                ),
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
                                      var body = {
                                        "name": controller.productName.text,
                                        "barcodes": controller.barcode.text,
                                        "quantity":
                                            double.tryParse(
                                              controller.quantity.text,
                                            ) ??
                                            0,
                                        "selling_price":
                                            double.tryParse(
                                              controller.sellingPrice.text,
                                            ) ??
                                            0,
                                        "purchase_price":
                                            double.tryParse(
                                              controller.purchasePrice.text,
                                            ) ??
                                            0,
                                        "location": controller.location.text,
                                        "stock_type": "packet",
                                        "isloosed": controller.isLoose,
                                        "isflavorRequired":
                                            controller
                                                    .isFlavorAndWeightNotRequired
                                                    .value
                                                ? false
                                                : true,
                                        "purchase_date":
                                            controller.purchaseDate.text,
                                        "expiry_date":
                                            controller.exprieDate.text,
                                        "category": controller.category.text,
                                        "animal_type":
                                            controller.animalType.text,
                                        "flavour": controller.flavor.text,
                                        "level": controller.level.text,
                                        "rack": controller.rack.text,
                                        "weight": controller.weight.text,
                                        "discount":
                                            double.tryParse(
                                              controller.discount.text,
                                            ) ??
                                            0,
                                      };
                                      controller.updateProductQuantity(
                                        body: body,
                                        productId:
                                            controller.data['productId']
                                                .toString(),
                                      );
                                    } else {
                                      AppLogger.debug(
                                        'Form validation - isLoose: ${controller.isLoose}',
                                        'ProductDetailView',
                                      );
                                      var body = {
                                        "product_id":
                                            controller.data['productId'],
                                        "quantity":
                                            controller.looseQuantity.text,
                                        "selling_price":
                                            controller.looseSellingPrice.text,
                                      };
                                      controller.updateLoosedProductQuantity(
                                        body: body,
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

  void showBarcode(TextEditingController qtyController) {
    commonBottomSheet(
      label: 'BarCode',
      onPressed: () {
        Get.back();
        controller.setData();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomPadding(
            paddingOption: OnlyPadding(top: 20),
            child: BarcodeWidget(
              barcode: Barcode.code128(),
              data: controller.barcode.text,
              height: 80,
              width: 200,
              drawText: true,
            ),
          ),
          SizedBox(
            width: 220,
            child: CommonTextField(
              label: 'Quantity',
              astraIsRequred: false,
              hintText: 'hintText',
              controller: qtyController,
            ),
          ),
          setHeight(height: 15),
          CommonButton(
            label: 'Generate Barcode',
            onTap: () {
              AppRoutes.navigateRoutes(
                routeName: AppRouteName.barcodePrintView,
                data: {
                  'productData': controller.data,
                  "qyt": double.tryParse(qtyController.text)?.toInt() ?? 1,
                },
              );
            },
          ),
          setHeight(height: 50),
        ],
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