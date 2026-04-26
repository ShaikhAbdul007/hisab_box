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

  Stats({
    this.totalProducts,
    this.outOfStock,
    this.looseStock,
    this.todaySales,
    this.totalCustomers,
  });

  Stats.fromJson(Map<String, dynamic> json) {
    totalProducts = json['total_products'];
    outOfStock = json['out_of_stock'];
    looseStock = json['loose_stock'];
    todaySales = json['today_sales'];
    totalCustomers = json['total_customers'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_products'] = totalProducts;
    data['out_of_stock'] = outOfStock;
    data['loose_stock'] = looseStock;
    data['today_sales'] = todaySales;
    data['total_customers'] = totalCustomers;
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
  String? userId;
  String? userActivity;
  String? module;
  String? type;
  String? createdAt;

  RecentActivitiesData({
    this.id,
    this.userId,
    this.userActivity,
    this.module,
    this.type,
    this.createdAt,
  });

  RecentActivitiesData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    userActivity = json['user_activity'];
    module = json['module'];
    type = json['type'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['user_activity'] = userActivity;
    data['module'] = module;
    data['type'] = type;
    data['created_at'] = createdAt;
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
