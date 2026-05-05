class AllCustomerModel {
  bool? success;
  String? msg;
  CustomerResponseData? data;

  AllCustomerModel({this.success, this.msg, this.data});

  AllCustomerModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    msg = json['message'];
    data =
        json['data'] != null
            ? CustomerResponseData.fromJson(json['data'])
            : null;
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'msg': msg, 'data': data?.toJson()};
  }
}

class CustomerResponseData {
  List<CustomerItem>? customers;
  PaginationModel? pagination;

  CustomerResponseData({this.customers, this.pagination});

  CustomerResponseData.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      customers = <CustomerItem>[];
      json['data'].forEach((item) {
        customers!.add(CustomerItem.fromJson(item));
      });
    }

    pagination =
        json['pagination'] != null
            ? PaginationModel.fromJson(json['pagination'])
            : null;
  }

  Map<String, dynamic> toJson() {
    return {
      'data': customers?.map((e) => e.toJson()).toList(),
      'pagination': pagination?.toJson(),
    };
  }
}

class CustomerItem {
  String? id;
  String? userId;
  String? mobileNo;
  String? name;
  String? address;
  String? description;
  String? createdAt;

  CustomerItem({
    this.id,
    this.userId,
    this.mobileNo,
    this.name,
    this.address,
    this.description,
    this.createdAt,
  });

  CustomerItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    mobileNo = json['mobile_no'];
    name = json['name'];
    address = json['address'];
    description = json['description'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'mobile_no': mobileNo,
      'name': name,
      'address': address,
      'description': description,
      'created_at': createdAt,
    };
  }
}

class PaginationModel {
  int? page;
  int? limit;
  int? total;
  int? totalPages;

  PaginationModel({this.page, this.limit, this.total, this.totalPages});

  PaginationModel.fromJson(Map<String, dynamic> json) {
    page = json['page'];
    limit = json['limit'];
    total = json['total'];
    totalPages = json['totalPages'];
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'limit': limit,
      'total': total,
      'totalPages': totalPages,
    };
  }
}
