class LooseCategoryModel {
  final String name;
  final String unit;
  final int price;
  final String createdAt;
  final String time;
  final String id;

  LooseCategoryModel({
    required this.name,
    required this.unit,
    required this.price,
    required this.createdAt,
    required this.time,
    required this.id,
  });

  Map<String, dynamic> toJson() {
    return {
      'label': name,
      'unit': unit,
      'price': price,
      'createdAt': createdAt,
      'time': time,
      'id': id,
    };
  }

  factory LooseCategoryModel.fromJson(Map<String, dynamic> json) {
    return LooseCategoryModel(
      id: json['id'] ?? '',
      name: json['name'] ?? "",
      createdAt: json['created_at'] ?? "",
      time: json['time'] ?? "",
      unit: json['unit'] ?? "",
      price: json['price'] ?? "",
    );
  }
}
