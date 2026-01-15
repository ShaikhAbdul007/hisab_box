class LooseInvetoryModel {
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
  String? purchaseDate;
  String? expireDate;
  String? location;
  String? level;
  String? rack;
  int? discount;
  bool? isLoosed;
  bool? isFlavorAndWeightNotRequired;

  LooseInvetoryModel({
    this.barcode,
    this.name,
    this.category,
    this.quantity,
    this.discount,
    this.purchasePrice,
    this.sellingPrice,
    this.createdDate,
    this.updatedDate,
    this.createdTime,
    this.updatedTime,
    this.color,
    this.isLoosed,
    this.animalType,
    this.weight,
    this.flavor,
    this.box,
    this.isFlavorAndWeightNotRequired,

    this.perpiece,
    this.level,
    this.rack,
    this.location,
    this.expireDate,
    this.purchaseDate,
  });

  LooseInvetoryModel.fromJson(Map<String, dynamic> json) {
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
    isLoosed = json['isLoose'];
    animalType = json['animalType'];
    box = json['box'];
    perpiece = json['perpiece'];
    expireDate = json['exprieDate'];
    location = json['location'];
    discount = json['discount'];
    level = json['level'];
    rack = json['rack'];
    purchaseDate = json['purchaseDate'];
    expireDate = json['exprieDate'];
    location = json['location'];
    isFlavorAndWeightNotRequired = json['isFlavorAndWeightNotRequired'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['barcode'] = barcode;
    data['name'] = name;
    data['category'] = category;
    data['isFlavorAndWeightNotRequired'] = isFlavorAndWeightNotRequired;
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
    data['level'] = level;
    data['rack'] = rack;
    data['exprieDate'] = expireDate;
    data['location'] = location;
    data['discount'] = discount;
    data['isLoose'] = isLoosed;
    data['purchaseDate'] = purchaseDate;
    return data;
  }
}
