class GrnModel {
  bool? success;
  String? msg;
  GrnData? data;

  GrnModel({this.success, this.msg, this.data});

  GrnModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    msg = json['message'];
    data = json['data'] != null ? GrnData.fromJson(json['data']) : null;
  }
}

class GrnData {
  List<GrnItem>? data;
  GrnPagination? pagination;

  GrnData({this.data, this.pagination});

  GrnData.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <GrnItem>[];
      for (final item in json['data']) {
        data!.add(GrnItem.fromJson(item));
      }
    }
    pagination =
        json['pagination'] != null
            ? GrnPagination.fromJson(json['pagination'])
            : null;
  }
}

class GrnItem {
  String? id;
  String? grnNo;
  String? productName;
  String? barcode;
  num? quantity;
  num? returnQuantity;
  String? reason;
  String? condition;
  String? status;
  String? notes;
  String? createdAt;

  GrnItem({
    this.id,
    this.grnNo,
    this.productName,
    this.barcode,
    this.quantity,
    this.returnQuantity,
    this.reason,
    this.condition,
    this.status,
    this.notes,
    this.createdAt,
  });

  GrnItem.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    grnNo = json['grn_no']?.toString();
    productName = json['product_name']?.toString();
    barcode = json['barcode']?.toString();
    quantity = num.tryParse(json['quantity']?.toString() ?? '0');
    returnQuantity = num.tryParse(json['return_quantity']?.toString() ?? '0');
    reason = json['reason']?.toString();
    condition = json['condition']?.toString();
    status = json['status']?.toString();
    notes = json['notes']?.toString();
    createdAt = (json['created_at'] ?? json['createdAt'])?.toString();
  }
}

class GrnPagination {
  int? page;
  int? limit;
  int? total;
  int? totalPages;

  GrnPagination({this.page, this.limit, this.total, this.totalPages});

  GrnPagination.fromJson(Map<String, dynamic> json) {
    page = int.tryParse(json['page']?.toString() ?? '0');
    limit = int.tryParse(json['limit']?.toString() ?? '0');
    total = int.tryParse(json['total']?.toString() ?? '0');
    totalPages = int.tryParse(json['totalPages']?.toString() ?? '0');
  }
}
