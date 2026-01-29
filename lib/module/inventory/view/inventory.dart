import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/common_widget/common_container.dart';
import 'package:inventory/common_widget/common_padding.dart';
import 'package:inventory/common_widget/common_progressbar.dart';
import 'package:inventory/module/inventory/model/product_model.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../common_widget/colors.dart';
import '../../../helper/helper.dart';
import '../../../helper/textstyle.dart';
import '../../../keys/keys.dart';
import '../../../routes/route_name.dart';
import '../../../routes/routes.dart';
import '../controller/inventroy_controller.dart';
import '../widget/show_dialog_boxs.dart';

class InventoryView extends GetView<InventroyController> {
  const InventoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isloosedInventory =
        controller.flag == false && controller.navigate == 'loose';

    return PopScope(
      canPop: false,
      child: CommonAppbar(
        backgroundColor: Colors.white,
        appBarLabel:
            isloosedInventory
                ? 'Loose Inventory'
                : (controller.flag == true ? 'Inventory' : 'Sell Product'),
        body: Stack(
          children: [
            ListView(
              children: [
                CustomPadding(
                  paddingOption: OnlyPadding(left: 18, top: 10),
                  child: Text(
                    controller.flag == true
                        ? 'Scan product barcode to add the product.'
                        : isloosedInventory
                        ? 'Scan product barcode to add the loose product.'
                        : 'Scan product barcode to sell the product.',
                    style: CustomTextStyle.customRaleway(
                      fontSize: 19,
                      color: AppColors.blackColor,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                CommonContainer(
                  height: 400,
                  width: 500,
                  margin: OnlyPadding(top: 40).getPadding(),
                  border: Border.all(color: AppColors.blackColor, width: 2.w),
                  radius: 3,
                  child: MobileScanner(
                    controller: controller.mobileScannerController,
                    onDetect: (barcodes) async {
                      if (barcodes.raw == null) return;
                      await controller.stopCameraAfterDetect(barcodes);
                      if (controller.flag == true) {
                        await productInventory(
                          barcodes,
                          inventoryScanKey,
                          isloosedInventory,
                        );
                        return;
                      }
                      if (isloosedInventory) {
                        await _handleLooseInventory(barcodes);
                        return;
                      }
                      await sellInventory(barcodes, inventoryScanKey);
                    },
                  ),
                ),
              ],
            ),
            Obx(
              () =>
                  controller.isExistingProductInfo.value
                      ? BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: CommonProgressbar(
                          color: AppColors.redColor,
                          size: 50,
                        ),
                      )
                      : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  // ===============================
  // SELL INVENTORY
  // ===============================
  Future<void> sellInventory(
    BarcodeCapture barcodes,
    GlobalKey<FormState> inventoryScanKey,
  ) async {
    final scannedValue = controller.barcodeValue.value;
    final isURL = Uri.tryParse(scannedValue)?.hasAbsolutePath ?? false;

    if (isURL) {
      _showInvalidBarcodeDialog();
      return;
    }

    final (bool exists, ProductModel? product) = await controller
        .existingProductInfo(scannedValue);

    if (!exists || product == null) {
      _showProductNotFoundDialog();
      return;
    }

    if (product.isLoosed == true) {
      checkProductStatusDialog(
        label: 'Is this product sold in Packet or Loose?',
        packetOnTap: () {
          Get.back();
          _handleSell(scannedValue, 'Packet', inventoryScanKey);
        },
        looseDoneOnTap: () {
          Get.back();
          _handleSell(scannedValue, 'Loose', inventoryScanKey);
        },
      );
      return;
    }

    _handleSell(scannedValue, 'Packet', inventoryScanKey);
  }

  // ===============================
  // PRODUCT INVENTORY
  // ===============================
  Future<void> productInventory(
    BarcodeCapture barcodes,
    GlobalKey<FormState> inventoryScanKey,
    bool isloosedInventory,
  ) async {
    final scannedValue = controller.barcodeValue.value;
    final isURL = Uri.tryParse(scannedValue)?.hasAbsolutePath ?? false;

    if (isURL) {
      _showInvalidBarcodeDialog();
      return;
    }

    final (bool exists, _) = await controller.existingProductInfo(scannedValue);

    if (exists) {
      exisitngProductDialog(
        message:
            '$scannedValue-${controller.existProductName.value}\n'
            'Already exists. Update quantity manually from inventory.',
        onPressed: () {
          Get.back();
          controller.mobileScannerController.start();
        },
      );
      return;
    }

    final res = await AppRoutes.futureNavigationToRoute(
      routeName: AppRouteName.productView,
      data: {'barcode': scannedValue, 'flag': isloosedInventory},
    );

    if (res == true) {
      controller.mobileScannerController.start();
    }
  }

  // ===============================
  // LOOSE INVENTORY FLOW
  // ===============================
  Future<void> _handleLooseInventory(BarcodeCapture barcodes) async {
    final scannedValue = controller.barcodeValue.value;
    final isURL = Uri.tryParse(scannedValue)?.hasAbsolutePath ?? false;

    if (isURL) {
      _showInvalidBarcodeDialog();
      return;
    }

    final (bool exists, ProductModel? product) = await controller
        .existingProductInfo(scannedValue);

    if (!exists || product == null) {
      _showProductNotFoundDialog();
      return;
    }

    final res = await AppRoutes.futureNavigationToRoute(
      routeName: AppRouteName.productView,
      data: {
        'barcode': scannedValue,
        'flag': true,
        'productName': product.name,
      },
    );

    if (res == true) {
      controller.mobileScannerController.start();
    }
  }

  // ===============================
  // COMMON SELL HANDLER
  // ===============================
  void _handleSell(
    String barcode,
    String sellType,
    GlobalKey<FormState> inventoryScanKey,
  ) {
    controller.handleScan(
      barcode: barcode,
      sellType: sellType,
      afterProductAdding: () {
        productSavingDialog(
          label: 'Scanning Done, product added',
          scanAgainOnTap: () async {
            Get.back();
            controller.mobileScannerController.start();
          },
          scanccingDoneOnTap: () async {
            Get.back();
            AppRoutes.navigateRoutes(routeName: AppRouteName.sellListAfterScan);
          },
        );
      },
      qtyIsNotEnough: _handleQtyNotEnough,
    );
  }

  // ===============================
  // COMMON DIALOGS
  // ===============================
  void _handleQtyNotEnough() {
    productNotWithScannedAvailableDialog(
      manualSellOnTap: () => Get.back(),
      '${controller.existProductName.value} product is out of stock.',
      scanAgainOnTap: () {
        Get.back();
        controller.mobileScannerController.start();
      },
      scanningDoneOnTap2: () {
        if (controller.scannedProductDetails.isNotEmpty) {
          Get.back();
          AppRoutes.navigateRoutes(
            routeName: AppRouteName.sellListAfterScan,
            data: {'productList': controller.scannedProductDetails},
          );
        } else {
          Get.back();
          controller.mobileScannerController.start();
          showMessage(message: 'Please scan the product first');
        }
      },
    );
  }

  void _showInvalidBarcodeDialog() {
    productNotAvailableDialog(
      productModel: controller.scannedProductDetails,
      label:
          "Scanned code contains a link, not a valid product number.\n"
          "If two codes are available, kindly scan the Barcode instead of the QR Code.\n"
          "Please scan the Barcode instead of QR Code.",
      scannedDoneOnTap: () {
        if (controller.scannedProductDetails.isNotEmpty) {
          Get.back();
          AppRoutes.navigateRoutes(
            routeName: AppRouteName.sellListAfterScan,
            data: {'productList': controller.scannedProductDetails},
          );
        } else {
          Get.back();
          controller.mobileScannerController.start();
          showMessage(message: 'Please scan the product first');
        }
      },
      onTap: () {
        Get.back();
        controller.mobileScannerController.start();
      },
    );
  }

  void _showProductNotFoundDialog() {
    productNotAvailableDialog(
      productModel: controller.scannedProductDetails,
      label: 'Scanned product is not available in stock or not in SHOP',
      scannedDoneOnTap: () {
        if (controller.scannedProductDetails.isNotEmpty) {
          Get.back();
          AppRoutes.navigateRoutes(
            routeName: AppRouteName.sellListAfterScan,
            data: {'productList': controller.scannedProductDetails},
          );
        } else {
          Get.back();
          controller.mobileScannerController.start();
          showMessage(message: 'Please scan the product first');
        }
      },
      onTap: () {
        Get.back();
        controller.mobileScannerController.start();
      },
    );
  }
}





















// class InventoryView extends GetView<InventroyController> {
//   const InventoryView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // bool isloosedInventory = false;
//     bool isloosedInventory =
//         controller.flag == false && controller.navigate == 'loose';
//     return PopScope(
//       canPop: false,
//       child: CommonAppbar(
//         backgroundColor: Colors.white,
//         appBarLabel:
//             isloosedInventory
//                 ? 'Loose Inventory'
//                 : (controller.flag == true ? 'Inventory' : 'Sell Product'),
//         body: Stack(
//           children: [
//             ListView(
//               children: [
//                 CustomPadding(
//                   paddingOption: OnlyPadding(left: 18, top: 10),
//                   child: Text(
//                     controller.flag == true
//                         ? 'Scan product barcode to add the product.'
//                         : isloosedInventory
//                         ? 'Scan product barcode to add the loose product.'
//                         : 'Scan product barcode to sell the product.',
//                     style: CustomTextStyle.customRaleway(
//                       fontSize: 19,
//                       color: AppColors.blackColor,
//                       letterSpacing: 1,
//                     ),
//                   ),
//                 ),
//                 CommonContainer(
//                   height: 400,
//                   width: 500,
//                   margin: OnlyPadding(top: 40, right: 0, left: 0).getPadding(),
//                   border: Border.all(color: AppColors.blackColor, width: 2.w),
//                   radius: 3,
//                   child: MobileScanner(
//                     controller: controller.mobileScannerController,
//                     onDetect: (barcodes) async {
//                       if (barcodes.raw != null) {
//                         if (controller.flag == true) {
//                           await controller.stopCameraAfterDetect(barcodes);
//                           productInventory(
//                             barcodes,
//                             inventoryScanKey,
//                             isloosedInventory,
//                           );
//                         } else if (isloosedInventory) {
//                           await controller.stopCameraAfterDetect(barcodes);
//                           String scannedValue = controller.barcodeValue.value;
//                           bool isURL =
//                               Uri.tryParse(scannedValue)?.hasAbsolutePath ??
//                               false;
//                           if (!isURL) {
//                             var res = await controller.existingProductInfo(
//                               controller.auth.currentUser!.uid,
//                               controller.barcodeValue.value,
//                               // controller.barcodeValue.value,
//                             );
//                             if (res.$1 == true) {
//                               controller.stopCameraAfterDetect(barcodes);
//                               var resss =
//                                   await AppRoutes.futureNavigationToRoute(
//                                     routeName: AppRouteName.productView,
//                                     data: {
//                                       'barcode': controller.barcodeValue.value,
//                                       'flag': isloosedInventory,
//                                       'productName': res.$2.name,
//                                     },
//                                   );

//                               if (resss == true) {
//                                 controller.mobileScannerController.start();
//                               }
//                             } else {
//                               productNotAvailableDialog(
//                                 productModel: controller.scannedProductDetails,
//                                 scannedDoneOnTap: () {
//                                   if (controller
//                                       .scannedProductDetails
//                                       .isNotEmpty) {
//                                     Get.back();
//                                     AppRoutes.navigateRoutes(
//                                       routeName: AppRouteName.sellListAfterScan,
//                                       data: {
//                                         'productList':
//                                             controller.scannedProductDetails,
//                                       },
//                                     );
//                                   } else {
//                                     Get.back();
//                                     controller.mobileScannerController.start();
//                                     showMessage(
//                                       message: 'Please scan the product first',
//                                     );
//                                   }
//                                 },
//                                 label:
//                                     'Scanned product is not available in stock Or Product is not in SHOP',
//                                 onTap: () {
//                                   Get.back();
//                                   controller.mobileScannerController.start();
//                                 },
//                               );
//                             }
//                           } else {
//                             productNotAvailableDialog(
//                               productModel: controller.scannedProductDetails,
//                               scannedDoneOnTap: () {
//                                 if (controller
//                                     .scannedProductDetails
//                                     .isNotEmpty) {
//                                   Get.back();
//                                   AppRoutes.navigateRoutes(
//                                     routeName: AppRouteName.sellListAfterScan,
//                                     data: {
//                                       'productList':
//                                           controller.scannedProductDetails,
//                                     },
//                                   );
//                                 } else {
//                                   Get.back();
//                                   controller.mobileScannerController.start();
//                                   showMessage(
//                                     message: 'Please scan the product first',
//                                   );
//                                 }
//                               },
//                               label:
//                                   "Scanned code contains a link, not a valid product number.Please check and scan again\nIf two codes are available, kindly scan the 📦 Barcode instead of the 🔲 QR Code.",
//                               onTap: () {
//                                 Get.back();
//                                 controller.mobileScannerController.start();
//                               },
//                             );
//                           }
//                         } else {
//                           await controller.stopCameraAfterDetect(barcodes);
//                           sellInventory(barcodes, inventoryScanKey);
//                         }
//                       }
//                     },

//                     //// Ondetct end
//                   ),
//                 ),
//               ],
//             ),
//             Obx(
//               () =>
//                   controller.isExistingProductInfo.value
//                       ? BackdropFilter(
//                         filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
//                         child: CommonProgressbar(
//                           color: AppColors.redColor,
//                           size: 50,
//                         ),
//                       )
//                       : SizedBox.shrink(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> sellInventory(
//     BarcodeCapture barcodes,
//     // BuildContext context,
//     GlobalKey<FormState> inventoryScanKey,
//   ) async {
//     await controller.stopCameraAfterDetect(barcodes);
//     String scannedValue = controller.barcodeValue.value;
//     bool isURL = Uri.tryParse(scannedValue)?.hasAbsolutePath ?? false;
//     if (!isURL) {
//       final (bool existProductOrNot, ProductModel productModel) existproduct =
//           await controller.existingProductInfo(
//             controller.auth.currentUser!.uid,
//             controller.barcodeValue.value,
//           );
//       print(existproduct.$1);
//       print(existproduct.$2.isLoosed);
//       print(existproduct.$2.quantity);

//       if (existproduct.$1 == true) {
//         if (existproduct.$2.isLoosed == true) {
//           checkProductStatusDialog(
//             label: 'Is this product sell in Packet or Loose',
//             packetOnTap: () {
//               Get.back();
//               controller.handleScan(
//                 barcode: controller.barcodeValue.value,
//                 sellType: 'Packet',
//                 afterProductAdding: () {
//                   productSavingDialog(
//                     label: 'Scanning Done, product added',
//                     scanAgainOnTap: () async {
//                       Get.back();
//                       controller.mobileScannerController.start();
//                     },
//                     scanccingDoneOnTap: () async {
//                       Get.back();
//                       AppRoutes.navigateRoutes(
//                         routeName: AppRouteName.sellListAfterScan,
//                       );
//                     },
//                   );
//                 },
//                 qtyIsNotEnough: () {
//                   productNotWithScannedAvailableDialog(
//                     manualSellOnTap: () {
//                       Get.back();
//                     },
//                     '${controller.existProductName.value} product is out of stock right now.',
//                     scanAgainOnTap: () {
//                       Get.back();
//                       controller.mobileScannerController.start();
//                     },
//                     scanningDoneOnTap2: () {
//                       if (controller.scannedProductDetails.isNotEmpty) {
//                         Get.back();
//                         AppRoutes.navigateRoutes(
//                           routeName: AppRouteName.sellListAfterScan,
//                           data: {
//                             'productList': controller.scannedProductDetails,
//                           },
//                         );
//                       } else {
//                         Get.back();
//                         controller.mobileScannerController.start();
//                         showMessage(message: 'Please scan the product first');
//                       }
//                     },
//                   );
//                 },
//               );
//             },
//             looseDoneOnTap: () {
//               Get.back();
//               controller.handleScan(
//                 barcode: controller.barcodeValue.value,
//                 sellType: 'Loose',
//                 //product: existproduct.$2,
//                 afterProductAdding: () {
//                   productSavingDialog(
//                     label: 'Scanning Done, product added',
//                     scanAgainOnTap: () async {
//                       Get.back();
//                       controller.mobileScannerController.start();
//                     },
//                     scanccingDoneOnTap: () async {
//                       Get.back();
//                       AppRoutes.navigateRoutes(
//                         routeName: AppRouteName.sellListAfterScan,
//                       );
//                     },
//                   );
//                 },
//                 qtyIsNotEnough: () {
//                   productNotWithScannedAvailableDialog(
//                     manualSellOnTap: () {
//                       Get.back();
//                       //  openManualySell(inventoryScanKey: inventoryScanKey);
//                     },
//                     '${controller.existProductName.value} product is out of stock right now.',
//                     scanAgainOnTap: () {
//                       Get.back();
//                       controller.mobileScannerController.start();
//                     },
//                     scanningDoneOnTap2: () {
//                       if (controller.scannedProductDetails.isNotEmpty) {
//                         Get.back();
//                         AppRoutes.navigateRoutes(
//                           routeName: AppRouteName.sellListAfterScan,
//                           data: {
//                             'productList': controller.scannedProductDetails,
//                           },
//                         );
//                       } else {
//                         Get.back();
//                         controller.mobileScannerController.start();
//                         showMessage(message: 'Please scan the product first');
//                       }
//                     },
//                   );
//                 },
//               );
//             },
//           );
//         } else {
//           controller.handleScan(
//             barcode: controller.barcodeValue.value,
//             sellType: 'Packet',
//             afterProductAdding: () {
//               productSavingDialog(
//                 label: 'Scanning Done, product added',
//                 scanAgainOnTap: () async {
//                   Get.back();
//                   controller.mobileScannerController.start();
//                 },
//                 scanccingDoneOnTap: () async {
//                   Get.back();
//                   AppRoutes.navigateRoutes(
//                     routeName: AppRouteName.sellListAfterScan,
//                   );
//                 },
//               );
//             },
//             qtyIsNotEnough: () {
//               productNotWithScannedAvailableDialog(
//                 manualSellOnTap: () {
//                   Get.back();
//                   //  openManualySell(inventoryScanKey: inventoryScanKey);
//                 },
//                 '${controller.existProductName.value} product is out of stock right now.',
//                 scanAgainOnTap: () {
//                   Get.back();
//                   controller.mobileScannerController.start();
//                 },
//                 scanningDoneOnTap2: () {
//                   if (controller.scannedProductDetails.isNotEmpty) {
//                     Get.back();
//                     AppRoutes.navigateRoutes(
//                       routeName: AppRouteName.sellListAfterScan,
//                       data: {'productList': controller.scannedProductDetails},
//                     );
//                   } else {
//                     Get.back();
//                     controller.mobileScannerController.start();
//                     showMessage(message: 'Please scan the product first');
//                   }
//                 },
//               );
//             },
//           );
//         }
//       } else {
//         productNotAvailableDialog(
//           productModel: controller.scannedProductDetails,
//           scannedDoneOnTap: () {
//             if (controller.scannedProductDetails.isNotEmpty) {
//               Get.back();
//               AppRoutes.navigateRoutes(
//                 routeName: AppRouteName.sellListAfterScan,
//                 data: {'productList': controller.scannedProductDetails},
//               );
//             } else {
//               Get.back();
//               controller.mobileScannerController.start();
//               showMessage(message: 'Please scan the product first');
//             }
//           },
//           label:
//               'Scanned product is not available in stock Or Product is not in SHOP',
//           onTap: () {
//             Get.back();
//             controller.mobileScannerController.start();
//           },
//         );
//       }
//     } else {
//       productNotAvailableDialog(
//         productModel: controller.scannedProductDetails,
//         scannedDoneOnTap: () {
//           if (controller.scannedProductDetails.isNotEmpty) {
//             Get.back();
//             AppRoutes.navigateRoutes(
//               routeName: AppRouteName.sellListAfterScan,
//               data: {'productList': controller.scannedProductDetails},
//             );
//           } else {
//             Get.back();
//             controller.mobileScannerController.start();
//             showMessage(message: 'Please scan the product first');
//           }
//         },
//         label:
//             "Scanned code contains a link, not a valid product number.Please check and scan again\nIf two codes are available, kindly scan the Barcode instead of the QR Code.",
//         onTap: () {
//           Get.back();
//           controller.mobileScannerController.start();
//         },
//       );
//     }
//   }

//   Future<void> productInventory(
//     BarcodeCapture barcodes,
//     GlobalKey<FormState> inventoryScanKey,
//     // BuildContext context,
//     bool isloosedInventory,
//   ) async {
//     await controller.stopCameraAfterDetect(barcodes);
//     String scannedValue = controller.barcodeValue.value;
//     customMessageOrErrorPrint(message: 'scannedValue is $scannedValue');
//     bool isURL = Uri.tryParse(scannedValue)?.hasAbsolutePath ?? false;
//     if (!isURL) {
//       var exist = await controller.existingProductInfo(
//         controller.auth.currentUser!.uid,
//         controller.barcodeValue.value,
//       );
//       if (exist.$1) {
//         String message =
//             '${controller.barcodeValue.value}-${controller.existProductName.value}\nAlready exist if you want to updated quantity.\nDo it manually form inventory list.';
//         exisitngProductDialog(
//           message: message,
//           onPressed: () {
//             Get.back();
//             controller.mobileScannerController.start();
//           },
//         );
//       } else {
//         controller.stopCameraAfterDetect(barcodes);
//         var res = await AppRoutes.futureNavigationToRoute(
//           routeName: AppRouteName.productView,
//           data: {
//             'barcode': controller.barcodeValue.value,
//             'flag': isloosedInventory,
//           },
//         );
//         if (res == true) {
//           controller.mobileScannerController.start();
//         }
//       }
//     } else {
//       productNotAvailableDialog(
//         scannedDoneOnTap: () {
//           if (controller.scannedProductDetails.isNotEmpty) {
//             Get.back();
//             AppRoutes.navigateRoutes(
//               routeName: AppRouteName.sellListAfterScan,
//               data: {'productList': controller.scannedProductDetails},
//             );
//           } else {
//             Get.back();
//             controller.mobileScannerController.start();
//             showMessage(message: 'Please scan the product first');
//           }
//         },
//         productModel: controller.scannedProductDetails,
//         label:
//             "Scanned code contains a link, not a valid product number.Please check and scan again\nIf two codes are available, kindly scan the Barcode instead of the QR Code.",
//         onTap: () {
//           Get.back();
//           controller.mobileScannerController.start();
//         },
//       );
//     }
//   }
// }






  // void openManualySell({required GlobalKey<FormState> inventoryScanKey}) {
  //   openManuallySellBottomSheet(
  //     onPressedOnTap: () {
  //       // controller.clear();
  //       controller.cameraStart();
  //     },
  //     formkeys: inventoryScanKey,
  //     child: Obx(
  //       () =>
  //           controller.isfullLooseSellingListLoading.value
  //               ? CommonProgressbar(color: AppColors.blackColor)
  //               : controller.fullLooseSellingList.isEmpty
  //               ? Column(
  //                 children: [
  //                   CommonNodatafound(message: 'No Loose Data Found', size: 15),
  //                   setHeight(height: 30),
  //                 ],
  //               )
  //               :
  //               // ManuallyInventoryBottomsheetComponent(
  //               //   controller: controller,
  //               //   formkeys: inventoryScanKey,
  //               //   addInventoryOnTap: () {
  //               //     if (inventoryScanKey.currentState!.validate()) {
  //               //       ProductModel selectedProduct = controller
  //               //           .fullLooseSellingList
  //               //           .firstWhere(
  //               //             (p) => p.id == controller.selectedManuallySell,
  //               //           );
  //               //       unfocus();
  //               //       if (selectedProduct.isLooseCategory == true) {
  //               //         controller.handleLooseScan(product: selectedProduct);
  //               //         controller.selectedManuallySell = null;
  //               //         controller.looseQuantity.clear();
  //               //         controller.isDoneButtonReq.value = true;
  //               //       } else {
  //               //         if (controller.looseOldQty >
  //               //             int.parse(controller.looseQuantity.text)) {
  //               //           controller.handleLooseScan(product: selectedProduct);
  //               //           controller.selectedManuallySell = null;
  //               //           controller.looseQuantity.clear();
  //               //           controller.isDoneButtonReq.value = true;
  //               //         } else {
  //               //           showSnackBar(
  //               //             error:
  //               //                 "Product is out of stock\nYou cannot add more than available stock.",
  //               //           );
  //               //         }
  //               //       }
  //               //     }
  //               //   },
  //               //   listItems: controller.fullLooseSellingList,
  //               //   notifyParent: (np) {
  //               //     controller.selectedManuallySell = np;
  //               //   },
  //               //   manuallyInventoryOnTap: () async {
  //               //     if (controller.scannedProductDetails.isNotEmpty) {
  //               //       Get.back();
  //               //       AppRoutes.navigateRoutes(
  //               //         routeName: AppRouteName.sellListAfterScan,
  //               //         data: {'productList': controller.scannedProductDetails},
  //               //       );
  //               //     } else {
  //               //       showMessage(message: 'Please scan the product first');
  //               //     }
  //               //   },
  //               // ),
  //               SizedBox(),
  //     ),
  //   );
  // }



// else if (controller.flag == false &&
//                         controller.navigate == 'loose') {
//                       await controller.stopCameraAfterDetect(barcodes);
//                       String scannedValue = controller.barcodeValue.value;

//                       bool isURL =
//                           Uri.tryParse(scannedValue)?.hasAbsolutePath ?? false;
//                       if (!isURL) {
//                         await controller.existingProductInfo(
//                           controller.auth.currentUser!.uid,
//                           controller.barcodeValue.value,
//                         );
//                         var res = await controller.fetchLooseProductByBarcode(
//                           barcode: controller.barcodeValue.value,
//                         );
//                         if (res == true) {
//                           openLooseInventoryBottomSheet(
//                             formkeys: inventoryScanKey,
//                           );
//                         } else {
//                           productNotAvailableDialog(
//                             context,
//                             'Scanned product is not available in stock',
//                             onTap: () {
//                               Get.back();
//                               controller.mobileScannerController.start();
//                             },
//                           );
//                         }
//                       } else {
//                         productNotAvailableDialog(
//                           context,
//                           "Scanned code contains a link, not a valid product number.Please check and scan again\n"
//                           "If two codes are available, kindly scan the 📦 Barcode instead of the 🔲 QR Code.",
//                           onTap: () {
//                             Get.back();
//                             controller.mobileScannerController.start();
//                           },
//                         );
//                       }
//                     }