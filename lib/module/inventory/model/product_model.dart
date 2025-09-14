class ProductModel {
  String? barcode;
  String? name;
  String? category;
  int? quantity;
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
  int? box;
  int? perpiece;
  bool? isLoosed;
  String? id;
  String? paymentMethod;
  int? billNo;
  bool? isLooseCategory;
  bool? isFlavorAndWeightNotRequired;

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
    this.box,
    this.perpiece,
    this.isLoosed,
    this.id,
    this.isFlavorAndWeightNotRequired,
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
    animalType = json['animalType'];
    box = json['box'];
    perpiece = json['perpiece'];
    isLoosed = json['isLoose'];
    billNo = json['billNo'];
    paymentMethod = json['paymentMethod'];
    isLooseCategory = json['isLooseCategory'];
    isFlavorAndWeightNotRequired = json['isFlavorAndWeightNotRequired'];
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
    return data;
  }
}
