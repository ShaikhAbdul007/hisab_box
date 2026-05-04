class BarcodeExistingModel {
  bool? success;
  String? msg;
  BarcodeExistingData? data;

  BarcodeExistingModel({this.success, this.msg, this.data});

  BarcodeExistingModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    msg = json['msg'];
    data =
        json['data'] != null
            ? BarcodeExistingData.fromJson(json['data'])
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['msg'] = msg;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class BarcodeExistingData {
  String? id;
  String? userId;
  String? name;
  String? barcodes;
  int? quantity;
  String? sellingPrice;
  String? purchasePrice;
  String? location;
  String? stockType;
  bool? isloosed;
  bool? isflavorrequired;
  String? purchaseDate;
  String? expiryDate;
  String? category;
  String? animalType;
  dynamic flavour;
  String? level;
  String? rack;
  dynamic weight;
  int? discount;
  String? createdAt;
  String? updatedAt;
  String? barcode;
  String? flag;
  String? categoryName;
  String? animalTypeName;
  int? packetQuantity;
  String? packetPrice;

  bool? isflavorRequired;

  BarcodeExistingData({
    this.id,
    this.userId,
    this.name,
    this.barcodes,
    this.quantity,
    this.sellingPrice,
    this.purchasePrice,
    this.location,
    this.stockType,
    this.isloosed,
    this.isflavorrequired,
    this.purchaseDate,
    this.expiryDate,
    this.category,
    this.animalType,
    this.flavour,
    this.level,
    this.rack,
    this.weight,
    this.discount,
    this.createdAt,
    this.updatedAt,
    this.barcode,
    this.flag,
    this.categoryName,
    this.animalTypeName,
    this.packetQuantity,
    this.packetPrice,

    this.isflavorRequired,
  });

  BarcodeExistingData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    name = json['name'];
    barcodes = json['barcodes'];
    quantity = json['quantity'];
    sellingPrice = json['selling_price'];
    purchasePrice = json['purchase_price'];
    location = json['location'];
    stockType = json['stock_type'];
    isloosed = json['isloosed'];
    isflavorrequired = json['isflavorrequired'];
    purchaseDate = json['purchase_date'];
    expiryDate = json['expiry_date'];
    category = json['category'];
    animalType = json['animal_type'];
    flavour = json['flavour'];
    level = json['level'];
    rack = json['rack'];
    weight = json['weight'];
    discount = json['discount'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    barcode = json['barcode'];
    flag = json['flag'];
    categoryName = json['category_name'];
    animalTypeName = json['animal_type_name'];
    packetQuantity = json['packet_quantity'];
    packetPrice = json['packet_price'];

    isflavorRequired = json['isflavorRequired'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['name'] = name;
    data['barcodes'] = barcodes;
    data['quantity'] = quantity;
    data['selling_price'] = sellingPrice;
    data['purchase_price'] = purchasePrice;
    data['location'] = location;
    data['stock_type'] = stockType;
    data['isloosed'] = isloosed;
    data['isflavorrequired'] = isflavorrequired;
    data['purchase_date'] = purchaseDate;
    data['expiry_date'] = expiryDate;
    data['category'] = category;
    data['animal_type'] = animalType;
    data['flavour'] = flavour;
    data['level'] = level;
    data['rack'] = rack;
    data['weight'] = weight;
    data['discount'] = discount;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['barcode'] = barcode;
    data['flag'] = flag;
    data['category_name'] = categoryName;
    data['animal_type_name'] = animalTypeName;
    data['packet_quantity'] = packetQuantity;
    data['packet_price'] = packetPrice;
    data['isflavorRequired'] = isflavorRequired;
    return data;
  }
}
