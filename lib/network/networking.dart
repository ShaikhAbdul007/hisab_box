import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // For MediaType
import 'package:inventory/helper/app_message.dart';
import 'package:inventory/helper/logger.dart';
import 'package:inventory/network/api_endpoint.dart';
import 'package:inventory/network/base_client.dart';
import '../cache_manager/cache_manager.dart';

class Networking extends BaseClient with CacheManager {
  Networking._();

  static final Networking _instance = Networking._();

  factory Networking() => _instance;
  @override
  Future getData({required String url, Map<String, dynamic>? body}) async {
    dynamic jsonGetResposne;
    String? token;
    token = checkingTokenExpireOrNot();
    AppLogger.info(''' url: $url ,token: $token''');
    try {
      var response = await http.get(
        Uri.parse(url).replace(queryParameters: body),
        headers: <String, String>{
          'Content-Type': ApiEndPoint.contentType,
          'Authorization': "Bearer $token",
        },
      );

      jsonGetResposne = await fetchResponse(response);
    } on SocketException {
      return Future.error(internetError);
    } on HttpException {
      return Future.error(httpError);
    } on Exception catch (e) {
      return Future.error(e);
    }
    return jsonGetResposne;
  }

  @override
  Future postData({
    required String url,
    required Map<String, dynamic> body,
  }) async {
    dynamic jsonPostResponse;
    String? token;
    token = checkingTokenExpireOrNot();
    AppLogger.info(''' url: $url ,body: $body,token: $token ''');
    try {
      var response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          //'Accept': ApiEndPoint.accept,
          'Content-Type': ApiEndPoint.contentType,
          'Authorization': "Bearer $token",
        },
        body: jsonEncode(body),
      );

