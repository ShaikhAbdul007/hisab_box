// class PrintInvoiceModel {
//   final int? billNo;
//   final bool? discount;
//   final double? discountValue;
//   final double? finalAmount;
//   final int? itemsCount;
//   final String? soldAt;
//   final String? time;
//   final double? totalAmount;
//   final List<SellItem>? items;
//   final PaymentModel? payment;

//   PrintInvoiceModel({
//     this.billNo,
//     this.discount,
//     this.discountValue,
//     this.finalAmount,
//     this.itemsCount,
//     this.soldAt,
//     this.time,
//     this.totalAmount,
//     this.items,
//     this.payment,
//   });

//   factory PrintInvoiceModel.fromJson(Map<String, dynamic> json) {
//     return PrintInvoiceModel(
//       billNo: json['billNo'],
//       discount: json['discount'],
//       discountValue: (json['discountValue'] ?? 0).toDouble(),
//       finalAmount: (json['finalAmount'] ?? 0).toDouble(),
//       itemsCount: json['itemsCount'],
//       soldAt: json['soldAt'],
//       time: json['time'],
//       totalAmount: (json['totalAmount'] ?? 0).toDouble(),
//       items:
//           (json['items'] as List<dynamic>?)
//               ?.map((e) => SellItem.fromJson(e))
//               .toList() ??
//           [],
//       payment:
//           json['payment'] != null
//               ? PaymentModel.fromJson(json['payment'])
//               : null,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'billNo': billNo,
//       'discount': discount,
//       'discountValue': discountValue,
//       'finalAmount': finalAmount,
//       'itemsCount': itemsCount,
//       'soldAt': soldAt,
//       'time': time,
//       'totalAmount': totalAmount,
//       'items': items?.map((e) => e.toJson()).toList(),
//       'payment': payment?.toJson(),
//     };
//   }
// }

// class SellItem {
//   String? name;
//   int? quantity;
//   double? originalPrice;
//   int? originalDiscount;
//   int? discount;
//   double? finalPrice;
//   String? category;
//   String? barcode;
//   dynamic id;
//   double? purchasePrice;
//   String? weight;
//   String? flavours;
//   String? animalType;
//   String? color;
//   int? box;
//   int? perpiece;
//   bool? isLoose;
//   String? paymentMethod;
//   bool? isLooseCategory;
//   bool? isFlavorAndWeightNotRequired;
//   String? exprieDate;
//   String? location;
//   bool? isActive;
//   String? sellType;
//   String? rack;
//   String? level;
//   SellItem({
//     this.name,
//     this.quantity,
//     this.isActive,
//     this.sellType,
//     this.originalPrice,
//     this.originalDiscount,
//     this.discount,
//     this.finalPrice,
//     this.category,
//     this.barcode,
//     this.id,
//     this.purchasePrice,
//     this.weight,
//     this.flavours,
//     this.animalType,
//     this.color,
//     this.box,
//     this.perpiece,
//     this.isLoose,
//     this.paymentMethod,
//     this.isLooseCategory,
//     this.isFlavorAndWeightNotRequired,
//     this.exprieDate,
//     this.location,
//     this.level,
//     this.rack,
//   });

//   SellItem.fromJson(Map<String, dynamic> json) {
//     name = json['name'] ?? '';
//     level = json['level'] ?? '';
//     rack = json['rack'] ?? '';
//     quantity = json['quantity'] ?? 0;
//     originalPrice = json['originalPrice'] ?? 0.0;
//     originalDiscount = json['originalDiscount'] ?? 0;
//     discount = json['discount'] ?? 0;
//     finalPrice = json['finalPrice'] ?? 0.0;
//     category = json['category'] ?? '';
//     barcode = json['barcode'] ?? '';
//     id = json['id'] ?? '';
//     purchasePrice = json['purchasePrice'] ?? 0.0;
//     weight = json['weight'] ?? '';
//     flavours = json['flavour'] ?? '';
//     animalType = json['animalType'] ?? '';
//     color = json['color'] ?? '';
//     box = json['box'] ?? 0;
//     perpiece = json['perpiece'] ?? 0;
//     isLoose = json['isLoose'] ?? false;
//     paymentMethod = json['paymentMethod'] ?? '';
//     sellType = json['sellType'] ?? '';
//     isActive = json['isActive'] ?? false;
//     isLooseCategory = json['isLooseCategory'] ?? false;
//     isFlavorAndWeightNotRequired =
//         json['isFlavorAndWeightNotRequired'] ?? false;
//     exprieDate = json['exprieDate'] ?? '';
//     location = json['location'] ?? '';
//     sellType = json['sellType'] ?? '';
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['name'] = name;
//     data['level'] = level;
//     data['sellType'] = sellType;
//     data['rack'] = rack;
//     data['quantity'] = quantity;
//     data['originalPrice'] = originalPrice;
//     data['originalDiscount'] = originalDiscount;
//     data['discount'] = discount;
//     data['finalPrice'] = finalPrice;
//     data['category'] = category;
//     data['barcode'] = barcode;
//     data['isActive'] = isActive;
//     data['sellType'] = sellType;
//     data['id'] = id;
//     data['purchasePrice'] = purchasePrice;
//     data['weight'] = weight;
//     data['flavour'] = flavours;
//     data['animalType'] = animalType;
//     data['color'] = color;
//     data['box'] = box;
//     data['perpiece'] = perpiece;
//     data['isLoose'] = isLoose;
//     data['paymentMethod'] = paymentMethod;
//     data['isLooseCategory'] = isLooseCategory;
//     data['isFlavorAndWeightNotRequired'] = isFlavorAndWeightNotRequired;
//     data['exprieDate'] = exprieDate;
//     data['location'] = location;
//     return data;
//   }
// }

