class AddProductModel {
  bool? success;
  String? msg;
  AddProductData? data;

  AddProductModel({this.success, this.msg, this.data});

  AddProductModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    msg = json['message'];
    data = json['data'] != null ? AddProductData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = msg;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class AddProductData {
  bool? success;
  String? productId;
  String? barcode;
  bool? isExisting;

  AddProductData({this.success, this.productId, this.barcode, this.isExisting});

  AddProductData.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    productId = json['productId'];
    barcode = json['barcode'];
    isExisting = json['isExisting'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['productId'] = productId;
    data['barcode'] = barcode;
    data['isExisting'] = isExisting;
    return data;
  }
}
