class BarcodeExistingModel {
  bool? success;
  String? msg;
  BarcodeExistingData? data;

  BarcodeExistingModel({this.success, this.msg, this.data});

  factory BarcodeExistingModel.fromJson(Map<String, dynamic> json) {
    return BarcodeExistingModel(
      success: json['success'],
      msg: json['msg'],
      data:
          json['data'] != null
              ? BarcodeExistingData.fromJson(json['data'])
              : null,
    );
  }
}

class BarcodeExistingData {
  String? id;
  String? userId;
  String? name;

  String? barcode;

  double? sellingPrice;
  double? purchasePrice;

  String? location;
  String? stockType;

  bool? isLoosed;
  bool? isFlavorRequired;

  String? purchaseDate;
  String? expiryDate;

  String? categoryId;
  String? categoryName;

  String? animalTypeId;
  String? animalTypeName;

  String? colorId;
  String? colorName;

  String? brand;

  dynamic flavour;
  String? level;
  String? rack;
  dynamic weight;

  int? quantity;
  int? packetQuantity;

  double? packetPrice;
  double? godownPacketPrice;

  int? godownPacketQuantity;

  int? discount;

  String? createdAt;
  String? updatedAt;

  bool? inStock;
  String? message;

  BarcodeExistingData({
    this.id,
    this.userId,
    this.name,
    this.barcode,

    this.sellingPrice,
    this.purchasePrice,
    this.location,
    this.stockType,
    this.isLoosed,
    this.isFlavorRequired,
    this.purchaseDate,
    this.expiryDate,
    this.categoryId,
    this.categoryName,
    this.animalTypeId,
    this.animalTypeName,
    this.colorId,
    this.colorName,
    this.brand,
    this.flavour,
    this.level,
    this.rack,
    this.weight,
    this.quantity,
    this.packetQuantity,
    this.packetPrice,
    this.godownPacketPrice,
    this.godownPacketQuantity,
    this.discount,
    this.createdAt,
    this.updatedAt,
    this.inStock,
    this.message,
  });

  factory BarcodeExistingData.fromJson(Map<String, dynamic> json) {
    return BarcodeExistingData(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      barcode: json['barcode'],

      sellingPrice: _parseDouble(json['selling_price']),
      purchasePrice: _parseDouble(json['purchase_price']),

      location: json['location'],
      stockType: json['stock_type'],

      isLoosed: json['isloosed'],
      isFlavorRequired: json['isflavorRequired'],

      purchaseDate: json['purchase_date'],
      expiryDate: json['expiry_date'],

      categoryId: json['category_id'],
      categoryName: json['category_name'],

      animalTypeId: json['animal_type_id'],
      animalTypeName: json['animal_type_name'],

      colorId: json['color_id'],
      colorName: json['color_name'],

      brand: json['brand'],

      flavour: json['flavour'],
      level: json['level'],
      rack: json['rack'],
      weight: json['weight'],

      quantity: json['quantity'],
      packetQuantity: json['packet_quantity'],

      packetPrice: _parseDouble(json['packet_price']),
      godownPacketPrice: _parseDouble(json['godown_packet_price']),
      godownPacketQuantity: json['godown_packet_quantity'],

      discount: json['discount'],

      createdAt: json['created_at'],
      updatedAt: json['updated_at'],

      inStock: json['in_stock'],
      message: json['message'],
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;

    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value);

    return null;
  }
}
