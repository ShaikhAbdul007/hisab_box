class CategoryModel {
  final String? id;
  final String? name;
  final String? createdAt;
  final String? time;

  CategoryModel({this.id, this.name, this.createdAt, this.time});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? '',
      time: json['time'] ?? '',
      name: json['name'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'time': time, 'created_at': createdAt};
  }

  @override
  String toString() => name ?? '';
}
