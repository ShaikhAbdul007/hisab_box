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

  bool? isLoosed;
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

    this.isLoosed,
    this.id,
    this.isFlavorAndWeightNotRequired,
    this.location,
    this.discount,
    this.expireDate,
    this.purchaseDate,
    this.sellType,
  });

  // 🔥 SUPABASE ROW → MODEL
  ProductModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    barcode = json['barcode'];
    name = json['name'];
    category = json['category'];
    sellType = json['sell_type'];
    location = json['location'];
    quantity = json['quantity'];
    isActive = json['is_active'];

    purchasePrice = (json['purchase_price'] as num?)?.toDouble();
    sellingPrice = (json['selling_price'] as num?)?.toDouble();

    flavor = json['flavour'];
    weight = json['weight'];
    color = json['color'];
    animalType = json['animal_type'];

    isLoosed = json['is_loose'];

    isFlavorAndWeightNotRequired = json['is_flavor_and_weight_not_required'];

    billNo = json['bill_no'];
    paymentMethod = json['payment_method'];
    discount = json['discount'];

    level = json['level'];
    rack = json['rack'];

    purchaseDate = json['purchase_date'];
    expireDate = json['expire_date'];

    createdDate = json['created_date'];
    updatedDate = json['updated_date'];
    createdTime = json['created_time'];
    updatedTime = json['updated_time'];
  }

  // 🔥 MODEL → SUPABASE INSERT / UPDATE
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['id'] = id;
    data['barcode'] = barcode;
    data['name'] = name;
    data['category'] = category;
    data['sell_type'] = sellType;
    data['location'] = location;
    data['quantity'] = quantity;
    data['is_active'] = isActive;

    data['purchase_price'] = purchasePrice;
    data['selling_price'] = sellingPrice;

    data['flavour'] = flavor;
    data['weight'] = weight;
    data['color'] = color;
    data['animal_type'] = animalType;

    data['is_loose'] = isLoosed;
    data['is_flavor_and_weight_not_required'] = isFlavorAndWeightNotRequired;

    data['bill_no'] = billNo;
    data['payment_method'] = paymentMethod;
    data['discount'] = discount;

    data['level'] = level;
    data['rack'] = rack;

    data['purchase_date'] = purchaseDate;
    data['expire_date'] = expireDate;
    return data;
  }
}
