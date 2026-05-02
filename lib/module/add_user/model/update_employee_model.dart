class UpdateEmpolyeeModel {
  bool? success;
  String? msg;
  Data? data;

  UpdateEmpolyeeModel({this.success, this.msg, this.data});

  UpdateEmpolyeeModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    msg = json['msg'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
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

class Data {
  String? employeeId;
  Permissions? permissions;

  Data({this.employeeId, this.permissions});

  Data.fromJson(Map<String, dynamic> json) {
    employeeId = json['employeeId'];
    permissions =
        json['permissions'] != null
            ? Permissions.fromJson(json['permissions'])
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['employeeId'] = employeeId;
    if (permissions != null) {
      data['permissions'] = permissions!.toJson();
    }
    return data;
  }
}

class Permissions {
  bool? pCustomerList;
  bool? pSeeTodaySale;
  bool? pAddProduct;
  bool? pSeeReport;

  Permissions({
    this.pCustomerList,
    this.pSeeTodaySale,
    this.pAddProduct,
    this.pSeeReport,
  });

  Permissions.fromJson(Map<String, dynamic> json) {
    pCustomerList = json['p_customer_list'];
    pSeeTodaySale = json['p_see_today_sale'];
    pAddProduct = json['p_add_product'];
    pSeeReport = json['p_see_report'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['p_customer_list'] = pCustomerList;
    data['p_see_today_sale'] = pSeeTodaySale;
    data['p_add_product'] = pAddProduct;
    data['p_see_report'] = pSeeReport;
    return data;
  }
}
