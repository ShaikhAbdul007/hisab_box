class ProductModel {
  String? barcode;
  String? name;
  String? category;
  num? quantity;
  double? purchasePrice;
  double? sellingPrice;
  String? createdDate;
  String? updatedDate;
  String? createdTime;
  String? updatedTime;
  String? color;
  String? weight;
  String? flavor;
  String? animalType;
  String? level;
  String? rack;
  String? box; // For loose category products
  bool? isLoosed;
  bool? isLooseCategory; // For loose category products
  String? id;
  String? paymentMethod;
  int? billNo;

  bool? isFlavorAndWeightNotRequired;
  int? discount;
  String? purchaseDate;
  String? expireDate;
  String? location;
  bool? isActive;
  String? sellType;
  String? stockType; // packet/loose

  // Additional fields for database compatibility
  String? categoryId; // For foreign key reference
  String? animalTypeId; // For foreign key reference
  String? userId; // For multi-tenant support

  ProductModel({
    this.barcode,
    this.name,
    this.category,
    this.quantity,
    this.billNo,
    this.paymentMethod,
    this.purchasePrice,
    this.isActive,
    this.sellingPrice,
    this.createdDate,
    this.updatedDate,
    this.createdTime,
    this.updatedTime,
    this.color,
    this.animalType,
    this.weight,
    this.flavor,
    this.level,
    this.rack,
    this.box,
    this.isLoosed,
    this.isLooseCategory,
    this.id,
    this.isFlavorAndWeightNotRequired,
    this.location,
    this.discount,
    this.expireDate,
    this.purchaseDate,
    this.sellType,
    this.stockType,
    this.categoryId,
    this.animalTypeId,
    this.userId,
  });

  ProductModel.fromJson(Map<String, dynamic> json) {
    bool parseBool(dynamic value, {bool fallback = false}) {
      if (value is bool) return value;
      if (value is num) return value != 0;
      if (value is String) {
        final normalized = value.trim().toLowerCase();
        if (normalized == 'true' ||
            normalized == 't' ||
            normalized == '1' ||
            normalized == 'yes') {
          return true;
        }
        if (normalized == 'false' ||
            normalized == 'f' ||
            normalized == '0' ||
            normalized == 'no') {
          return false;
        }
      }
      return fallback;
    }

    id = json['id'];
    barcode = json['barcode'];
    name = json['name']?.toString();
    sellType = json['sell_type'];
    location = json['location'];
    stockType = json['stock_type'];
    userId = json['user_id'];
    box = json['box'];

    // Category handling - both name and ID
    if (json['category'] is String) {
      category = json['category'];
    } else if (json['categories'] != null) {
      category = json['categories']['name'];
      categoryId = json['categories']['id']?.toString();
    }
    categoryId = categoryId ?? json['category_id']?.toString();

    // Animal type handling - both name and ID
    if (json['animal_type'] is String) {
      animalType = json['animal_type'];
    } else if (json['animals'] != null) {
      animalType = json['animals']['name'];
      animalTypeId = json['animals']['id']?.toString();
    }
    animalTypeId = animalTypeId ?? json['animal_type_id']?.toString();

    // Safe numeric parsing
    quantity =
        json['quantity'] is num
            ? json['quantity']
            : num.tryParse(json['quantity']?.toString() ?? '0') ?? 0;

    isActive = parseBool(json['is_active'], fallback: true);
    isLooseCategory = parseBool(
      json['is_loose_category'] ??
          json['isLooseCategory'] ??
          json['is_loose_cat'] ??
          json['isLoosed'],
      fallback: false,
    );

    purchasePrice = (json['purchase_price'] as num?)?.toDouble();
    sellingPrice = (json['selling_price'] as num?)?.toDouble();

    // Mapping DB 'flavour' to Model 'flavor'
    flavor = json['flavour']?.toString();
    weight = json['weight']?.toString();
    color = json['color']?.toString();

    // Mapping DB 'stock_type == loose' to isLoosed
    isLoosed = parseBool(
      json['is_loose'] ?? json['isLoosed'] ?? (json['stock_type'] == 'loose'),
      fallback: false,
    );

    isFlavorAndWeightNotRequired =
        json['is_flavor_and_weight_not_required'] ?? false;

    billNo =
        json['bill_no'] is int
            ? json['bill_no']
            : int.tryParse(json['bill_no']?.toString() ?? '');

    paymentMethod = json['payment_method']?.toString();

    // Fixed discount parsing
    discount =
        json['discount'] is int
            ? json['discount']
            : int.tryParse(json['discount']?.toString() ?? '0') ?? 0;

    level = json['level']?.toString();
    rack = json['rack']?.toString();

    purchaseDate = json['purchase_date']?.toString();
    expireDate = json['expiry_date']?.toString();

    createdDate =
        json['created_date']?.toString() ?? json['created_at']?.toString();
    updatedDate =
        json['updated_date']?.toString() ?? json['updated_at']?.toString();
    createdTime = json['created_time']?.toString();
    updatedTime = json['updated_time']?.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': categoryId ?? category,
      'animal_type': animalTypeId ?? animalType,
      'flavour': flavor,
      'weight': weight,
      'color': color,
      'rack': rack,
      'level': level,
      'box': box,
      'is_active': isActive,
      'is_loose_category': isLooseCategory,
      'is_flavor_and_weight_not_required': isFlavorAndWeightNotRequired,
      'user_id': userId,
      'stock_type': stockType,
      'sell_type': sellType,
      'location': location,
      // Stock fields
      'barcode': barcode,
      'quantity': quantity,
      'selling_price': sellingPrice,
      'purchase_price': purchasePrice,
      'discount': discount?.toString(),
      'purchase_date': purchaseDate,
      'expiry_date': expireDate,
    };
  }
}

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
  int? packetPrice;
  String? looseQuantity;
  String? loosePrice;
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
    this.looseQuantity,
    this.loosePrice,
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
    looseQuantity = json['loose_quantity'];
    loosePrice = json['loose_price'];
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
    data['loose_quantity'] = looseQuantity;
    data['loose_price'] = loosePrice;
    data['isflavorRequired'] = isflavorRequired;
    return data;
  }
}
