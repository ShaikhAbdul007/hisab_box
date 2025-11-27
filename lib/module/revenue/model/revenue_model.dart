class SellsModel {
  final String? billNo;
  final bool? discount;
  final double? discountValue;
  final double? finalAmount;
  final int? itemsCount;
  final String? soldAt;
  final String? time;
  final double? totalAmount;
  final List<SellItem>? items;
  final PaymentModel? payment;

  SellsModel({
    this.billNo,
    this.discount,
    this.discountValue,
    this.finalAmount,
    this.itemsCount,
    this.soldAt,
    this.time,
    this.totalAmount,
    this.items,
    this.payment,
  });

  factory SellsModel.fromJson(Map<String, dynamic> json) {
    return SellsModel(
      billNo: json['billNo'],
      discount: json['discount'],
      discountValue: (json['discountValue'] ?? 0).toDouble(),
      finalAmount: (json['finalAmount'] ?? 0).toDouble(),
      itemsCount: json['itemsCount'],
      soldAt: json['soldAt'],
      time: json['time'],
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => SellItem.fromJson(e))
              .toList() ??
          [],
      payment:
          json['payment'] != null
              ? PaymentModel.fromJson(json['payment'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'billNo': billNo,
      'discount': discount,
      'discountValue': discountValue,
      'finalAmount': finalAmount,
      'itemsCount': itemsCount,
      'soldAt': soldAt,
      'time': time,
      'totalAmount': totalAmount,
      'items': items?.map((e) => e.toJson()).toList(),
      'payment': payment?.toJson(),
    };
  }
}

class SellItem {
  String? name;
  int? quantity;
  double? originalPrice;
  int? originalDiscount;
  int? discount;
  double? finalPrice;
  String? category;
  String? barcode;
  dynamic id;
  double? purchasePrice;
  String? weight;
  String? flavours;
  String? animalType;
  String? color;
  int? box;
  int? perpiece;
  bool? isLoose;
  String? paymentMethod;
  bool? isLooseCategory;
  bool? isFlavorAndWeightNotRequired;
  String? exprieDate;
  String? location;

  SellItem({
    this.name,
    this.quantity,
    this.originalPrice,
    this.originalDiscount,
    this.discount,
    this.finalPrice,
    this.category,
    this.barcode,
    this.id,
    this.purchasePrice,
    this.weight,
    this.flavours,
    this.animalType,
    this.color,
    this.box,
    this.perpiece,
    this.isLoose,
    this.paymentMethod,
    this.isLooseCategory,
    this.isFlavorAndWeightNotRequired,
    this.exprieDate,
    this.location,
  });

  SellItem.fromJson(Map<String, dynamic> json) {
    name = json['name'] ?? '';
    quantity = json['quantity'] ?? 0;
    originalPrice = json['originalPrice'] ?? 0.0;
    originalDiscount = json['originalDiscount'] ?? 0;
    discount = json['discount'] ?? 0;
    finalPrice = json['finalPrice'] ?? 0.0;
    category = json['category'] ?? '';
    barcode = json['barcode'] ?? '';
    id = json['id'] ?? '';
    purchasePrice = json['purchasePrice'] ?? 0.0;
    weight = json['weight'] ?? '';
    flavours = json['flavours'] ?? '';
    animalType = json['animalType'] ?? '';
    color = json['color'] ?? '';
    box = json['box'] ?? 0;
    perpiece = json['perpiece'] ?? 0;
    isLoose = json['isLoose'] ?? false;
    paymentMethod = json['paymentMethod'] ?? '';
    isLooseCategory = json['isLooseCategory'] ?? false;
    isFlavorAndWeightNotRequired =
        json['isFlavorAndWeightNotRequired'] ?? false;
    exprieDate = json['exprieDate'] ?? '';
    location = json['location'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['quantity'] = quantity;
    data['originalPrice'] = originalPrice;
    data['originalDiscount'] = originalDiscount;
    data['discount'] = discount;
    data['finalPrice'] = finalPrice;
    data['category'] = category;
    data['barcode'] = barcode;
    data['id'] = id;
    data['purchasePrice'] = purchasePrice;
    data['weight'] = weight;
    data['flavours'] = flavours;
    data['animalType'] = animalType;
    data['color'] = color;
    data['box'] = box;
    data['perpiece'] = perpiece;
    data['isLoose'] = isLoose;
    data['paymentMethod'] = paymentMethod;
    data['isLooseCategory'] = isLooseCategory;
    data['isFlavorAndWeightNotRequired'] = isFlavorAndWeightNotRequired;
    data['exprieDate'] = exprieDate;
    data['location'] = location;
    return data;
  }
}

class PaymentModel {
  final double cash;
  final double upi;
  final double card;
  final double credit;
  final double totalAmount;
  final bool isRoundOff;
  final double roundOffAmount;
  final String? type;

  PaymentModel({
    required this.cash,
    required this.upi,
    required this.card,
    required this.credit,
    required this.totalAmount,
    required this.isRoundOff,
    required this.roundOffAmount,
    required this.type,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      cash: (json['cash'] ?? 0).toDouble(),
      upi: (json['upi'] ?? 0).toDouble(),
      card: (json['card'] ?? 0).toDouble(),
      credit: (json['credit'] ?? 0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      isRoundOff: json['isRoundOff'] ?? false,
      roundOffAmount: (json['roundOffAmount'] ?? 0).toDouble(),
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cash': cash,
      'upi': upi,
      'card': card,
      'credit': credit,
      'totalAmount': totalAmount,
      'isRoundOff': isRoundOff,
      'roundOffAmount': roundOffAmount,
      'type': type,
    };
  }
}
