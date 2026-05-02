class ReportTopProductModel {
  bool? success;
  String? msg;
  List<ReportTopProductData>? data;

  ReportTopProductModel({this.success, this.msg, this.data});

  ReportTopProductModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    msg = json['msg'];
    if (json['data'] != null) {
      data = <ReportTopProductData>[];
      json['data'].forEach((v) {
        data!.add(ReportTopProductData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['msg'] = msg;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ReportTopProductData {
  String? productName;
  int? qty;

  ReportTopProductData({this.productName, this.qty});

  ReportTopProductData.fromJson(Map<String, dynamic> json) {
    productName = json['productName'];
    qty = json['qty'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['productName'] = productName;
    data['qty'] = qty;
    return data;
  }
}