// class PaymentModel {
//   final double cash;
//   final double upi;
//   final double card;
//   final double credit;
//   final double totalAmount;
//   final bool isRoundOff;
//   final double roundOffAmount;
//   final String? type;

//   PaymentModel({
//     required this.cash,
//     required this.upi,
//     required this.card,
//     required this.credit,
//     required this.totalAmount,
//     required this.isRoundOff,
//     required this.roundOffAmount,
//     required this.type,
//   });

//   factory PaymentModel.fromJson(Map<String, dynamic> json) {
//     return PaymentModel(
//       cash: (json['cash'] ?? 0).toDouble(),
//       upi: (json['upi'] ?? 0).toDouble(),
//       card: (json['card'] ?? 0).toDouble(),
//       credit: (json['credit'] ?? 0).toDouble(),
//       totalAmount: (json['totalAmount'] ?? 0).toDouble(),
//       isRoundOff: json['isRoundOff'] ?? false,
//       roundOffAmount: (json['roundOffAmount'] ?? 0).toDouble(),
//       type: json['type'],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'cash': cash,
//       'upi': upi,
//       'card': card,
//       'credit': credit,
//       'totalAmount': totalAmount,
//       'isRoundOff': isRoundOff,
//       'roundOffAmount': roundOffAmount,
//       'type': type,
//     };
//   }
// }

// class InvoiceModel {
//   bool? success;
//   String? msg;
//   Data? data;

//   InvoiceModel({this.success, this.msg, this.data});

//   InvoiceModel.fromJson(Map<String, dynamic> json) {
//     success = json['success'];
//     msg = json['message'];
//     data = json['data'] != null ? Data.fromJson(json['data']) : null;
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['success'] = success;
//     data['message'] = msg;
//     if (this.data != null) {
//       data['data'] = this.data!.toJson();
//     }
//     return data;
//   }
// }

// class Data {
//   String? id;
//   String? invoiceNo;
//   String? finalAmount;
//   String? totalAmount;
//   int? roundOff;
//   String? createdAt;
//   dynamic customerName;
//   dynamic customerMobile;
//   String? status;
//   List<Items>? items;
//   List<Payments>? payments;

//   Data({
//     this.id,
//     this.invoiceNo,
//     this.finalAmount,
//     this.totalAmount,
//     this.roundOff,
//     this.createdAt,
//     this.customerName,
//     this.customerMobile,
//     this.status,
//     this.items,
//     this.payments,
//   });

//   Data.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     invoiceNo = json['invoice_no'];
//     finalAmount = json['final_amount'];
//     totalAmount = json['total_amount'];
//     roundOff = json['round_off'];
//     createdAt = json['created_at'];
//     customerName = json['customer_name'];
//     customerMobile = json['customer_mobile'];
//     status = json['status'];
//     if (json['items'] != null) {
//       items = <Items>[];
//       json['items'].forEach((v) {
//         items!.add(Items.fromJson(v));
//       });
//     }
//     if (json['payments'] != null) {
//       payments = <Payments>[];
//       json['payments'].forEach((v) {
//         payments!.add(Payments.fromJson(v));
//       });
//     }
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['id'] = id;
//     data['invoice_no'] = invoiceNo;
//     data['final_amount'] = finalAmount;
//     data['total_amount'] = totalAmount;
//     data['round_off'] = roundOff;
//     data['created_at'] = createdAt;
//     data['customer_name'] = customerName;
//     data['customer_mobile'] = customerMobile;
//     data['status'] = status;
//     if (items != null) {
//       data['items'] = items!.map((v) => v.toJson()).toList();
//     }
//     if (payments != null) {
//       data['payments'] = payments!.map((v) => v.toJson()).toList();
//     }
//     return data;
//   }
// }

// class Items {
//   String? id;
//   String? productName;
//   int? quantity;
//   String? originalPrice;
//   String? totalPrice;
//   String? stockType;
//   String? location;

//   Items({
//     this.id,
//     this.productName,
//     this.quantity,
//     this.originalPrice,
//     this.totalPrice,
//     this.stockType,
//     this.location,
//   });

//   Items.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     productName = json['product_name'];
//     quantity = json['quantity'];
//     originalPrice = json['original_price'];
//     totalPrice = json['total_price'];
//     stockType = json['stock_type'];
//     location = json['location'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['id'] = id;
//     data['product_name'] = productName;
//     data['quantity'] = quantity;
//     data['original_price'] = originalPrice;
//     data['total_price'] = totalPrice;
//     data['stock_type'] = stockType;
//     data['location'] = location;
//     return data;
//   }
// }

// class Payments {
//   String? id;
//   String? paymentMode;
//   String? amount;
//   dynamic referenceNo;

//   Payments({this.id, this.paymentMode, this.amount, this.referenceNo});

//   Payments.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     paymentMode = json['payment_mode'];
//     amount = json['amount'];
//     referenceNo = json['reference_no'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['id'] = id;
//     data['payment_mode'] = paymentMode;
//     data['amount'] = amount;
//     data['reference_no'] = referenceNo;
//     return data;
//   }
// }
