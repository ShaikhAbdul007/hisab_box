class ProductReportModel {
  String? productName;
  String? category;
  String? animalCategory;
  String? weight;
  String? flavor;
  String? quantity;

  ProductReportModel({
    this.productName,
    this.category,
    this.animalCategory,
    this.weight,
    this.flavor,
    this.quantity,
  });

  factory ProductReportModel.fromJson(Map<String, dynamic> json) {
    return ProductReportModel(
      productName: json['name'] ?? '',
      category: json['category'] ?? '',
      animalCategory: json['animalType'] ?? '',
      weight: json['weight'] ?? '',
      flavor: json['flavours'] ?? '',
      quantity: json['quantity'] ?? '',
    );
  }
}
