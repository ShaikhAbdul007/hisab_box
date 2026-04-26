abstract class BaseClient {
  Future<dynamic> getData({required String url,Map<String, dynamic> body});
  Future<dynamic> postData({
    required String url,
    required Map<String, dynamic> body,
  });
  Future<dynamic> putData({
    required String url,
    required Map<String, dynamic> body,
  });
  Future<dynamic> deleteData({
    required String url,
    required Map<String, dynamic> body,
  });
  Future<dynamic> postMultipartRequestData({
    required String url,
    required Map<String, String> body,
    bool requiresAuth = true,
  });
}