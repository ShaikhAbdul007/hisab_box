class CustomerDetails {
  String? id;
  String? name;
  String? mobile;
  String? address;

  CustomerDetails({this.id, this.name, this.mobile, this.address});

  CustomerDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    mobile = json['mobile'];
    address = json['address'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['mobile'] = mobile;
    data['address'] = address;
    return data;
  }
}
