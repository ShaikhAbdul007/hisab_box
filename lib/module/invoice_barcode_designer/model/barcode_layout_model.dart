// ── Enums ────────────────────────────────────────────────────────────────────

enum CanvasSize {
  mm58,
  mm80;

  double get widthMm => this == CanvasSize.mm58 ? 58.0 : 80.0;

  static CanvasSize fromString(String value) {
    switch (value) {
      case 'mm80':
        return CanvasSize.mm80;
      case 'mm58':
      default:
        return CanvasSize.mm58;
    }
  }
}

enum ElementType {
  barcode,
  productName,
  price,
  weight,
  // ── Shop Name ─────────────────────────────────────────────────────────────
  shopName,
  // ── Pet Shop ──────────────────────────────────────────────────────────────
  flavour,
  animalType,
  // ── Clothing Shop ─────────────────────────────────────────────────────────
  color,
  brand,
  // ── Common ────────────────────────────────────────────────────────────────
  category,
  expiry;

  static ElementType fromString(String value) {
    switch (value) {
      case 'productName':
        return ElementType.productName;
      case 'price':
        return ElementType.price;
      case 'weight':
        return ElementType.weight;
      case 'shopName':
        return ElementType.shopName;
      case 'flavour':
        return ElementType.flavour;
      case 'animalType':
        return ElementType.animalType;
      case 'color':
        return ElementType.color;
      case 'brand':
        return ElementType.brand;
      case 'category':
        return ElementType.category;
      case 'expiry':
        return ElementType.expiry;
      case 'barcode':
      default:
        return ElementType.barcode;
    }
  }

  String get label {
    switch (this) {
      case ElementType.barcode:
        return 'Barcode';
      case ElementType.productName:
        return 'Product Name';
      case ElementType.price:
        return 'Price';
      case ElementType.weight:
        return 'Weight';
      case ElementType.shopName:
        return 'Shop Name';
      case ElementType.flavour:
        return 'Flavour';
      case ElementType.animalType:
        return 'Animal Type';
      case ElementType.color:
        return 'Color';
      case ElementType.brand:
        return 'Brand';
      case ElementType.category:
        return 'Category';
      case ElementType.expiry:
        return 'Expiry Date';
    }
  }

  bool get isTextElement => this != ElementType.barcode;
}

enum FontSizeOption {
  small,
  medium,
  large;

  double get ptValue {
    switch (this) {
      case FontSizeOption.small:
        return 8.0;
      case FontSizeOption.medium:
        return 11.0;
      case FontSizeOption.large:
        return 14.0;
    }
  }

  static FontSizeOption fromString(String value) {
    switch (value) {
      case 'small':
        return FontSizeOption.small;
      case 'large':
        return FontSizeOption.large;
      case 'medium':
      default:
        return FontSizeOption.medium;
    }
  }
}

enum DesignerFontFamily {
  raleway,
  montserrat,
  openSans,
  poppins,
  arOneSans;

  String get label {
    switch (this) {
      case DesignerFontFamily.raleway:
        return 'Raleway';
      case DesignerFontFamily.montserrat:
        return 'Montserrat';
      case DesignerFontFamily.openSans:
        return 'Open Sans';
      case DesignerFontFamily.poppins:
        return 'Poppins';
      case DesignerFontFamily.arOneSans:
        return 'AR One Sans';
    }
  }

  static DesignerFontFamily fromString(String value) {
    switch (value) {
      case 'montserrat':
        return DesignerFontFamily.montserrat;
      case 'openSans':
        return DesignerFontFamily.openSans;
      case 'poppins':
        return DesignerFontFamily.poppins;
      case 'arOneSans':
        return DesignerFontFamily.arOneSans;
      case 'raleway':
      default:
        return DesignerFontFamily.raleway;
    }
  }
}

// ── BarcodeElement ────────────────────────────────────────────────────────────

class BarcodeElement {
  final ElementType type;
  final double x; // mm
  final double y; // mm
  final double? width; // mm — barcode only
  final double? height; // mm — barcode only
  final double? fontSize; // pt — text elements only
  final bool visible;

