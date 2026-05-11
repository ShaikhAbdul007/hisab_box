import 'dart:typed_data';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart'
    as printer;
import 'package:get/get.dart';
import 'package:inventory/bluetooth/bluetooth.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/helper/helper.dart';
import 'package:inventory/module/invoice_barcode_designer/model/barcode_layout_model.dart';
import 'package:inventory/module/invoice_barcode_designer/repo/designer_repo.dart';
import 'package:inventory/module/inventorylist/model/inventory_model.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';

class BardcodeController extends GetxController
    with CacheManager, CommonBluetooth {
  Rx<printer.ReceiptController?> receiptController =
      Rx<printer.ReceiptController?>(null);
  RxBool isPrintingLoading = false.obs;
  RxBool isShareReceiptLoading = false.obs;
  // Used to force BarcodePrinterView rebuild after designer changes
  RxInt layoutRefreshKey = 0.obs;
  BluetoothCharacteristic? _writeChar;
  BluetoothDevice? _printer;
  var data = Get.arguments;

  String _toEscPosSafe(String value) {
    const fallback = '?';
    final normalized = value
        .replaceAll('₹', 'Rs.')
        .replaceAll('–', '-')
        .replaceAll('—', '-')
        .replaceAll('’', "'")
        .replaceAll('‘', "'")
        .replaceAll('“', '"')
        .replaceAll('”', '"');

    final buffer = StringBuffer();
    for (final rune in normalized.runes) {
      if (rune >= 32 && rune <= 255) {
        buffer.writeCharCode(rune);
      } else if (rune == 10 || rune == 13 || rune == 9) {
        buffer.writeCharCode(rune);
      } else {
        buffer.write(fallback);
      }
    }
    return buffer.toString();
  }

  /// Keep one-line text within 58mm printable width to avoid printer overflow.
  String _fit58mmLine(String value, {int maxChars = 26}) {
    final compact = value.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (compact.length <= maxChars) return compact;
    return compact.substring(0, maxChars);
  }

  String _elementText({
    required ElementType type,
    required InventoryItem product,
    required String priceSegment,
  }) {
    switch (type) {
      case ElementType.productName:
        return product.name ?? '';
      case ElementType.price:
        return priceSegment;
      case ElementType.weight:
        return product.weight ?? '';
      case ElementType.shopName:
        final user = retrieveUserDetail();
        return user.data?.name ?? '';
      case ElementType.flavour:
        return product.flavour ?? '';
      case ElementType.animalType:
        return product.animalTypeName ?? '';
      case ElementType.color:
        return product.color ?? '';
      case ElementType.brand:
        return product.brand ?? '';
      case ElementType.category:
        return product.categoryName ?? '';
      case ElementType.expiry:
        return product.expireDate ?? '';
      case ElementType.barcode:
        return '';
    }
  }

  PosTextSize _toPosSize(double? fontSize) {
    final f = fontSize ?? 8;
    if (f >= 12) return PosTextSize.size3;
    if (f >= 9) return PosTextSize.size2;
    return PosTextSize.size1;
  }

  PosFontType _toPosFontType(DesignerFontFamily family) {
    switch (family) {
      case DesignerFontFamily.montserrat:
      case DesignerFontFamily.poppins:
      case DesignerFontFamily.arOneSans:
        return PosFontType.fontB;
      case DesignerFontFamily.openSans:
      case DesignerFontFamily.raleway:
        return PosFontType.fontA;
    }
  }

  @override
  void onInit() {
    checkBluetoothConnectivitys();
    super.onInit();
  }

  void setReceiptController(printer.ReceiptController controller) {
    receiptController.value = controller;
    customMessageOrErrorPrint(
      message: "📏 PAPER SIZE: ${controller.paperSize.paperWidthMM}",
    );
  }

  Future<bool> checkBluetoothConnectivitys() async {
    var res = await checkBluetoothConnectivity();
    return res;
  }

  Future<List<int>> buildLabelBytes({
    required String barcodeNo,
    required int quantity,
  }) async {
    final profile = await CapabilityProfile.load();

    // NEW (additive): Load saved barcode layout — falls back to defaultLayout() if none saved
    final layout = await DesignerRepo().getBarcodeLayout();
    final paperSize = PaperSize.mm58;

    final gen = Generator(paperSize, profile);
    List<int> bytes = [];
    final posFont = _toPosFontType(layout.textFontFamily);

    // 1. Data Cleaning
    final barcodeData = barcodeNo.toUpperCase().trim();
    final InventoryItem product =
        data['productData']['product'] as InventoryItem;
    final String priceText = product.sellingPrice ?? '0';

    final String priceSegment =
        layout.fixedPriceLabel ? 'Fixed Price Rs.$priceText' : 'Rs.$priceText';
    final sortedVisibleTextElements =
        layout.elements
            .where((e) => e.visible && e.type != ElementType.barcode)
            .toList()
          ..sort((a, b) {
            final byY = a.y.compareTo(b.y);
            if (byY != 0) return byY;
            return a.x.compareTo(b.x);
          });
    final barcodeElement =
        layout.elements
            .where((e) => e.type == ElementType.barcode && e.visible)
            .firstOrNull;

    for (int i = 0; i < quantity; i++) {
      bytes += gen.reset();

      // 2. Barcode Optimization

      bytes += gen.barcode(
        Barcode.code128(barcodeData.split('')),
        height: ((barcodeElement?.height ?? 15) * 3.0).clamp(35.0, 80.0).toInt(),
        width: 2,
        align: PosAlign.center,
        textPos: BarcodeText.none,
      );

      // 3. Text Formatting (designer-driven)
      for (final e in sortedVisibleTextElements) {
        final raw = _elementText(
          type: e.type,
          product: product,
          priceSegment: priceSegment,
        );
        if (raw.trim().isEmpty) continue;

        final posSize = _toPosSize(e.fontSize);
        int maxC = 28;
        if (posSize == PosTextSize.size2) maxC = 14;
        if (posSize == PosTextSize.size3) maxC = 9;

        final safe = _fit58mmLine(_toEscPosSafe(raw), maxChars: maxC);
        bytes += gen.text(
          safe,
          styles: PosStyles(
            align: PosAlign.center,
            fontType: posFont,
            height: posSize,
            width: posSize,
          ),
        );
      }

      // 4. Critical: Label Gap Detection
      // Sirf feed(3) ke bajaye ye commands try karein:
      bytes += gen.feed(2);
      // Kuch printers ko GS FF (0x1D 0x0C) command chahiye hoti hai next label pe jane ke liye
      bytes += [0x1D, 0x0C];
    }

    return bytes;
  }

  Future<void> printEscPosBytes(List<int> bytes) async {
    if (_writeChar == null) {
      throw Exception('Printer not connected');
    }

    const int chunkSize = 180;

    for (int i = 0; i < bytes.length; i += chunkSize) {
      final chunk = bytes.sublist(
        i,
        (i + chunkSize > bytes.length) ? bytes.length : i + chunkSize,
      );

      await _writeChar!.write(
        Uint8List.fromList(chunk),
        withoutResponse: _writeChar!.properties.writeWithoutResponse,
      );

      await Future.delayed(const Duration(milliseconds: 40));
    }
  }

  Future<void> connectPrinterWithSavedAddress(String mac) async {
    // 🔥 Direct device from MAC
    _printer = BluetoothDevice.fromId(mac);

    // Connect (will use existing system connection if present)
    await _printer!.connect(license: License.free, autoConnect: false);

    // Discover services
    final services = await _printer!.discoverServices();

    for (final service in services) {
      for (final c in service.characteristics) {
        if (c.properties.write || c.properties.writeWithoutResponse) {
          _writeChar = c;
          return;
        }
      }
    }

    throw Exception('Writable characteristic not found');
  }

  Future<void> printBarcodeLabelsFromSavedPrinter({
    required String barcode,
    required int quantity,
  }) async {
    final String bluetoothAddress = retrievePrinterAddress() ?? '';

    if (bluetoothAddress.isEmpty) {
      throw Exception('No saved printer address');
    }

    // 1️⃣ Connect using saved MAC
    await connectPrinterWithSavedAddress(bluetoothAddress);

    // 2️⃣ Build ESC/POS bytes
    final List<int> bytes = await buildLabelBytes(
      barcodeNo: barcode,
      quantity: quantity,
    );

    // 3️⃣ Print
    await printEscPosBytes(bytes);
  }
}
