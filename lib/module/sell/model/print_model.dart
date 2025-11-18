class PrintModel {
  String? name;
  int? quantity;
  double? originalPrice;
  int? originalDiscount;
  int? discount;
  double? finalPrice;
  String? category;
  String? barcode;
  dynamic id;
  double? purchasePrice;
  String? weight;
  String? flavours;
  String? animalType;
  String? color;
  int? box;
  int? perpiece;
  bool? isLoose;
  String? paymentMethod;
  bool? isLooseCategory;
  bool? isFlavorAndWeightNotRequired;
  String? exprieDate;
  String? location;

  PrintModel({
    this.name,
    this.quantity,
    this.originalPrice,
    this.originalDiscount,
    this.discount,
    this.finalPrice,
    this.category,
    this.barcode,
    this.id,
    this.purchasePrice,
    this.weight,
    this.flavours,
    this.animalType,
    this.color,
    this.box,
    this.perpiece,
    this.isLoose,
    this.paymentMethod,
    this.isLooseCategory,
    this.isFlavorAndWeightNotRequired,
    this.exprieDate,
    this.location,
  });

  PrintModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    quantity = json['quantity'];
    originalPrice = json['originalPrice'];
    originalDiscount = json['originalDiscount'];
    discount = json['discount'];
    finalPrice = json['finalPrice'];
    category = json['category'];
    barcode = json['barcode'];
    id = json['id'];
    purchasePrice = json['purchasePrice'];
    weight = json['weight'];
    flavours = json['flavours'];
    animalType = json['animalType'];
    color = json['color'];
    box = json['box'];
    perpiece = json['perpiece'];
    isLoose = json['isLoose'];
    paymentMethod = json['paymentMethod'];
    isLooseCategory = json['isLooseCategory'];
    isFlavorAndWeightNotRequired = json['isFlavorAndWeightNotRequired'];
    exprieDate = json['exprieDate'];
    location = json['location'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['quantity'] = quantity;
    data['originalPrice'] = originalPrice;
    data['originalDiscount'] = originalDiscount;
    data['discount'] = discount;
    data['finalPrice'] = finalPrice;
    data['category'] = category;
    data['barcode'] = barcode;
    data['id'] = id;
    data['purchasePrice'] = purchasePrice;
    data['weight'] = weight;
    data['flavours'] = flavours;
    data['animalType'] = animalType;
    data['color'] = color;
    data['box'] = box;
    data['perpiece'] = perpiece;
    data['isLoose'] = isLoose;
    data['paymentMethod'] = paymentMethod;
    data['isLooseCategory'] = isLooseCategory;
    data['isFlavorAndWeightNotRequired'] = isFlavorAndWeightNotRequired;
    data['exprieDate'] = exprieDate;
    data['location'] = location;
    return data;
  }
}
