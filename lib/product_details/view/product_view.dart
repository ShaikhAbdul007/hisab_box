import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/common_widget/common_progressbar.dart';
import 'package:inventory/common_widget/common_switch.dart';
import 'package:inventory/helper/helper.dart';
import '../../common_widget/common_button.dart';
import '../../common_widget/common_calender.dart';
import '../../common_widget/common_dropdown.dart';
import '../../common_widget/size.dart';
import '../../common_widget/textfiled.dart';
import '../../helper/app_message.dart';
import '../controller/controller.dart';
import '../widget/inventory_bottomsheep_component_text.dart';

class ProductView extends GetView<ProductController> {
  const ProductView({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonAppbar(
      isleadingButtonRequired: true,
      backgroundColor: AppColors.whiteColor,
      appBarLabel: 'Add Product',
      body: Form(
        key: controller.inventoryScanKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 10,
              children: [
                setHeight(height: 20),
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
                            controller.categoryList.isEmpty
                                ? Center(
                                  child: CommonProgressbar(
                                    color: AppColors.blackColor,
                                  ),
                                )
                                : CommonDropDown(
                                  listItems: controller.categoryList.value,
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
                                  hintText: 'Animal Type',
                                  listItems: controller.animalTypeList.value,
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
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 5,
                        ),
                        inputLength: 5,
                        keyboardType: TextInputType.number,
                        hintText: 'Enter stock',
                        label: 'Stock',
                        controller: controller.quantity,
                      ),
                    ),
                    Flexible(
                      child: CommonDropDown(
                        listItems: [true, false],
                        hintText: 'Select isLoose',
                        notifyParent: (val) {
                          controller.isLoose = val;
                          print(' controller.isLoose ${controller.isLoose}');
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
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 5,
                        ),
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
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 5,
                        ),

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
                  () => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
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
                      if (controller.inventoryScanKey.currentState!
                          .validate()) {
                        unfocus();
                        controller.saveNewProduct(
                          barcode: controller.barcodeValue.value,
                        );
                      }
                    },
                  ),
                ),
                setHeight(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// class LooseInventoryBottomsheetComponent extends StatelessWidget {
//   final GlobalKey<FormState> formkeys;
//   final InventroyController controller;

//   const LooseInventoryBottomsheetComponent({
//     super.key,
//     required this.formkeys,
//     required this.controller,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Form(
//       key: formkeys,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         spacing: 10,
//         children: [
//           InventoryBottomsheetComponentText(
//             readOnly1: true,
//             readOnly2: true,
//             controller1: controller.barcode,
//             controller2: controller.loooseProductName,
//             label1: 'Barcode',
//             hintText1: 'Enter barcode',
//             hintText2: 'Enter product name',
//             label2: 'Product name',
//             validator2: (name) {
//               if (name!.isEmpty) {
//                 return emptyProductName;
//               } else {
//                 return null;
//               }
//             },
//           ),
//           InventoryBottomsheetComponentText(
//             inputLength1: 5,
//             keyboardType1: TextInputType.numberWithOptions(
//               signed: false,
//               decimal: false,
//             ),
//             hintText1: 'Enter quantity',
//             label1: 'Quantity',
//             controller1: controller.looseQuantity,
//             validator1: (purchasePrice) {
//               if (purchasePrice!.isEmpty) {
//                 return emptyProductPurchasePrice;
//               } else {
//                 return null;
//               }
//             },
//             inputLength2: 5,
//             keyboardType2: TextInputType.numberWithOptions(
//               signed: false,
//               decimal: false,
//             ),
//             hintText2: 'Selling Price (sp)',
//             label2: 'Selling Price (₹)',
//             controller2: controller.sellingPrice,
//             validator2: (sellingPrice) {
//               if (sellingPrice!.isEmpty) {
//                 return emptyProductSellingPrice;
//               } else {
//                 return null;
//               }
//             },
//           ),
//           Obx(
//             () => CommonButton(
//               isLoading: controller.isLooseProductSave.value,
//               label: saveButton,
//               onTap: () async {
//                 if (formkeys.currentState!.validate()) {
//                   unfocus();
//                   controller.saveNewLooseProduct(
//                     barcode: controller.barcodeValue.value,
//                   );
//                 }
//               },
//             ),
//           ),
//           setHeight(height: 50),
//         ],
//       ),
//     );
//   }
// }

// class ManuallyInventoryBottomsheetComponent extends StatelessWidget {
//   final GlobalKey<FormState> formkeys;
//   final InventroyController controller;
//   final List<dynamic> listItems;

//   final dynamic Function(dynamic) notifyParent;
//   final void Function() manuallyInventoryOnTap;
//   final void Function() addInventoryOnTap;
//   const ManuallyInventoryBottomsheetComponent({
//     super.key,
//     required this.formkeys,
//     required this.controller,
//     required this.listItems,
//     required this.notifyParent,
//     required this.manuallyInventoryOnTap,
//     required this.addInventoryOnTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Form(
//       key: formkeys,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         spacing: 10,
//         children: [
//           CommonDropDown(
//             // selectedDropDownItem: controller.selectedManuallySell,
//             listItems: listItems,
//             hintText: 'Select',
//             notifyParent: notifyParent,
//           ),
//           CommonTextField(
//             validator: (v) {
//               if (v!.isEmpty) {
//                 return emptyProductQuantity;
//               } else {
//                 return null;
//               }
//             },
//             contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
//             inputLength: 3,
//             keyboardType: TextInputType.number,
//             hintText: 'Quantity',
//             label: 'Quantity',
//             controller: controller.looseQuantity,
//           ),

//           Obx(
//             () => Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 CommonButton(
//                   bgColor: AppColors.buttonGreenColor,
//                   width: 170,
//                   isLoading: controller.isLooseProductSave.value,
//                   label: 'Add More',
//                   onTap: addInventoryOnTap,
//                 ),
//                 controller.isDoneButtonReq.value
//                     ? CommonButton(
//                       width: 170,
//                       isLoading: controller.isLooseProductSave.value,
//                       label: 'Save',
//                       onTap: manuallyInventoryOnTap,
//                     )
//                     : Container(),
//               ],
//             ),
//           ),
//           setHeight(height: 50),
//         ],
//       ),
//     );
//   }
// }





 // for (int i = 0; i < controller.categoryList.length; i++) {
                      //   if (val == controller.categoryList[i].id) {
                      //     if (controller.categoryList[i].name == 'treat') {
                      //       controller.isTreatSelected.value = true;
                      //     } else {
                      //       controller.isTreatSelected.value = false;
                      //     }
                      //   }
                      // }