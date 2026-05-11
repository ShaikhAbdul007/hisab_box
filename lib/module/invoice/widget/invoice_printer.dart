import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inventory/helper/logger.dart';
import 'package:inventory/helper/shop_type.dart';
import 'package:inventory/module/invoice_barcode_designer/repo/designer_repo.dart';
import 'package:inventory/module/invoice_barcode_designer/model/barcode_layout_model.dart';
import 'package:inventory/module/invoice_barcode_designer/model/invoice_config_model.dart';
import 'package:inventory/module/inventorylist/model/inventory_model.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer_library.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/helper/set_format_date.dart';
import 'package:inventory/helper/textstyle.dart';
import 'package:inventory/module/invoice/model/invoice_model.dart';
import 'package:upi_payment_qrcode_generator/upi_payment_qrcode_generator.dart';

// ── Thermal-safe color — pure black, no grey ─────────────────────────────────
const Color _k = Colors.black;

/// Null-safe capitalize — no extension dependency
String _cap(String? s) {
  if (s == null || s.isEmpty) return '';
  return s[0].toUpperCase() + s.substring(1);
}

class InvoicePrinterView extends StatelessWidget with CacheManager {
  final InvoiceData printInvoiceModel;
  final String paymentMethod;
  final void Function(ReceiptController) onInitialized;

  InvoicePrinterView({
    super.key,
    required this.onInitialized,
    required this.paymentMethod,
    required this.printInvoiceModel,
  });

