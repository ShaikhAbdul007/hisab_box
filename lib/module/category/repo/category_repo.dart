import 'package:inventory/module/category/model/category_model.dart';
import 'package:inventory/module/category/model/create_category_model.dart';
import 'package:inventory/network/api_endpoint.dart';
import 'package:inventory/network/networking.dart';

class CategoryRepo {
  Networking networking = Networking();

  Future<CategoryModel> getCategory() async {
    try {
      final response = await networking.getData(
        url: '${ApiEndPoint.fullBaseUrl}${ApiEndPoint.getCategories}',
      );
      return CategoryModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<CreateCategoryModel> createCategory({
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await networking.postData(
        url: '${ApiEndPoint.fullBaseUrl}${ApiEndPoint.createCategory}',
        body: body,
      );
      return CreateCategoryModel.fromJson(response);
    } catch (e) {
      return CreateCategoryModel(success: false, msg: e.toString());
    }
  }

  Future<CreateCategoryModel> deleteCategory({required String id}) async {
    try {
      final response = await networking.deleteData(
        url: '${ApiEndPoint.fullBaseUrl}${ApiEndPoint.deleteCategory}/$id',
      );
      return CreateCategoryModel.fromJson(response);
    } catch (e) {
      return CreateCategoryModel(success: false, msg: e.toString());
    }
  }
}
