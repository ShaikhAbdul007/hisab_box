class GoDownStockTransferToShopModel {
  final String id;
  final String barcode;
  final String productName;
  final int requestedQty;
  final String status;

  GoDownStockTransferToShopModel({
    required this.id,
    required this.barcode,
    required this.productName,
    required this.requestedQty,
    required this.status,
  });

  factory GoDownStockTransferToShopModel.fromJson(
    Map<String, dynamic> json,
    String id,
  ) {
    return GoDownStockTransferToShopModel(
      id: id,
      barcode: json['barcode'],
      productName: json['productName'],
      requestedQty: json['requestedQty'],
      status: json['status'],
    );
  }
}