  const BarcodeElement({
    required this.type,
    required this.x,
    required this.y,
    this.width,
    this.height,
    this.fontSize,
    this.visible = true,
  });

  BarcodeElement copyWith({
    ElementType? type,
    double? x,
    double? y,
    double? width,
    double? height,
    double? fontSize,
    bool? visible,
  }) {
    return BarcodeElement(
      type: type ?? this.type,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      fontSize: fontSize ?? this.fontSize,
      visible: visible ?? this.visible,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'x': x,
      'y': y,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (fontSize != null) 'fontSize': fontSize,
      'visible': visible,
    };
  }

  factory BarcodeElement.fromJson(Map<String, dynamic> json) {
    return BarcodeElement(
      type: ElementType.fromString(json['type'] as String? ?? 'barcode'),
      x: (json['x'] as num?)?.toDouble() ?? 0.0,
      y: (json['y'] as num?)?.toDouble() ?? 0.0,
      width: (json['width'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
      fontSize: (json['fontSize'] as num?)?.toDouble(),
      visible: json['visible'] as bool? ?? true,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BarcodeElement &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          x == other.x &&
          y == other.y &&
          width == other.width &&
          height == other.height &&
          fontSize == other.fontSize &&
          visible == other.visible;

  @override
  int get hashCode =>
      type.hashCode ^
      x.hashCode ^
      y.hashCode ^
      width.hashCode ^
      height.hashCode ^
      fontSize.hashCode ^
      visible.hashCode;
}

// ── BarcodeLayoutModel ────────────────────────────────────────────────────────

class BarcodeLayoutModel {
  final CanvasSize canvasSize;
  final double canvasWidth; // mm
  final double canvasHeight; // mm
  final bool fixedPriceLabel;
  final DesignerFontFamily textFontFamily;
  final List<BarcodeElement> elements;

  const BarcodeLayoutModel({
    required this.canvasSize,
    required this.canvasWidth,
    required this.canvasHeight,
    this.fixedPriceLabel = false,
    this.textFontFamily = DesignerFontFamily.raleway,
    required this.elements,
  });

  factory BarcodeLayoutModel.defaultLayout() => const BarcodeLayoutModel(
    canvasSize: CanvasSize.mm58,
    canvasWidth: 58.0,
    canvasHeight: 30.0,
    fixedPriceLabel: false,
    textFontFamily: DesignerFontFamily.raleway,
    elements: [
      BarcodeElement(
        type: ElementType.barcode,
        x: 10.0,
        y: 5.0,
        width: 38.0,
        height: 15.0,
      ),
      BarcodeElement(
        type: ElementType.shopName,
        x: 10.0,
        y: 2.0,
        fontSize: 10.0,
        visible: false,
      ),
      BarcodeElement(
        type: ElementType.productName,
        x: 10.0,
        y: 22.0,
        fontSize: 8.0,
      ),
      BarcodeElement(type: ElementType.price, x: 35.0, y: 22.0, fontSize: 10.0),
    ],
  );

  /// Pet Shop default — barcode + name + price + animalType + weight + flavour
  factory BarcodeLayoutModel.petShopDefault() => const BarcodeLayoutModel(
    canvasSize: CanvasSize.mm58,
    canvasWidth: 58.0,
    canvasHeight: 42.0,
    fixedPriceLabel: false,
    textFontFamily: DesignerFontFamily.raleway,
    elements: [
      BarcodeElement(
        type: ElementType.barcode,
        x: 5.0,
        y: 2.0,
        width: 48.0,
        height: 14.0,
      ),
      BarcodeElement(
        type: ElementType.shopName,
        x: 2.0,
        y: 2.0,
        fontSize: 9.0,
        visible: false,
      ),
      BarcodeElement(
        type: ElementType.productName,
        x: 2.0,
        y: 18.0,
        fontSize: 8.0,
      ),
      BarcodeElement(type: ElementType.price, x: 38.0, y: 18.0, fontSize: 9.0),
      BarcodeElement(
        type: ElementType.animalType,
        x: 2.0,
        y: 25.0,
        fontSize: 7.0,
      ),
      BarcodeElement(type: ElementType.weight, x: 2.0, y: 32.0, fontSize: 7.0),
      BarcodeElement(
        type: ElementType.flavour,
        x: 25.0,
        y: 32.0,
        fontSize: 7.0,
      ),
    ],
  );

  /// Clothing Shop default — barcode + name + price + brand + color + category
  factory BarcodeLayoutModel.clothingShopDefault() => const BarcodeLayoutModel(
    canvasSize: CanvasSize.mm58,
    canvasWidth: 58.0,
    canvasHeight: 42.0,
    fixedPriceLabel: false,
    textFontFamily: DesignerFontFamily.raleway,
    elements: [
      BarcodeElement(
        type: ElementType.barcode,
        x: 5.0,
        y: 2.0,
        width: 48.0,
        height: 14.0,
      ),
      BarcodeElement(
        type: ElementType.shopName,
        x: 2.0,
        y: 2.0,
        fontSize: 9.0,
        visible: false,
      ),
      BarcodeElement(
        type: ElementType.productName,
        x: 2.0,
        y: 18.0,
        fontSize: 8.0,
      ),
      BarcodeElement(type: ElementType.price, x: 38.0, y: 18.0, fontSize: 9.0),
      BarcodeElement(type: ElementType.brand, x: 2.0, y: 25.0, fontSize: 7.0),
      BarcodeElement(type: ElementType.color, x: 2.0, y: 32.0, fontSize: 7.0),
      BarcodeElement(
        type: ElementType.category,
        x: 25.0,
        y: 32.0,
        fontSize: 7.0,
      ),
    ],
  );

  BarcodeLayoutModel copyWith({
    CanvasSize? canvasSize,
    double? canvasWidth,
    double? canvasHeight,
    bool? fixedPriceLabel,
    DesignerFontFamily? textFontFamily,
    List<BarcodeElement>? elements,
  }) {
    return BarcodeLayoutModel(
      canvasSize: canvasSize ?? this.canvasSize,
      canvasWidth: canvasWidth ?? this.canvasWidth,
      canvasHeight: canvasHeight ?? this.canvasHeight,
      fixedPriceLabel: fixedPriceLabel ?? this.fixedPriceLabel,
      textFontFamily: textFontFamily ?? this.textFontFamily,
      elements: elements ?? this.elements,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'canvasSize': canvasSize.name,
      'canvasWidth': canvasWidth,
      'canvasHeight': canvasHeight,
      'fixedPriceLabel': fixedPriceLabel,
      'textFontFamily': textFontFamily.name,
      'elements': elements.map((e) => e.toJson()).toList(),
    };
  }

  factory BarcodeLayoutModel.fromJson(Map<String, dynamic> json) {
    final elementsList = json['elements'];
    final elements =
        (elementsList is List)
            ? elementsList
                .map(
                  (e) => BarcodeElement.fromJson(
                    Map<String, dynamic>.from(e as Map),
                  ),
                )
                .toList()
            : <BarcodeElement>[];

    return BarcodeLayoutModel(
      canvasSize: CanvasSize.fromString(
        json['canvasSize'] as String? ?? 'mm58',
      ),
      canvasWidth: (json['canvasWidth'] as num?)?.toDouble() ?? 58.0,
      canvasHeight: (json['canvasHeight'] as num?)?.toDouble() ?? 30.0,
      fixedPriceLabel: json['fixedPriceLabel'] as bool? ?? false,
      textFontFamily: DesignerFontFamily.fromString(
        json['textFontFamily'] as String? ?? 'raleway',
      ),
      elements: elements,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BarcodeLayoutModel &&
          runtimeType == other.runtimeType &&
          canvasSize == other.canvasSize &&
          canvasWidth == other.canvasWidth &&
          canvasHeight == other.canvasHeight &&
          fixedPriceLabel == other.fixedPriceLabel &&
          textFontFamily == other.textFontFamily &&
          _listEquals(elements, other.elements);

  @override
  int get hashCode =>
      canvasSize.hashCode ^
      canvasWidth.hashCode ^
      canvasHeight.hashCode ^
      fixedPriceLabel.hashCode ^
      textFontFamily.hashCode ^
      elements.hashCode;

  static bool _listEquals(List<BarcodeElement> a, List<BarcodeElement> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
