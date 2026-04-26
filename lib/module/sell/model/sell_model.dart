// class SaleModel {
//   final String barcode;
//   final String name;
//   final int quantity;
//   final String category;
//   final String soldAt;
//   final String time;
//   final String billNo;
//   final double amount;
//   final String weight;
//   final String flavor;
//   final double discountPercentage;
//   final double sellingPrice;
//   final double amountAfterDiscount;
//   final String animalType;
//   double get totalAmount => amountAfterDiscount;
//   SaleModel({
//     this.billNo = '0',
//     required this.sellingPrice,
//     required this.animalType,
//     required this.barcode,
//     required this.name,
//     required this.quantity,
//     required this.category,
//     required this.soldAt,
//     required this.time,
//     required this.amount,
//     required this.weight,
//     required this.flavor,
//     required this.discountPercentage,
//     required this.amountAfterDiscount,
//   });

//   factory SaleModel.fromMap(Map<String, dynamic> data) {
//     return SaleModel(
//       barcode: data['barcode'] ?? '',
//       name: data['name'] ?? '', // 👈 yeh line add karo
//       quantity: data['quantity'] ?? 0,
//       category: data['category'] ?? '',
//       soldAt: data['soldAt'] ?? '',
//       time: data['time'] ?? '',
//       amount: (data['amount'] ?? 0).toDouble(),
//       billNo: data['billNo']?.toString() ?? '0',
//       flavor: data['flavour'] ?? '',
//       weight: data['weight'] ?? '',
//       discountPercentage: (data['discountValue'] ?? 0).toDouble(),
//       amountAfterDiscount: (data['finalAmount'] ?? 0).toDouble(),
//       sellingPrice: (data['finalAmount'] ?? 0).toDouble(),
//       animalType: data['animal_type'] ?? '',
//     );
//   }
//   Map<String, dynamic> toJson() {
//     return {
//       'barcode': barcode,
//       'name': name,
//       'quantity': quantity,
//       'category': category,
//       'soldAt': soldAt,
//       'time': time,
//       'billNo': billNo,
//       'amount': amount,
//       'weight': weight,
//       'flavour': flavor,
//       'discountValue': discountPercentage,
//       'sellingPrice': sellingPrice,
//       'finalAmount': amountAfterDiscount,
//       'animalType': animalType,
//     };
//   }
// }

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
  int? grandTotal;
  int? totalBills;
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
