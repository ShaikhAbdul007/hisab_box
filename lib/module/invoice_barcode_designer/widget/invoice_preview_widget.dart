import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/helper/shop_type.dart';
import 'package:inventory/helper/textstyle.dart';
import 'package:inventory/module/invoice_barcode_designer/model/barcode_layout_model.dart';
import 'package:inventory/module/invoice_barcode_designer/model/invoice_config_model.dart';

const Color _kHeaderBg = Color(0xFF2A2A2A);

class InvoicePreviewWidget extends StatelessWidget {
  final InvoiceConfigModel config;
  final InvoiceTemplate template;
  final ShopType shopType;

  const InvoicePreviewWidget({
    super.key,
    required this.config,
    required this.template,
    required this.shopType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.black),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: _buildTemplate(),
      ),
    );
  }

  Widget _buildTemplate() {
    switch (template.id) {
      case 'template_2':
        return _ModernTemplate(config: config, shopType: shopType);
      case 'template_3':
        return _MinimalTemplate(config: config, shopType: shopType);
      case 'template_4':
        return _DetailedTemplate(config: config, shopType: shopType);
      case 'template_1':
      default:
        return _ClassicTemplate(config: config, shopType: shopType);
    }
  }
}

String _previewInfo(InvoiceConfigModel config, ShopType shopType) {
  final fields = <String>[];
  switch (shopType) {
    case ShopType.petShop:
      if (config.showFlavour) fields.add('Flavour: Chicken');
      if (config.showWeight) fields.add('Weight: 1kg');
      if (config.showAnimalType) fields.add('Type: Dog');
      if (config.showBrand) fields.add('Brand: PetFoodCo');
      break;
    case ShopType.clothingShop:
      if (config.showColor) fields.add('Color: Black');
      if (config.showBrand) fields.add('Brand: Nike');
      if (config.showSize) fields.add('Size: M');
      break;
  }
  return fields.join(' · ');
}

TextStyle _invoiceStyle(
  DesignerFontFamily family, {
  Color color = AppColors.blackColor,
  FontWeight fontWeight = FontWeight.normal,
  double fontSize = 15,
  double letterSpacing = 0,
}) {
  switch (family) {
    case DesignerFontFamily.montserrat:
      return CustomTextStyle.customMontserrat(
        color: color,
        fontWeight: fontWeight,
        fontSize: fontSize,
        letterSpacing: letterSpacing,
      );
    case DesignerFontFamily.openSans:
      return CustomTextStyle.customOpenSans(
        color: color,
        fontWeight: fontWeight,
        fontSize: fontSize,
        letterSpacing: letterSpacing,
      );
    case DesignerFontFamily.poppins:
      return CustomTextStyle.customPoppin(
        color: color,
        fontWeight: fontWeight,
        fontSize: fontSize,
        letterSpacing: letterSpacing,
      );
    case DesignerFontFamily.arOneSans:
      return CustomTextStyle.customNato(
        color: color,
        fontWeight: fontWeight,
        fontSize: fontSize,
        letterSpacing: letterSpacing,
      );
    case DesignerFontFamily.raleway:
      return CustomTextStyle.customRaleway(
        color: color,
        fontWeight: fontWeight,
        fontSize: fontSize,
        letterSpacing: letterSpacing,
      );
  }
}

// ── Font size helper ──────────────────────────────────────────────────────────

double _fs(FontSizeOption option, {double base = 11}) {
  switch (option) {
    case FontSizeOption.small:
      return base;
    case FontSizeOption.large:
      return base + 6;
    case FontSizeOption.medium:
      return base + 3;
  }
}

// ── Classic Template ──────────────────────────────────────────────────────────

class _ClassicTemplate extends StatelessWidget {
  final InvoiceConfigModel config;
  final ShopType shopType;
  const _ClassicTemplate({required this.config, required this.shopType});

