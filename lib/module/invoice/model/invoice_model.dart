class InvoiceModel {
  bool? success;
  String? msg;
  InvoiceData? data;

  InvoiceModel({this.success, this.msg, this.data});

  InvoiceModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    msg = json['message'];
    data = json['data'] != null ? InvoiceData.fromJson(json['data']) : null;
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

class InvoiceData {
  String? id;
  String? invoiceNo; // maps from 'billNo'
  String? finalAmount; // maps from orderSummary.finalAmount
  String? totalAmount; // maps from orderSummary.subtotal
  int? roundOff; // kept for backward compat
  String? createdAt; // maps from 'dateTime'
  dynamic customerName;
  dynamic customerMobile;
  String? status;
  // new fields
  String? saleId;
  String? billNo;
  String? dateTime;
  OrderSummaryInvoice? orderSummary;
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
    this.saleId,
    this.billNo,
    this.dateTime,
    this.orderSummary,
    this.items,
    this.payments,
  });

  InvoiceData.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? json['saleId'];
    saleId = json['saleId'];
    billNo = json['billNo'];
    invoiceNo = json['billNo'] ?? json['invoice_no'];
    dateTime = json['dateTime'];
    createdAt = json['dateTime'] ?? json['created_at'];
    customerName = json['customerName'] ?? json['customer_name'];
    customerMobile = json['customerMobile'] ?? json['customer_mobile'];
    status = json['status'];
    if (json['orderSummary'] != null) {
      orderSummary = OrderSummaryInvoice.fromJson(json['orderSummary']);
      finalAmount = orderSummary?.finalAmount ?? json['final_amount'];
      totalAmount = orderSummary?.subtotal ?? json['total_amount'];
    } else {
      finalAmount = json['final_amount'];
      totalAmount = json['total_amount'];
      roundOff = json['round_off'];
    }
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
    data['saleId'] = saleId;
    data['billNo'] = billNo;
    data['invoice_no'] = invoiceNo;
    data['dateTime'] = dateTime;
    data['final_amount'] = finalAmount;
    data['total_amount'] = totalAmount;
    data['round_off'] = roundOff;
    data['created_at'] = createdAt;
    data['customer_name'] = customerName;
    data['customer_mobile'] = customerMobile;
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

class OrderSummaryInvoice {
  String? subtotal;
  String? totalDiscount;
  String? customerSaved;
  String? roundOff;
  String? finalAmount;

  OrderSummaryInvoice({
    this.subtotal,
    this.totalDiscount,
    this.customerSaved,
    this.roundOff,
    this.finalAmount,
  });

  OrderSummaryInvoice.fromJson(Map<String, dynamic> json) {
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

class InvoiceDataItems {
  String? id;
  String? productName;
  int? quantity;
  String? originalPrice;
  String? totalPrice;
  String? stockType;
  String? location;
  // new fields from API
  String? productId;
  int? discountPercent;
  String? discountAmount;
  int? discountGiven;
  String? finalPrice;
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
  String? brand;
  String? colorName;

  InvoiceDataItems({
    this.id,
    this.productName,
    this.quantity,
    this.originalPrice,
    this.totalPrice,
    this.stockType,
    this.location,
    this.productId,
    this.discountPercent,
    this.discountAmount,
    this.discountGiven,
    this.finalPrice,
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
    this.brand,
    this.colorName,
  });

  InvoiceDataItems.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productId = json['productId'];
    productName = json['productName'] ?? json['product_name'];
    quantity = json['quantity'];
    originalPrice = json['originalPrice'] ?? json['original_price'];
    discountPercent = json['discountPercent'];
    discountAmount = json['discountAmount'];
    discountGiven = json['discountGiven'];
    finalPrice = json['finalPrice'];
    totalPrice = json['totalPrice'] ?? json['total_price'];
    stockType = json['stockType'] ?? json['stock_type'];
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
    brand = json['brand'];
    colorName = json['colorName'];
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
    data['brand'] = brand;
    data['colorName'] = colorName;
    return data;
  }
}

class Payments {
  String? id;
  String? paymentMode; // kept for backward compat
  String? mode; // new — maps from 'mode'
  String? amount;
  dynamic referenceNo;

  Payments({
    this.id,
    this.paymentMode,
    this.mode,
    this.amount,
    this.referenceNo,
  });

  Payments.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    mode = json['mode'];
    paymentMode = json['mode'] ?? json['payment_mode'];
    amount = json['amount'];
    referenceNo = json['referenceNo'] ?? json['reference_no'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['mode'] = mode;
    data['payment_mode'] = paymentMode;
    data['amount'] = amount;
    data['referenceNo'] = referenceNo;
    return data;
  }
}
