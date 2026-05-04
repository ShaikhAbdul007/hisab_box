class CreateGrModel {
  bool? success;
  String? msg;
  CreateGrData? data;

  CreateGrModel({this.success, this.msg, this.data});

  CreateGrModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    msg = json['msg'];
    data = json['data'] != null ? CreateGrData.fromJson(json['data']) : null;
  }
}

class CreateGrData {
  CreateGrn? grn;
  String? message;
  CreateGrStockUpdate? stockUpdate;

  CreateGrData({this.grn, this.message, this.stockUpdate});

  CreateGrData.fromJson(Map<String, dynamic> json) {
    grn = json['grn'] != null ? CreateGrn.fromJson(json['grn']) : null;
    message = json['message'];
    stockUpdate =
        json['stockUpdate'] != null
            ? CreateGrStockUpdate.fromJson(json['stockUpdate'])
            : null;
  }
}

class CreateGrn {
  String? id;
  String? userId;
  String? grnNo;
  String? saleId;
  String? productId;
  String? productName;
  String? barcode;
  num? quantity;
  num? returnQuantity;
  String? reason;
  String? condition;
  String? status;
  num? refundAmount;
  String? refundMode;
  String? stockType;
  String? location;
  String? notes;
  String? createdAt;
  String? updatedAt;
  String? approvedBy;
  String? approvedAt;

  CreateGrn({
    this.id,
    this.userId,
    this.grnNo,
    this.saleId,
    this.productId,
    this.productName,
    this.barcode,
    this.quantity,
    this.returnQuantity,
    this.reason,
    this.condition,
    this.status,
    this.refundAmount,
    this.refundMode,
    this.stockType,
    this.location,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.approvedBy,
    this.approvedAt,
  });

  CreateGrn.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    userId = json['user_id']?.toString();
    grnNo = json['grn_no']?.toString();
    saleId = json['sale_id']?.toString();
    productId = json['product_id']?.toString();
    productName = json['product_name']?.toString();
    barcode = json['barcode']?.toString();
    quantity = num.tryParse(json['quantity']?.toString() ?? '0');
    returnQuantity = num.tryParse(json['return_quantity']?.toString() ?? '0');
    reason = json['reason']?.toString();
    condition = json['condition']?.toString();
    status = json['status']?.toString();
    refundAmount = num.tryParse(json['refund_amount']?.toString() ?? '0');
    refundMode = json['refund_mode']?.toString();
    stockType = json['stock_type']?.toString();
    location = json['location']?.toString();
    notes = json['notes']?.toString();
    createdAt = (json['created_at'] ?? json['createdAt'])?.toString();
    updatedAt = (json['updated_at'] ?? json['updatedAt'])?.toString();
    approvedBy = json['approved_by']?.toString();
    approvedAt = json['approved_at']?.toString();
  }
}

class CreateGrStockUpdate {
  num? previousStock;
  num? deducted;
  num? currentStock;

  CreateGrStockUpdate({this.previousStock, this.deducted, this.currentStock});

  CreateGrStockUpdate.fromJson(Map<String, dynamic> json) {
    previousStock = num.tryParse(json['previousStock']?.toString() ?? '0');
    deducted = num.tryParse(json['deducted']?.toString() ?? '0');
    currentStock = num.tryParse(json['currentStock']?.toString() ?? '0');
  }
}
