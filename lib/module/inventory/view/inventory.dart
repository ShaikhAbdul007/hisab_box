import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/common_bottom_sheet.dart';
import 'package:inventory/common_widget/common_dialogue.dart';
import 'package:inventory/module/inventory/model/product_model.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../common_widget/colors.dart';
import '../../../common_widget/common_appbar.dart';
import '../../../common_widget/common_button.dart';
import '../../../common_widget/common_popup_appbar.dart';
import '../../../common_widget/size.dart';
import '../../../helper/helper.dart';
import '../../../helper/textstyle.dart';
import '../../../routes/routes.dart';
import '../controller/inventroy_controller.dart';
import '../widget/inventory_bottomsheet_component.dart';

class InventoryView extends GetView<InventroyController> {
  const InventoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final inventoryScanKey = GlobalKey<FormState>();
    return CommonAppbar(
      appBarLabel:
          controller.flag == false && controller.navigate == 'loose'
              ? 'Loose Inventory'
              : controller.flag == true
              ? 'Inventory'
              : 'Sell Product',

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
                      await controller.stopCameraAfterDetect(barcodes);
                      String scannedValue = controller.barcodeValue.value;
                      bool isURL =
                          Uri.tryParse(scannedValue)?.hasAbsolutePath ?? false;
                      if (!isURL) {
                        var exist = await controller.existingProductInfo(
                          controller.auth.currentUser!.uid,
                          controller.barcodeValue.value,
                        );
                        if (exist.$1) {
                          String message =
                              '${controller.barcodeValue.value}-${controller.existProductName.value}\nAlready exist if you want to updated quantity.\nDo it manually form inventory list.';
                          exisitngProductDialog(message: message);
                        } else {
                          openInventoryBottomSheet(formkeys: inventoryScanKey);
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
                      await controller.stopCameraAfterDetect(barcodes);
                      String scannedValue = controller.barcodeValue.value;
                      bool isURL =
                          Uri.tryParse(scannedValue)?.hasAbsolutePath ?? false;
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
                                context,
                                'Scanning Done, product added',
                              );
                            },
                            qtyIsNotEnough: () {
                              productNotWithScannedAvailableDialog(
                                context,
                                '${controller.existProductName.value} you scanned is out of stock right now. you already scanned ${controller.scannedQty.value} NO',
                                onTap: () {
                                  Get.back();
                                  controller.mobileScannerController.start();
                                },
                                onTap2: () {
                                  if (controller
                                      .scannedProductDetails
                                      .isNotEmpty) {
                                    Get.back();
                                    AppRoutes.navigateRoutes(
                                      routeName: AppRouteName.sellListAfterScan,
                                      data: {
                                        'productList':
                                            controller.scannedProductDetails,
                                      },
                                    );
                                  } else {
                                    Get.back();
                                    controller.mobileScannerController.start();
                                    showMessage(
                                      message: 'Please scan the product first',
                                    );
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
                          "Scanned code contains a link, not a valid product number.Please check and scan again\n"
                          "If two codes are available, kindly scan the 📦 Barcode instead of the 🔲 QR Code.",
                          onTap: () {
                            Get.back();
                            controller.mobileScannerController.start();
                          },
                        );
                      }
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

  void exisitngProductDialog({required String message}) {
    Get.defaultDialog(
      title: '',
      titleStyle: CustomTextStyle.customNato(fontSize: 0),
      titlePadding: EdgeInsets.zero,
      barrierDismissible: false,
      content: Column(
        children: [
          CommonPopupAppbar(
            label: '⚠️ Alert',
            onPressed: () {
              Get.back();
              controller.mobileScannerController.start();
            },
          ),
          Divider(),
          Text(message, style: CustomTextStyle.customNato()),
        ],
      ),
    );
  }

  productNotAvailableDialog(
    BuildContext context,
    String label, {
    required void Function() onTap,
  }) {
    commonDialogBox(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Text(
              '⚠️ Error',
              style: CustomTextStyle.customRaleway(fontWeight: FontWeight.bold),
            ),
          ),
          setHeight(height: 10),
          Text(label, style: CustomTextStyle.customRaleway()),
          setHeight(height: 10),
          CommonButton(label: 'ok', onTap: onTap),
          setHeight(height: 30),
        ],
      ),
    );
  }

  productNotWithScannedAvailableDialog(
    BuildContext context,
    String label, {
    required void Function() onTap,
    required void Function() onTap2,
  }) {
    commonDialogBox(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Text(
              '⚠️ Error',
              style: CustomTextStyle.customRaleway(fontWeight: FontWeight.bold),
            ),
          ),
          setHeight(height: 10),
          Text(label, style: CustomTextStyle.customRaleway()),
          setHeight(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              CommonButton(width: 120, label: 'Scan Again', onTap: onTap),
              CommonButton(width: 150, label: 'Scanning Done', onTap: onTap2),
            ],
          ),
          setHeight(height: 30),
        ],
      ),
    );
  }

  productSavingDialog(BuildContext context, String label) {
    commonDialogBox(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Text('', style: CustomTextStyle.customRaleway(fontSize: 0)),
          ),
          setHeight(height: 10),
          Text(label, style: CustomTextStyle.customRaleway(fontSize: 15)),
          setHeight(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              CommonButton(
                width: 120,
                label: 'Scan Again',
                onTap: () async {
                  Get.back();
                  controller.mobileScannerController.start();
                },
              ),
              CommonButton(
                width: 140,
                label: 'Scanning Done',
                onTap: () async {
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
              ),
            ],
          ),
          setHeight(height: 30),
        ],
      ),
    );
  }

  openInventoryBottomSheet({required GlobalKey<FormState> formkeys}) {
    commonBottomSheet(
      label: 'Product Info',
      onPressed: () {
        controller.clear();
        controller.cameraStart();
      },
      child: InventoryBottomsheetComponent(
        formkeys: formkeys,
        controller: controller,
      ),
    );
  }

  openLooseInventoryBottomSheet({required GlobalKey<FormState> formkeys}) {
    commonBottomSheet(
      label: 'Loose Product Info',
      onPressed: () {
        controller.clear();
        controller.cameraStart();
      },
      child: ConstrainedBox(
        constraints: BoxConstraints(
          // Make sure the scroll view fills the screen if content is short
          minHeight: 100, // header height
        ),
        child: LooseInventoryBottomsheetComponent(
          formkeys: formkeys,
          controller: controller,
        ),
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