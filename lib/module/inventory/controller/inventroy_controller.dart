import 'package:inventory/helper/app_message.dart';
import 'package:inventory/helper/logger.dart';
import 'dart:async';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/module/inventory/model/product_model.dart';
import 'package:inventory/module/inventory/repo/inventory_repo.dart';
import 'package:inventory/module/inventorylist/model/inventory_model.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../helper/helper.dart';

class InventroyController extends GetxController with CacheManager {
  InventoryScanRepo inventoryScanRepo = InventoryScanRepo();
  RxList<InventoryItem> scannedProductDetails = <InventoryItem>[].obs;

  RxBool isTreatSelected = false.obs;
  RxBool isCameraStop = false.obs;
  RxBool isProductSaving = false.obs;
  RxBool isScannedQtyOutOfStock = false.obs;
  RxBool isExistingProductInfo = false.obs;
  RxBool isDoneButtonReq = false.obs;
  RxBool isfullLooseSellingListLoading = false.obs;

  late MobileScannerController mobileScannerController;
  double totalAmount = 0.0;
  RxInt scannedQty = 0.obs;
  RxString barcodeValue = ''.obs;
  String? selectedManuallySell;
  int looseOldQty = 0;
  RxString existProductName = ''.obs;
  RxInt stockqty = 0.obs;
  bool isLoose = false;

  var data = Get.arguments;
  bool? flag;
  String? navigate;
  AudioPlayer? player;

  @override
  void onInit() {
    flag = data['flag'];
    navigate = data['navigate'];

    mobileScannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      formats: [BarcodeFormat.all],
    );
    player = AudioPlayer();
    super.onInit();
  }

  Future<(bool existProductOrNot, BarcodeExistingData barcodeExistingData)>
  existingProductInfo(String barcode, String stocktype) async {
    isExistingProductInfo.value = true;
    var res = await fetchProductByBarcode(
      scannedBarcode: barcode,
      stocktype: stocktype,
    );
    try {
      if (res.success == true &&
          res.msg!.contains('Product fetched successfully')) {
        existProductName.value = res.data?.name ?? '';
        return (true, res.data ?? BarcodeExistingData());
      } else if (res.success == false &&
          res.msg!.contains('Product not found with barcode')) {
        return (false, res.data ?? BarcodeExistingData());
      } else {
        existProductName.value = res.data?.name ?? '';
        return (false, res.data ?? BarcodeExistingData());
      }
    } catch (e) {
      AppLogger.info(("🚨 Info Error: $e").toString());
      showSnackBar(error: e.toString());
      return (false, BarcodeExistingData());
    } finally {
      isExistingProductInfo.value = false;
    }
  }

  Future<void> handleScan({
    required String barcode,
    required String sellType,
    required VoidCallback afterProductAdding,
    required VoidCallback qtyIsNotEnough,
  }) async {
    try {
      final res = await fetchProductByBarcode(
        scannedBarcode: barcode,
        stocktype: sellType,
      );

      if (res.success != success || res.data == null) {
        showSnackBar(error: "❌ Product Not Found");
        return;
      }

      final product = res.data!;
      product.barcode = barcode;

      // 🔴 Location check
      if ((product.location ?? '').toLowerCase() != 'shop') {
        showSnackBar(error: 'Product should be in shop to sell.');
        return;
      }

      double availableQty = (product.quantity ?? 0).toDouble();

      if (availableQty <= 0) {
        qtyIsNotEnough();
        return;
      }

      final cartList = await retrieveCartProductList();

      final index = cartList.indexWhere(
        (p) => p.barcode == barcode && p.stockType == sellType,
      );

      if (index != -1) {
        final double currentQty =
            double.tryParse(cartList[index].quantity?.toString() ?? '0') ?? 0;
        if (currentQty >= availableQty) {
          qtyIsNotEnough();
          return;
        }
        cartList[index].quantity = (currentQty + 1).toString();
      } else {
        cartList.add(
          InventoryItem(
            barcode: barcode,
            id: product.id,
            name: product.name,
            sellingPrice: product.sellingPrice,
            discount: product.discount,
            quantity: '1.0',
            stockType: sellType,
            location: product.location,
          ),
        );
      }
      saveCartProductList(cartList);
      scannedProductDetails.assignAll(cartList);
      scannedProductDetails.refresh();
      afterProductAdding();
    } catch (e) {
      AppLogger.info(("🚨 Scan Error: $e").toString());
      showSnackBar(error: e.toString());
    }
  }

  Future<BarcodeExistingModel> fetchProductByBarcode({
    required String scannedBarcode,
    required String stocktype,
  }) async {
    var res = await inventoryScanRepo.fetchProductByBarcode(
      barcode: scannedBarcode,
      stocktype: stocktype,
    );
    return res;
  }

  void cameraStart() {
    mobileScannerController.start();
  }

  Future<void> stopCameraAfterDetect(BarcodeCapture barcodes) async {
    barcodeValue.value = barcodes.barcodes.first.rawValue.toString();
    mobileScannerController.stop();
  }

  @override
  void onClose() {
    mobileScannerController.dispose();
    player?.dispose();
    super.onClose();
  }
}
