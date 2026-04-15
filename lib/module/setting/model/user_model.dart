class UserModel {
  bool? success;
  String? msg;
  UserModelData? data;

  UserModel({this.success, this.msg, this.data});

  UserModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    msg = json['msg'];
    data = json['data'] != null ? UserModelData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['msg'] = msg;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class UserModelData {
  String? createdAt;
  String? updatedAt;
  String? id;
  String? name;
  String? email;
  String? mobileNo;
  String? shopType;
  String? address;
  String? city;
  String? state;
  String? pincode;
  String? roleId;
  bool? pCustomerList;
  bool? pCreditList;
  bool? pReconcileCredit;
  bool? pSeeTodaySale;
  bool? pSeeTodaySaleDetail;
  bool? pSeeRevenue;
  bool? pSeeReceivedCash;
  bool? pSeeReceivedCredit;
  bool? pSeeReceivedCard;
  bool? pSeeReceivedUpi;
  bool? pSeeReport;
  bool? pAddProduct;
  bool? pAddManualProduct;
  bool? pDeleteProduct;
  bool? pEditProductDetails;
  bool? pAddLooseProduct;
  bool? pEditLooseProductDetails;
  bool? pTransferGodownToShop;
  bool? pEditGodownProductDetails;
  bool? pAddUser;
  bool? pAddBankDetails;
  bool? pEditProfile;
  dynamic alternateMobileNo;
  dynamic profileImage;
  dynamic fcmToken;
  dynamic parentId;
  String? image;

  UserModelData({
    this.createdAt,
    this.updatedAt,
    this.id,
    this.name,
    this.email,
    this.mobileNo,
    this.shopType,
    this.address,
    this.city,
    this.state,
    this.pincode,
    this.roleId,
    this.pCustomerList,
    this.pCreditList,
    this.pReconcileCredit,
    this.pSeeTodaySale,
    this.pSeeTodaySaleDetail,
    this.pSeeRevenue,
    this.pSeeReceivedCash,
    this.pSeeReceivedCredit,
    this.pSeeReceivedCard,
    this.pSeeReceivedUpi,
    this.pSeeReport,
    this.pAddProduct,
    this.pAddManualProduct,
    this.pDeleteProduct,
    this.pEditProductDetails,
    this.pAddLooseProduct,
    this.pEditLooseProductDetails,
    this.pTransferGodownToShop,
    this.pEditGodownProductDetails,
    this.pAddUser,
    this.pAddBankDetails,
    this.pEditProfile,
    this.alternateMobileNo,
    this.profileImage,
    this.fcmToken,
    this.image,
    this.parentId,
  });

  UserModelData.fromJson(Map<String, dynamic> json) {
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    id = json['id'];
    name = json['name'];
    email = json['email'];
    mobileNo = json['mobile_no'];
    shopType = json['shop_type'];
    address = json['address'];
    city = json['city'];
    state = json['state'];
    pincode = json['pincode'];
    roleId = json['role_id'];
    pCustomerList = json['p_customer_list'];
    pCreditList = json['p_credit_list'];
    pReconcileCredit = json['p_reconcile_credit'];
    pSeeTodaySale = json['p_see_today_sale'];
    pSeeTodaySaleDetail = json['p_see_today_sale_detail'];
    pSeeRevenue = json['p_see_revenue'];
    pSeeReceivedCash = json['p_see_received_cash'];
    pSeeReceivedCredit = json['p_see_received_credit'];
    pSeeReceivedCard = json['p_see_received_card'];
    pSeeReceivedUpi = json['p_see_received_upi'];
    pSeeReport = json['p_see_report'];
    pAddProduct = json['p_add_product'];
    pAddManualProduct = json['p_add_manual_product'];
    pDeleteProduct = json['p_delete_product'];
    pEditProductDetails = json['p_edit_product_details'];
    pAddLooseProduct = json['p_add_loose_product'];
    pEditLooseProductDetails = json['p_edit_loose_product_details'];
    pTransferGodownToShop = json['p_transfer_godown_to_shop'];
    pEditGodownProductDetails = json['p_edit_godown_product_details'];
    pAddUser = json['p_add_user'];
    pAddBankDetails = json['p_add_bank_details'];
    pEditProfile = json['p_edit_profile'];
    alternateMobileNo = json['alternate_mobile_no'];
    profileImage = json['profile_image'];
    fcmToken = json['fcm_token'];
    parentId = json['parent_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['mobile_no'] = mobileNo;
    data['shop_type'] = shopType;
    data['address'] = address;
    data['city'] = city;
    data['state'] = state;
    data['pincode'] = pincode;
    data['role_id'] = roleId;
    data['p_customer_list'] = pCustomerList;
    data['p_credit_list'] = pCreditList;
    data['p_reconcile_credit'] = pReconcileCredit;
    data['p_see_today_sale'] = pSeeTodaySale;
    data['p_see_today_sale_detail'] = pSeeTodaySaleDetail;
    data['p_see_revenue'] = pSeeRevenue;
    data['p_see_received_cash'] = pSeeReceivedCash;
    data['p_see_received_credit'] = pSeeReceivedCredit;
    data['p_see_received_card'] = pSeeReceivedCard;
    data['p_see_received_upi'] = pSeeReceivedUpi;
    data['p_see_report'] = pSeeReport;
    data['p_add_product'] = pAddProduct;
    data['p_add_manual_product'] = pAddManualProduct;
    data['p_delete_product'] = pDeleteProduct;
    data['p_edit_product_details'] = pEditProductDetails;
    data['p_add_loose_product'] = pAddLooseProduct;
    data['p_edit_loose_product_details'] = pEditLooseProductDetails;
    data['p_transfer_godown_to_shop'] = pTransferGodownToShop;
    data['p_edit_godown_product_details'] = pEditGodownProductDetails;
    data['p_add_user'] = pAddUser;
    data['p_add_bank_details'] = pAddBankDetails;
    data['p_edit_profile'] = pEditProfile;
    data['alternate_mobile_no'] = alternateMobileNo;
    data['profile_image'] = profileImage;
    data['fcm_token'] = fcmToken;
    data['parent_id'] = parentId;
    return data;
  }
}
