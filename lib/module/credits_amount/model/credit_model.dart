class CreditModel {
  bool? success;
  String? message;
  CreditData? data;

  CreditModel({this.success, this.message, this.data});

  CreditModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? CreditData.fromJson(json['data']) : null;
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

class CreditData {
  List<CreditDataItem>? data;
  Summary? summary;
  Pagination? pagination;

  CreditData({this.data, this.summary, this.pagination});

  CreditData.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <CreditDataItem>[];
      json['data'].forEach((v) {
        data!.add(CreditDataItem.fromJson(v));
      });
    }
    summary =
        json['summary'] != null ? Summary.fromJson(json['summary']) : null;
    pagination =
        json['pagination'] != null
            ? Pagination.fromJson(json['pagination'])
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    if (summary != null) {
      data['summary'] = summary!.toJson();
    }
    if (pagination != null) {
      data['pagination'] = pagination!.toJson();
    }
    return data;
  }
}

class CreditDataItem {
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
  Customer? customer;

  CreditDataItem({
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

    this.customer,
  });

  CreditDataItem.fromJson(Map<String, dynamic> json) {
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

    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    customer =
        json['customer'] != null ? Customer.fromJson(json['customer']) : null;
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

    if (customer != null) {
      data['customer'] = customer!.toJson();
    }
    return data;
  }
}

class Customer {
  String? name;
  String? mobileNo;
  String? address;

  Customer({this.name, this.mobileNo, this.address});

  Customer.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    mobileNo = json['mobile_no'];
    address = json['address'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['mobile_no'] = mobileNo;
    data['address'] = address;
    return data;
  }
}

class Summary {
  int? totalPendingAmount;

  Summary({this.totalPendingAmount});

  Summary.fromJson(Map<String, dynamic> json) {
    totalPendingAmount = json['total_pending_amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_pending_amount'] = totalPendingAmount;
    return data;
  }
}

class Pagination {
  int? page;
  int? limit;
  int? total;
  int? totalPages;

  Pagination({this.page, this.limit, this.total, this.totalPages});

  Pagination.fromJson(Map<String, dynamic> json) {
    page = json['page'];
    limit = json['limit'];
    total = json['total'];
    totalPages = json['totalPages'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['page'] = page;
    data['limit'] = limit;
    data['total'] = total;
    data['totalPages'] = totalPages;
    return data;
  }
}
