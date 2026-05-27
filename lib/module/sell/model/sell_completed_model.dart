class SaleCompletedModel {
  bool? success;
  String? msg;
  SaleCompletedData? data;

  SaleCompletedModel({this.success, this.msg, this.data});

  SaleCompletedModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    msg = json['message'];
    data =
        json['data'] != null ? SaleCompletedData.fromJson(json['data']) : null;
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

class SaleCompletedData {
  bool? success;
  String? saleId;
  String? invoiceNo;
  num? totalAmount;
  String? message;

  SaleCompletedData({
    this.success,
    this.saleId,
    this.invoiceNo,
    this.totalAmount,
    this.message,
  });

  SaleCompletedData.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    saleId = json['sale_id'];
    invoiceNo = json['invoice_no'];
    totalAmount = json['total_amount'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['sale_id'] = saleId;
    data['invoice_no'] = invoiceNo;
    data['total_amount'] = totalAmount;
    data['message'] = message;
    return data;
  }
}
