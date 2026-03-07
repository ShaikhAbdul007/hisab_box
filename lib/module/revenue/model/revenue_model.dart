Map<String, dynamic> _asStringMap(dynamic data) {
  if (data is Map<String, dynamic>) return data;
  if (data is Map) return Map<String, dynamic>.from(data);
  return <String, dynamic>{};
}

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '0') ?? 0.0;
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '0') ?? 0;
}

class SellsModel {
  final int? billNo;
  final bool? isDiscountGiven;
  final double? discountValue;
  final double? finalAmount;
  final int? itemsCount;
  final String? soldAt;
  final String? time;
  final double? totalAmount;
  final List<SellItem>? items;
  final PaymentModel? payment;
  final String? customerName; // 🔥 Ye add kiya
  final String? customerMobile;

  SellsModel({
    this.billNo,
    this.isDiscountGiven,
    this.discountValue,
    this.finalAmount,
    this.customerName, // 🔥
    this.customerMobile,
    this.itemsCount,
    this.soldAt,
    this.time,
    this.totalAmount,
    this.items,
    this.payment,
  });

  factory SellsModel.fromJson(Map<String, dynamic> json) {
    final createdAtRaw = json['created_at']?.toString() ?? '';
    final DateTime? createdAt = DateTime.tryParse(createdAtRaw);

    final itemsRaw = (json['items'] ?? json['sale_items']) as List?;
    final parsedItems =
        itemsRaw?.map((e) => SellItem.fromJson(_asStringMap(e))).toList() ??
        <SellItem>[];

    final paymentRaw = json['payment'];
    final salePayments = (json['sale_payments'] as List?);
    final paymentMap =
        paymentRaw != null
            ? _asStringMap(paymentRaw)
            : (salePayments != null && salePayments.isNotEmpty)
            ? {
              'cash': _toDouble(salePayments.first['cash_amount']),
              'upi': _toDouble(salePayments.first['upi_amount']),
              'card': _toDouble(salePayments.first['card_amount']),
              'credit': _toDouble(salePayments.first['credit_amount']),
              'totalAmount': _toDouble(json['total_amount']),
              'roundOffAmount': _toDouble(
                salePayments.first['round_off_amount'],
              ),
              'isRoundOff':
                  _toDouble(salePayments.first['round_off_amount']) != 0,
              'type':
                  salePayments.first['payment_mode']?.toString().toUpperCase(),
            }
            : null;

    final customers = _asStringMap(json['customers']);

    return SellsModel(
      billNo: _toInt(json['billNo'] ?? json['bill_no']),
      isDiscountGiven: json['discount'],
      discountValue: _toDouble(json['discountValue']),
      finalAmount: _toDouble(
        json['finalAmount'] ?? json['totalAmount'] ?? json['total_amount'],
      ),
      itemsCount: _toInt(json['itemsCount'] ?? parsedItems.length),
      soldAt:
          json['soldAt']?.toString() ??
          (createdAt != null
              ? '${createdAt.year.toString().padLeft(4, '0')}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}'
              : ''),
      time:
          json['time']?.toString() ??
          (createdAt != null
              ? '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}:${createdAt.second.toString().padLeft(2, '0')}'
              : ''),
      customerName:
          json['customerName']?.toString() ??
          customers['name']?.toString() ??
          '',
      customerMobile:
          json['customerMobile']?.toString() ??
          customers['mobile_number']?.toString() ??
          '',
      totalAmount: _toDouble(json['totalAmount'] ?? json['total_amount']),
      items: parsedItems,
      payment: paymentMap != null ? PaymentModel.fromJson(paymentMap) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'billNo': billNo,
      'discount': isDiscountGiven,
      'discountValue': discountValue,
      'finalAmount': finalAmount,
      'itemsCount': itemsCount,
      'customerName': customerName, // 🔥
      'customerMobile': customerMobile,
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
  bool? isActive;
  String? sellType;

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
    this.isActive,
    this.sellType,
    this.paymentMethod,
    this.isLooseCategory,
    this.isFlavorAndWeightNotRequired,
    this.exprieDate,
    this.location,
  });

  SellItem.fromJson(Map<String, dynamic> json) {
    final products = _asStringMap(json['products']);
    final productBarcodes = (products['product_barcodes'] as List?);
    final categoriesMap = _asStringMap(products['categories']);
    final animalCategoriesMap = _asStringMap(products['animal_categories']);

    name = json['name']?.toString() ?? products['name']?.toString() ?? '';
    quantity = _toInt(json['quantity'] ?? json['qty']);
    originalPrice = _toDouble(json['originalPrice'] ?? json['original_price']);
    originalDiscount = _toInt(json['originalDiscount']);
    discount =
        _toInt(
          json['discount'] ??
              json['applied_discount_percent'] ??
              json['default_discount_percent'],
        );
    finalPrice = _toDouble(json['finalPrice'] ?? json['final_price']);
    category =
        json['category']?.toString() ??
        categoriesMap['name']?.toString() ??
        '';
    barcode =
        json['barcode']?.toString() ??
        ((productBarcodes != null && productBarcodes.isNotEmpty)
            ? productBarcodes.first['barcode']?.toString()
            : '') ??
        '';
    id = json['id'] ?? json['product_id'] ?? '';
    sellType =
        json['sellType']?.toString() ?? json['stock_type']?.toString() ?? '';
    isActive = json['isActive'] ?? false;
    purchasePrice = _toDouble(json['purchasePrice']);
    weight = json['weight']?.toString() ?? products['weight']?.toString() ?? '';
    flavours =
        json['flavour']?.toString() ??
        json['flavours']?.toString() ??
        products['flavour']?.toString() ??
        '';
    animalType =
        json['animal_type']?.toString() ??
        json['animalType']?.toString() ??
        animalCategoriesMap['name']?.toString() ??
        '';
    color = json['color']?.toString() ?? '';
    box = _toInt(json['box']);
    perpiece = _toInt(json['perpiece']);
    isLoose = json['isLoose'] ?? (json['stock_type']?.toString() == 'loose');
    paymentMethod = json['paymentMethod']?.toString() ?? '';
    isLooseCategory = json['isLooseCategory'] ?? false;
    isFlavorAndWeightNotRequired =
        json['isFlavorAndWeightNotRequired'] ?? false;
    exprieDate = json['expiry_date']?.toString() ?? '';
    location = json['location']?.toString() ?? '';
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
    data['flavour'] = flavours;
    data['animal_type'] = animalType;
    data['color'] = color;
    data['box'] = box;
    data['isActive'] = isActive;
    data['sellType'] = sellType;
    data['perpiece'] = perpiece;
    data['isLoose'] = isLoose;
    data['paymentMethod'] = paymentMethod;
    data['isLooseCategory'] = isLooseCategory;
    data['isFlavorAndWeightNotRequired'] = isFlavorAndWeightNotRequired;
    data['expiry_date'] = exprieDate;
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
  final bool? isRoundOff;
  final double roundOffAmount;
  final String? type;

  PaymentModel({
    required this.cash,
    required this.upi,
    required this.card,
    required this.credit,
    required this.totalAmount,
    this.isRoundOff,
    required this.roundOffAmount,
    required this.type,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      cash: _toDouble(json['cash']),
      upi: _toDouble(json['upi']),
      card: _toDouble(json['card']),
      credit: _toDouble(json['credit']),
      totalAmount: _toDouble(json['totalAmount']),
      isRoundOff: json['isRoundOff'] ?? false,
      roundOffAmount: _toDouble(json['roundOffAmount']),
      type: json['type']?.toString(),
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
