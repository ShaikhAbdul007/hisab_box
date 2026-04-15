import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:http/http.dart' as http;
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
  Future postMultipartRequestData({
    required String url,
    required Map<String, String> body,
    String? fileField,
    File? file,
    Uint8List? fileBytes,
    String? fileName,
  }) async {
    String? token = checkingTokenExpireOrNot();

    var request = http.MultipartRequest('POST', Uri.parse(url));

    // headers
    request.headers['Accept'] = 'application/json';
    if (token != null) request.headers['Authorization'] = 'Bearer $token';

    // add normal fields
    request.fields.addAll(body);

    // add file
    if (fileField != null) {
      if (!kIsWeb && file != null) {
        // Mobile
        request.files.add(
          await http.MultipartFile.fromPath(
            fileField,
            file.path,
            filename: fileName ?? file.path.split('/').last,
          ),
        );
      } else if (kIsWeb && fileBytes != null) {
        // Web
        request.files.add(
          http.MultipartFile.fromBytes(
            fileField,
            fileBytes,
            filename: fileName ?? 'file.png',
          ),
        );
      } else {
        throw Exception('File data missing for multipart request');
      }
    }
    AppLogger.info(
      ''' url: $url ,body: $body, filename:$fileName, fileBytes:$fileBytes,fileField:$fileField, token: $token''',
    );
    // send request
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    return await fetchResponse(response);
  }

  Future<dynamic> fetchResponse(http.Response response) async {
    dynamic data;
    switch (response.statusCode) {
      case 200:
        data = jsonDecode(response.body);
        break;
      case 201:
        data = jsonDecode(response.body);
        break;
      case 400:
        data = jsonDecode(response.body);
        break;
      case 401:
        data = jsonDecode(response.body);
        break;
      case 404:
        data = jsonDecode(response.body);
        break;
      case 500:
        data = jsonDecode(response.body);
        break;
      default:
        {
          data = somethingWentWrong;
        }
    }
    return data;
  }

  String? checkingTokenExpireOrNot() {
    var token = retriveToken();
    return token;
  }
}
