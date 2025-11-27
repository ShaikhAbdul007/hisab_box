class ReportTopProductModel {
  String? name;
  String? totalQty;
  int? revenue;

  ReportTopProductModel({this.name, this.totalQty, this.revenue});

  ReportTopProductModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    totalQty = json['totalQty'];
    revenue = json['revenue'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['totalQty'] = totalQty;
    data['revenue'] = revenue;
    return data;
  }
}
