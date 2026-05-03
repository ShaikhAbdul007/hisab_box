class SellModel {
  bool? success;
  String? msg;
  SellData? data;

  SellModel({this.success, this.msg, this.data});

  SellModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    msg = json['msg'];
    data = json['data'] != null ? SellData.fromJson(json['data']) : null;
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

class SellData {
  num? grandTotal;
  num? totalBills;
  List<SellItemData>? data;

  SellData({this.grandTotal, this.totalBills, this.data});

  SellData.fromJson(Map<String, dynamic> json) {
    grandTotal = json['grandTotal'];
    totalBills = json['totalBills'];
    if (json['data'] != null) {
      data = <SellItemData>[];
      json['data'].forEach((v) {
        data!.add(SellItemData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['grandTotal'] = grandTotal;
    data['totalBills'] = totalBills;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SellItemData {
  String? saleId;
  String? billNo;
  String? customerName;
  String? amount;
  String? paymentType;
  String? paymentMode;
  String? date;
  String? quantity;
  String? name;
  String? weight;
  String? category;
  String? animalType;
  String? flavor;
  String? barcode;
  String? finalPrice;
  String? discount;

  SellItemData({
    this.saleId,
    this.billNo,
    this.customerName,
    this.amount,
    this.paymentType,
    this.paymentMode,
    this.date,
  });

  SellItemData.fromJson(Map<String, dynamic> json) {
    saleId = json['saleId'];
    billNo = json['billNo'];
    customerName = json['customerName'];
    amount = json['amount'];
    paymentType = json['paymentType'];
    paymentMode = json['paymentMode'];
    date = json['date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['saleId'] = saleId;
    data['billNo'] = billNo;
    data['customerName'] = customerName;
    data['amount'] = amount;
    data['paymentType'] = paymentType;
    data['paymentMode'] = paymentMode;
    data['date'] = date;
    return data;
  }
}
