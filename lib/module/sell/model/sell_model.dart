class SaleModel {
  final String barcode;
  final String name;
  final int quantity;
  final String category;
  final String soldAt;
  final String time;
  final double amount;
  final String weight;
  final String flavor;
  final double discountPercentage;
  final double amountAfterDiscount;

  SaleModel({
    required this.barcode,
    required this.name,
    required this.quantity,
    required this.category,
    required this.soldAt,
    required this.time,
    required this.amount,
    required this.weight,
    required this.flavor,
    required this.discountPercentage,
    required this.amountAfterDiscount,
  });

  factory SaleModel.fromMap(Map<String, dynamic> data) {
    return SaleModel(
      barcode: data['barcode'] ?? '',
      name: data['name'] ?? '', // 👈 yeh line add karo
      quantity: data['quantity'] ?? 0,
      category: data['category'] ?? '',
      soldAt: data['soldAt'] ?? '',
      time: data['time'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      flavor: data['flavor'] ?? '',
      weight: data['weight'] ?? '',
      discountPercentage: (data['discountValue'] ?? 0).toDouble(),
      amountAfterDiscount: (data['finalAmount'] ?? 0).toDouble(),
    );
  }
}
