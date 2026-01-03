class BankModel {
  final String? bankName;
  final String? accountName;
  final String? upiId;

  BankModel({this.accountName, this.bankName, this.upiId});

  factory BankModel.formJson(Map<String, dynamic> json) {
    return BankModel(
      accountName: json['accountHolder'],
      bankName: json['bankName'],
      upiId: json['upiId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'accountHolder': accountName, 'upiId': upiId, 'bankName': bankName};
  }
}
