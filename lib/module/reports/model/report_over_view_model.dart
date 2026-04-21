class ReportOverviewModel {
  bool? success;
  String? msg;
  ReportOverviewData? data;

  ReportOverviewModel({this.success, this.msg, this.data});

  ReportOverviewModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    msg = json['msg'];
    data = json['data'] != null ? ReportOverviewData.fromJson(json['data']) : null;
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

class ReportOverviewData {
  int? cash;
  int? upi;
  int? card;
  int? creditUnpaid;
  int? totalRevenue;

  ReportOverviewData({this.cash, this.upi, this.card, this.creditUnpaid, this.totalRevenue});

  ReportOverviewData.fromJson(Map<String, dynamic> json) {
    cash = json['cash'];
    upi = json['upi'];
    card = json['card'];
    creditUnpaid = json['creditUnpaid'];
    totalRevenue = json['totalRevenue'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cash'] = cash;
    data['upi'] = upi;
    data['card'] = card;
    data['creditUnpaid'] = creditUnpaid;
    data['totalRevenue'] = totalRevenue;
    return data;
  }
}
