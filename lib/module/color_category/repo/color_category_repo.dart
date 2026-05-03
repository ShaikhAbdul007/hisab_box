import 'package:inventory/module/category/model/category_model.dart';
import 'package:inventory/network/api_endpoint.dart';
import 'package:inventory/network/networking.dart';

class ColorCategoryRepo {
  Networking networking = Networking();

  Future<CategoryModel> getColorCategories({
    int page = 1,
    int pageLimit = 20,
  }) async {
    try {
      final response = await networking.getData(
        url:
            '${ApiEndPoint.fullBaseUrl}${ApiEndPoint.getColorCategories}?page=$page&limit=$pageLimit',
      );
      return CategoryModel.fromJson(response);
    } catch (e) {
      return CategoryModel(success: false, msg: e.toString());
    }
  }

  Future<CategoryModel> createColorCategory({
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await networking.postData(
        url: '${ApiEndPoint.fullBaseUrl}${ApiEndPoint.createColorCategory}',
        body: body,
      );
      return CategoryModel.fromJson(response);
    } catch (e) {
      return CategoryModel(success: false, msg: e.toString());
    }
  }

  Future<CategoryModel> deleteColorCategory({required String id}) async {
    try {
      final response = await networking.deleteData(
        url: '${ApiEndPoint.fullBaseUrl}${ApiEndPoint.deleteColorCategory}/$id',
      );
      return CategoryModel.fromJson(response);
    } catch (e) {
      return CategoryModel(success: false, msg: e.toString());
    }
  }
}
