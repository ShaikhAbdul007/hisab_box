class BankDetailsModel {
  bool? success;
  String? msg;
  BankDetailsData? data;

  BankDetailsModel({this.success, this.msg, this.data});

  BankDetailsModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    msg = json['msg'];
    data = json['data'] != null ?  BankDetailsData.fromJson(json['data']) : null;
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

class BankDetailsData {
  String? id;
  String? userId;
  String? upiId;
  String? bankName;
  String? accountHolder;
  String? createdAt;
  String? updatedAt;

  BankDetailsData(
      {this.id,
      this.userId,
      this.upiId,
      this.bankName,
      this.accountHolder,
      this.createdAt,
      this.updatedAt});

  BankDetailsData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    upiId = json['upi_id'];
    bankName = json['bank_name'];
    accountHolder = json['account_holder'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['upi_id'] = upiId;
    data['bank_name'] = bankName;
    data['account_holder'] = accountHolder;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
