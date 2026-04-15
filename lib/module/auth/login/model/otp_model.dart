class SentOtpModel {
  bool? success;
  String? msg;
  SentOtpData? data;

  SentOtpModel({this.success, this.msg, this.data});

  SentOtpModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    msg = json['msg'];
    data = json['data'] != null ?  SentOtpData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['success'] = success;
    data['msg'] = msg;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class SentOtpData {
  String? userId;
  String? email;
  String? name;

  SentOtpData({this.userId, this.email, this.name});

  SentOtpData.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    email = json['email'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = userId;
    data['email'] = email;
    data['name'] = name;
    return data;
  }
}
