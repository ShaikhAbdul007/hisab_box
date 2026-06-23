class CreateCategoryModel {
  bool? success;
  String? msg;
  CreateCategoryData? data;

  CreateCategoryModel({this.success, this.msg, this.data});

  CreateCategoryModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    msg = json['message'];
    data =
        json['data'] != null ? CreateCategoryData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = msg;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class CreateCategoryData {
  String? id;
  String? userId;
  String? name;
  String? createdAt;
  dynamic time;

  CreateCategoryData({
    this.id,
    this.userId,
    this.name,
    this.createdAt,
    this.time,
  });

  CreateCategoryData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    name = json['name'];
    createdAt = json['created_at'];
    time = json['time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['name'] = name;
    data['created_at'] = createdAt;
    data['time'] = time;
    return data;
  }
}
