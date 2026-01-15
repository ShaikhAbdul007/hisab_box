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
  int? box;
  int? perpiece;
  bool? isLoosed;
  String? id;
  String? paymentMethod;
  int? billNo;
  bool? isLooseCategory;
  bool? isFlavorAndWeightNotRequired;
  int? discount;
  String? purchaseDate;
  String? expireDate;
  String? location;

  ProductModel({
    this.barcode,
    this.name,
    this.category,
    this.quantity,
    this.billNo,
    this.paymentMethod,
    this.purchasePrice,
    this.sellingPrice,
    this.createdDate,
    this.updatedDate,
    this.createdTime,
    this.updatedTime,
    this.color,
    this.isLooseCategory,
    this.animalType,
    this.weight,
    this.flavor,
    this.level,
    this.rack,
    this.box,
    this.perpiece,
    this.isLoosed,
    this.id,
    this.isFlavorAndWeightNotRequired,
    this.location,
    this.discount,
    this.expireDate,
    this.purchaseDate,
  });

  ProductModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    barcode = json['barcode'];
    name = json['name'];
    category = json['category'];
    quantity = json['quantity'];
    purchasePrice = json['purchasePrice'];
    sellingPrice = json['sellingPrice'];
    createdDate = json['createdDate'];
    updatedDate = json['updatedDate'];
    createdTime = json['createdTime'];
    updatedTime = json['updatedTime'];
    color = json['color'];
    flavor = json['flavours'];
    weight = json['weight'];
    level = json['level'];
    rack = json['rack'];
    animalType = json['animalType'];
    box = json['box'];
    perpiece = json['perpiece'];
    isLoosed = json['isLoose'];
    billNo = json['billNo'];
    paymentMethod = json['paymentMethod'];
    isLooseCategory = json['isLooseCategory'];
    isFlavorAndWeightNotRequired = json['isFlavorAndWeightNotRequired'];
    purchaseDate = json['purchaseDate'];
    expireDate = json['exprieDate'];
    location = json['location'];
    discount = json['discount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['barcode'] = barcode;
    data['name'] = name;
    data['category'] = category;
    data['quantity'] = quantity;
    data['purchasePrice'] = purchasePrice;
    data['sellingPrice'] = sellingPrice;
    data['createdDate'] = createdDate;
    data['updatedDate'] = updatedDate;
    data['createdTime'] = createdTime;
    data['updatedTime'] = updatedTime;
    data['weight'] = weight;
    data['flavours'] = flavor;
    data['animalType'] = animalType;
    data['color'] = color;
    data['box'] = box;
    data['perpiece'] = perpiece;
    data['isLoose'] = isLoosed;
    data['billNo'] = billNo;
    data['paymentMethod'] = paymentMethod;
    data['isLooseCategory'] = isLooseCategory;
    data['isFlavorAndWeightNotRequired'] = isFlavorAndWeightNotRequired;
    data['purchaseDate'] = purchaseDate;
    data['exprieDate'] = expireDate;
    data['location'] = location;
    data['discount'] = discount;
    data['level'] = level;
    data['rack'] = rack;
    return data;
  }
}
