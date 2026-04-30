class NeaExpiryModel {
  bool? success;
  String? msg;
  NeaExpiryData? data;

  NeaExpiryModel({this.success, this.msg, this.data});

  NeaExpiryModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    msg = json['msg'];
    data = json['data'] != null ? NeaExpiryData.fromJson(json['data']) : null;
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

class NeaExpiryData {
  List<NeaExpiryItemData>? data;
  int? expiryThresholdDays;
  Pagination? pagination;

  NeaExpiryData({this.data, this.expiryThresholdDays, this.pagination});

  NeaExpiryData.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <NeaExpiryItemData>[];
      json['data'].forEach((v) {
        data!.add(NeaExpiryItemData.fromJson(v));
      });
    }
    expiryThresholdDays = json['expiry_threshold_days'];
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
    data['expiry_threshold_days'] = expiryThresholdDays;
    if (pagination != null) {
      data['pagination'] = pagination!.toJson();
    }
    return data;
  }
}

class NeaExpiryItemData {
  String? stockId;
  String? productId;
  String? name;
  String? barcode;
  String? quantity;
  String? sellingPrice;
  String? location;
  String? stockType;
  String? expiryDate;
  String? level;
  String? rack;
  String? weight;
  String? categoryName;
  String? animalCategoryName;
  String? purchaseDate;
  String? flavour;
  String? createdAt;
  bool? isloosed;
  bool? isflavorRequired;

  NeaExpiryItemData({
    this.stockId,
    this.productId,
    this.flavour,
    this.name,
    this.barcode,
    this.quantity,
    this.sellingPrice,
    this.location,
    this.stockType,
    this.expiryDate,
    this.purchaseDate,
    this.createdAt,
    this.isloosed,
    this.isflavorRequired,
    this.level,
    this.rack,
    this.weight,
    this.categoryName,
    this.animalCategoryName,
  });

  NeaExpiryItemData.fromJson(Map<String, dynamic> json) {
    stockId = json['stock_id'];
    productId = json['product_id'];
    name = json['name'];
    barcode = json['barcode'];
    quantity = json['quantity'];
    sellingPrice = json['selling_price'];
    location = json['location'];
    stockType = json['stock_type'];
    expiryDate = json['expiry_date'];
    purchaseDate = json['purchase_date'];
    createdAt = json['created_at'];
    isloosed = json['isloosed'];
    isflavorRequired = json['isflavorRequired'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['stock_id'] = stockId;
    data['product_id'] = productId;
    data['name'] = name;
    data['barcode'] = barcode;
    data['quantity'] = quantity;
    data['selling_price'] = sellingPrice;
    data['location'] = location;
    data['stock_type'] = stockType;
    data['expiry_date'] = expiryDate;
    data['purchase_date'] = purchaseDate;
    data['created_at'] = createdAt;
    data['isloosed'] = isloosed;
    data['isflavorRequired'] = isflavorRequired;
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
