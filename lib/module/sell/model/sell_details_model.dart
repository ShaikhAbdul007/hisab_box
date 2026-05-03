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
  String? status;
  OrderSummary? orderSummary;
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
    this.status,
    this.orderSummary,
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
    status = json['status'];
    orderSummary =
        json['orderSummary'] != null
            ? OrderSummary.fromJson(json['orderSummary'])
            : null;
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
    data['status'] = status;
    if (orderSummary != null) {
      data['orderSummary'] = orderSummary!.toJson();
    }
    if (items != null) {
      data['items'] = items!.map((v) => v.toJson()).toList();
    }
    if (payments != null) {
      data['payments'] = payments!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class OrderSummary {
  String? subtotal;
  String? totalDiscount;
  String? customerSaved;
  String? roundOff;
  String? finalAmount;

  OrderSummary({
    this.subtotal,
    this.totalDiscount,
    this.customerSaved,
    this.roundOff,
    this.finalAmount,
  });

  OrderSummary.fromJson(Map<String, dynamic> json) {
    subtotal = json['subtotal'];
    totalDiscount = json['totalDiscount'];
    customerSaved = json['customerSaved'];
    roundOff = json['roundOff'];
    finalAmount = json['finalAmount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['subtotal'] = subtotal;
    data['totalDiscount'] = totalDiscount;
    data['customerSaved'] = customerSaved;
    data['roundOff'] = roundOff;
    data['finalAmount'] = finalAmount;
    return data;
  }
}

class SellDetailsItems {
  String? id;
  String? productId;
  String? productName;
  // backward compat aliases — existing code uses these

  // new fields from API
  int? quantity;
  String? originalPrice;
  int? discountPercent;
  String? discountAmount;
  int? discountGiven;
  String? finalPrice;
  String? totalPrice;
  String? stockType;
  String? location;
  String? barcode;
  String? flavour;
  String? weight;
  String? level;
  String? rack;
  int? productDiscount;
  String? sellingPrice;
  String? purchasePrice;
  String? categoryName;
  String? animalTypeName;

  SellDetailsItems({
    this.id,
    this.productId,
    this.productName,

    this.quantity,
    this.originalPrice,
    this.discountPercent,
    this.discountAmount,
    this.discountGiven,
    this.finalPrice,
    this.totalPrice,
    this.stockType,
    this.location,
    this.barcode,
    this.flavour,
    this.weight,
    this.level,
    this.rack,
    this.productDiscount,
    this.sellingPrice,
    this.purchasePrice,
    this.categoryName,
    this.animalTypeName,
  });

  SellDetailsItems.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productId = json['productId'];
    productName = json['productName'];
    quantity = json['quantity'];
    originalPrice = json['originalPrice'];
    discountPercent = json['discountPercent'];
    discountAmount = json['discountAmount'];
    discountGiven = json['discountGiven'];
    finalPrice = json['finalPrice'];
    totalPrice = json['totalPrice'];
    stockType = json['stockType'];
    location = json['location'];
    barcode = json['barcode'];
    flavour = json['flavour'];
    weight = json['weight'];
    level = json['level'];
    rack = json['rack'];
    productDiscount = json['productDiscount'];
    sellingPrice = json['sellingPrice'];
    purchasePrice = json['purchasePrice'];
    categoryName = json['categoryName'];
    animalTypeName = json['animalTypeName'];
    // backward compat
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['productId'] = productId;
    data['productName'] = productName;
    data['quantity'] = quantity;
    data['originalPrice'] = originalPrice;
    data['discountPercent'] = discountPercent;
    data['discountAmount'] = discountAmount;
    data['discountGiven'] = discountGiven;
    data['finalPrice'] = finalPrice;
    data['totalPrice'] = totalPrice;
    data['stockType'] = stockType;
    data['location'] = location;
    data['barcode'] = barcode;
    data['flavour'] = flavour;
    data['weight'] = weight;
    data['level'] = level;
    data['rack'] = rack;
    data['productDiscount'] = productDiscount;
    data['sellingPrice'] = sellingPrice;
    data['purchasePrice'] = purchasePrice;
    data['categoryName'] = categoryName;
    data['animalTypeName'] = animalTypeName;
    return data;
  }
}

class SellDetailsPayments {
  String? id;
  String? mode;
  String? amount;
  String? referenceNo;

  SellDetailsPayments({this.id, this.mode, this.amount, this.referenceNo});

  SellDetailsPayments.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    mode = json['mode'];
    amount = json['amount'];
    referenceNo = json['referenceNo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['mode'] = mode;
    data['amount'] = amount;
    data['referenceNo'] = referenceNo;
    return data;
  }
}
