class InventoryModel {
  bool? success;
  String? msg;
  InventoryData? data;

  InventoryModel({this.success, this.msg, this.data});

  InventoryModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    msg = json['msg'];
    data = json['data'] != null ? InventoryData.fromJson(json['data']) : null;
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

class InventoryData {
  List<InventoryItem>? data;
  Pagination? pagination;

  InventoryData({this.data, this.pagination});

  InventoryData.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <InventoryItem>[];
      json['data'].forEach((v) {
        data!.add(InventoryItem.fromJson(v));
      });
    }
    pagination =
        json['pagination'] != null
            ? Pagination.fromJson(json['pagination'])
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    if (pagination != null) {
      data['pagination'] = pagination!.toJson();
    }
    return data;
  }
}

class InventoryItem {
  String? id;
  String? name;
  String? barcodes;
  String? barcode;
  String? packetQuantity;
  String? packetPrice;
  String? quantity;
  String? sellingPrice;
  String? stockType;
  String? location;
  String? categoryName;
  String? animalTypeName;
  bool? isloosed;
  bool? isflavorRequired;
  String? flavour;
  String? level;
  String? rack;
  String? weight;
  int? discount;
  String? purchasePrice;
  String? expireDate;
  String? purchaseDate;
  String? createdAt;
  String? color;
  String? brand;
  String? brandType;

  InventoryItem({
    this.id,
    this.name,
    this.barcodes,
    this.barcode,
    this.packetQuantity,
    this.packetPrice,
    this.quantity,
    this.sellingPrice,
    this.stockType,
    this.createdAt,
    this.location,
    this.categoryName,
    this.animalTypeName,
    this.isloosed,
    this.isflavorRequired,
    this.flavour,
    this.level,
    this.rack,
    this.weight,
    this.discount,
    this.purchasePrice,
    this.expireDate,
    this.purchaseDate,
    this.color,
    this.brand,
  });

  InventoryItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    barcodes = json['barcodes'];
    barcode = json['barcode'];
    packetQuantity = json['packet_quantity'];
    packetPrice = json['packet_price'];
    quantity = json['quantity'];
    sellingPrice = json['selling_price'];
    stockType = json['stock_type'];
    location = json['location'];
    createdAt = json['created_at'];
    categoryName = json['category_name'];
    animalTypeName = json['animal_type_name'];
    isloosed = json['isloosed'];
    isflavorRequired = json['isflavorRequired'];
    flavour = json['flavour'];
    level = json['level'];
    rack = json['rack'];
    weight = json['weight'];
    discount = json['discount'];
    purchasePrice = json['purchase_price'];
    expireDate = json['expiry_date'];
    purchaseDate = json['purchase_date'];
    color = json['color_name'];
    brand = json['brand'];
    brandType = json['brand_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['barcodes'] = barcodes;
    data['barcode'] = barcode;
    data['packet_quantity'] = packetQuantity;
    data['packet_price'] = packetPrice;
    data['quantity'] = quantity;
    data['selling_price'] = sellingPrice;
    data['stock_type'] = stockType;
    data['location'] = location;
    data['category_name'] = categoryName;
    data['animal_type_name'] = animalTypeName;
    data['isloosed'] = isloosed;
    data['isflavorRequired'] = isflavorRequired;
    data['flavour'] = flavour;
    data['level'] = level;
    data['rack'] = rack;
    data['weight'] = weight;
    data['discount'] = discount;
    data['purchase_price'] = purchasePrice;
    data['created_at'] = createdAt;
    data['expiry_date'] = expireDate;
    data['purchase_date'] = purchaseDate;
    data['color_name'] = color;
    data['brand'] = brand;
    data['brand_type'] = brandType;
    return data;
  }
}

class Pagination {
  int? page;
  int? limit;
  int? total;
  int? totalPages;

  Pagination({this.page, this.limit, this.total, this.totalPages});

  Pagination.fromJson(Map<String, dynamic> json) {
    page = json['page'];
    limit = json['limit'];
    total = json['total'];
    totalPages = json['totalPages'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['page'] = page;
    data['limit'] = limit;
    data['total'] = total;
    data['totalPages'] = totalPages;
    return data;
  }
}
