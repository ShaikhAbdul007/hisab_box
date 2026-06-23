class AllExpenseModel {
  bool? success;
  String? message;
  List<AllExpenseData>? data;

  AllExpenseModel({this.success, this.message, this.data});

  AllExpenseModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != null) {
      data = <AllExpenseData>[];
      json['data'].forEach((v) {
        data!.add(AllExpenseData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AllExpenseData {
  String? id;
  String? userId;
  String? name;
  String? amount;
  String? paymentMode;
  String? createdAt;
  String? updatedAt;

  AllExpenseData({
    this.id,
    this.userId,
    this.name,
    this.amount,
    this.paymentMode,
    this.createdAt,
    this.updatedAt,
  });

  AllExpenseData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    name = json['name'];
    amount = json['amount'];
    paymentMode = json['payment_mode'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['name'] = name;
    data['amount'] = amount;
    data['payment_mode'] = paymentMode;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;

    return data;
  }
}
