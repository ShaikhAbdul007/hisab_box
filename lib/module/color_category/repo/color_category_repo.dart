import 'package:inventory/module/category/model/category_model.dart';
import 'package:inventory/module/category/model/create_category_model.dart';
import 'package:inventory/network/api_endpoint.dart';
import 'package:inventory/network/networking.dart';

class ColorCategoryRepo {
  Networking networking = Networking();

  Future<CategoryModel> getColorCategories() async {
    try {
      final response = await networking.getData(
        url: '${ApiEndPoint.fullBaseUrl}${ApiEndPoint.getColorCategories}',
      );
      return CategoryModel.fromJson(response);
    } catch (e) {
      return CategoryModel(success: false, msg: e.toString());
    }
  }

  Future<CreateCategoryModel> createColorCategory({
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await networking.postData(
        url: '${ApiEndPoint.fullBaseUrl}${ApiEndPoint.createColorCategory}',
        body: body,
      );
      return CreateCategoryModel.fromJson(response);
    } catch (e) {
      return CreateCategoryModel(success: false, msg: e.toString());
    }
  }

  Future<CreateCategoryModel> deleteColorCategory({required String id}) async {
    try {
      final response = await networking.deleteData(
        url: '${ApiEndPoint.fullBaseUrl}${ApiEndPoint.deleteColorCategory}/$id',
      );
      return CreateCategoryModel.fromJson(response);
    } catch (e) {
      return CreateCategoryModel(success: false, msg: e.toString());
    }
  }
}
