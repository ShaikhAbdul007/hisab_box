import 'dart:convert';

import 'package:inventory/module/product_details/model/add_product_model.dart';
import 'package:inventory/module/product_details/model/create_gr_model.dart';
import 'package:inventory/module/product_details/model/go_down_stock_transfer_to_shop_model.dart';
import 'package:inventory/network/api_endpoint.dart';
import 'package:inventory/network/networking.dart';

class ProductRepo {
  Networking networking = Networking();

  Future<AddProductModel> addProduct({required dynamic body}) async {
    try {
      final response = await networking.postData(
        url: '${ApiEndPoint.fullBaseUrl}${ApiEndPoint.addProduct}',
        body: body,
      );
      return AddProductModel.fromJson(response);
    } catch (e) {
      return AddProductModel(success: false, msg: e.toString());
    }
  }

  Future<AddProductModel> addLoosedProduct({required dynamic body}) async {
    try {
      final response = await networking.postData(
        url: '${ApiEndPoint.fullBaseUrl}${ApiEndPoint.addLoosedProduct}',
        body: body,
      );
      return AddProductModel.fromJson(response);
    } catch (e) {
      return AddProductModel(success: false, msg: e.toString());
    }
  }

  Future<CreateGrModel> addGrProduct({required dynamic body}) async {
    try {
      final response = await networking.postData(
        url:
            '${ApiEndPoint.fullBaseUrl}${ApiEndPoint.baseGr}${ApiEndPoint.createGr}',
        body: body,
      );
      return CreateGrModel.fromJson(response);
    } catch (e) {
      return CreateGrModel(success: false, msg: e.toString());
    }
  }

  Future<AddProductModel> updatePacketProduct({
    required dynamic body,
    required String productId,
  }) async {
    try {
      final response = await networking.patchData(
        url: '${ApiEndPoint.fullBaseUrl}${ApiEndPoint.getProducts}/$productId',
        body: body,
      );
      return AddProductModel.fromJson(response);
    } catch (e) {
      return AddProductModel(success: false, msg: e.toString());
    }
  }

  Future<AddProductModel> updateLoosePacketProduct({
    required dynamic body,
  }) async {
    try {
      final response = await networking.patchData(
        url: '${ApiEndPoint.fullBaseUrl}${ApiEndPoint.updateLoosedProduct}',
        body: body,
      );
      return AddProductModel.fromJson(response);
    } catch (e) {
      return AddProductModel(success: false, msg: e.toString());
    }
  }

  Future<TransferToShopModel> requestStockTransfer({
    required dynamic body,
  }) async {
    try {
      final response = await networking.postData(
        url: '${ApiEndPoint.fullBaseUrl}${ApiEndPoint.transferGodownToShop}',
        body: body,
      );
      return TransferToShopModel.fromJson(jsonDecode(response));
    } catch (e) {
      return TransferToShopModel(success: false, message: e.toString());
    }
  }
}
