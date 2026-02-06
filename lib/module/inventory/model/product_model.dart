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
    id = json['id']?.toString();
    barcode = json['barcode']?.toString();
    name = json['name']?.toString();
    sellType = json['sell_type']?.toString();
    location = json['location']?.toString();
    stockType = json['stock_type']?.toString();
    userId = json['user_id']?.toString();
    box = json['box']?.toString();

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

    isActive = json['is_active'] ?? true;
    isLooseCategory = json['is_loose_category'] ?? false;

    purchasePrice = (json['purchase_price'] as num?)?.toDouble();
    sellingPrice = (json['selling_price'] as num?)?.toDouble();

    // Mapping DB 'flavour' to Model 'flavor'
    flavor = json['flavour']?.toString();
    weight = json['weight']?.toString();
    color = json['color']?.toString();

    // Mapping DB 'stock_type == loose' to isLoosed
    isLoosed = json['is_loose'] ?? (json['stock_type'] == 'loose');

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
      'quantity': quantity,
      'selling_price': sellingPrice,
      'purchase_price': purchasePrice,
      'discount': discount?.toString(),
      'purchase_date': purchaseDate,
      'expiry_date': expireDate,
    };
  }
}
