class CreditCustomerDetailsModel {
  bool? success;
  String? message;
  CreditCustomerDetailsData? data;

  CreditCustomerDetailsModel({this.success, this.message, this.data});

  CreditCustomerDetailsModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? CreditCustomerDetailsData.fromJson(json['data']) : null;
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

class CreditCustomerDetailsData {
  String? customerId;
  CreditCustomerSummary? summary;
  List<CreditCustomerTransaction>? transactions;

  CreditCustomerDetailsData({this.customerId, this.summary, this.transactions});

  CreditCustomerDetailsData.fromJson(Map<String, dynamic> json) {
    customerId = json['customer_id'];
    summary = json['summary'] != null ? CreditCustomerSummary.fromJson(json['summary']) : null;
    if (json['transactions'] != null) {
      transactions = <CreditCustomerTransaction>[];
      json['transactions'].forEach((v) {
        transactions!.add(CreditCustomerTransaction.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['customer_id'] = customerId;
    if (summary != null) {
      data['summary'] = summary!.toJson();
    }
    if (transactions != null) {
      data['transactions'] = transactions!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CreditCustomerSummary {
  num? totalCredit;
  num? totalPaid;
  num? totalPending;

  CreditCustomerSummary({this.totalCredit, this.totalPaid, this.totalPending});

  CreditCustomerSummary.fromJson(Map<String, dynamic> json) {
    totalCredit = json['total_credit'];
    totalPaid = json['total_paid'];
    totalPending = json['total_pending'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_credit'] = totalCredit;
    data['total_paid'] = totalPaid;
    data['total_pending'] = totalPending;
    return data;
  }
}

class CreditCustomerTransaction {
  String? id;
  String? userId;
  String? customerId;
  String? mobileNo;
  String? creditAmount;
  String? paidAmount;
  String? remainingAmount;
  String? dateOfCredit;
  String? billNo;
  String? nameOfCustomer;
  String? status;
  String? createdAt;
  String? updatedAt;

  CreditCustomerTransaction({
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

  CreditCustomerTransaction.fromJson(Map<String, dynamic> json) {
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
    return data;
  }
}
