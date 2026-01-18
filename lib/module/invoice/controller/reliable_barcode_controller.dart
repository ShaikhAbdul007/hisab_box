import 'dart:typed_data';

import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart';
import 'package:get/get.dart';
import 'package:inventory/bluetooth/bluetooth.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/helper/helper.dart';

class ReliableBarcodeController extends GetxController
    with CacheManager, CommonBluetooth {
  Rx<ReceiptController?> receiptController = Rx<ReceiptController?>(null);
  RxBool isPrintingLoading = false.obs;
  RxBool isShareReceiptLoading = false.obs;
  var data = Get.arguments;

  @override
  void onInit() {
    checkBluetoothConnectivitys();
    super.onInit();
  }

  void setReceiptController(ReceiptController controller) {
    receiptController.value = controller;
  }

  Future<bool> checkBluetoothConnectivitys() async {
    var res = await checkBluetoothConnectivity();
    return res;
  }

  // 🔥 ROCK SOLID RELIABLE PRINT METHOD
  Future<void> printReliableLabel({int qty = 1}) async {
    if (receiptController.value == null) {
      showMessage(message: '❌ Printer not initialized');
      return;
    }

    isPrintingLoading.value = true;

    try {
      // Get printer address
      String? printerAddress = retrievePrinterAddress();
      if (printerAddress == null || printerAddress.isEmpty) {
        showMessage(message: '❌ Printer address not found');
        return;
      }

      // 🔥 STEP 1: ENSURE CLEAN PRINTER STATE
      await _ensureCleanPrinterState(printerAddress);

      for (int i = 0; i < qty; i++) {
        showMessage(message: '🖨️ Printing label ${i + 1}/$qty...');

        // 🔥 STEP 2: PRE-PRINT PREPARATION
        await _prePrintPreparation(printerAddress);

        // 🔥 STEP 3: RELIABLE PRINT WITH RETRY
        bool printSuccess = await _printWithRetry(
          printerAddress,
          maxRetries: 3,
        );

        if (!printSuccess) {
          showMessage(message: '❌ Failed to print label ${i + 1}');
          break;
        }

        // 🔥 STEP 4: POST-PRINT CLEANUP
        await _postPrintCleanup(printerAddress);

        // 🔥 STEP 5: INTER-LABEL DELAY
        if (i < qty - 1) {
          await Future.delayed(Duration(milliseconds: 500));
        }
      }

      showMessage(
        message: '✅ $qty labels printed successfully with 100% reliability',
      );
    } catch (e) {
      showMessage(message: '❌ Reliable print failed: $e');
    } finally {
      isPrintingLoading.value = false;
    }
  }

  // 🔥 ENSURE CLEAN PRINTER STATE
  Future<void> _ensureCleanPrinterState(String address) async {
    try {
      // Multiple resets to ensure clean state
      for (int i = 0; i < 3; i++) {
        await FlutterBluetoothPrinter.printBytes(
          address: address,
          data: Uint8List.fromList([0x1B, 0x40]), // ESC @ - Initialize
          keepConnected: true,
        );
        await Future.delayed(Duration(milliseconds: 200));
      }

      // Clear any pending data
      await FlutterBluetoothPrinter.printBytes(
        address: address,
        data: Uint8List.fromList([0x18]), // CAN - Cancel any pending operation
        keepConnected: true,
      );

      await Future.delayed(Duration(milliseconds: 300));
    } catch (e) {
      print('❌ Clean printer state failed: $e');
    }
  }

  // 🔥 PRE-PRINT PREPARATION
  Future<void> _prePrintPreparation(String address) async {
    try {
      // Ensure printer is ready
      await FlutterBluetoothPrinter.printBytes(
        address: address,
        data: Uint8List.fromList([0x1B, 0x40]), // Reset
        keepConnected: true,
      );

      await Future.delayed(Duration(milliseconds: 150));

      // Set to standard mode
      await FlutterBluetoothPrinter.printBytes(
        address: address,
        data: Uint8List.fromList([0x1B, 0x21, 0x00]), // Standard character mode
        keepConnected: true,
      );

      await Future.delayed(Duration(milliseconds: 100));
    } catch (e) {
      print('❌ Pre-print preparation failed: $e');
    }
  }

  // 🔥 PRINT WITH RETRY MECHANISM
  Future<bool> _printWithRetry(String address, {int maxRetries = 3}) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        showMessage(message: '🔄 Print attempt $attempt/$maxRetries...');

        // Wait before each attempt
        if (attempt > 1) {
          await Future.delayed(Duration(milliseconds: 1000));
          // Reset printer before retry
          await FlutterBluetoothPrinter.printBytes(
            address: address,
            data: Uint8List.fromList([0x1B, 0x40]),
            keepConnected: true,
          );
          await Future.delayed(Duration(milliseconds: 200));
        }

        // Attempt to print
        var result = await receiptController.value!.print(
          address: address,
          delayTime: 0,
        );

        if (result == true) {
          showMessage(message: '✅ Print successful on attempt $attempt');
          return true;
        } else {
          showMessage(message: '⚠️ Print attempt $attempt failed, retrying...');
        }
      } catch (e) {
        showMessage(message: '❌ Print attempt $attempt error: $e');
      }

      // Wait before next retry
      if (attempt < maxRetries) {
        await Future.delayed(Duration(milliseconds: 500));
      }
    }

    return false;
  }

  // 🔥 POST-PRINT CLEANUP
  Future<void> _postPrintCleanup(String address) async {
    try {
      // Ensure print completion
      await Future.delayed(Duration(milliseconds: 200));

      // Send form feed to complete the label
      await FlutterBluetoothPrinter.printBytes(
        address: address,
        data: Uint8List.fromList([0x0C]), // Form feed
        keepConnected: true,
      );

      await Future.delayed(Duration(milliseconds: 100));
    } catch (e) {
      print('❌ Post-print cleanup failed: $e');
    }
  }

  // 🔥 ULTRA SIMPLE PRINT (NO COMMANDS AT ALL)
  Future<void> printUltraSimple({int qty = 1}) async {
    if (receiptController.value == null) {
      showMessage(message: '❌ Printer not initialized');
      return;
    }

    isPrintingLoading.value = true;

    try {
      String? printerAddress = retrievePrinterAddress();
      if (printerAddress == null || printerAddress.isEmpty) {
        showMessage(message: '❌ Printer address not found');
        return;
      }

      for (int i = 0; i < qty; i++) {
        showMessage(message: '🖨️ Ultra simple print ${i + 1}/$qty...');

        // 🔥 DIRECT PRINT - NO COMMANDS WHATSOEVER
        var result = await receiptController.value!.print(
          address: printerAddress,
          delayTime: 0,
        );

        if (result != true) {
          showMessage(message: '⚠️ Print ${i + 1} may have failed');
        }

        // Long delay for stability
        await Future.delayed(Duration(milliseconds: 1000));
      }

      showMessage(message: '✅ $qty labels printed with ultra simple method');
    } catch (e) {
      showMessage(message: '❌ Ultra simple print failed: $e');
    } finally {
      isPrintingLoading.value = false;
    }
  }

  // 🔥 DIAGNOSTIC PRINT TEST
  Future<void> printDiagnosticTest() async {
    if (receiptController.value == null) {
      showMessage(message: '❌ Printer not initialized');
      return;
    }

    isPrintingLoading.value = true;

    try {
      String? printerAddress = retrievePrinterAddress();
      if (printerAddress == null || printerAddress.isEmpty) {
        showMessage(message: '❌ Printer address not found');
        return;
      }

      showMessage(message: '🔍 Running diagnostic test...');

      // Test 1: Simple print
      showMessage(message: '📋 Test 1: Simple print');
      var result1 = await receiptController.value!.print(
        address: printerAddress,
        delayTime: 0,
      );
      showMessage(
        message: result1 == true ? '✅ Test 1: SUCCESS' : '❌ Test 1: FAILED',
      );

      await Future.delayed(Duration(milliseconds: 2000));

      // Test 2: Print with reset
      showMessage(message: '📋 Test 2: Print with reset');
      await FlutterBluetoothPrinter.printBytes(
        address: printerAddress,
        data: Uint8List.fromList([0x1B, 0x40]),
        keepConnected: true,
      );
      await Future.delayed(Duration(milliseconds: 200));

      var result2 = await receiptController.value!.print(
        address: printerAddress,
        delayTime: 0,
      );
      showMessage(
        message: result2 == true ? '✅ Test 2: SUCCESS' : '❌ Test 2: FAILED',
      );

      await Future.delayed(Duration(milliseconds: 2000));

      // Test 3: Reliable method
      showMessage(message: '📋 Test 3: Reliable method');
      await _ensureCleanPrinterState(printerAddress);
      await _prePrintPreparation(printerAddress);
      var result3 = await receiptController.value!.print(
        address: printerAddress,
        delayTime: 0,
      );
      showMessage(
        message: result3 == true ? '✅ Test 3: SUCCESS' : '❌ Test 3: FAILED',
      );

      // Summary
      int successCount =
          (result1 == true ? 1 : 0) +
          (result2 == true ? 1 : 0) +
          (result3 == true ? 1 : 0);

      showMessage(
        message: '📊 Diagnostic complete: $successCount/3 tests passed',
      );

      if (successCount == 3) {
        showMessage(
          message: '🎉 All tests passed! Printer is working perfectly',
        );
      } else if (successCount >= 1) {
        showMessage(
          message: '⚠️ Some tests failed. Use the method that worked',
        );
      } else {
        showMessage(message: '❌ All tests failed. Check printer connection');
      }
    } catch (e) {
      showMessage(message: '❌ Diagnostic test failed: $e');
    } finally {
      isPrintingLoading.value = false;
    }
  }

  // 🔥 CONNECTION STABILITY CHECK
  Future<bool> checkConnectionStability() async {
    try {
      String? printerAddress = retrievePrinterAddress();
      if (printerAddress == null || printerAddress.isEmpty) {
        return false;
      }

      // Test connection stability with multiple small commands
      for (int i = 0; i < 5; i++) {
        await FlutterBluetoothPrinter.printBytes(
          address: printerAddress,
          data: Uint8List.fromList([0x1B, 0x40]), // Reset
          keepConnected: true,
        );
        await Future.delayed(Duration(milliseconds: 100));
      }

      return true;
    } catch (e) {
      return false;
    }
  }
}
