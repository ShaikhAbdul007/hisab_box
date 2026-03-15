class UserModel {
  final String? id;
  final String? parentId;
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
  final bool? isSaved;
  final String? role;
  final bool pCustomerList;
  final bool pCreditList;
  final bool pReconcileCredit;
  final bool pAddUser;
  final bool pAddBankDetails;
  final bool pSeeRevenue;
  final bool pSeeReceivedCash;
  final bool pSeeReceivedCredit;
  final bool pSeeReceivedCard;
  final bool pSeeReceivedUpi;
  final bool pSeeReport;
  final bool pSeeTodaySale;
  final bool pSeeTodaySaleDetail;
  final bool pAddProduct;
  final bool pAddManualProduct;
  final bool pDeleteProduct;
  final bool pAddLooseProduct;
  final bool pTransferGodownToShop;
  final bool pEditProfile;
  final bool pEditProductDetails;
  final bool pEditLooseProductDetails;
  final bool pEditGodownProductDetails;
  final String? fcmToken;

  UserModel({
    this.fcmToken,
    this.id,
    this.parentId,
    this.role,
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
    this.isSaved,
    this.pCustomerList = false,
    this.pCreditList = false,
    this.pReconcileCredit = false,
    this.pAddUser = false,
    this.pAddBankDetails = false,
    this.pSeeRevenue = false,
    this.pSeeReceivedCash = false,
    this.pSeeReceivedCredit = false,
    this.pSeeReceivedCard = false,
    this.pSeeReceivedUpi = false,
    this.pSeeReport = false,
    this.pSeeTodaySale = false,
    this.pSeeTodaySaleDetail = false,
    this.pAddProduct = false,
    this.pAddManualProduct = false,
    this.pDeleteProduct = false,
    this.pAddLooseProduct = false,
    this.pTransferGodownToShop = false,
    this.pEditProfile = false,
    this.pEditProductDetails = false,
    this.pEditLooseProductDetails = false,
    this.pEditGodownProductDetails = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return UserModel(
      fcmToken: json['fcm_token'] ?? '',
      id: id ?? json['id'],
      parentId: json['parent_id'],
      name: json['name'],
      email: json['email'],
      password: json['password'] ?? '',
      mobileNo: json['mobile_no'] ?? '',
      alternateMobileNo: json['alternate_mobile_no'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      pincode: json['pincode'] ?? '',
      discountPerProduct: json['discountPerProduct'] ?? false,
      shoptype: json['shop_type'] ?? '',
      image: json['profile_image'] ?? '',
      isSaved: json['isSaved'] ?? false,
      role: json['role'] ?? 'admin',
      pCustomerList: json['p_customer_list'] ?? false,
      pCreditList: json['p_credit_list'] ?? false,
      pReconcileCredit: json['p_reconcile_credit'] ?? false,
      pAddUser: json['p_add_user'] ?? false,
      pAddBankDetails: json['p_add_bank_details'] ?? false,
      pSeeRevenue: json['p_see_revenue'] ?? false,
      pSeeReceivedCash: json['p_see_received_cash'] ?? false,
      pSeeReceivedCredit: json['p_see_received_credit'] ?? false,
      pSeeReceivedCard: json['p_see_received_card'] ?? false,
      pSeeReceivedUpi: json['p_see_received_upi'] ?? false,
      pSeeReport: json['p_see_report'] ?? false,
      pSeeTodaySale: json['p_see_today_sale'] ?? false,
      pSeeTodaySaleDetail: json['p_see_today_sale_detail'] ?? false,
      pAddProduct: json['p_add_product'] ?? false,
      pAddManualProduct: json['p_add_manual_product'] ?? false,
      pDeleteProduct: json['p_delete_product'] ?? false,
      pAddLooseProduct: json['p_add_loose_product'] ?? false,
      pTransferGodownToShop: json['p_transfer_godown_to_shop'] ?? false,
      pEditProfile: json['p_edit_profile'] ?? false,
      pEditProductDetails: json['p_edit_product_details'] ?? false,
      pEditLooseProductDetails: json['p_edit_loose_product_details'] ?? false,
      pEditGodownProductDetails: json['p_edit_godown_product_details'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fcm_token': fcmToken,
      "id": id,
      "parent_id": parentId,
      "name": name,
      "email": email,
      "mobile_no": mobileNo,
      "alternate_mobile_no": alternateMobileNo,
      "address": address,
      "city": city,
      "state": state,
      "pincode": pincode,
      "shop_type": shoptype,
      "profile_image": image,
      "role": role,
      "isSaved": isSaved,
      "discountPerProduct": discountPerProduct,
      "p_customer_list": pCustomerList,
      "p_credit_list": pCreditList,
      "p_reconcile_credit": pReconcileCredit,
      "p_add_user": pAddUser,
      "p_add_bank_details": pAddBankDetails,
      "p_see_revenue": pSeeRevenue,
      "p_see_received_cash": pSeeReceivedCash,
      "p_see_received_credit": pSeeReceivedCredit,
      "p_see_received_card": pSeeReceivedCard,
      "p_see_received_upi": pSeeReceivedUpi,
      "p_see_report": pSeeReport,
      "p_see_today_sale": pSeeTodaySale,
      "p_see_today_sale_detail": pSeeTodaySaleDetail,
      "p_add_product": pAddProduct,
      "p_add_manual_product": pAddManualProduct,
      "p_delete_product": pDeleteProduct,
      "p_add_loose_product": pAddLooseProduct,
      "p_transfer_godown_to_shop": pTransferGodownToShop,
      "p_edit_profile": pEditProfile,
      "p_edit_product_details": pEditProductDetails,
      "p_edit_loose_product_details": pEditLooseProductDetails,
      "p_edit_godown_product_details": pEditGodownProductDetails,
    };
  }
}
