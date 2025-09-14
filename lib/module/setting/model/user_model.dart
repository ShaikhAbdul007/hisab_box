class InventoryUserModel {
  final String? id;
  final String? name;
  final String? email;
  final String? password;
  final String? mobileNo;
  final String? alternateMobileNo;
  final String? address;
  final String? city;
  final String? state;
  final String? pincode;

  InventoryUserModel({
    this.id,
    this.name,
    this.email,
    this.password,
    this.mobileNo,
    this.alternateMobileNo,
    this.address,
    this.city,
    this.state,
    this.pincode,
  });

  factory InventoryUserModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return InventoryUserModel(
      id: id,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      mobileNo: json['mobileNo'] ?? '',
      alternateMobileNo: json['alternateMobileNo'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      pincode: json['pincode'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "email": email,
      "password": password,
      "mobileNo": mobileNo,
      "alternateMobileNo": alternateMobileNo,
      "address": address,
      "city": city,
      "state": state,
      "pincode": pincode,
    };
  }
}
