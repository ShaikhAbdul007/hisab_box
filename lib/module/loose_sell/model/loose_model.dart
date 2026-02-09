class LooseInvetoryModel {
  String? id;
  String? productId;
  String? userId;
  String? name;
  String? category;
  String? animalType;
  int? quantity;
  double? sellingPrice;
  double? purchasePrice;
  String? weight;
  String? flavor;
  String? rack;
  String? level;
  String? expireDate;
  String? purchaseDate;
  String? location;
  String? barcode;
  bool? isLooseCategory;
  bool? isActive;
  bool? isFlavorAndWeightNotRequired;
  String? color;
  String? box;
  String? stockType;
  String? sellType;

  String? categoryId;
  String? animalTypeId;
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
    // 1. Direct from loose_stocks table
    id = json['id']?.toString();
    productId = json['product_id']?.toString();
    userId = json['user_id']?.toString();
    quantity = int.tryParse(json['quantity']?.toString() ?? '0');
    sellingPrice = double.tryParse(json['selling_price']?.toString() ?? '0.0');
    createdAt = json['created_at']?.toString();
    updatedAt = json['updated_at']?.toString();

    // 2. Data from joined products table
    if (json['products'] != null) {
      final p = json['products'];
      name = p['name']?.toString();
      flavor = p['flavour']?.toString(); // Variable 'flavor' -> DB 'flavour'
      weight = p['weight']?.toString();
      rack = p['rack']?.toString();
      level = p['level']?.toString();
      color = p['color']?.toString();
      box = p['box']?.toString();
      isLooseCategory = p['is_loose_category'] ?? false;
      isFlavorAndWeightNotRequired =
          p['is_flavor_and_weight_not_required'] ?? false;

      // Category handling (Relation check)
      if (p['categories'] != null) {
        category = p['categories']['name']?.toString();
        categoryId = p['categories']['id']?.toString();
      } else {
        categoryId = p['category']?.toString();
      }

      // Animal type handling (Relation check)
      if (p['animal_categories'] != null) {
        // Matching your table list
        animalType = p['animal_categories']['name']?.toString();
        animalTypeId = p['animal_categories']['id']?.toString();
      } else {
        animalTypeId = p['animal_type']?.toString();
      }

      // 3. Location & Active Status from product_stock
      final stock = p['product_stock'] as List?;
      if (stock != null && stock.isNotEmpty) {
        location = stock[0]['location']?.toString();
        isActive = stock[0]['is_active'] ?? true;
        stockType = stock[0]['stock_type']?.toString();
      }

      // 4. Dates from stock_batches
      final batches = p['stock_batches'] as List?;
      if (batches != null && batches.isNotEmpty) {
        purchaseDate = batches[0]['purchase_date']?.toString();
        expireDate = batches[0]['expiry_date']?.toString();
        purchasePrice = double.tryParse(
          batches[0]['purchase_price']?.toString() ?? '0.0',
        );
      }

      // 5. Barcode from product_barcodes
      final barcodes = p['product_barcodes'] as List?;
      if (barcodes != null && barcodes.isNotEmpty) {
        barcode = barcodes[0]['barcode']?.toString();
      }
    } else {
      // Fallback for direct field mapping
      name = json['name']?.toString();
      flavor = json['flavour']?.toString();
      weight = json['weight']?.toString();
      rack = json['rack']?.toString();
      level = json['level']?.toString();
      isLooseCategory = json['is_loose_category'] ?? false;
      isActive = json['is_active'] ?? true;
      location = json['location']?.toString() ?? 'shop';
      stockType = json['stock_type']?.toString() ?? 'loose';
      discount = int.tryParse(json['discount']?.toString() ?? '0');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'user_id': userId,
      'quantity': quantity,
      'selling_price': sellingPrice,
      'name': name,
      'category': categoryId ?? category, // Maps to 'category' column
      'animal_type': animalTypeId ?? animalType, // Maps to 'animal_type' column
      'flavour': flavor, // Maps to 'flavour' column
      'weight': weight,
      'rack': rack,
      'level': level,
      'color': color,
      'box': box,
      'location': location,
      'is_loose_category': isLooseCategory,
      'is_active': isActive,
      'is_flavor_and_weight_not_required': isFlavorAndWeightNotRequired,
      'stock_type': stockType,
      'sell_type': sellType,
      'discount':
          discount
              ?.toString(), // Database columns shows 'discount' in product_stock
      'purchase_date': purchaseDate,
      'expiry_date': expireDate,
      'purchase_price': purchasePrice,
    };
  }
}
