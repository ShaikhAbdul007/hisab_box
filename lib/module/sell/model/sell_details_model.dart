class SellDetailsModel {
  bool? success;
  String? msg;
  SellDetailsData? data;

  SellDetailsModel({this.success, this.msg, this.data});

  SellDetailsModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    msg = json['msg'];
    data = json['data'] != null ? SellDetailsData.fromJson(json['data']) : null;
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

class SellDetailsData {
  String? saleId;
  String? billNo;
  String? customerName;
  String? customerMobile;
  String? dateTime;
  String? paymentType;
  String? totalAmount;
  int? roundOff;
  String? finalTotal;
  List<SellDetailsItems>? items;
  List<SellDetailsPayments>? payments;

  SellDetailsData({
    this.saleId,
    this.billNo,
    this.customerName,
    this.customerMobile,
    this.dateTime,
    this.paymentType,
    this.totalAmount,
    this.roundOff,
    this.finalTotal,
    this.items,
    this.payments,
  });

  SellDetailsData.fromJson(Map<String, dynamic> json) {
    saleId = json['saleId'];
    billNo = json['billNo'];
    customerName = json['customerName'];
    customerMobile = json['customerMobile'];
    dateTime = json['dateTime'];
    paymentType = json['paymentType'];
    totalAmount = json['totalAmount'];
    roundOff = json['roundOff'];
    finalTotal = json['finalTotal'];
    if (json['items'] != null) {
      items = <SellDetailsItems>[];
      json['items'].forEach((v) {
        items!.add(SellDetailsItems.fromJson(v));
      });
    }
    if (json['payments'] != null) {
      payments = <SellDetailsPayments>[];
      json['payments'].forEach((v) {
        payments!.add(SellDetailsPayments.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['saleId'] = saleId;
    data['billNo'] = billNo;
    data['customerName'] = customerName;
    data['customerMobile'] = customerMobile;
    data['dateTime'] = dateTime;
    data['paymentType'] = paymentType;
    data['totalAmount'] = totalAmount;
    data['roundOff'] = roundOff;
    data['finalTotal'] = finalTotal;
    if (items != null) {
      data['items'] = items!.map((v) => v.toJson()).toList();
    }
    if (payments != null) {
      data['payments'] = payments!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SellDetailsItems {
  String? productName;
  int? qty;
  String? rate;
  int? discount;
  String? total;

  SellDetailsItems({
    this.productName,
    this.qty,
    this.rate,
    this.discount,
    this.total,
  });

  SellDetailsItems.fromJson(Map<String, dynamic> json) {
    productName = json['productName'];
    qty = json['qty'];
    rate = json['rate'];
    discount = json['discount'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['productName'] = productName;
    data['qty'] = qty;
    data['rate'] = rate;
    data['discount'] = discount;
    data['total'] = total;
    return data;
  }
}

class SellDetailsPayments {
  String? mode;
  String? amount;

  SellDetailsPayments({this.mode, this.amount});

  SellDetailsPayments.fromJson(Map<String, dynamic> json) {
    mode = json['mode'];
    amount = json['amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['mode'] = mode;
    data['amount'] = amount;
    return data;
  }
}
