import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/common_widget/common_progressbar.dart';
import 'package:inventory/helper/shop_type.dart';
import 'package:inventory/module/inventory/model/product_model.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../common_widget/colors.dart';
import '../../../helper/helper.dart';
import '../../../helper/logger.dart';
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

    final bool isClothingShop =
        controller.shopTypeEnum == ShopType.clothingShop;

    AppLogger.info(
      'isloosedInventory: $isloosedInventory flag: ${controller.flag}',
    );

    // ── Labels ──────────────────────────────────────────────────────
    final String appBarLabel =
        isloosedInventory
            ? controller.shopTypeEnum.config.looseStockGridLabel
            : (controller.flag == true ? 'Inventory' : 'Sell Product');

    final String instructionText =
        controller.flag == true
            ? 'Point the camera at a product barcode to add it to inventory.'
            : isloosedInventory
            ? 'Scan a barcode to add a ${controller.shopTypeEnum.config.looseStockGridLabel.toLowerCase()} product.'
            : 'Point the camera at a product barcode to sell it.';

    return PopScope(
      canPop: false,
      child: Stack(
        children: [
          CommonAppbar(
            backgroundColor: AppColors.blackColor,
            appBarLabel: appBarLabel,
            body: Stack(
              children: [
                // ── Full-screen camera ─────────────────────────────
                Positioned.fill(
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
                          isClothingShop ? 'clothing' : 'packet',
                        );
                        return;
                      } else if (isloosedInventory &&
                          !controller.shopTypeEnum.config.supportsGRStock) {
                        await _handleLooseInventory(barcodes);
                        return;
                      } else if (isloosedInventory &&
                          controller.shopTypeEnum.config.supportsGRStock) {
                        await _handleGRInventory(barcodes);
                        return;
                      } else {
                        await sellInventory(
                          barcodes,
                          inventoryScanKey,
                          isClothingShop ? 'clothing' : 'packet',
                        );
                      }
                    },
                  ),
                ),

                // ── Dark overlay with scan window ──────────────────
                Positioned.fill(child: _ScanOverlay()),

                // ── Bottom instruction card ────────────────────────
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _InstructionCard(text: instructionText),
                ),
              ],
            ),
          ),

          // ── Loading blur overlay ───────────────────────────────────
          Obx(
            () =>
                controller.isExistingProductInfo.value
                    ? BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.4),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CommonProgressBar(color: Colors.white, size: 40),
                              SizedBox(height: 16.h),
                              Text(
                                'Checking product...',
                                style: CustomTextStyle.customPoppin(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  // ── All logic methods below are UNTOUCHED ──────────────────────────────────

  Future<void> sellInventory(
    BarcodeCapture barcodes,
    GlobalKey<FormState> inventoryScanKey,
    String stocktype,
  ) async {
    final scannedValue = controller.barcodeValue.value;
    final isURL = Uri.tryParse(scannedValue)?.hasAbsolutePath ?? false;
    if (isURL) {
      _showInvalidBarcodeDialog();
      return;
    }
    final (bool exists, BarcodeExistingData? product) = await controller
        .existingProductInfo(scannedValue, stocktype);
    if (!exists || product == null) {
      _showProductNotFoundDialog();
      return;
    }
    final productLocation = (product.location ?? '').trim().toLowerCase();
    if (productLocation != 'shop') {
      showSnackBar(error: 'Product should be in shop to sell.');
      controller.mobileScannerController.start();
      return;
    }
    if ((product.quantity ?? 0) <= 0) {
      productNotWithScannedAvailableDialog(
        manualSellOnTap: () => Get.back(),
        '${product.name ?? "Product"} is out of stock.',
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
            showSnackBar(error: 'Please scan the product first');
          }
        },
      );
      return;
    }
    if (product.isLoosed == true) {
      checkProductStatusDialog(
        label: 'Is this product sold in Packet or Loose?',
        packetOnTap: () {
          Get.back();
          _handleSell(scannedValue, stocktype, inventoryScanKey);
        },
        looseDoneOnTap: () {
          Get.back();
          _handleSell(scannedValue, stocktype, inventoryScanKey);
        },
      );
      return;
    }
    _handleSell(scannedValue, stocktype, inventoryScanKey);
  }

  Future<void> productInventory(
    BarcodeCapture barcodes,
    GlobalKey<FormState> inventoryScanKey,
    bool isloosedInventory,
    String stockType,
  ) async {
    final scannedValue = controller.barcodeValue.value;
    final isURL = Uri.tryParse(scannedValue)?.hasAbsolutePath ?? false;
    if (isURL) {
      _showInvalidBarcodeDialog();
      return;
    }
    final (bool exists, _) = await controller.existingProductInfo(
      scannedValue,
      stockType,
    );
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
    } else {
      controller.mobileScannerController.start();
      final res = await AppRoutes.futureNavigationToRoute(
        routeName: AppRouteName.productView,
        data: {'barcode': scannedValue, 'flag': isloosedInventory},
      );
      if (res == true) {
        controller.mobileScannerController.start();
      }
    }
  }

  Future<void> _handleLooseInventory(BarcodeCapture barcodes) async {
    final scannedValue = controller.barcodeValue.value;
    final isURL = Uri.tryParse(scannedValue)?.hasAbsolutePath ?? false;
    if (isURL) {
      _showInvalidBarcodeDialog();
      return;
    }
    final (bool exists, BarcodeExistingData? product) = await controller
        .existingProductInfo(scannedValue, 'loose');
    if (!exists || product == null) {
      _showProductNotFoundDialog();
      return;
    }
    final productLocation = (product.location ?? '').trim().toLowerCase();
    final canAddInLooseInventory =
        product.isLoosed == true && productLocation == 'shop';
    if (canAddInLooseInventory == false) {
      showMessage(
        message:
            '${product.name ?? 'This'} product can be added to loose only if it is packet and not in shop.',
      );
      controller.mobileScannerController.start();
      return;
    } else {
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
  }

  Future<void> _handleGRInventory(BarcodeCapture barcodes) async {
    final scannedValue = controller.barcodeValue.value;
    final isURL = Uri.tryParse(scannedValue)?.hasAbsolutePath ?? false;
    if (isURL) {
      _showInvalidBarcodeDialog();
      return;
    }
    final (bool exists, BarcodeExistingData? product) = await controller
        .existingProductInfo(scannedValue, 'clothing');
    if (!exists || product == null) {
      _showProductNotFoundDialog();
      return;
    }
    if ((product.quantity ?? 0) <= 0) {
      productNotWithScannedAvailableDialog(
        manualSellOnTap: () => Get.back(),
        '${product.name ?? "Product"} is out of stock.',
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
            showSnackBar(error: 'Please scan the product first');
          }
        },
      );
      return;
    }
    final productLocation = (product.location ?? '').trim().toLowerCase();
    final canAddInGRInventory = productLocation == 'shop';
    if (canAddInGRInventory == false) {
      showMessage(
        message:
            '${product.name ?? 'This'} product can be added to gr only if product is in the shop.',
      );
      controller.mobileScannerController.start();
      return;
    } else {
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
  }

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
          showSnackBar(error: 'Please scan the product first');
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
          showSnackBar(error: 'Please scan the product first');
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
          showSnackBar(error: 'Please scan the product first');
        }
      },
      onTap: () {
        Get.back();
        controller.mobileScannerController.start();
      },
    );
  }
}

