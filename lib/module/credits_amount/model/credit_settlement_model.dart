class CreditSettlementModel {
  bool? success;
  String? message;
  CreditSettlementData? data;

  CreditSettlementModel({this.success, this.message, this.data});

  CreditSettlementModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data =
        json['data'] != null
            ? CreditSettlementData.fromJson(json['data'])
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class CreditSettlementData {
  String? id;
  String? userId;
  String? customerId;
  String? mobileNo;
  String? creditAmount;
  int? paidAmount;
  int? remainingAmount;
  String? dateOfCredit;
  String? billNo;
  String? nameOfCustomer;
  String? status;
  String? createdAt;
  String? updatedAt;

  CreditSettlementData({
    this.id,
    this.userId,
    this.customerId,
    this.mobileNo,
    this.creditAmount,
    this.paidAmount,
    this.remainingAmount,
    this.dateOfCredit,
    this.billNo,
    this.nameOfCustomer,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  CreditSettlementData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    customerId = json['customer_id'];
    mobileNo = json['mobile_no'];
    creditAmount = json['credit_amount'];
    paidAmount = json['paid_amount'];
    remainingAmount = json['remaining_amount'];
    dateOfCredit = json['date_of_credit'];
    billNo = json['bill_no'];
    nameOfCustomer = json['name_of_customer'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['customer_id'] = customerId;
    data['mobile_no'] = mobileNo;
    data['credit_amount'] = creditAmount;
    data['paid_amount'] = paidAmount;
    data['remaining_amount'] = remainingAmount;
    data['date_of_credit'] = dateOfCredit;
    data['bill_no'] = billNo;
    data['name_of_customer'] = nameOfCustomer;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }
}
