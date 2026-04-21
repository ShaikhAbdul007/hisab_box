class EmpolyeeModel {
  bool? success;
  String? msg;
  List<EmpolyeeData>? data;

  EmpolyeeModel({this.success, this.msg, this.data});

  EmpolyeeModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    msg = json['msg'];
    if (json['data'] != null) {
      data = <EmpolyeeData>[];
      json['data'].forEach((v) {
        data!.add(EmpolyeeData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['msg'] = msg;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class EmpolyeeData {
  String? id;
  String? name;
  String? email;
  String? mobileNo;
  int? alternateMobileNo;
  String? address;
  String? city;
  String? state;
  int? pincode;
  String? shopType;
  String? profileImage;
  String? profilepic;
  String? createdAt;
  String? updatedAt;
  String? fcmToken;
  String? roleId;
  String? parentId;
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
  Role? role;
  Permissions? permissions;

  EmpolyeeData({
    this.id,
    this.name,
    this.email,
    this.mobileNo,
    this.alternateMobileNo,
    this.address,
    this.city,
    this.state,
    this.pincode,
    this.shopType,
    this.profileImage,
    this.profilepic,
    this.createdAt,
    this.updatedAt,
    this.fcmToken,
    this.roleId,
    this.parentId,
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
    this.role,
    this.permissions,
  });

  EmpolyeeData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    mobileNo = json['mobile_no'];
    alternateMobileNo = json['alternate_mobile_no'];
    address = json['address'];
    city = json['city'];
    state = json['state'];
    pincode = json['pincode'];
    shopType = json['shop_type'];
    profileImage = json['profile_image'];
    profilepic = json['profilepic'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    fcmToken = json['fcm_token'];
    roleId = json['role_id'];
    parentId = json['parent_id'];
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
    role = json['role'] != null ? Role.fromJson(json['role']) : null;
    permissions =
        json['permissions'] != null
            ? Permissions.fromJson(json['permissions'])
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['mobile_no'] = mobileNo;
    data['alternate_mobile_no'] = alternateMobileNo;
    data['address'] = address;
    data['city'] = city;
    data['state'] = state;
    data['pincode'] = pincode;
    data['shop_type'] = shopType;
    data['profile_image'] = profileImage;
    data['profilepic'] = profilepic;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['fcm_token'] = fcmToken;
    data['role_id'] = roleId;
    data['parent_id'] = parentId;
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
    if (role != null) {
      data['role'] = role!.toJson();
    }
    if (permissions != null) {
      data['permissions'] = permissions!.toJson();
    }
    return data;
  }
}

class Role {
  String? id;
  String? name;
  int? level;

  Role({this.id, this.name, this.level});

  Role.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    level = json['level'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['level'] = level;
    return data;
  }
}

class Permissions {
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

  Permissions({
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
  });

  Permissions.fromJson(Map<String, dynamic> json) {
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
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
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
    return data;
  }
}