  @override
  Widget build(BuildContext context) {
    final f = _fs(config.fontSize);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: _kHeaderBg,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (config.showLogo)
                Text(
                  'SHOP NAME',
                  style: CustomTextStyle.customRaleway(
                    fontSize: f + 2,
                    color: AppColors.whiteColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              if (config.showAddress)
                Text(
                  '123 Main Street, City',
                  style: CustomTextStyle.customRaleway(
                    fontSize: f - 1,
                    color: Colors.white,
                  ),
                ),
              if (config.showMobile)
                Text(
                  '+91 98765 43210',
                  style: CustomTextStyle.customRaleway(
                    fontSize: f - 1,
                    color: Colors.white,
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PreviewRow(
                label: 'Invoice #',
                value: '001',
                fontSize: f,
                fontFamily: config.invoiceFontFamily,
              ),
              if (config.showGST)
                _PreviewRow(
                  label: 'GST No.',
                  value: '27XXXXX1234Z1',
                  fontSize: f,
                  fontFamily: config.invoiceFontFamily,
                ),
              Divider(height: 12.h, color: Colors.black),
              _PreviewRow(
                label: 'Product A',
                value: '₹ 100',
                fontSize: f,
                fontFamily: config.invoiceFontFamily,
              ),
              if (_previewInfo(config, shopType).isNotEmpty)
                _PreviewRow(
                  label: 'Info',
                  value: _previewInfo(config, shopType),
                  fontSize: f - 1,
                  fontFamily: config.invoiceFontFamily,
                ),
              _PreviewRow(
                label: 'Product B',
                value: '₹ 200',
                fontSize: f,
                fontFamily: config.invoiceFontFamily,
              ),
              Divider(height: 12.h, color: Colors.black),
              _PreviewRow(
                label: 'Total',
                value: '₹ 300',
                fontSize: f,
                fontFamily: config.invoiceFontFamily,
                bold: true,
              ),
            ],
          ),
        ),
        Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          child: Text(
            config.footerText,
            style: CustomTextStyle.customRaleway(
              fontSize: f - 1,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

// ── Modern Template ───────────────────────────────────────────────────────────

class _ModernTemplate extends StatelessWidget {
  final InvoiceConfigModel config;
  final ShopType shopType;
  const _ModernTemplate({required this.config, required this.shopType});

  @override
  Widget build(BuildContext context) {
    final f = _fs(config.fontSize);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: _kHeaderBg,
          padding: EdgeInsets.all(12.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (config.showLogo)
                Expanded(
                  child: Text(
                    'SHOP',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CustomTextStyle.customRaleway(
                      fontSize: f + 4,
                      color: AppColors.whiteColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              if (config.showLogo) SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'INVOICE',
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: CustomTextStyle.customRaleway(
                    fontSize: f,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.all(10.w),
          child: Column(
            children: [
              _CompactRow(
                label: 'Item 1',
                value: '₹100',
                fontSize: f,
                fontFamily: config.invoiceFontFamily,
              ),
              if (_previewInfo(config, shopType).isNotEmpty)
                _CompactRow(
                  label: 'Info',
                  value: _previewInfo(config, shopType),
                  fontSize: f - 1,
                  fontFamily: config.invoiceFontFamily,
                ),
              _CompactRow(
                label: 'Item 2',
                value: '₹200',
                fontSize: f,
                fontFamily: config.invoiceFontFamily,
              ),
              _CompactRow(
                label: 'Item 3',
                value: '₹150',
                fontSize: f,
                fontFamily: config.invoiceFontFamily,
              ),
              Divider(height: 10.h),
              _CompactRow(
                label: 'Total',
                value: '₹450',
                fontSize: f,
                fontFamily: config.invoiceFontFamily,
                bold: true,
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: Text(
            config.footerText,
            style: CustomTextStyle.customRaleway(
              fontSize: f - 2,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

// ── Minimal Template ──────────────────────────────────────────────────────────

class _MinimalTemplate extends StatelessWidget {
  final InvoiceConfigModel config;
  final ShopType shopType;
  const _MinimalTemplate({required this.config, required this.shopType});

  @override
  Widget build(BuildContext context) {
    final f = _fs(config.fontSize);
    return Padding(
      padding: EdgeInsets.all(12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (config.showLogo)
            Text(
              'Shop Name',
              style: CustomTextStyle.customRaleway(
                fontSize: f + 1,
                fontWeight: FontWeight.w700,
              ),
            ),
          if (config.showMobile)
            Text(
              '+91 98765 43210',
              style: CustomTextStyle.customRaleway(
                fontSize: f - 1,
                color: Colors.black,
              ),
            ),
          SizedBox(height: 8.h),
          Text(
            'Item 1 .............. ₹100',
            style: CustomTextStyle.customRaleway(fontSize: f),
          ),
          if (_previewInfo(config, shopType).isNotEmpty)
            Text(
              'Info .... ${_previewInfo(config, shopType)}',
              style: CustomTextStyle.customRaleway(fontSize: f - 1),
            ),
          Text(
            'Item 2 .............. ₹200',
            style: CustomTextStyle.customRaleway(fontSize: f),
          ),
          Divider(height: 10.h),
          Text(
            'Total ............... ₹300',
            style: CustomTextStyle.customRaleway(
              fontSize: f,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            config.footerText,
            style: CustomTextStyle.customRaleway(
              fontSize: f - 2,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Detailed Template ─────────────────────────────────────────────────────────

class _DetailedTemplate extends StatelessWidget {
  final InvoiceConfigModel config;
  final ShopType shopType;
  const _DetailedTemplate({required this.config, required this.shopType});

  @override
  Widget build(BuildContext context) {
    final f = _fs(config.fontSize);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: _kHeaderBg,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (config.showLogo)
                Text(
                  'SHOP NAME',
                  style: CustomTextStyle.customRaleway(
                    fontSize: f + 1,
                    color: AppColors.whiteColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              if (config.showAddress)
                Text(
                  '123 Main St, City - 400001',
                  style: CustomTextStyle.customRaleway(
                    fontSize: f - 2,
                    color: Colors.white,
                  ),
                ),
              if (config.showMobile)
                Text(
                  'Ph: +91 98765 43210',
                  style: CustomTextStyle.customRaleway(
                    fontSize: f - 2,
                    color: Colors.white,
                  ),
                ),
              if (config.showGST)
                Text(
                  'GSTIN: 27XXXXX1234Z1',
                  style: CustomTextStyle.customRaleway(
                    fontSize: f - 2,
                    color: Colors.white,
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          child: Column(
            children: [
              _PreviewRow(
                label: 'Product A x2',
                value: '₹200',
                fontSize: f,
                fontFamily: config.invoiceFontFamily,
              ),
              if (_previewInfo(config, shopType).isNotEmpty)
                _PreviewRow(
                  label: 'Info',
                  value: _previewInfo(config, shopType),
                  fontSize: f - 1,
                  fontFamily: config.invoiceFontFamily,
                ),
              _PreviewRow(
                label: 'Product B x1',
                value: '₹150',
                fontSize: f,
                fontFamily: config.invoiceFontFamily,
              ),
              Divider(height: 8.h),
              _PreviewRow(
                label: 'Subtotal',
                value: '₹350',
                fontSize: f,
                fontFamily: config.invoiceFontFamily,
              ),
              _PreviewRow(
                label: 'GST (18%)',
                value: '₹63',
                fontSize: f,
                fontFamily: config.invoiceFontFamily,
              ),
              _PreviewRow(
                label: 'Total',
                value: '₹413',
                fontSize: f,
                fontFamily: config.invoiceFontFamily,
                bold: true,
              ),
            ],
          ),
        ),
        Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
          child: Text(
            config.footerText,
            style: CustomTextStyle.customRaleway(
              fontSize: f - 2,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

// ── Shared row widgets ────────────────────────────────────────────────────────

class _PreviewRow extends StatelessWidget {
  final String label;
  final String value;
  final double fontSize;
  final DesignerFontFamily fontFamily;
  final bool bold;

  const _PreviewRow({
    required this.label,
    required this.value,
    required this.fontSize,
    required this.fontFamily,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.5.h),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _invoiceStyle(
                fontFamily,
                fontSize: fontSize,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            flex: 4,
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: _invoiceStyle(
                fontFamily,
                fontSize: fontSize,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactRow extends StatelessWidget {
  final String label;
  final String value;
  final double fontSize;
  final DesignerFontFamily fontFamily;
  final bool bold;

  const _CompactRow({
    required this.label,
    required this.value,
    required this.fontSize,
    required this.fontFamily,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _invoiceStyle(
                fontFamily,
                fontSize: fontSize,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            flex: 4,
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: _invoiceStyle(
                fontFamily,
                fontSize: fontSize,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
