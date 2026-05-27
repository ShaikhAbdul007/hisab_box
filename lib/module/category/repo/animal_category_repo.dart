import 'package:inventory/module/category/model/category_model.dart';
import 'package:inventory/network/api_endpoint.dart';
import 'package:inventory/network/networking.dart';

class AnimalCategoryRepo {
  Networking networking = Networking();

  Future<CategoryModel> getAnimalCategory({
    int page = 1,
    int pageLimit = 20,
  }) async {
    try {
      final response = await networking.getData(
        url:
            '${ApiEndPoint.fullBaseUrl}${ApiEndPoint.getAnimalCategories}?page=$page&limit=$pageLimit',
      );
      return CategoryModel.fromJson(response);
    } catch (e) {
      return CategoryModel(msg: e.toString(), success: false);
    }
  }

  Future<CategoryModel> createAnimalCategory({
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await networking.postData(
        url: '${ApiEndPoint.fullBaseUrl}${ApiEndPoint.createAnimalCategory}',
        body: body,
      );
      return CategoryModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<CategoryModel> deleteAnimalCategory({required String id}) async {
    try {
      final response = await networking.deleteData(
        url:
            '${ApiEndPoint.fullBaseUrl}${ApiEndPoint.deleteAnimalCategory}/$id',
      );
      return CategoryModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}
