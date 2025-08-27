class CategoryModel {
  final String id;
  final String name;
  final String createdAt;
  final String time;

  CategoryModel({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.time,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? '',
      time: json['time'] ?? '',
      name: json['name'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'time': time, 'createdAt': createdAt};
  }
}
