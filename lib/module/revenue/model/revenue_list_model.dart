class RevenueListModel {
  bool? success;
  String? msg;
  RevenueListData? data;

  RevenueListModel({this.success, this.msg, this.data});

  RevenueListModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    msg = json['message'];
    data = json['data'] != null ? RevenueListData.fromJson(json['data']) : null;
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

class RevenueListData {
  int? grandTotal;
  int? totalBills;
  List<RevenueListItemData>? data;
  Pagination? pagination;

  RevenueListData({
    this.grandTotal,
    this.totalBills,
    this.data,
    this.pagination,
  });

  RevenueListData.fromJson(Map<String, dynamic> json) {
    grandTotal = json['grandTotal'];
    totalBills = json['totalBills'];

    if (json['data'] != null) {
      data = <RevenueListItemData>[];
      json['data'].forEach((v) {
        data!.add(RevenueListItemData.fromJson(v));
      });
    }

    pagination =
        json['pagination'] != null
            ? Pagination.fromJson(json['pagination'])
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = <String, dynamic>{};

    dataMap['grandTotal'] = grandTotal;
    dataMap['totalBills'] = totalBills;

    if (data != null) {
      dataMap['data'] = data!.map((v) => v.toJson()).toList();
    }

    if (pagination != null) {
      dataMap['pagination'] = pagination!.toJson();
    }

    return dataMap;
  }
}

class RevenueListItemData {
  String? saleId;
  String? billNo;
  String? customerName;
  String? customerMobile;
  String? amount;
  String? totalAmount;
  String? roundOff;
  String? paymentType;
  List<String>? paymentMode;
  String? date;
  String? status;

  RevenueListItemData({
    this.saleId,
    this.billNo,
    this.customerName,
    this.customerMobile,
    this.amount,
    this.totalAmount,
    this.roundOff,
    this.paymentType,
    this.paymentMode,
    this.date,
    this.status,
  });

  RevenueListItemData.fromJson(Map<String, dynamic> json) {
    saleId = json['saleId'];
    billNo = json['billNo'];
    customerName = json['customerName'];
    customerMobile = json['customerMobile'];
    amount = json['amount'];
    totalAmount = json['totalAmount'];
    roundOff = json['roundOff'];
    paymentType = json['paymentType'];
    if (json['paymentMode'] is List) {
      paymentMode = List<String>.from(json['paymentMode']);
    } else if (json['paymentMode'] is String) {
      paymentMode = [json['paymentMode'] as String];
    } else {
      paymentMode = [];
    }
    date = json['date'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['saleId'] = saleId;
    data['billNo'] = billNo;
    data['customerName'] = customerName;
    data['customerMobile'] = customerMobile;
    data['amount'] = amount;
    data['totalAmount'] = totalAmount;
    data['roundOff'] = roundOff;
    data['paymentType'] = paymentType;
    data['paymentMode'] = paymentMode;
    data['date'] = date;
    data['status'] = status;

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
