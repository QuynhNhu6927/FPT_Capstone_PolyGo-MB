import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/config/api_constants.dart';
import '../../models/api_response.dart';
import '../../models/payment/cancel_deposit_model.dart';
import '../../models/payment/deposit_model.dart';
class PaymentService {
  final ApiClient apiClient;

  PaymentService(this.apiClient);

  Future<ApiResponse<DepositUrlResponse>> getDepositUrl({
    required String token,
    required DepositUrlRequest request,
  }) async {
    try {
      final response = await apiClient.post(
        ApiConstants.deposit,
        data: request.toJson(),
        headers: {
          ApiConstants.headerAuthorization: "Bearer $token",
          ApiConstants.headerContentType: ApiConstants.contentTypeJson,
        },
      );

      dynamic jsonData = response.data;
      if (jsonData is String) {
        jsonData = jsonDecode(jsonData);
      }

      final dataMap = jsonData["data"] ?? {};

      final deposit = DepositUrlResponse.fromJson(dataMap);

      return ApiResponse(
        data: deposit,
        message: jsonData["message"] ?? "Success",
        statusCode: response.statusCode,
      );
    } on DioError catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<CancelDepositResponse>> cancelDeposit({
    required String token,
    required CancelDepositRequest request,
  }) async {
    try {
      final response = await apiClient.post(
        ApiConstants.cancelDeposit,
        data: request.toJson(),
        headers: {
          ApiConstants.headerAuthorization: "Bearer $token",
          ApiConstants.headerContentType: ApiConstants.contentTypeJson,
        },
      );

      dynamic jsonData = response.data;
      if (jsonData is String) jsonData = jsonDecode(jsonData);

      final dataMap = jsonData["data"] ?? {};
      final cancelResponse = CancelDepositResponse.fromJson(dataMap);

      return ApiResponse(
        data: cancelResponse,
        message: jsonData["message"] ?? "Success",
        statusCode: response.statusCode,
      );
    } on DioError catch (e) {
      rethrow;
    }
  }
}
