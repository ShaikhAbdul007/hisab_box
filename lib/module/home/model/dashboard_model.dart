class DashboardModel {
  bool? success;
  String? message;
  DashboardData? data;

  DashboardModel({this.success, this.message, this.data});

  DashboardModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['msg'];
    data = json['data'] != null ? DashboardData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['msg'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class DashboardData {
  Stats? stats;
  RecentActivities? recentActivities;

  DashboardData({this.stats, this.recentActivities});

  DashboardData.fromJson(Map<String, dynamic> json) {
    stats = json['stats'] != null ? Stats.fromJson(json['stats']) : null;
    recentActivities =
        json['recent_activities'] != null
            ? RecentActivities.fromJson(json['recent_activities'])
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (stats != null) {
      data['stats'] = stats!.toJson();
    }
    if (recentActivities != null) {
      data['recent_activities'] = recentActivities!.toJson();
    }
    return data;
  }
}

class Stats {
  num? totalProducts;
  num? outOfStock;
  num? looseStock;
  num? todaySales;
  num? totalCustomers;
  // new fields
  num? nearExpiry;
  num? totalGrns;
  num? pendingGrns;
  num? approvedGrns;
  num? rejectedGrns;

  Stats({
    this.totalProducts,
    this.outOfStock,
    this.looseStock,
    this.todaySales,
    this.totalCustomers,
    this.nearExpiry,
    this.totalGrns,
    this.pendingGrns,
    this.approvedGrns,
    this.rejectedGrns,
  });

  Stats.fromJson(Map<String, dynamic> json) {
    totalProducts = json['total_products'];
    outOfStock = json['out_of_stock'];
    looseStock = json['loose_stock'];
    todaySales = json['today_sales'];
    totalCustomers = json['total_customers'];
    nearExpiry = json['near_expiry'];
    totalGrns = json['total_grns'];
    pendingGrns = json['pending_grns'];
    approvedGrns = json['approved_grns'];
    rejectedGrns = json['rejected_grns'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_products'] = totalProducts;
    data['out_of_stock'] = outOfStock;
    data['loose_stock'] = looseStock;
    data['today_sales'] = todaySales;
    data['total_customers'] = totalCustomers;
    data['near_expiry'] = nearExpiry;
    data['total_grns'] = totalGrns;
    data['pending_grns'] = pendingGrns;
    data['approved_grns'] = approvedGrns;
    data['rejected_grns'] = rejectedGrns;
    return data;
  }
}

class RecentActivities {
  List<RecentActivitiesData>? recentActivitiesData;
  Pagination? pagination;

  RecentActivities({this.recentActivitiesData, this.pagination});

  RecentActivities.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      recentActivitiesData = <RecentActivitiesData>[];
      json['data'].forEach((v) {
        recentActivitiesData!.add(RecentActivitiesData.fromJson(v));
      });
    }
    pagination =
        json['pagination'] != null
            ? Pagination.fromJson(json['pagination'])
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (recentActivitiesData != null) {
      data['data'] = recentActivitiesData!.map((v) => v.toJson()).toList();
    }
    if (pagination != null) {
      data['pagination'] = pagination!.toJson();
    }
    return data;
  }
}

class RecentActivitiesData {
  String? id;
  String? type;
  String? referenceNo;
  String? status;
  String? createdAt;
  String? description;
  // kept for backward compat
  String? userId;
  String? userActivity;
  String? module;

  RecentActivitiesData({
    this.id,
    this.type,
    this.referenceNo,
    this.status,
    this.createdAt,
    this.description,
    this.userId,
    this.userActivity,
    this.module,
  });

  RecentActivitiesData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    referenceNo = json['reference_no'];
    status = json['status'];
    createdAt = json['created_at'];
    description = json['description'];
    // backward compat
    userId = json['user_id'];
    userActivity = json['user_activity'];
    module = json['module'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['type'] = type;
    data['reference_no'] = referenceNo;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['description'] = description;
    data['user_id'] = userId;
    data['user_activity'] = userActivity;
    data['module'] = module;
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
