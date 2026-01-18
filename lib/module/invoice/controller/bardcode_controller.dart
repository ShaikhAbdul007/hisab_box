import 'dart:typed_data';

import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart';
import 'package:get/get.dart';
import 'package:inventory/bluetooth/bluetooth.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/helper/helper.dart';

class BardcodeController extends GetxController
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

  // 🔥 SIMPLE PRINT FUNCTION WITHOUT COMPLEX COMMANDS
  Future<void> printSimpleLabel({required int qty}) async {
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
        // 🔥 SIMPLE PRINT WITHOUT ALIGNMENT COMMANDS
        await receiptController.value!.print(address: printerAddress);

        // Small delay between labels
        await Future.delayed(Duration(milliseconds: 100));
      }

      showMessage(message: '✅ $qty label(s) printed successfully');
    } catch (e) {
      showMessage(message: '❌ Print failed: $e');
    } finally {
      isPrintingLoading.value = false;
    }
  }

  // 🔥 PRINT WITH BASIC RESET ONLY
  Future<void> printWithBasicReset({required int qty}) async {
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

      for (int i = 0; i < qty; i++) {
        // 🔥 ONLY BASIC PRINTER RESET (NO COMPLEX COMMANDS)
        await _sendBasicReset(printerAddress);

        // Print the label
        await receiptController.value!.print(address: printerAddress);

        // Small delay between labels
        await Future.delayed(Duration(milliseconds: 100));
      }

      showMessage(message: '✅ $qty labels printed with basic reset');
    } catch (e) {
      showMessage(message: '❌ Print with basic reset failed: $e');
    } finally {
      isPrintingLoading.value = false;
    }
  }

  // 🔥 BASIC PRINTER RESET ONLY
  Future<void> _sendBasicReset(String address) async {
    try {
      // Only basic printer reset - no complex commands
      await FlutterBluetoothPrinter.printBytes(
        address: address,
        data: Uint8List.fromList([
          0x1B,
          0x40,
        ]), // ESC @ - Initialize printer only
        keepConnected: true,
      );

      await Future.delayed(Duration(milliseconds: 100));
    } catch (e) {
      print('❌ Basic reset failed: $e');
    }
  }

  // 🔥 SEND ALIGNMENT RESET COMMANDS
  Future<void> _sendAlignmentCommands(String address) async {
    try {
      // Reset printer to default state
      await FlutterBluetoothPrinter.printBytes(
        address: address,
        data: Uint8List.fromList([0x1B, 0x40]), // ESC @ - Initialize printer
        keepConnected: true,
      );

      // Set label mode for consistent positioning
      await FlutterBluetoothPrinter.printBytes(
        address: address,
        data: Uint8List.fromList([0x1B, 0x69, 0x61, 0x01]), // Set label mode
        keepConnected: true,
      );

      // Set print position to start of label
      await FlutterBluetoothPrinter.printBytes(
        address: address,
        data: Uint8List.fromList([
          0x1B,
          0x24,
          0x00,
          0x00,
        ]), // Set absolute print position
        keepConnected: true,
      );

      // Set line spacing to minimum for consistent layout
      await FlutterBluetoothPrinter.printBytes(
        address: address,
        data: Uint8List.fromList([0x1B, 0x33, 0x00]), // Set line spacing to 0
        keepConnected: true,
      );

      await Future.delayed(Duration(milliseconds: 50));
    } catch (e) {
      print('❌ Alignment commands failed: $e');
    }
  }

  // 🔥 SEND POST-PRINT COMMANDS FOR NEXT LABEL
  Future<void> _sendPostPrintCommands(String address) async {
    try {
      // Feed to next label position
      await FlutterBluetoothPrinter.printBytes(
        address: address,
        data: Uint8List.fromList([
          0x1B,
          0x64,
          0x01,
        ]), // Feed 1 line to position for next label
        keepConnected: true,
      );

      // Optional: Partial cut for label separation (uncomment if supported)
      // await FlutterBluetoothPrinter.printBytes(
      //   address: address,
      //   data: Uint8List.fromList([0x1D, 0x56, 0x01]), // Partial cut
      //   keepConnected: true,
      // );

      await Future.delayed(Duration(milliseconds: 50));
    } catch (e) {
      print('❌ Post-print commands failed: $e');
    }
  }

  // 🔥 ADVANCED ALIGNMENT COMMANDS FOR PERFECT POSITIONING
  Future<void> _sendAdvancedAlignmentCommands(String address) async {
    try {
      // Complete printer reset
      await FlutterBluetoothPrinter.printBytes(
        address: address,
        data: Uint8List.fromList([0x1B, 0x40]), // ESC @ - Initialize printer
        keepConnected: true,
      );

      await Future.delayed(Duration(milliseconds: 100));

      // Set label mode with specific dimensions
      await FlutterBluetoothPrinter.printBytes(
        address: address,
        data: Uint8List.fromList([0x1B, 0x69, 0x61, 0x01]), // Set label mode
        keepConnected: true,
      );

      // Set exact label size (25mm x 50mm)
      await FlutterBluetoothPrinter.printBytes(
        address: address,
        data: Uint8List.fromList([
          0x1B,
          0x51,
          0xBD,
          0x00,
          0x5F,
          0x00,
        ]), // Set label size
        keepConnected: true,
      );

      // Set print origin to top-left
      await FlutterBluetoothPrinter.printBytes(
        address: address,
        data: Uint8List.fromList([
          0x1B,
          0x24,
          0x00,
          0x00,
        ]), // Set absolute print position
        keepConnected: true,
      );

      // Set minimum line spacing
      await FlutterBluetoothPrinter.printBytes(
        address: address,
        data: Uint8List.fromList([0x1B, 0x33, 0x00]), // Set line spacing to 0
        keepConnected: true,
      );

      // Set character spacing to minimum
      await FlutterBluetoothPrinter.printBytes(
        address: address,
        data: Uint8List.fromList([0x1B, 0x20, 0x00]), // Set character spacing
        keepConnected: true,
      );

      await Future.delayed(Duration(milliseconds: 100));
    } catch (e) {
      print('❌ Advanced alignment commands failed: $e');
    }
  }

  // 🔥 ADVANCED POST-PRINT COMMANDS FOR CONSISTENT NEXT LABEL
  Future<void> _sendAdvancedPostPrintCommands(String address) async {
    try {
      // Precise feed to next label start position
      await FlutterBluetoothPrinter.printBytes(
        address: address,
        data: Uint8List.fromList([
          0x1B,
          0x64,
          0x02,
        ]), // Feed 2 lines for proper spacing
        keepConnected: true,
      );

      // Set print position for next label
      await FlutterBluetoothPrinter.printBytes(
        address: address,
        data: Uint8List.fromList([
          0x1B,
          0x24,
          0x00,
          0x00,
        ]), // Reset print position
        keepConnected: true,
      );

      // Optional: Form feed to next label (uncomment if needed)
      // await FlutterBluetoothPrinter.printBytes(
      //   address: address,
      //   data: Uint8List.fromList([0x0C]), // Form feed
      //   keepConnected: true,
      // );

      await Future.delayed(Duration(milliseconds: 100));
    } catch (e) {
      print('❌ Advanced post-print commands failed: $e');
    }
  }
}
