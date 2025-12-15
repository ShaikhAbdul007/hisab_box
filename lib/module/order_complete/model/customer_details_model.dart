class CustomerDetails {
  String? id;
  String? address;
  String? createdAt;
  List<InvoiceModel>? invoices;
  String? mobile;
  String? name;

  CustomerDetails({
    this.address,
    this.createdAt,
    this.invoices,
    this.mobile,
    this.name,
    this.id,
  });

  factory CustomerDetails.fromJson(Map<String, dynamic> json) {
    return CustomerDetails(
      address: json["address"],
      id: json["id"],
      createdAt: json["createdAt"],
      mobile: json["mobile"],
      name: json["name"],
      invoices:
          json["invoices"] != null
              ? (json["invoices"] as List)
                  .map((e) => InvoiceModel.fromJson(e))
                  .toList()
              : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "address": address,
      "id": id,
      "createdAt": createdAt,
      "mobile": mobile,
      "name": name,
      "invoices": invoices?.map((e) => e.toJson()).toList(),
    };
  }
}

class InvoiceModel {
  String? billNo;
  bool? discount;
  num? discountValue;
  num? finalAmount;
  List<InvoiceItem>? items;
  PaymentInfo? payment;
  String? soldAt;
  String? time;
  num? totalAmount;

  InvoiceModel({
    this.billNo,
    this.discount,
    this.discountValue,
    this.finalAmount,
    this.items,
    this.payment,
    this.soldAt,
    this.time,
    this.totalAmount,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      billNo: json["billNo"],
      discount: json["discount"],
      discountValue: json["discountValue"],
      finalAmount: json["finalAmount"],
      soldAt: json["soldAt"],
      time: json["time"],
      totalAmount: json["totalAmount"],
      items:
          json["items"] != null
              ? (json["items"] as List)
                  .map((e) => InvoiceItem.fromJson(e))
                  .toList()
              : [],
      payment:
          json["payment"] != null
              ? PaymentInfo.fromJson(json["payment"])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "billNo": billNo,
      "discount": discount,
      "discountValue": discountValue,
      "finalAmount": finalAmount,
      "soldAt": soldAt,
      "time": time,
      "totalAmount": totalAmount,
      "items": items?.map((e) => e.toJson()).toList(),
      "payment": payment?.toJson(),
    };
  }
}

class InvoiceItem {
  String? animalType;
  String? barcode;
  int? box;
  String? category;
  String? color;
  num? discount;
  String? exprieDate;
  num? finalPrice;
  String? flavours;
  String? id;
  bool? isFlavorAndWeightNotRequired;
  bool? isLoose;
  bool? isLooseCategory;
  String? location;
  String? name;
  num? originalDiscount;
  num? originalPrice;
  String? paymentMethod;
  num? perpiece;
  num? purchasePrice;
  num? quantity;
  String? weight;
  int? itemsCount;

  InvoiceItem({
    this.animalType,
    this.barcode,
    this.box,
    this.category,
    this.color,
    this.discount,
    this.exprieDate,
    this.finalPrice,
    this.flavours,
    this.id,
    this.isFlavorAndWeightNotRequired,
    this.isLoose,
    this.isLooseCategory,
    this.location,
    this.name,
    this.originalDiscount,
    this.originalPrice,
    this.paymentMethod,
    this.perpiece,
    this.purchasePrice,
    this.quantity,
    this.weight,
    this.itemsCount,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      animalType: json["animalType"],
      barcode: json["barcode"],
      box: json["box"],
      category: json["category"],
      color: json["color"],
      discount: json["discount"],
      exprieDate: json["exprieDate"],
      finalPrice: json["finalPrice"],
      flavours: json["flavours"],
      id: json["id"],
      isFlavorAndWeightNotRequired: json["isFlavorAndWeightNotRequired"],
      isLoose: json["isLoose"],
      isLooseCategory: json["isLooseCategory"],
      location: json["location"],
      name: json["name"],
      originalDiscount: json["originalDiscount"],
      originalPrice: json["originalPrice"],
      paymentMethod: json["paymentMethod"],
      perpiece: json["perpiece"],
      purchasePrice: json["purchasePrice"],
      quantity: json["quantity"],
      weight: json["weight"],
      itemsCount: json["itemsCount"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "animalType": animalType,
      "barcode": barcode,
      "box": box,
      "category": category,
      "color": color,
      "discount": discount,
      "exprieDate": exprieDate,
      "finalPrice": finalPrice,
      "flavours": flavours,
      "id": id,
      "isFlavorAndWeightNotRequired": isFlavorAndWeightNotRequired,
      "isLoose": isLoose,
      "isLooseCategory": isLooseCategory,
      "location": location,
      "name": name,
      "originalDiscount": originalDiscount,
      "originalPrice": originalPrice,
      "paymentMethod": paymentMethod,
      "perpiece": perpiece,
      "purchasePrice": purchasePrice,
      "quantity": quantity,
      "weight": weight,
      "itemsCount": itemsCount,
    };
  }
}

class PaymentInfo {
  num? card;
  num? cash;
  num? credit;
  bool? isRoundOff;
  num? roundOffAmount;
  num? totalAmount;
  String? type;
  num? upi;

  PaymentInfo({
    this.card,
    this.cash,
    this.credit,
    this.isRoundOff,
    this.roundOffAmount,
    this.totalAmount,
    this.type,
    this.upi,
  });

  factory PaymentInfo.fromJson(Map<String, dynamic> json) {
    return PaymentInfo(
      card: json["card"],
      cash: json["cash"],
      credit: json["credit"],
      isRoundOff: json["isRoundOff"],
      roundOffAmount: json["roundOffAmount"],
      totalAmount: json["totalAmount"],
      type: json["type"],
      upi: json["upi"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "card": card,
      "cash": cash,
      "credit": credit,
      "isRoundOff": isRoundOff,
      "roundOffAmount": roundOffAmount,
      "totalAmount": totalAmount,
      "type": type,
      "upi": upi,
    };
  }
}
