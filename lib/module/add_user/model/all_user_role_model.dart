class AllUserRoleModel {
  bool? success;
  String? msg;
  List<AllUserRoleData>? data;

  AllUserRoleModel({this.success, this.msg, this.data});

  AllUserRoleModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    msg = json['message'];
    if (json['data'] != null) {
      data = <AllUserRoleData>[];
      json['data'].forEach((v) {
        data!.add(AllUserRoleData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = msg;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AllUserRoleData {
  String? id;
  String? name;
  int? level;
  String? createdAt;
  String? updatedAt;

  AllUserRoleData({
    this.id,
    this.name,
    this.level,
    this.createdAt,
    this.updatedAt,
  });

  AllUserRoleData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    level = json['level'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['level'] = level;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }

  @override
  String toString() {
    return name ?? '';
  }
}
