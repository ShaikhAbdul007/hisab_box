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

  LooseInvetoryModel({
    this.barcode,
    this.name,
    this.category,
    this.quantity,
    this.purchasePrice,
    this.sellingPrice,
    this.createdDate,
    this.updatedDate,
    this.createdTime,
    this.updatedTime,
    this.color,
    this.animalType,
    this.weight,
    this.flavor,
    this.box,
    this.perpiece,
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
    animalType = json['animalType'];
    box = json['box'];
    perpiece = json['perpiece'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
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
    return data;
  }
}
