class TransferToShopModel {
  bool? success;
  String? message;
  TransferToShopData? data;

  TransferToShopModel({this.success, this.message, this.data});

  TransferToShopModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data =
        json['data'] != null ? TransferToShopData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class TransferToShopData {
  bool? success;
  int? transferredQuantity;

  TransferToShopData({this.success, this.transferredQuantity});

  TransferToShopData.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    transferredQuantity = json['transferredQuantity'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['transferredQuantity'] = transferredQuantity;
    return data;
  }
}
