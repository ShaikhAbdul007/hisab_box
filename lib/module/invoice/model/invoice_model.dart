class InvoiceModel {
  bool? success;
  String? msg;
  InvoiceData? data;

  InvoiceModel({this.success, this.msg, this.data});

  InvoiceModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    msg = json['msg'];
    data = json['data'] != null ? InvoiceData.fromJson(json['data']) : null;
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

class InvoiceData {
  String? id;
  String? invoiceNo;
  String? finalAmount;
  String? totalAmount;
  int? roundOff;
  String? createdAt;
  dynamic customerName;
  dynamic customerMobile;
  String? status;
  List<InvoiceDataItems>? items;
  List<Payments>? payments;

  InvoiceData({
    this.id,
    this.invoiceNo,
    this.finalAmount,
    this.totalAmount,
    this.roundOff,
    this.createdAt,
    this.customerName,
    this.customerMobile,
    this.status,
    this.items,
    this.payments,
  });

  InvoiceData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    invoiceNo = json['invoice_no'];
    finalAmount = json['final_amount'];
    totalAmount = json['total_amount'];
    roundOff = json['round_off'];
    createdAt = json['created_at'];
    customerName = json['customer_name'];
    customerMobile = json['customer_mobile'];
    status = json['status'];
    if (json['items'] != null) {
      items = <InvoiceDataItems>[];
      json['items'].forEach((v) {
        items!.add(InvoiceDataItems.fromJson(v));
      });
    }
    if (json['payments'] != null) {
      payments = <Payments>[];
      json['payments'].forEach((v) {
        payments!.add(Payments.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['invoice_no'] = invoiceNo;
    data['final_amount'] = finalAmount;
    data['total_amount'] = totalAmount;
    data['round_off'] = roundOff;
    data['created_at'] = createdAt;
    data['customer_name'] = customerName;
    data['customer_mobile'] = customerMobile;
    data['status'] = status;
    if (items != null) {
      data['items'] = items!.map((v) => v.toJson()).toList();
    }
    if (payments != null) {
      data['payments'] = payments!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class InvoiceDataItems {
  String? id;
  String? productName;
  int? quantity;
  String? originalPrice;
  String? totalPrice;
  String? stockType;
  String? location;

  InvoiceDataItems({
    this.id,
    this.productName,
    this.quantity,
    this.originalPrice,
    this.totalPrice,
    this.stockType,
    this.location,
  });

  InvoiceDataItems.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productName = json['product_name'];
    quantity = json['quantity'];
    originalPrice = json['original_price'];
    totalPrice = json['total_price'];
    stockType = json['stock_type'];
    location = json['location'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['product_name'] = productName;
    data['quantity'] = quantity;
    data['original_price'] = originalPrice;
    data['total_price'] = totalPrice;
    data['stock_type'] = stockType;
    data['location'] = location;
    return data;
  }
}

class Payments {
  String? id;
  String? paymentMode;
  String? amount;
  dynamic referenceNo;

  Payments({this.id, this.paymentMode, this.amount, this.referenceNo});

  Payments.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    paymentMode = json['payment_mode'];
    amount = json['amount'];
    referenceNo = json['reference_no'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['payment_mode'] = paymentMode;
    data['amount'] = amount;
    data['reference_no'] = referenceNo;
    return data;
  }
}
