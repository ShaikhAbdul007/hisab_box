import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inventory/helper/logger.dart';
import 'package:inventory/helper/shop_type.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer_library.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_progressbar.dart';
import 'package:inventory/common_widget/size.dart';
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
    final bankDetails = retrieveBankModelDetail();
    final shopType = ShopType.fromString(user.data?.shopType ?? '');
    final isClothing = shopType == ShopType.clothingShop;

    final String initials =
        user.data?.name?.isNotEmpty == true
            ? user.data!.name!.substring(0, 1).toUpperCase()
            : 'HB';

    final (date, time) = splitDateTime(printInvoiceModel.dateTime ?? '');
    final isCash = paymentMethod.trim().toLowerCase() == 'cash';
    final total = safeNum(printInvoiceModel.orderSummary?.finalAmount);
    final savedAmount = printInvoiceModel.orderSummary?.customerSaved ?? '0';
    final hasSavings = (double.tryParse(savedAmount) ?? 0) > 0;

    AppLogger.info('isCash is $isCash');

    return Receipt(
      backgroundColor: AppColors.whiteColor,
      builder:
          (context) => SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  setHeight(height: 16),

                  // ── Shop header ────────────────────────────────────────────
                  _buildShopHeader(user, initials),

                  setHeight(height: 12),
                  _dashedDivider(),
                  setHeight(height: 12),

                  // ── Bill meta ──────────────────────────────────────────────
                  _buildMetaSection(date, time, user),

                  setHeight(height: 12),
                  _dashedDivider(),
                  setHeight(height: 10),

                  // ── Items ──────────────────────────────────────────────────
                  _buildItemsSection(),

                  setHeight(height: 4),
                  _dashedDivider(),
                  setHeight(height: 10),

                  // ── Totals ─────────────────────────────────────────────────
                  _buildTotalsSection(),

                  setHeight(height: 12),
                  _dashedDivider(),
                  setHeight(height: 14),

                  // ── Savings ────────────────────────────────────────────────
                  if (hasSavings) ...[
                    _buildSavingsSection(savedAmount),
                    setHeight(height: 14),
                  ],

                  // ── Thank you ──────────────────────────────────────────────
                  _buildThankYouSection(),

                  setHeight(height: 16),
                  _dashedDivider(),
                  setHeight(height: 14),

                  // ── UPI QR (non-cash only) ─────────────────────────────────
                  if (bankDetails.data?.upiId?.isNotEmpty == true &&
                      !isCash) ...[
                    _buildUpiSection(bankDetails, total),
                    setHeight(height: 14),
                    _dashedDivider(),
                    setHeight(height: 14),
                  ],

                  // ── Pet Shop ad ────────────────────────────────────────────
                  if (!isClothing) ...[
                    _buildAdSection(),
                    setHeight(height: 14),
                  ],

                  // ── Powered by HisaabBox (Clothing Shop only) ──────────────
                  if (isClothing) ...[_buildPoweredBy(), setHeight(height: 14)],

                  setHeight(height: 60),
                ],
              ),
            ),
          ),
      onInitialized: (ctrl) {
        AppLogger.info('Printer Controller Initialized!');
        onInitialized(ctrl);
      },
    );
  }

  // ── Shop header ──────────────────────────────────────────────────────────────
  Widget _buildShopHeader(dynamic user, String initials) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Avatar
        Container(
          width: 64.w,
          height: 64.h,
          decoration: const BoxDecoration(color: _k, shape: BoxShape.circle),
          child:
              user.data?.profilepic?.isNotEmpty == true
                  ? ClipOval(
                    child: Image.network(
                      user.data!.profilepic!,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,
                      errorBuilder:
                          (_, __, ___) => Center(
                            child: Text(
                              initials,
                              style: CustomTextStyle.customMontserrat(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                    ),
                  )
                  : Center(
                    child: Text(
                      initials,
                      style: CustomTextStyle.customMontserrat(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
        ),

        setWidth(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.data?.name ?? '',
                style: CustomTextStyle.customMontserrat(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: _k,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              setHeight(height: 4),
              Text(
                _phoneText(user),
                style: CustomTextStyle.customMontserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _k,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _phoneText(dynamic user) {
    final mobile = user.data?.mobileNo ?? '';
    final alt = user.data?.alternateMobileNo ?? '';
    if (alt.toString().isNotEmpty) return '$mobile / $alt';
    return mobile;
  }

  // ── Bill meta ────────────────────────────────────────────────────────────────
  Widget _buildMetaSection(String date, String time, dynamic user) {
    final addr = _cap(user.data?.address);
    final city = _cap(user.data?.city);
    final pin = user.data?.pincode ?? '';
    final address = [addr, city, pin].where((s) => s.isNotEmpty).join(', ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (address.isNotEmpty) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on, size: 14.sp, color: _k),
              setWidth(width: 4),
              Expanded(
                child: Text(
                  address,
                  style: CustomTextStyle.customMontserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _k,
                  ),
                ),
              ),
            ],
          ),
          setHeight(height: 10),
          _dashedDivider(),
        ],
        setHeight(height: 10),
        _metaRow('Bill No', printInvoiceModel.invoiceNo ?? ''),
        setHeight(height: 6),
        _metaRow('Date', date),
        setHeight(height: 6),
        _metaRow('Time', time),
        setHeight(height: 6),
        _metaRow('Payment', _cap(paymentMethod)),
      ],
    );
  }

  Widget _metaRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 110.w,
          child: Text(
            label,
            style: CustomTextStyle.customMontserrat(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: _k,
            ),
          ),
        ),
        Text(
          ':  ',
          style: CustomTextStyle.customMontserrat(fontSize: 15, color: _k),
        ),
        Expanded(
          child: Text(
            value,
            style: CustomTextStyle.customMontserrat(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: _k,
            ),
          ),
        ),
      ],
    );
  }

  // ── Items ────────────────────────────────────────────────────────────────────
  Widget _buildItemsSection() {
    final items = printInvoiceModel.items ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Column headers
        Row(
          children: [
            Expanded(
              flex: 5,
              child: Text(
                'ITEM',
                style: CustomTextStyle.customMontserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: _k,
                ),
              ),
            ),
            Text(
              'AMOUNT',
              style: CustomTextStyle.customMontserrat(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: _k,
              ),
            ),
          ],
        ),
        setHeight(height: 8),
        _thinDivider(),
        setHeight(height: 8),

        ...items.map((item) => _buildItemRow(item)),
      ],
    );
  }

  Widget _buildItemRow(InvoiceDataItems item) {
    final discount = item.discountPercent ?? 0;
    final hasDiscount = discount > 0;

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName ?? 'No Name',
                  style: CustomTextStyle.customMontserrat(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: _k,
                  ),
                ),
                setHeight(height: 3),
                if (_itemSubtitle(item).isNotEmpty)
                  Text(
                    _itemSubtitle(item),
                    style: CustomTextStyle.customMontserrat(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _k,
                    ),
                  ),
                setHeight(height: 3),
                RichText(
                  text: TextSpan(
                    text: '${item.quantity} x Rs.${item.originalPrice}',
                    style: CustomTextStyle.customMontserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _k,
                    ),
                    children:
                        hasDiscount
                            ? [
                              TextSpan(
                                text: ' @ $discount%',
                                style: CustomTextStyle.customMontserrat(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: _k,
                                ),
                              ),
                            ]
                            : [],
                  ),
                ),
              ],
            ),
          ),
          Text(
            'Rs. ${item.totalPrice ?? item.finalPrice ?? ''}',
            style: CustomTextStyle.customMontserrat(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: _k,
            ),
          ),
        ],
      ),
    );
  }

  String _itemSubtitle(InvoiceDataItems item) {
    final parts = <String>[];
    if ((item.categoryName ?? '').isNotEmpty) parts.add(item.categoryName!);
    if ((item.animalTypeName ?? '').isNotEmpty) parts.add(item.animalTypeName!);
    if ((item.colorName ?? '').isNotEmpty) parts.add(item.colorName!);
    if ((item.brand ?? '').isNotEmpty) parts.add(item.brand!);
    return parts.join(' | ');
  }

  // ── Totals ───────────────────────────────────────────────────────────────────
  Widget _buildTotalsSection() {
    final summary = printInvoiceModel.orderSummary;
    final subtotal = summary?.subtotal ?? '';
    final discount = summary?.totalDiscount ?? '0';
    final roundOff = summary?.roundOff ?? '0';
    final finalAmt = summary?.finalAmount ?? '';
    final hasDiscount = (double.tryParse(discount) ?? 0) > 0;
    final hasRoundOff = (double.tryParse(roundOff) ?? 0) != 0;

    return Column(
      children: [
        // Subtotal row + divider
        if (subtotal.isNotEmpty) ...[
          _totalRow('Subtotal', 'Rs. $subtotal'),
          setHeight(height: 6),
          _dashedDivider(),
          setHeight(height: 6),
        ],

        // Discount row + divider
        if (hasDiscount) ...[
          _totalRow('Discount', '- Rs. $discount'),
          setHeight(height: 6),
          _thinDivider(),
          setHeight(height: 6),
        ],

        // Round off row + divider
        if (hasRoundOff) ...[
          _totalRow('Round Off', 'Rs. $roundOff'),
          setHeight(height: 6),
          _thinDivider(),
          setHeight(height: 6),
        ],

        setHeight(height: 4),

        // Grand Total — bold, larger
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'GRAND TOTAL',
              style: CustomTextStyle.customMontserrat(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: _k,
              ),
            ),
            Text(
              'Rs. $finalAmt',
              style: CustomTextStyle.customMontserrat(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: _k,
              ),
            ),
          ],
        ),
        setHeight(height: 6),
        _thickDivider(),
      ],
    );
  }

  Widget _totalRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: CustomTextStyle.customMontserrat(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: _k,
          ),
        ),
        Text(
          value,
          style: CustomTextStyle.customMontserrat(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: _k,
          ),
        ),
      ],
    );
  }

  // ── Savings ──────────────────────────────────────────────────────────────────
  Widget _buildSavingsSection(String savedAmount) {
    return Column(
      children: [
        Center(
          child: Text(
            '** You saved Rs. $savedAmount on this order! **',
            textAlign: TextAlign.center,
            style: CustomTextStyle.customMontserrat(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: _k,
            ),
          ),
        ),
        setHeight(height: 4),
        Center(
          child: Text(
            'Add more items to unlock bigger discounts',
            textAlign: TextAlign.center,
            style: CustomTextStyle.customMontserrat(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _k,
            ),
          ),
        ),
      ],
    );
  }

  // ── Thank you ────────────────────────────────────────────────────────────────
  Widget _buildThankYouSection() {
    return Column(
      children: [
        Center(
          child: Text(
            '** Thank You for Shopping With Us **',
            textAlign: TextAlign.center,
            style: CustomTextStyle.customMontserrat(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: _k,
            ),
          ),
        ),
        setHeight(height: 8),
        Center(
          child: Text(
            'Your satisfaction is our priority.\nWe look forward to serving you again!',
            textAlign: TextAlign.center,
            style: CustomTextStyle.customMontserrat(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _k,
            ),
          ),
        ),
        setHeight(height: 12),
        Center(
          child: Text(
            'Visit Again !',
            style: CustomTextStyle.customMontserrat(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: _k,
            ),
          ),
        ),
        setHeight(height: 4),
        Center(
          child: Text(
            'Keep shopping to save more!',
            style: CustomTextStyle.customMontserrat(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _k,
            ),
          ),
        ),
      ],
    );
  }

  // ── UPI QR ───────────────────────────────────────────────────────────────────
  Widget _buildUpiSection(dynamic bankDetails, num total) {
    return Column(
      children: [
        Center(
          child: Text(
            'Scan to Pay',
            style: CustomTextStyle.customMontserrat(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: _k,
            ),
          ),
        ),
        setHeight(height: 10),
        Center(
          child: UPIPaymentQRCode(
            upiDetails: UPIDetails(
              upiID: bankDetails.data?.upiId ?? '',
              payeeName: bankDetails.data?.accountHolder ?? '',
              amount: total.toDouble(),
            ),
            size: 180,
            embeddedImageSize: const Size(50, 50),
            loader: CommonProgressBar(color: AppColors.blackColor),
          ),
        ),
        setHeight(height: 10),
        Center(
          child: Text(
            'Rs. ${total.toStringAsFixed(2)} /-',
            style: CustomTextStyle.customMontserrat(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: _k,
            ),
          ),
        ),
      ],
    );
  }

  // ── Pet Shop ad ──────────────────────────────────────────────────────────────
  Widget _buildAdSection() {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '#Add.\n',
            style: CustomTextStyle.customOpenSans(
              color: _k,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(
            text: 'Raah Constra\n',
            style: CustomTextStyle.customOpenSans(
              color: _k,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(
            text:
                'Water Proofing | Interior Design | False Ceiling | Painting | All Renovation Work.\n',
            style: CustomTextStyle.customOpenSans(
              color: _k,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextSpan(
            text: 'www.raahconstra.com\n',
            style: CustomTextStyle.customOpenSans(
              color: _k,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextSpan(
            text: 'Contact: 9930024594',
            style: CustomTextStyle.customOpenSans(
              color: _k,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── Powered by HisaabBox (Clothing Shop) ─────────────────────────────────────
  Widget _buildPoweredBy() {
    return Column(
      children: [
        // _dashedDivider(),
        setHeight(height: 10),
        Center(
          child: Text(
            'Powered by',
            style: CustomTextStyle.customMontserrat(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _k,
            ),
          ),
        ),
        setHeight(height: 4),
        Center(
          child: Text(
            'HisaabBox',
            style: CustomTextStyle.customMontserrat(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: _k,
            ),
          ),
        ),
        setHeight(height: 2),
        Center(
          child: Text(
            'Smart Billing & Inventory Management',
            style: CustomTextStyle.customMontserrat(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _k,
            ),
          ),
        ),
        setHeight(height: 8),
        // _dashedDivider(),
      ],
    );
  }

  // ── Divider helpers ──────────────────────────────────────────────────────────

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
    final shopType = ShopType.fromString(user.data?.shopType ?? '');
    final product = data['productData']['product'];

    final String subtitle =
        shopType.config.supportsGRStock
            ? '${product.color ?? ''} | ${product.brand ?? ''} | Rs.${product.sellingPrice ?? ''}'
            : '${product.flavor ?? ''} | ${product.weight ?? ''} | Rs.${product.sellingPrice ?? ''}';

    return Receipt(
      defaultTextStyle: const TextStyle(fontSize: 12),
      builder: (context) {
        return SizedBox(
          height: 200,
          width: 189,
          child: Padding(
            padding: const EdgeInsets.only(
              right: 6,
              left: 6,
              top: 15,
              bottom: 30,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                BarcodeWidget(
                  barcode: Barcode.code128(),
                  data: user.data?.name ?? '',
                  height: 90,
                  width: 175,
                ),
                const SizedBox(height: 2),
                Text(
                  product.name ?? '',
                  style: CustomTextStyle.customMontserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _k,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  style: CustomTextStyle.customMontserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _k,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
      onInitialized: onInitialized,
    );
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
