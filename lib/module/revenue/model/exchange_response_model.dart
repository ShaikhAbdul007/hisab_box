class ExchangeResponseModel {
  bool? success;
  String? message;
  ExchangeResponseData? data;

  ExchangeResponseModel({this.success, this.message, this.data});

  ExchangeResponseModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? ExchangeResponseData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = <String, dynamic>{};
    dataMap['success'] = success;
    dataMap['message'] = message;
    if (data != null) {
      dataMap['data'] = data!.toJson();
    }
    return dataMap;
  }
}

class ExchangeResponseData {
  bool? success;
  String? saleId;
  String? invoiceNo;
  String? message;

  ExchangeResponseData({
    this.success,
    this.saleId,
    this.invoiceNo,
    this.message,
  });

  ExchangeResponseData.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    saleId = json['sale_id'];
    invoiceNo = json['invoice_no'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = <String, dynamic>{};
    dataMap['success'] = success;
    dataMap['sale_id'] = saleId;
    dataMap['invoice_no'] = invoiceNo;
    dataMap['message'] = message;
    return dataMap;
  }
}