// ── Scan Overlay ──────────────────────────────────────────────────────────────
class _ScanOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final double scanSize = 260.w;
    final double top = (MediaQuery.of(context).size.height - scanSize) / 2 - 80;

    return Stack(
      children: [
        // Dark overlay
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.55),
            BlendMode.srcOut,
          ),
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  backgroundBlendMode: BlendMode.dstOut,
                ),
              ),
              Positioned(
                left: (MediaQuery.of(context).size.width - scanSize) / 2,
                top: top,
                child: Container(
                  width: scanSize,
                  height: scanSize,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Corner brackets
        Positioned(
          left: (MediaQuery.of(context).size.width - scanSize) / 2,
          top: top,
          child: _ScanFrame(size: scanSize),
        ),

        // Hint text above frame
        Positioned(
          left: 0,
          right: 0,
          top: top - 48,
          child: Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                'Align barcode within the frame',
                style: CustomTextStyle.customOpenSans(
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Scan Frame with corner brackets ──────────────────────────────────────────
class _ScanFrame extends StatelessWidget {
  final double size;
  const _ScanFrame({required this.size});

  @override
  Widget build(BuildContext context) {
    const double bracketLen = 28;
    const double bracketThick = 3.5;
    const Color bracketColor = Colors.white;
    final double r = 16.r;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Top-left
          Positioned(
            top: 0,
            left: 0,
            child: _Bracket(
              horizontal: true,
              length: bracketLen,
              thickness: bracketThick,
              color: bracketColor,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(r)),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: _Bracket(
              horizontal: false,
              length: bracketLen,
              thickness: bracketThick,
              color: bracketColor,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(r)),
            ),
          ),
          // Top-right
          Positioned(
            top: 0,
            right: 0,
            child: _Bracket(
              horizontal: true,
              length: bracketLen,
              thickness: bracketThick,
              color: bracketColor,
              borderRadius: BorderRadius.only(topRight: Radius.circular(r)),
              alignRight: true,
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: _Bracket(
              horizontal: false,
              length: bracketLen,
              thickness: bracketThick,
              color: bracketColor,
              borderRadius: BorderRadius.only(topRight: Radius.circular(r)),
            ),
          ),
          // Bottom-left
          Positioned(
            bottom: 0,
            left: 0,
            child: _Bracket(
              horizontal: true,
              length: bracketLen,
              thickness: bracketThick,
              color: bracketColor,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(r)),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: _Bracket(
              horizontal: false,
              length: bracketLen,
              thickness: bracketThick,
              color: bracketColor,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(r)),
              alignBottom: true,
            ),
          ),
          // Bottom-right
          Positioned(
            bottom: 0,
            right: 0,
            child: _Bracket(
              horizontal: true,
              length: bracketLen,
              thickness: bracketThick,
              color: bracketColor,
              borderRadius: BorderRadius.only(bottomRight: Radius.circular(r)),
              alignRight: true,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: _Bracket(
              horizontal: false,
              length: bracketLen,
              thickness: bracketThick,
              color: bracketColor,
              borderRadius: BorderRadius.only(bottomRight: Radius.circular(r)),
              alignBottom: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _Bracket extends StatelessWidget {
  final bool horizontal;
  final double length;
  final double thickness;
  final Color color;
  final BorderRadius borderRadius;
  final bool alignRight;
  final bool alignBottom;

  const _Bracket({
    required this.horizontal,
    required this.length,
    required this.thickness,
    required this.color,
    required this.borderRadius,
    this.alignRight = false,
    this.alignBottom = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: horizontal ? length : thickness,
      height: horizontal ? thickness : length,
      decoration: BoxDecoration(color: color, borderRadius: borderRadius),
    );
  }
}

// ── Instruction card at bottom ────────────────────────────────────────────────
class _InstructionCard extends StatelessWidget {
  final String text;
  const _InstructionCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 32.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.barcode_viewfinder,
            color: Colors.white,
            size: 22.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              text,
              style: CustomTextStyle.customOpenSans(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
