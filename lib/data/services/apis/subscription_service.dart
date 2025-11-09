import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/config/api_constants.dart';
import '../../models/api_response.dart';
import '../../models/subscription/subscription_auto_renew_response.dart';
import '../../models/subscription/subscription_cancel_request.dart';
import '../../models/subscription/subscription_cancel_response.dart';
import '../../models/subscription/subscription_current_response.dart';
import '../../models/subscription/subscription_plan_list_response.dart';
import '../../models/subscription/subscription_request.dart';
import '../../models/subscription/subscription_response.dart';
import '../../models/transaction/wallet_transaction_list_response.dart';

class SubscriptionService {
  final ApiClient apiClient;

  SubscriptionService(this.apiClient);

  Future<ApiResponse<SubscriptionPlanListResponse>> getSubscriptionPlans({
    required String token,
    int pageNumber = 1,
    int pageSize = 10,
    String? lang,
  }) async {
    try {
      final query = {
        'pageNumber': pageNumber.toString(),
        'pageSize': pageSize.toString(),
        if (lang != null) 'lang': lang,
      };

      final response = await apiClient.get(
        ApiConstants.subscriptionPlans,
        queryParameters: query,
        headers: {
          ApiConstants.headerAuthorization: 'Bearer $token',
        },
      );

      final json = response.data as Map<String, dynamic>;
      return ApiResponse.fromJson(
        json,
            (data) => SubscriptionPlanListResponse.fromJson(json),
      );
    } on DioError catch (e) {
      if (e.response != null) {
       //
      }
      rethrow;
    }
  }

  Future<ApiResponse<SubscriptionResponse>> subscribe({
    required String token,
    required SubscriptionRequest request,
  }) async {
    try {
      final response = await apiClient.post(
        ApiConstants.subscribe,
        data: request.toJson(),
        headers: {
          ApiConstants.headerAuthorization: 'Bearer $token',
          ApiConstants.headerContentType: ApiConstants.contentTypeJson,
        },
      );

      final json = response.data as Map<String, dynamic>;
      return ApiResponse.fromJson(
        json,
            (data) => SubscriptionResponse.fromJson(data),
      );
    } on DioError catch (e) {
      // Nếu server trả về lỗi, parse message
      if (e.response != null && e.response?.data != null) {
        return ApiResponse<SubscriptionResponse>(
          data: null,
          message: e.response?.data['message'] ?? e.message,
          statusCode: e.response?.statusCode,
        );
      }
      rethrow;
    }
  }

  Future<ApiResponse<CurrentSubscription>> getCurrentSubscription({
    required String token,
  }) async {
    try {
      final response = await apiClient.get(
        ApiConstants.currentSubscription,
        headers: {
          ApiConstants.headerAuthorization: 'Bearer $token',
        },
      );

      final json = response.data as Map<String, dynamic>;
      // Lấy thẳng CurrentSubscription từ json['data']
      return ApiResponse.fromJson(
        json,
            (data) => CurrentSubscription.fromJson(data),
      );
    } on DioError catch (e) {
      if (e.response != null && e.response?.data != null) {
        return ApiResponse<CurrentSubscription>(
          data: null,
          message: e.response?.data['message'] ?? e.message,
          statusCode: e.response?.statusCode,
        );
      }
      rethrow;
    }
  }

  Future<ApiResponse<SubscriptionCancelResponse>> cancelSubscription({
    required String token,
    required SubscriptionCancelRequest request,
  }) async {
    try {
      final response = await apiClient.post(
        ApiConstants.cancelSubscription,
        data: request.toJson(),
        headers: {
          ApiConstants.headerAuthorization: 'Bearer $token',
          ApiConstants.headerContentType: ApiConstants.contentTypeJson,
        },
      );

      final json = response.data as Map<String, dynamic>;
      return ApiResponse.fromJson(
        json,
            (data) => SubscriptionCancelResponse.fromJson(data),
      );
    } on DioError catch (e) {
      if (e.response != null && e.response?.data != null) {
        return ApiResponse<SubscriptionCancelResponse>(
          data: null,
          message: e.response?.data['message'] ?? e.message,
          statusCode: e.response?.statusCode,
        );
      }
      rethrow;
    }
  }

  Future<ApiResponse<SubscriptionAutoRenewResponse>> updateAutoRenew({
    required String token,
    required bool autoRenew,
  }) async {
    try {
      final url = "${ApiConstants.updateAutoRenew}?autoRenew=$autoRenew";

      final response = await apiClient.put(
        url,
        headers: {
          ApiConstants.headerAuthorization: 'Bearer $token',
          ApiConstants.headerContentType: ApiConstants.contentTypeJson,
        },
      );

      final json = response.data as Map<String, dynamic>;
      return ApiResponse.fromJson(
        json,
            (data) => SubscriptionAutoRenewResponse.fromJson(data),
      );
    } on DioError catch (e) {
      if (e.response != null && e.response?.data != null) {
        return ApiResponse<SubscriptionAutoRenewResponse>(
          data: null,
          message: e.response?.data['message'] ?? e.message,
          statusCode: e.response?.statusCode,
        );
      }
      rethrow;
    }
  }

  Future<ApiResponse<WalletTransactionListResponse>> getWalletTransactions({
    required String token,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await apiClient.get(
        ApiConstants.transactions,
        queryParameters: {
          'pageNumber': pageNumber.toString(),
          'pageSize': pageSize.toString(),
        },
        headers: {
          ApiConstants.headerAuthorization: 'Bearer $token',
        },
      );

      final json = response.data as Map<String, dynamic>;
      return ApiResponse.fromJson(
        json,
            (data) => WalletTransactionListResponse.fromJson(json),
      );
    } on DioError catch (e) {
      if (e.response != null && e.response?.data != null) {
        return ApiResponse<WalletTransactionListResponse>(
          data: null,
          message: e.response?.data['message'] ?? e.message,
          statusCode: e.response?.statusCode,
        );
      }
      rethrow;
    }
  }


}
