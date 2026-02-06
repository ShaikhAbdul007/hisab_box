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
      child: Stack(
        children: [
          CommonAppbar(
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
                      } else if (isloosedInventory) {
                        await _handleLooseInventory(barcodes);
                        return;
                      } else {
                        await sellInventory(barcodes, inventoryScanKey);
                      }
                    },
                  ),
                ),
              ],
            ),
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
