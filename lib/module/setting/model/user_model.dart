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
  final bool? discountPerProduct;
  final String? shoptype;
  final String? image;

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
    this.shoptype,
    this.discountPerProduct,
    this.image,
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
      discountPerProduct: json['discountPerProduct'] ?? false,
      shoptype: json['shoptype'] ?? '',
      image: json['profileImage'] ?? '',
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
      "shoptype": shoptype,
      "discountPerProduct": discountPerProduct,
      "profileImage": image,
    };
  }
}
