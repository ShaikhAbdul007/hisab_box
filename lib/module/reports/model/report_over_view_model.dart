class ReportOverviewModel {
  bool? success;
  String? msg;
  ReportOverviewModelData? data;

  ReportOverviewModel({this.success, this.msg, this.data});

  ReportOverviewModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    msg = json['message'];
    data =
        json['data'] != null
            ? ReportOverviewModelData.fromJson(json['data'])
            : null;
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

class ReportOverviewModelData {
  String? date;
  ReportOverviewData? data;

  ReportOverviewModelData({this.date, this.data});

  ReportOverviewModelData.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    data =
        json['summary'] != null
            ? ReportOverviewData.fromJson(json['summary'])
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['date'] = date;
    if (this.data != null) {
      data['summary'] = this.data!.toJson();
    }
    return data;
  }
}

class ReportOverviewData {
  num? cash;
  num? upi;
  num? card;
  num? credit;
  num? creditUnpaid;
  num? totalRevenue;

  ReportOverviewData({
    this.cash,
    this.upi,
    this.card,
    this.credit,
    this.creditUnpaid,
    this.totalRevenue,
  });

  ReportOverviewData.fromJson(Map<String, dynamic> json) {
    cash = json['cash'];
    upi = json['upi'];
    card = json['card'];
    credit = json['credit'];
    creditUnpaid = json['creditUnpaid'];
    totalRevenue = json['totalRevenue'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cash'] = cash;
    data['upi'] = upi;
    data['card'] = card;
    data['credit'] = credit;
    data['creditUnpaid'] = creditUnpaid;
    data['totalRevenue'] = totalRevenue;
    return data;
  }
}
