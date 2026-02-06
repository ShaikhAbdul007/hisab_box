class LooseInvetoryModel {
  String? id; // loose_stocks table ki primary key (UUID)
  String? productId; // product link karne ke liye
  String? userId;
  String? name;
  String? category;
  String? animalType;
  int? quantity;
  double? sellingPrice;
  double? purchasePrice; // Agar batches se join kiya hai
  String? weight;
  String? flavor;
  String? rack;
  String? level;
  String? expireDate;
  String? purchaseDate;
  String? location; // Usually 'shop'
  String? barcode; // Multiple barcodes handle karne ke liye
  bool? isLooseCategory; // Database column name is_loose_category hai
  bool? isActive; // Database column name is_active hai
  bool? isFlavorAndWeightNotRequired;
  String? color;
  String? box; // For loose category products
  String? stockType; // loose/packet
  String? sellType; // Packet/Loose

  // Additional fields for database compatibility
  String? categoryId; // For foreign key reference
  String? animalTypeId; // For foreign key reference
  String? createdAt;
  String? updatedAt;
  int? discount;

  LooseInvetoryModel({
    this.id,
    this.productId,
    this.userId,
    this.name,
    this.category,
    this.animalType,
    this.isActive,
    this.quantity,
    this.sellingPrice,
    this.purchasePrice,
    this.weight,
    this.flavor,
    this.expireDate,
    this.location,
    this.purchaseDate,
    this.rack,
    this.level,
    this.barcode,
    this.isLooseCategory,
    this.isFlavorAndWeightNotRequired,
    this.color,
    this.box,
    this.stockType,
    this.sellType,
    this.categoryId,
    this.animalTypeId,
    this.createdAt,
    this.updatedAt,
    this.discount,
  });

  LooseInvetoryModel.fromJson(Map<String, dynamic> json) {
    // 1. Direct from loose_stocks
    id = json['id']?.toString();
    productId = json['product_id']?.toString();
    userId = json['user_id']?.toString();
    quantity = int.tryParse(json['quantity']?.toString() ?? '0');
    sellingPrice = double.tryParse(json['selling_price']?.toString() ?? '0.0');
    createdAt = json['created_at']?.toString();
    updatedAt = json['updated_at']?.toString();

    // 2. Data from products table (if joined)
    if (json['products'] != null) {
      final p = json['products'];
      name = p['name'];
      flavor = p['flavour'];
      weight = p['weight'];
      rack = p['rack'];
      level = p['level'];
      color = p['color'];
      box = p['box'];
      isLooseCategory = p['is_loose_category'] ?? false;
      isFlavorAndWeightNotRequired =
          p['is_flavor_and_weight_not_required'] ?? false;

      // Category handling - both name and ID
      if (p['categories'] != null) {
        category = p['categories']['name'];
        categoryId = p['categories']['id']?.toString();
      } else if (p['category'] != null) {
        category = p['category'];
      }

      // Animal type handling - both name and ID
      if (p['animals'] != null) {
        animalType = p['animals']['name'];
        animalTypeId = p['animals']['id']?.toString();
      } else if (p['animal_type'] != null) {
        animalType = p['animal_type'];
      }

      // 3. Location from product_stock (if available)
      final stock = p['product_stock'] as List?;
      if (stock != null && stock.isNotEmpty) {
        location = stock[0]['location'];
        isActive = stock[0]['is_active'] ?? true;
        stockType = stock[0]['stock_type'];
      } else {
        // Fallback: check stock_batches for location
        final batches = p['stock_batches'] as List?;
        if (batches != null && batches.isNotEmpty) {
          location = batches[0]['location'] ?? 'shop';
          stockType = batches[0]['stock_type'];
        } else {
          location = 'shop'; // default fallback
          stockType = 'loose'; // default for loose products
        }
      }

      // 4. Dates from stock_batches
      final batches = p['stock_batches'] as List?;
      if (batches != null && batches.isNotEmpty) {
        purchaseDate = batches[0]['purchase_date'];
        expireDate = batches[0]['expiry_date'];
        purchasePrice = double.tryParse(
          batches[0]['purchase_price']?.toString() ?? '0.0',
        );
      }

      // 5. Barcode from product_barcodes (if available)
      final barcodes = p['product_barcodes'] as List?;
      if (barcodes != null && barcodes.isNotEmpty) {
        barcode = barcodes[0]['barcode'];
      }
    } else {
      // Direct field mapping if no join
      name = json['name'];
      category = json['category'];
      animalType = json['animal_type'];
      flavor = json['flavour'];
      weight = json['weight'];
      rack = json['rack'];
      level = json['level'];
      color = json['color'];
      box = json['box'];
      location = json['location'] ?? 'shop';
      barcode = json['barcode'];
      isLooseCategory = json['is_loose_category'] ?? false;
      isActive = json['is_active'] ?? true;
      isFlavorAndWeightNotRequired =
          json['is_flavor_and_weight_not_required'] ?? false;
      stockType = json['stock_type'] ?? 'loose';
      sellType = json['sell_type'];
      discount = int.tryParse(json['discount']?.toString() ?? '0');
      purchaseDate = json['purchase_date'];
      expireDate = json['expiry_date'];
      purchasePrice = double.tryParse(
        json['purchase_price']?.toString() ?? '0.0',
      );
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['product_id'] = productId;
    data['user_id'] = userId;
    data['quantity'] = quantity;
    data['selling_price'] = sellingPrice;
    data['name'] = name;
    data['category'] = categoryId ?? category;
    data['animal_type'] = animalTypeId ?? animalType;
    data['flavour'] = flavor;
    data['weight'] = weight;
    data['rack'] = rack;
    data['level'] = level;
    data['color'] = color;
    data['box'] = box;
    data['location'] = location;
    data['barcode'] = barcode;
    data['is_loose_category'] = isLooseCategory;
    data['is_active'] = isActive;
    data['is_flavor_and_weight_not_required'] = isFlavorAndWeightNotRequired;
    data['stock_type'] = stockType;
    data['sell_type'] = sellType;
    data['discount'] = discount;
    data['purchase_date'] = purchaseDate;
    data['expiry_date'] = expireDate;
    data['purchase_price'] = purchasePrice;
    return data;
  }
}
