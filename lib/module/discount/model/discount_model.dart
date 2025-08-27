class DiscountModel {
  final int label;
  final String createdAt;
  final String time;
  final String id;

  DiscountModel({
    required this.label,
    required this.createdAt,
    required this.time,
    required this.id,
  });

  Map<String, dynamic> toJson() {
    return {'label': label, 'createdAt': createdAt, 'time': time, 'id': id};
  }

  factory DiscountModel.fromJson(Map<String, dynamic> json) {
    return DiscountModel(
      id: json['id'] ?? '',
      label: json['label'] ?? "",
      createdAt: json['createdAt'] ?? "",
      time: json['time'] ?? "",
    );
  }
}