      jsonPostResponse = await fetchResponse(response);
    } on SocketException {
      return Future.error(internetError);
    } on HttpException {
      return Future.error(httpError);
    } on Exception catch (e) {
      return Future.error(e);
    }
    return jsonPostResponse;
  }

  @override
  Future deleteData({required String url, Map<String, dynamic>? body}) async {
    dynamic jsonDeleteResponse;
    String? token;
    token = checkingTokenExpireOrNot();
    AppLogger.info(''' url: $url ,body: $body,token: $token ''');
    try {
      var response = await http.delete(
        Uri.parse(url),
        headers: <String, String>{
          'Accept': ApiEndPoint.accept,
          'Content-Type': ApiEndPoint.contentType,
          'Authorization': "Bearer $token",
        },
        // body: jsonEncode(body),
      );

      jsonDeleteResponse = await fetchResponse(response);
    } on SocketException {
      return Future.error(internetError);
    } on HttpException {
      return Future.error(httpError);
    } on Exception catch (e) {
      return Future.error(e);
    }
    return jsonDeleteResponse;
  }

  @override
  Future putData({required String url, Map<String, dynamic>? body}) async {
    dynamic jsonPutResponse;
    String? token;
    token = checkingTokenExpireOrNot();
    AppLogger.info(''' url: $url ,body: $body,token: $token ''');
    try {
      var response = await http.put(
        Uri.parse(url),
        headers: <String, String>{
          'Accept': ApiEndPoint.accept,
          'Content-Type': ApiEndPoint.contentType,
          'Authorization': "Bearer $token",
        },
        body: jsonEncode(body),
      );

      jsonPutResponse = await fetchResponse(response);
    } on SocketException {
      return Future.error(internetError);
    } on HttpException {
      return Future.error(httpError);
    } on Exception catch (e) {
      return Future.error(e);
    }
    return jsonPutResponse;
  }

  @override
  Future patchData({
    required String url,
    required Map<String, dynamic> body,
  }) async {
    dynamic jsonPutResponse;
    String? token;
    token = checkingTokenExpireOrNot();
    AppLogger.info(''' url: $url ,body: $body,token: $token ''');
    try {
      var response = await http.patch(
        Uri.parse(url),
        headers: <String, String>{
          'Accept': ApiEndPoint.accept,
          'Content-Type': ApiEndPoint.contentType,
          'Authorization': "Bearer $token",
        },
        body: jsonEncode(body),
      );

      jsonPutResponse = await fetchResponse(response);
    } on SocketException {
      return Future.error(internetError);
    } on HttpException {
      return Future.error(httpError);
    } on Exception catch (e) {
      return Future.error(e);
    }
    return jsonPutResponse;
  }

  @override
  Future<dynamic> postMultipartRequestData({
    required String url,
    required Map<String, String> body,
    String? fileField,
    File? file,
    Uint8List? fileBytes,
    String? fileName,
    bool requiresAuth = true, // Add this parameter
  }) async {
    try {
      String? token = requiresAuth ? checkingTokenExpireOrNot() : null;

      final request = http.MultipartRequest('POST', Uri.parse(url));

      /// Let MultipartRequest generate Content-Type with boundary automatically.
      request.headers['Accept'] = '*/*';
      request.headers['Cache-Control'] = 'no-cache';

      if (requiresAuth && token != null && token.trim().isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      /// normal form fields
      request.fields.addAll(body);

      /// file upload (optional)
      if (fileField != null && file != null && file.existsSync()) {
        /// Mobile / iOS / Android / Simulator
        if (!kIsWeb) {
          // Get file extension to determine content type
          final extension = file.path.split('.').last.toLowerCase();
          String contentType = 'image/jpeg'; // default

          if (extension == 'png') {
            contentType = 'image/png';
          } else if (extension == 'jpg' || extension == 'jpeg') {
            contentType = 'image/jpeg';
          } else if (extension == 'gif') {
            contentType = 'image/gif';
          } else if (extension == 'webp') {
            contentType = 'image/webp';
          }

          request.files.add(
            await http.MultipartFile.fromPath(
              fileField,
              file.path,
              filename: fileName ?? file.path.split('/').last,
              contentType: MediaType.parse(contentType),
            ),
          );
        }
        /// Flutter Web
        else if (kIsWeb && fileBytes != null) {
          request.files.add(
            http.MultipartFile.fromBytes(
              fileField,
              fileBytes,
              filename: fileName ?? 'upload_file.png',
              contentType: MediaType.parse('image/png'),
            ),
          );
        }
      }

      AppLogger.info('''
url: $url
body: $body
fileField: $fileField
fileName: $fileName
token: $token
requiresAuth: $requiresAuth
''');

      /// send request
      final streamedResponse = await request.send();

      final response = await http.Response.fromStream(streamedResponse);

      AppLogger.info('''
statusCode: ${response.statusCode}
responseBody: ${response.body}
headers: ${response.headers}
requestHeaders: ${request.headers}
''');

      return await fetchResponse(response);
    } catch (e) {
      AppLogger.info("🚨 Multipart Request Error: $e");
      rethrow;
    }
  }

  Future<dynamic> fetchResponse(http.Response response) async {
    final body = response.body.trim();

    if (body.isEmpty) {
      return {
        'success': false,
        'msg': 'Empty response from server (${response.statusCode})',
      };
    }

    try {
      return jsonDecode(body);
    } on FormatException {
      final contentType = response.headers['content-type'] ?? '';
      final lowerBody = body.toLowerCase();
      final isHtmlResponse =
          contentType.contains('text/html') ||
          lowerBody.startsWith('<!doctype html') ||
          lowerBody.startsWith('<html');

      return {
        'success': false,
        'msg':
            isHtmlResponse
                ? 'Server error (${response.statusCode}). Received HTML instead of JSON.'
                : 'Unexpected server response (${response.statusCode}).',
        if (kDebugMode) 'raw_response': body,
      };
    }
  }

  String? checkingTokenExpireOrNot() {
    var token = retriveToken();
    return token;
  }
}
