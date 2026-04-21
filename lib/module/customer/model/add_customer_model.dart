class AddCustomerModel {
  bool? success;
  String? msg;
  AddCustomerData? data;

  AddCustomerModel({this.success, this.msg, this.data});

  AddCustomerModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    msg = json['msg'];
    data = json['data'] != null ? AddCustomerData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['msg'] = msg;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class AddCustomerData {
  String? id;
  String? userId;
  String? mobileNo;
  String? name;
  String? address;
  String? description;
  String? createdAt;

  AddCustomerData(
      {this.id,
      this.userId,
      this.mobileNo,
      this.name,
      this.address,
      this.description,
      this.createdAt});

  AddCustomerData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    mobileNo = json['mobile_no'];
    name = json['name'];
    address = json['address'];
    description = json['description'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['mobile_no'] = mobileNo;
    data['name'] = name;
    data['address'] = address;
    data['description'] = description;
    data['created_at'] = createdAt;
    return data;
  }
}
