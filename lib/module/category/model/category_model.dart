class CategoryModel {
  bool? success;
  String? msg;
  CategoryModelData? categorymodeldata;

  CategoryModel({this.success, this.msg, this.categorymodeldata});

  CategoryModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    msg = json['msg'];
    categorymodeldata = json['data'] != null ? CategoryModelData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['msg'] = msg;
    if (this.categorymodeldata != null) {
      data['data'] = this.categorymodeldata!.toJson();
    }
    return data;
  }
}

class CategoryModelData {
  List<CategoryModelListData>? data;
  Pagination? pagination;

  CategoryModelData({this.data, this.pagination});

  CategoryModelData.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <CategoryModelListData>[];
      json['data'].forEach((v) {
        data!.add(CategoryModelListData.fromJson(v));
      });
    }
    pagination = json['pagination'] != null
        ? Pagination.fromJson(json['pagination'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    if (pagination != null) {
      data['pagination'] = pagination!.toJson();
    }
    return data;
  }
}

class CategoryModelListData {
  String? id;
  String? userId;
  String? name;
  String? createdAt;
  dynamic time;

  CategoryModelListData({this.id, this.userId, this.name, this.createdAt, this.time});

  CategoryModelListData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    name = json['name'];
    createdAt = json['created_at'];
    time = json['time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['name'] = name;
    data['created_at'] = createdAt;
    data['time'] = time;
    return data;
  }
}

class Pagination {
  int? page;
  int? limit;
  int? total;
  int? totalPages;

  Pagination({this.page, this.limit, this.total, this.totalPages});

  Pagination.fromJson(Map<String, dynamic> json) {
    page = json['page'];
    limit = json['limit'];
    total = json['total'];
    totalPages = json['totalPages'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['page'] = page;
    data['limit'] = limit;
    data['total'] = total;
    data['totalPages'] = totalPages;
    return data;
  }
}
