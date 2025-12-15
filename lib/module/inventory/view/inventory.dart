import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/common_widget/common_nodatafound.dart';
import 'package:inventory/common_widget/common_padding.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../common_widget/colors.dart';
import '../../../common_widget/common_progressbar.dart';
import '../../../helper/helper.dart';
import '../../../helper/textstyle.dart';
import '../../../keys/keys.dart';
import '../../../routes/route_name.dart';
import '../../../routes/routes.dart';
import '../controller/inventroy_controller.dart';
import '../widget/inventory_bottom_sheets.dart';
import '../widget/show_dialog_boxs.dart';

class InventoryView extends GetView<InventroyController> {
  const InventoryView({super.key});

  @override
  Widget build(BuildContext context) {
    bool isloosedInventory = false;
    isloosedInventory =
        controller.flag == false && controller.navigate == 'loose';
    return PopScope(
      canPop: false,
      child: CommonAppbar(
        backgroundColor: Colors.white,
        appBarLabel:
            isloosedInventory
                ? 'Loose Inventory'
                : (controller.flag == true ? 'Inventory' : 'Sell Product'),
        body: ListView(
          children: [
            CustomPadding(
              paddingOption: OnlyPadding(left: 18, top: 10),
              child: Text(
                controller.flag == true
                    ? 'Scan product barcode to add the product.'
                    : 'Scan product barcode to sell the product.',
                style: CustomTextStyle.customOpenSans(
                  fontSize: 17,
                  color: AppColors.blackColor,
                  letterSpacing: 1,
                ),
              ),
            ),
            Container(
              height: 300.h,
              width: 400.w,
              margin: OnlyPadding(top: 100, right: 20, left: 20).getPadding(),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.blackColor, width: 5.w),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: MobileScanner(
                controller: controller.mobileScannerController,
                onDetect: (barcodes) async {
                  if (barcodes.raw != null) {
                    if (controller.flag == true) {
                      await controller.stopCameraAfterDetect(barcodes);
                      productInventory(
                        barcodes,
                        inventoryScanKey,

                        isloosedInventory,
                      );
                    } else if (isloosedInventory) {
                      String scannedValue = controller.barcodeValue.value;
                      bool isURL =
                          Uri.tryParse(scannedValue)?.hasAbsolutePath ?? false;
                      var res = await controller.existingProductInfo(
                        controller.auth.currentUser!.uid,
                        controller.barcodeValue.value,
                      );
                      if (res.$1 == true) {
                      } else {
                        var barcode = await controller
                            .fetchLooseProductByBarcode(
                              barcode: controller.barcodeValue.value,
                            );
                      }
                    } else {
                      await controller.stopCameraAfterDetect(barcodes);
                      String scannedValue = controller.barcodeValue.value;
                      sellInventory(barcodes, inventoryScanKey);
                    }
                  }
                },

                //// Ondetct end
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> sellInventory(
    BarcodeCapture barcodes,
    // BuildContext context,
    GlobalKey<FormState> inventoryScanKey,
  ) async {
    await controller.stopCameraAfterDetect(barcodes);
    String scannedValue = controller.barcodeValue.value;
    bool isURL = Uri.tryParse(scannedValue)?.hasAbsolutePath ?? false;
    if (!isURL) {
      var existproduct = await controller.existingProductInfo(
        controller.auth.currentUser!.uid,
        controller.barcodeValue.value,
      );
      if (existproduct.$1 == true) {
        controller.handleScan(
          product: existproduct.$2,
          afterProductAdding: () {
            productSavingDialog(
              label: 'Scanning Done, product added',
              // manualSellOnTap: () {
              //   Get.back();
              //   openManualySell(inventoryScanKey: inventoryScanKey);
              // },
              scanAgainOnTap: () async {
                Get.back();
                controller.mobileScannerController.start();
              },
              scanccingDoneOnTap: () async {
                Get.back();
                AppRoutes.navigateRoutes(
                  routeName: AppRouteName.sellListAfterScan,
                );
              },
            );
          },
          qtyIsNotEnough: () {
            productNotWithScannedAvailableDialog(
              manualSellOnTap: () {
                Get.back();
                openManualySell(inventoryScanKey: inventoryScanKey);
              },
              '${controller.existProductName.value} product is out of stock right now. you already scanned ${controller.scannedQty.value} NO',
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
          },
        );
      } else {
        productNotAvailableDialog(
          label: 'Scanned product is not available in stock ',
          onTap: () {
            Get.back();
            controller.mobileScannerController.start();
          },
        );
      }
    } else {
      productNotAvailableDialog(
        label:
            "Scanned code contains a link, not a valid product number.Please check and scan again\nIf two codes are available, kindly scan the 📦 Barcode instead of the 🔲 QR Code.",
        onTap: () {
          Get.back();
          controller.mobileScannerController.start();
        },
      );
    }
  }

  Future<void> productInventory(
    BarcodeCapture barcodes,
    GlobalKey<FormState> inventoryScanKey,
    // BuildContext context,
    bool isloosedInventory,
  ) async {
    await controller.stopCameraAfterDetect(barcodes);
    String scannedValue = controller.barcodeValue.value;
    customMessageOrErrorPrint(message: 'scannedValue is $scannedValue');
    bool isURL = Uri.tryParse(scannedValue)?.hasAbsolutePath ?? false;
    if (!isURL) {
      var exist = await controller.existingProductInfo(
        controller.auth.currentUser!.uid,
        controller.barcodeValue.value,
      );
      if (exist.$1) {
        String message =
            '${controller.barcodeValue.value}-${controller.existProductName.value}\nAlready exist if you want to updated quantity.\nDo it manually form inventory list.';
        exisitngProductDialog(
          message: message,
          onPressed: () {
            Get.back();
            controller.mobileScannerController.start();
          },
        );
      } else {
        controller.stopCameraAfterDetect(barcodes);
        var res = await AppRoutes.futureNavigationToRoute(
          routeName: AppRouteName.productView,
          data: {
            'barcode': controller.barcodeValue.value,
            'flag': isloosedInventory,
          },
        );
        if (res == true) {
          controller.mobileScannerController.start();
        }
      }
    } else {
      productNotAvailableDialog(
        label:
            "Scanned code contains a link, not a valid product number.Please check and scan again\nIf two codes are available, kindly scan the 📦 Barcode instead of the 🔲 QR Code.",
        onTap: () {
          Get.back();
          controller.mobileScannerController.start();
        },
      );
    }
  }

  void openManualySell({required GlobalKey<FormState> inventoryScanKey}) {
    openManuallySellBottomSheet(
      onPressedOnTap: () {
        // controller.clear();
        controller.cameraStart();
      },
      formkeys: inventoryScanKey,
      child: Obx(
        () =>
            controller.isfullLooseSellingListLoading.value
                ? CommonProgressbar(color: AppColors.blackColor)
                : controller.fullLooseSellingList.isEmpty
                ? Column(
                  children: [
                    CommonNodatafound(message: 'No Loose Data Found', size: 15),
                    setHeight(height: 30),
                  ],
                )
                :
                // ManuallyInventoryBottomsheetComponent(
                //   controller: controller,
                //   formkeys: inventoryScanKey,
                //   addInventoryOnTap: () {
                //     if (inventoryScanKey.currentState!.validate()) {
                //       ProductModel selectedProduct = controller
                //           .fullLooseSellingList
                //           .firstWhere(
                //             (p) => p.id == controller.selectedManuallySell,
                //           );
                //       unfocus();
                //       if (selectedProduct.isLooseCategory == true) {
                //         controller.handleLooseScan(product: selectedProduct);
                //         controller.selectedManuallySell = null;
                //         controller.looseQuantity.clear();
                //         controller.isDoneButtonReq.value = true;
                //       } else {
                //         if (controller.looseOldQty >
                //             int.parse(controller.looseQuantity.text)) {
                //           controller.handleLooseScan(product: selectedProduct);
                //           controller.selectedManuallySell = null;
                //           controller.looseQuantity.clear();
                //           controller.isDoneButtonReq.value = true;
                //         } else {
                //           showSnackBar(
                //             error:
                //                 "Product is out of stock\nYou cannot add more than available stock.",
                //           );
                //         }
                //       }
                //     }
                //   },
                //   listItems: controller.fullLooseSellingList,
                //   notifyParent: (np) {
                //     controller.selectedManuallySell = np;
                //   },
                //   manuallyInventoryOnTap: () async {
                //     if (controller.scannedProductDetails.isNotEmpty) {
                //       Get.back();
                //       AppRoutes.navigateRoutes(
                //         routeName: AppRouteName.sellListAfterScan,
                //         data: {'productList': controller.scannedProductDetails},
                //       );
                //     } else {
                //       showMessage(message: 'Please scan the product first');
                //     }
                //   },
                // ),
                SizedBox(),
      ),
    );
  }
}








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