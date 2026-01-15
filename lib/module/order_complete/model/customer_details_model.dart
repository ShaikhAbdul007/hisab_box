class CustomerDetails {
  String? id;
  String? address;
  String? createdAt;
  String? mobile;
  String? name;

  double totalPurchase = 0;
  double totalPaid = 0;
  double totalCredit = 0;

  CustomerDetails({
    this.address,
    this.createdAt,
    this.mobile,
    this.name,
    this.id,
    this.totalPurchase = 0,
    this.totalPaid = 0,
    this.totalCredit = 0,
  });

  factory CustomerDetails.fromJson(Map<String, dynamic> json) {
    return CustomerDetails(
      address: json["address"],
      id: json["mobile"], // doc id
      createdAt: json["createdAt"],
      mobile: json["mobile"],
      name: json["name"],
      totalPurchase: (json["totalPurchase"] ?? 0).toDouble(),
      totalPaid: (json["totalPaid"] ?? 0).toDouble(),
      totalCredit: (json["totalCredit"] ?? 0).toDouble(),
    );
  }
}