  @override
  Widget build(BuildContext context) {
    final user = retrieveUserDetail();
    final shopType = ShopType.fromString(user.data?.shopType ?? '');
    final bankDetails = retrieveBankModelDetail();
    final invoiceConfig = DesignerRepo().getInvoiceConfigSync();
    final String initials =
        user.data?.name?.isNotEmpty == true
            ? user.data!.name!.substring(0, 1).toUpperCase()
            : 'HB';
    final (date, time) = splitDateTime(printInvoiceModel.dateTime ?? '');
    final isCash = paymentMethod.trim().toLowerCase() == 'cash';
    final total = safeNum(printInvoiceModel.orderSummary?.finalAmount);
    final fs = invoiceConfig.fontSize;
    final invoiceFontFamily = _fontFamilyName(invoiceConfig.invoiceFontFamily);
    final double horizontalPadding = 20.w;
    final FontWeight itemTitleWeight = FontWeight.w700;
    final summary = printInvoiceModel.orderSummary;
    final items = printInvoiceModel.items ?? [];
    final customerName = printInvoiceModel.customerName?.toString() ?? '';
    final customerMobile = printInvoiceModel.customerMobile?.toString() ?? '';
    final savedAmount = summary?.customerSaved ?? '0';
    final hasSavings = (double.tryParse(savedAmount) ?? 0) > 0;

    AppLogger.info('isCash is $isCash');

    return Receipt(
      backgroundColor: Colors.white,
      builder:
          (context) => DefaultTextStyle(
            style: TextStyle(fontFamily: invoiceFontFamily, color: Colors.black),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
              // ══════════════════════════════════════════════════════════════════
              // 1. HEADER — black background, white text (thermal-safe)
              // ══════════════════════════════════════════════════════════════════
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 12.h,
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (invoiceConfig.showLogo)
                          Container(
                            width: 42.w,
                            height: 42.w,
                            decoration: const BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              initials,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: fs.invoiceFontSize(base: 16),
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        if (invoiceConfig.showLogo) SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.data?.name ?? '',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: fs.invoiceFontSize(base: 18),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              if (invoiceConfig.showMobile &&
                                  (user.data?.mobileNo ?? '').isNotEmpty)
                                Text(
                                  _phoneText(user),
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: fs.invoiceFontSize(base: 12),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    _dashedDivider(),
                    if (invoiceConfig.showAddress &&
                        _addressText(user).isNotEmpty) ...[
                      SizedBox(height: 7.h),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.black,
                            size: fs.invoiceFontSize(base: 12),
                          ),
                          SizedBox(width: 5.w),
                          Expanded(
                            child: Text(
                              _addressText(user),
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: fs.invoiceFontSize(base: 12),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 7.h),
                      _dashedDivider(),
                    ],
                  ],
                ),
              ),

              // ══════════════════════════════════════════════════════════════════
              // 2. BILL INFO — invoice no + date + time + payment
              // ══════════════════════════════════════════════════════════════════
              SizedBox(height: 7.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  children: [
                    _metaRow(
                      'Bill No',
                      '#${printInvoiceModel.invoiceNo ?? ''}',
                      fs,
                    ),
                    _metaRow('Date', date, fs),
                    _metaRow('Time', time, fs),
                    _metaRow('Payment', _cap(paymentMethod), fs),
                  ],
                ),
              ),

              // ══════════════════════════════════════════════════════════════════
              // 3. CUSTOMER (if available)
              // ══════════════════════════════════════════════════════════════════
              if (customerName.isNotEmpty) ...[
                SizedBox(height: 10.h),
                _thinSeparator(),
                SizedBox(height: 10.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Customer',
                        style: TextStyle(
                          fontSize: fs.invoiceFontSize(base: 10),
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        customerName,
                        style: TextStyle(
                          fontSize: fs.invoiceFontSize(base: 13),
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (customerMobile.isNotEmpty)
                        Text(
                          customerMobile,
                          style: TextStyle(
                            fontSize: fs.invoiceFontSize(base: 11),
                            color: Colors.black,
                          ),
                        ),
                    ],
                  ),
                ),
              ],

              // ══════════════════════════════════════════════════════════════════
              // 4. ITEMS
              // ══════════════════════════════════════════════════════════════════
              SizedBox(height: 14.h),
              _dashedDivider(),
              SizedBox(height: 6.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'ITEM',
                        style: TextStyle(
                          fontSize: fs.invoiceFontSize(base: 9),
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    Text(
                      'AMOUNT',
                      style: TextStyle(
                        fontSize: fs.invoiceFontSize(base: 9),
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 6.h),
              _dashedDivider(),
              SizedBox(height: 8.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: List.generate(items.length, (i) {
                    final item = items[i];
                    final discount = item.discountPercent ?? 0;
                    final subtitle = _itemSubtitle(
                      item,
                      config: invoiceConfig,
                      shopType: shopType,
                    );
                    final isLast = i == items.length - 1;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.productName ?? '',
                                      style: TextStyle(
                                        fontSize: fs.invoiceFontSize(base: 13),
                                        fontWeight: itemTitleWeight,
                                        color: Colors.black,
                                      ),
                                    ),
                                    if (subtitle.isNotEmpty) ...[
                                      SizedBox(height: 2.h),
                                      Text(
                                        subtitle,
                                        style: TextStyle(
                                          fontSize: fs.invoiceFontSize(base: 9),
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                    SizedBox(height: 3.h),
                                    Text(
                                      discount > 0
                                          ? '${item.quantity} × ₹${item.originalPrice}  (−$discount%)'
                                          : '${item.quantity} × ₹${item.originalPrice}',
                                      style: TextStyle(
                                        fontSize: fs.invoiceFontSize(base: 11),
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                '₹${item.totalPrice ?? item.finalPrice ?? ''}',
                                style: TextStyle(
                                  fontSize: fs.invoiceFontSize(base: 13),
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!isLast) _dashedDivider(),
                      ],
                    );
                  }),
                ),
              ),

              // ══════════════════════════════════════════════════════════════════
              // 5. TOTALS
              // ══════════════════════════════════════════════════════════════════
              SizedBox(height: 8.h),
              _dashedDivider(),
              SizedBox(height: 10.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  children: [
                    if ((summary?.subtotal ?? '').isNotEmpty)
                      _totalRow('Subtotal', '₹${summary!.subtotal}', fs),
                    if ((double.tryParse(summary?.totalDiscount ?? '0') ?? 0) >
                        0) ...[
                      SizedBox(height: 6.h),
                      _totalRow(
                        'Discount',
                        '−₹${summary?.customerSaved ?? '0'}',
                        fs,
                      ),
                    ],
                    if ((double.tryParse(summary?.roundOff ?? '0') ?? 0) !=
                        0) ...[
                      SizedBox(height: 6.h),
                      _totalRow('Round Off', '₹${summary?.roundOff}', fs),
                    ],
                    SizedBox(height: 10.h),
                    _dashedDivider(),
                    SizedBox(height: 10.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'GRAND TOTAL',
                          style: TextStyle(
                            fontSize: fs.invoiceFontSize(base: 15),
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          '₹${summary?.finalAmount ?? ''}',
                          style: TextStyle(
                            fontSize: fs.invoiceFontSize(base: 16),
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                  ],
                ),
              ),

              // ══════════════════════════════════════════════════════════════════
              // 6. YOU SAVED (if applicable)
              // ══════════════════════════════════════════════════════════════════
              if (hasSavings) ...[
                SizedBox(height: 14.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Column(
                    children: [
                      Text(
                        '*** You Saved ₹$savedAmount on this bill! ***',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: fs.invoiceFontSize(base: 12),
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        'Keep shopping to save more!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: fs.invoiceFontSize(base: 10),
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // ══════════════════════════════════════════════════════════════════
              // 7. UPI QR
              // ══════════════════════════════════════════════════════════════════
              if (bankDetails.data?.upiId?.isNotEmpty == true && !isCash) ...[
                SizedBox(height: 14.h),
                _dashedDivider(),
                SizedBox(height: 14.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: _buildUpiSection(bankDetails, total),
                ),
              ],

              // ══════════════════════════════════════════════════════════════════
              // 8. THANK YOU + VISIT AGAIN
              // ══════════════════════════════════════════════════════════════════
              SizedBox(height: 16.h),
              _dashedDivider(),
              SizedBox(height: 14.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  children: [
                    Text(
                      invoiceConfig.footerText.isNotEmpty
                          ? invoiceConfig.footerText
                          : '** Thank You for Shopping With Us **',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: fs.invoiceFontSize(base: 13),
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Visit Again!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: fs.invoiceFontSize(base: 16),
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Keep shopping to save more!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: fs.invoiceFontSize(base: 10),
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Thank you for shopping...',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: fs.invoiceFontSize(base: 9),
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

              // ══════════════════════════════════════════════════════════════════
              // 9. TERMS & CONDITIONS
              // ══════════════════════════════════════════════════════════════════
              SizedBox(height: 14.h),
              _dashedDivider(),
              SizedBox(height: 10.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Terms & Conditions',
                      style: TextStyle(
                        fontSize: fs.invoiceFontSize(base: 11),
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      invoiceConfig.termsAndConditionsText.trim().isNotEmpty
                          ? invoiceConfig.termsAndConditionsText
                          : '1. Goods once sold will not be taken back or exchanged.\n'
                              '2. No refund on sold items.\n'
                              '3. All disputes subject to local jurisdiction.',
                      style: TextStyle(
                        fontSize: fs.invoiceFontSize(base: 12),
                        color: Colors.black,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              // ══════════════════════════════════════════════════════════════════
              // 10. POWERED BY
              // ══════════════════════════════════════════════════════════════════
              SizedBox(height: 14.h),
              _dashedDivider(),
              SizedBox(height: 10.h),
              Column(
                children: [
                  SizedBox(height: 10.h),
                  Text(
                    'Powered by',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: fs.invoiceFontSize(base: 10),
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'HisaabBox',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: fs.invoiceFontSize(base: 15),
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Smart Billing & Inventory Management',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: fs.invoiceFontSize(base: 10),
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30.h),
              ],
            ),
          ),
      onInitialized: (ctrl) {
        AppLogger.info('Printer Controller Initialized!');
        onInitialized(ctrl);
      },
    );
  }

  // ── Private helpers ──────────────────────────────────────────────────────────

  /// Build address string from user data.
  String _addressText(dynamic user) {
    final addr = _cap(user.data?.address);
    final city = _cap(user.data?.city);
    final pin = user.data?.pincode ?? '';
    return [addr, city, pin].where((s) => s.isNotEmpty).join(', ');
  }

  /// Label-left + value-right meta row on white background.
  Widget _metaRow(String label, String value, FontSizeOption fs) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 9.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: fs.invoiceFontSize(base: 13),
              color: Colors.black,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: fs.invoiceFontSize(base: 13),
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Thin separator line.
  Widget _thinSeparator() => Container(height: 1, color: Colors.black);

  /// Label-left + value-right totals row.
  Widget _totalRow(String label, String value, FontSizeOption fs) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fs.invoiceFontSize(base: 12),
            color: Colors.black,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: fs.invoiceFontSize(base: 12),
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  // ── Preserved method signatures ──────────────────────────────────────────────

  String _phoneText(dynamic user) {
    final mobile = user.data?.mobileNo ?? '';
    final alt = user.data?.alternateMobileNo ?? '';
    if (alt.toString().isNotEmpty) return '$mobile / $alt';
    return mobile;
  }

  String _itemSubtitle(
    InvoiceDataItems item, {
    required InvoiceConfigModel config,
    required ShopType shopType,
  }) {
    final parts = <String>[];
    switch (shopType) {
      case ShopType.petShop:
        if (config.showFlavour && (item.flavour ?? '').isNotEmpty) {
          parts.add(item.flavour!);
        }
        if (config.showWeight && (item.weight ?? '').isNotEmpty) {
          parts.add(item.weight!);
        }
        if (config.showAnimalType && (item.animalTypeName ?? '').isNotEmpty) {
          parts.add(item.animalTypeName!);
        }
        if (config.showBrand && (item.brand ?? '').isNotEmpty) {
          parts.add(item.brand!);
        }
        break;
      case ShopType.clothingShop:
        if (config.showColor && (item.colorName ?? '').isNotEmpty) {
          parts.add(item.colorName!);
        }
        if (config.showBrand && (item.brand ?? '').isNotEmpty) {
          parts.add(item.brand!);
        }
        if (config.showSize && (item.categoryName ?? '').isNotEmpty) {
          parts.add(item.categoryName!);
        }
        break;
    }
    return parts.join(' | ');
  }

  Widget _buildUpiSection(dynamic bankDetails, num total) {
    return Column(
      children: [
        Text(
          'Scan to Pay',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _k,
          ),
        ),
        SizedBox(height: 10.h),
        Center(
          child: UPIPaymentQRCode(
            upiDetails: UPIDetails(
              upiID: bankDetails.data?.upiId ?? '',
              payeeName: bankDetails.data?.accountHolderName ?? '',
              amount: total.toDouble(),
            ),
            size: 160.w,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          '₹ ${total.toStringAsFixed(2)}',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: _k,
          ),
        ),
      ],
    );
  }

  /// Solid thick line — used around items section
  Widget _thickDivider() => Container(height: 2, color: _k);

  /// Solid thin line — used between total rows
  Widget _thinDivider() => Container(height: 1, color: _k);

  /// Dashed line — used between major sections
  Widget _dashedDivider() => Row(
    children: List.generate(
      50,
      (i) => Expanded(
        child: Container(
          height: 1.5,
          color: i.isEven ? _k : Colors.transparent,
        ),
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// BARCODE PRINTER VIEW — unchanged logic
// ─────────────────────────────────────────────────────────────────────────────
class BarcodePrinterView extends StatelessWidget with CacheManager {
  final void Function(ReceiptController) onInitialized;
  final dynamic data;

  BarcodePrinterView({super.key, required this.onInitialized, this.data});

  @override
  Widget build(BuildContext context) {
    var user = retrieveUserDetail();

    // Cast product to InventoryItem for type-safe field access
    final InventoryItem product =
        data['productData']['product'] as InventoryItem;

    // Load saved layout from DesignerRepo
    final layoutFuture = DesignerRepo().getBarcodeLayout();
    final shopType = ShopType.fromString(user.data?.shopType ?? '');
    final shopDefault =
        shopType == ShopType.clothingShop
            ? BarcodeLayoutModel.clothingShopDefault()
            : BarcodeLayoutModel.petShopDefault();

    return FutureBuilder(
      future: layoutFuture,
      builder: (context, snapshot) {
        // If stored layout has fewer elements than shop default, use shop default
        final stored = snapshot.data;
        final layout =
            (stored != null &&
                    stored.elements.length >= shopDefault.elements.length)
                ? stored
                : shopDefault;
        final selectedFontFamily = _fontFamilyName(layout.textFontFamily);

        // Canvas dimensions in px (96 dpi)
        final double canvasW = layout.canvasWidth * 96 / 25.4;
        final double canvasH = layout.canvasHeight * 96 / 25.4;

        // Build element widgets based on saved layout
        final List<Widget> stackChildren = [];
        for (final element in layout.elements) {
          if (!element.visible) continue;

          final double xPx = element.x * 96 / 25.4;
          final double yPx = element.y * 96 / 25.4;

          Widget? child;
          switch (element.type) {
            case ElementType.barcode:
              final double wPx = (element.width ?? 38) * 96 / 25.4;
              final double hPx = (element.height ?? 15) * 96 / 25.4;
              child = SizedBox(
                width: wPx,
                height: hPx,
                child: BarcodeWidget(
                  barcode: Barcode.code128(),
                  data: product.barcode ?? user.data?.name ?? '',
                  drawText: false,
                ),
              );
              break;
            case ElementType.productName:
              child = _barcodeText(
                product.name ?? '',
                (element.fontSize ?? 8) + 2,
                fontFamily: selectedFontFamily,
                bold: true,
              );
              break;
            case ElementType.price:
              final priceValue = 'Rs.${product.sellingPrice ?? ''}';
              child = _barcodeText(
                layout.fixedPriceLabel ? 'Fixed Price $priceValue' : priceValue,
                (element.fontSize ?? 10) + 2,
                fontFamily: selectedFontFamily,
                bold: true,
              );
              break;
            case ElementType.weight:
              final w = product.weight ?? '';
              if (w.isNotEmpty) {
                child = _barcodeText(
                  w,
                  element.fontSize ?? 7,
                  fontFamily: selectedFontFamily,
                );
              }
              break;
            case ElementType.shopName:
              final sn = user.data?.name ?? '';
              if (sn.isNotEmpty) {
                child = _barcodeText(
                  sn,
                  element.fontSize ?? 10,
                  fontFamily: selectedFontFamily,
                  bold: true,
                );
              }
              break;
            case ElementType.flavour:
              final fl = product.flavour ?? '';
              if (fl.isNotEmpty) {
                child = _barcodeText(
                  fl,
                  element.fontSize ?? 7,
                  fontFamily: selectedFontFamily,
                );
              }
              break;
            case ElementType.animalType:
              final at = product.animalTypeName ?? '';
              if (at.isNotEmpty) {
                child = _barcodeText(
                  at,
                  element.fontSize ?? 7,
                  fontFamily: selectedFontFamily,
                );
              }
              break;
            case ElementType.color:
              // InventoryItem uses 'color' field (mapped from color_name in JSON)
              final cl = product.color ?? '';
              if (cl.isNotEmpty) {
                child = _barcodeText(
                  cl,
                  element.fontSize ?? 7,
                  fontFamily: selectedFontFamily,
                );
              }
              break;
            case ElementType.brand:
              final br = product.brand ?? '';
              if (br.isNotEmpty) {
                child = _barcodeText(
                  br,
                  element.fontSize ?? 7,
                  fontFamily: selectedFontFamily,
                );
              }
              break;
            case ElementType.category:
              final cat = product.categoryName ?? '';
              if (cat.isNotEmpty) {
                child = _barcodeText(
                  cat,
                  element.fontSize ?? 7,
                  fontFamily: selectedFontFamily,
                );
              }
              break;
            case ElementType.expiry:
              final exp = product.expireDate ?? '';
              if (exp.isNotEmpty) {
                child = _barcodeText(
                  'Exp: $exp',
                  element.fontSize ?? 7,
                  fontFamily: selectedFontFamily,
                );
              }
              break;
          }

          if (child != null) {
            stackChildren.add(Positioned(left: xPx, top: yPx, child: child));
          }
        }

        return Receipt(
          defaultTextStyle: const TextStyle(fontSize: 12),
          builder: (context) {
            return SizedBox(
              width: canvasW,
              height: canvasH,
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: stackChildren,
              ),
            );
          },
          onInitialized: onInitialized,
        );
      },
    );
  }
}

// ── Barcode label text helper ─────────────────────────────────────────────────
Text _barcodeText(
  String value,
  double fontSize, {
  required String fontFamily,
  bool bold = false,
}) {
  final double adjustedSize = fontSize < 10 ? 10.0 : fontSize;
  return Text(
    value,
    style: TextStyle(
      fontFamily: fontFamily,
      fontSize: adjustedSize,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
      color: _k,
    ),
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
  );
}

String _fontFamilyName(DesignerFontFamily family) {
  switch (family) {
    case DesignerFontFamily.montserrat:
      return 'Montserrat';
    case DesignerFontFamily.openSans:
      return 'Open Sans';
    case DesignerFontFamily.poppins:
      return 'Poppins';
    case DesignerFontFamily.arOneSans:
      return 'AR One Sans';
    case DesignerFontFamily.raleway:
      return 'Raleway';
  }
}

class BarcodeRichText extends StatelessWidget {
  final String label;
  final String labelValue;
  const BarcodeRichText({
    super.key,
    required this.label,
    required this.labelValue,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: '$label : ',
        style: CustomTextStyle.customMontserrat(fontSize: 15, color: _k),
        children: [
          TextSpan(
            text: labelValue,
            style: CustomTextStyle.customMontserrat(
              fontSize: 20,
              color: _k,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ── FontSizeOption extension for invoice font scaling ─────────────────────────
extension InvoiceFontSizeExt on FontSizeOption {
  double invoiceFontSize({required double base}) {
    switch (this) {
      case FontSizeOption.small:
        return base;
      case FontSizeOption.large:
        return base + 6;
      case FontSizeOption.medium:
        return base + 3;
    }
  }
}
