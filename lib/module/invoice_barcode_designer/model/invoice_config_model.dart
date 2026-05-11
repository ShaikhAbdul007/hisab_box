import 'package:inventory/module/invoice_barcode_designer/model/barcode_layout_model.dart';

// ── InvoiceTemplate ───────────────────────────────────────────────────────────

class InvoiceTemplate {
  final String id;
  final String name;
  final String description;

  const InvoiceTemplate({
    required this.id,
    required this.name,
    required this.description,
  });

  /// Pre-defined templates
  static const List<InvoiceTemplate> all = [
    InvoiceTemplate(
      id: 'template_1',
      name: 'Classic',
      description: 'Clean layout with header, table, and footer',
    ),
    InvoiceTemplate(
      id: 'template_2',
      name: 'Modern',
      description: 'Bold header with compact item rows',
    ),
    InvoiceTemplate(
      id: 'template_3',
      name: 'Minimal',
      description: 'Simple text-only layout, fast to print',
    ),
    InvoiceTemplate(
      id: 'template_4',
      name: 'Detailed',
      description: 'Full details including GST, address, and bank info',
    ),
  ];

  static InvoiceTemplate byId(String id) {
    return all.firstWhere((t) => t.id == id, orElse: () => all.first);
  }
}

// ── InvoiceConfigModel ────────────────────────────────────────────────────────

class InvoiceConfigModel {
  final String templateId;
  final FontSizeOption fontSize;
  final DesignerFontFamily invoiceFontFamily;
  final bool showLogo;
  final bool showGST;
  final bool showAddress;
  final bool showMobile;
  final bool showBrand;
  final bool showColor;
  final bool showSize;
  final bool showFlavour;
  final bool showWeight;
  final bool showAnimalType;
  final String footerText;
  final String termsAndConditionsText;

  /// Fixed black — not user-configurable
  static const String headerColor = '#000000';

  const InvoiceConfigModel({
    this.templateId = 'template_1',
    this.fontSize = FontSizeOption.medium,
    this.invoiceFontFamily = DesignerFontFamily.raleway,
    this.showLogo = true,
    this.showGST = true,
    this.showAddress = true,
    this.showMobile = true,
    this.showBrand = true,
    this.showColor = true,
    this.showSize = true,
    this.showFlavour = true,
    this.showWeight = true,
    this.showAnimalType = true,
    this.footerText = 'Thank you for shopping!',
    this.termsAndConditionsText =
        '1. Goods once sold will not be taken back or exchanged.\n'
        '2. No refund on sold items.\n'
        '3. All disputes subject to local jurisdiction.',
  });

  InvoiceConfigModel copyWith({
    String? templateId,
    FontSizeOption? fontSize,
    DesignerFontFamily? invoiceFontFamily,
    bool? showLogo,
    bool? showGST,
    bool? showAddress,
    bool? showMobile,
    bool? showBrand,
    bool? showColor,
    bool? showSize,
    bool? showFlavour,
    bool? showWeight,
    bool? showAnimalType,
    String? footerText,
    String? termsAndConditionsText,
  }) {
    return InvoiceConfigModel(
      templateId: templateId ?? this.templateId,
      fontSize: fontSize ?? this.fontSize,
      invoiceFontFamily: invoiceFontFamily ?? this.invoiceFontFamily,
      showLogo: showLogo ?? this.showLogo,
      showGST: showGST ?? this.showGST,
      showAddress: showAddress ?? this.showAddress,
      showMobile: showMobile ?? this.showMobile,
      showBrand: showBrand ?? this.showBrand,
      showColor: showColor ?? this.showColor,
      showSize: showSize ?? this.showSize,
      showFlavour: showFlavour ?? this.showFlavour,
      showWeight: showWeight ?? this.showWeight,
      showAnimalType: showAnimalType ?? this.showAnimalType,
      footerText: footerText ?? this.footerText,
      termsAndConditionsText:
          termsAndConditionsText ?? this.termsAndConditionsText,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'templateId': templateId,
      'fontSize': fontSize.name,
      'invoiceFontFamily': invoiceFontFamily.name,
      'showLogo': showLogo,
      'showGST': showGST,
      'showAddress': showAddress,
      'showMobile': showMobile,
      'showBrand': showBrand,
      'showColor': showColor,
      'showSize': showSize,
      'showFlavour': showFlavour,
      'showWeight': showWeight,
      'showAnimalType': showAnimalType,
      'footerText': footerText,
      'termsAndConditionsText': termsAndConditionsText,
    };
  }

  factory InvoiceConfigModel.fromJson(Map<String, dynamic> json) {
    return InvoiceConfigModel(
      templateId: json['templateId'] as String? ?? 'template_1',
      fontSize: FontSizeOption.fromString(
        json['fontSize'] as String? ?? 'medium',
      ),
      invoiceFontFamily: DesignerFontFamily.fromString(
        json['invoiceFontFamily'] as String? ?? 'raleway',
      ),
      showLogo: json['showLogo'] as bool? ?? true,
      showGST: json['showGST'] as bool? ?? true,
      showAddress: json['showAddress'] as bool? ?? true,
      showMobile: json['showMobile'] as bool? ?? true,
      showBrand:
          json['showBrand'] as bool? ??
          json['showProductInfo'] as bool? ??
          json['showBarcode'] as bool? ??
          true,
      showColor:
          json['showColor'] as bool? ??
          json['showProductInfo'] as bool? ??
          json['showBarcode'] as bool? ??
          true,
      showSize:
          json['showSize'] as bool? ??
          json['showProductInfo'] as bool? ??
          json['showBarcode'] as bool? ??
          true,
      showFlavour:
          json['showFlavour'] as bool? ??
          json['showProductInfo'] as bool? ??
          json['showBarcode'] as bool? ??
          true,
      showWeight:
          json['showWeight'] as bool? ??
          json['showProductInfo'] as bool? ??
          json['showBarcode'] as bool? ??
          true,
      showAnimalType:
          json['showAnimalType'] as bool? ??
          json['showProductInfo'] as bool? ??
          json['showBarcode'] as bool? ??
          true,
      footerText: json['footerText'] as String? ?? 'Thank you for shopping!',
      termsAndConditionsText:
          json['termsAndConditionsText'] as String? ??
          '1. Goods once sold will not be taken back or exchanged.\n'
              '2. No refund on sold items.\n'
              '3. All disputes subject to local jurisdiction.',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvoiceConfigModel &&
          runtimeType == other.runtimeType &&
          templateId == other.templateId &&
          fontSize == other.fontSize &&
          invoiceFontFamily == other.invoiceFontFamily &&
          showLogo == other.showLogo &&
          showGST == other.showGST &&
          showAddress == other.showAddress &&
          showMobile == other.showMobile &&
          showBrand == other.showBrand &&
          showColor == other.showColor &&
          showSize == other.showSize &&
          showFlavour == other.showFlavour &&
          showWeight == other.showWeight &&
          showAnimalType == other.showAnimalType &&
          footerText == other.footerText &&
          termsAndConditionsText == other.termsAndConditionsText;

  @override
  int get hashCode =>
      templateId.hashCode ^
      fontSize.hashCode ^
      invoiceFontFamily.hashCode ^
      showLogo.hashCode ^
      showGST.hashCode ^
      showAddress.hashCode ^
      showMobile.hashCode ^
      showBrand.hashCode ^
      showColor.hashCode ^
      showSize.hashCode ^
      showFlavour.hashCode ^
      showWeight.hashCode ^
      showAnimalType.hashCode ^
      footerText.hashCode ^
      termsAndConditionsText.hashCode;
}
