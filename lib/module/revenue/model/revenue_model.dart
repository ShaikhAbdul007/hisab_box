class BillModel {
  final String billNo;
  final bool discount;
  final num discountValue;
  final num finalAmount;
  final List<RevenueModel> items;
  final int itemsCount;
  final String paymentMethod;
  final String soldAt;
  final String time;
  final num totalAmount;

  BillModel({
    required this.billNo,
    required this.discount,
    required this.discountValue,
    required this.finalAmount,
    required this.items,
    required this.itemsCount,
    required this.paymentMethod,
    required this.soldAt,
    required this.time,
    required this.totalAmount,
  });

  factory BillModel.fromJson(Map<String, dynamic> json) {
    return BillModel(
      billNo: json['billNo'] ?? '',
      discount: json['discount'] ?? false,
      discountValue: json['discountValue'] ?? 0,
      finalAmount: json['finalAmount'] ?? 0,
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => RevenueModel.fromJson(e))
              .toList() ??
          [],
      itemsCount: json['itemsCount'] ?? 0,
      paymentMethod: json['paymentMethod'] ?? '',
      soldAt: json['soldAt'] ?? '',
      time: json['time'] ?? '',
      totalAmount: json['totalAmount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'billNo': billNo,
      'discount': discount,
      'discountValue': discountValue,
      'finalAmount': finalAmount,
      'items': items.map((e) => e.toJson()).toList(),
      'itemsCount': itemsCount,
      'paymentMethod': paymentMethod,
      'soldAt': soldAt,
      'time': time,
      'totalAmount': totalAmount,
    };
  }
}

class RevenueModel {
  final String barcode;
  final String name;
  final String category;
  final String animalCategory;
  final String flavour;
  final String weight;
  final String soldAt;
  final String time;
  final String box;
  final bool isLoose;
  final bool isLooseCategory;
  final num sellingPrice;
  final num amount;
  final int quantity;
  final int discountPercentage;

  RevenueModel({
    required this.barcode,
    required this.name,
    required this.category,
    required this.flavour,
    required this.weight,
    required this.box,
    required this.isLoose,
    required this.isLooseCategory,
    required this.sellingPrice,
    required this.amount,
    required this.quantity,
    required this.soldAt,
    required this.time,
    required this.animalCategory,
    required this.discountPercentage,
  });

  factory RevenueModel.fromJson(Map<String, dynamic> json) {
    return RevenueModel(
      barcode: json['barcode'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      flavour: json['flavour'] ?? '',
      weight: json['weight'] ?? '',
      box: json['box'] ?? '',
      isLoose: json['isLoose'] ?? false,
      isLooseCategory: json['isLooseCategory'] ?? false,
      sellingPrice: json['sellingPrice'] ?? 0,
      amount: json['amount'] ?? 0,
      quantity: json['quantity'] ?? 0,
      animalCategory: json['animalCategory'] ?? '',
      discountPercentage: json['discountPercentage'] ?? 0,
      soldAt: json['soldAt'] ?? '',
      time: json['time'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'barcode': barcode,
      'name': name,
      'category': category,
      'flavour': flavour,
      'weight': weight,
      'box': box,
      'isLoose': isLoose,
      'isLooseCategory': isLooseCategory,
      'sellingPrice': sellingPrice,
      'amount': amount,
      'quantity': quantity,
      'soldAt': soldAt,
      'time': time,
      'animalCategory': animalCategory,
      'discountPercentage': discountPercentage,
    };
  }
}
