import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/module/inventory/model/product_model.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../common_widget/colors.dart';
import '../../../common_widget/common_appbar.dart';
import '../../../helper/helper.dart';
import '../../../routes/routes.dart';
import '../controller/inventroy_controller.dart';
import '../widget/inventory_bottom_sheets.dart';
import '../widget/show_dialog_boxs.dart';

class InventoryView extends GetView<InventroyController> {
  const InventoryView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.flag = controller.data['flag'];

    controller.navigate = controller.data['navigate'];
    final inventoryScanKey = GlobalKey<FormState>();
    return CommonAppbar(
      appBarLabel:
          (controller.flag == false && controller.navigate == 'loose')
              ? 'Loose Inventory'
              : (controller.flag == true ? 'Inventory' : 'Sell Product'),
      firstActionChild:
          ((controller.flag == false && controller.navigate == 'loose') ||
                  controller.flag == true)
              ? Container()
              : InkWell(
                onTap: () {
                  openManualySell(inventoryScanKey: inventoryScanKey);
                },

                child: Icon(Icons.sell),
              ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              height: 600,
              width: 400,
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.amberColorShade100,
                  width: 8,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              child: MobileScanner(
                controller: controller.mobileScannerController,
                onDetect: (barcodes) async {
                  if (barcodes.raw != null) {
                    if (controller.flag == true) {
                      await productInventory(
                        barcodes,
                        inventoryScanKey,
                        context,
                      );
                    } else if (controller.flag == false &&
                        controller.navigate == 'loose') {
                      await controller.stopCameraAfterDetect(barcodes);
                      String scannedValue = controller.barcodeValue.value;
                      bool isURL =
                          Uri.tryParse(scannedValue)?.hasAbsolutePath ?? false;
                      if (!isURL) {
                        var fetchLooseProductByBarcode = await controller
                            .fetchLooseProductByBarcode(
                              barcode: controller.barcodeValue.value,
                            );

                        if (fetchLooseProductByBarcode == false) {
                          String message =
                              '${controller.barcodeValue.value}-${controller.existProductName.value} product does not mark as loose sell,\nPlease mark it as loose sell form stock';
                          exisitngProductDialog(
                            message: message,
                            onPressed: () {
                              Get.back();
                              controller.mobileScannerController.start();
                            },
                          );
                        } else {
                          openLooseInventoryBottomSheet(
                            controller: controller,
                            formkeys: inventoryScanKey,
                          );
                        }
                      } else {
                        productNotAvailableDialog(
                          context,
                          "Scanned code contains a link, not a valid product number.Please check and scan again\n"
                          "If two codes are available, kindly scan the 📦 Barcode instead of the 🔲 QR Code.",
                          onTap: () {
                            Get.back();
                            controller.mobileScannerController.start();
                          },
                        );
                      }
                    } else {
                      await sellInventory(barcodes, context, inventoryScanKey);
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> sellInventory(
    BarcodeCapture barcodes,
    BuildContext context,
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
              context: context,
              label: 'Scanning Done, product added',
              manualSellOnTap: () {
                Get.back();
                openManualySell(inventoryScanKey: inventoryScanKey);
              },
              scanAgainOnTap: () async {
                Get.back();
                controller.mobileScannerController.start();
              },
              scanccingDoneOnTap: () async {
                if (controller.scannedProductDetails.isNotEmpty) {
                  Get.back();
                  AppRoutes.navigateRoutes(
                    routeName: AppRouteName.sellListAfterScan,
                    data: {'productList': controller.scannedProductDetails},
                  );
                } else {
                  showMessage(message: 'Please scan the product first');
                }
              },
            );
          },
          qtyIsNotEnough: () {
            productNotWithScannedAvailableDialog(
              manualSellOnTap: () {
                Get.back();
                openManualySell(inventoryScanKey: inventoryScanKey);
              },
              context,
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
          context,
          'Scanned product is not available in stock ',
          onTap: () {
            Get.back();
            controller.mobileScannerController.start();
          },
        );
      }
    } else {
      productNotAvailableDialog(
        context,
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
    BuildContext context,
  ) async {
    await controller.stopCameraAfterDetect(barcodes);
    String scannedValue = controller.barcodeValue.value;
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
        openInventoryBottomSheet(
          formkeys: inventoryScanKey,
          controller: controller,
        );
      }
    } else {
      productNotAvailableDialog(
        context,
        "Scanned code contains a link, not a valid product number.Please check and scan again\nIf two codes are available, kindly scan the 📦 Barcode instead of the 🔲 QR Code.",
        onTap: () {
          Get.back();
          controller.mobileScannerController.start();
        },
      );
    }
  }

  openManualySell({required GlobalKey<FormState> inventoryScanKey}) {
    openManuallySellBottomSheet(
      controller: controller,
      addInventoryOnTap: () {
        if (inventoryScanKey.currentState!.validate()) {
          ProductModel selectedProduct = controller.fullLooseSellingList
              .firstWhere((p) => p.id == controller.selectedManuallySell);
          unfocus();
          if (selectedProduct.isLooseCategory == true) {
            controller.handleLooseScan(product: selectedProduct);
            controller.selectedManuallySell = null;
            controller.looseQuantity.clear();
            controller.isDoneButtonReq.value = true;
          } else {
            if (controller.looseOldQty >
                int.parse(controller.looseQuantity.text)) {
              print('object');
              controller.handleLooseScan(product: selectedProduct);
              controller.selectedManuallySell = null;
              controller.looseQuantity.clear();
              controller.isDoneButtonReq.value = true;
            } else {
              showSnackBar(
                error:
                    "Product is out of stock\nYou cannot add more than available stock.",
              );
            }
          }
        }
      },
      manuallyInventoryOnTap: () async {
        if (controller.scannedProductDetails.isNotEmpty) {
          Get.back();
          AppRoutes.navigateRoutes(
            routeName: AppRouteName.sellListAfterScan,
            data: {'productList': controller.scannedProductDetails},
          );
        } else {
          showMessage(message: 'Please scan the product first');
        }
      },
      formkeys: inventoryScanKey,
      listItems: controller.fullLooseSellingList,
      notifyParent: (np) {
        controller.selectedManuallySell = np;
      },
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