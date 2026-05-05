class AddUserRole {
  bool? success;
  String? msg;
  AddUserRoleData? data;

  AddUserRole({this.success, this.msg, this.data});

  AddUserRole.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    msg = json['message'];
    data = json['data'] != null ? AddUserRoleData.fromJson(json['data']) : null;
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

class AddUserRoleData {
  String? id;
  String? name;
  int? level;
  String? createdAt;
  String? updatedAt;

  AddUserRoleData({
    this.id,
    this.name,
    this.level,
    this.updatedAt,
    this.createdAt,
  });

  AddUserRoleData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    level = json['level'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    updatedAt = json['updatedAt'];
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['level'] = level;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['updatedAt'] = updatedAt;
    data['createdAt'] = createdAt;
    return data;
  }
}
