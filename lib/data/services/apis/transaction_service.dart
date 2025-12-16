import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/config/api_constants.dart';
import '../../models/api_response.dart';
import '../../models/transaction/add_bank_request.dart';
import '../../models/transaction/delete_bank.dart';
import '../../models/transaction/send_inquiry_model.dart';
import '../../models/transaction/wallet_info_response.dart';
import '../../models/transaction/wallet_transaction_model.dart';
import '../../models/transaction/withdraw_confirm_request.dart';
import '../../models/transaction/withdraw_request_model.dart';

class TransactionService {
  final ApiClient apiClient;

  TransactionService(this.apiClient);

  Future<ApiResponse<WalletInfoResponse>> getWalletInfo({
    required String token,
  }) async {
    try {
      final response = await apiClient.get(
        ApiConstants.transactionWallet,
        headers: {
          ApiConstants.headerAuthorization: "Bearer $token",
        },
      );

      final json = response.data as Map<String, dynamic>;

      return ApiResponse.fromJson(
        json,
            (data) => WalletInfoResponse.fromJson(data),
      );
    } on DioError catch (e) {
      if (e.response != null && e.response?.data != null) {
        return ApiResponse<WalletInfoResponse>(
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
    String? description,
    String? transactionType,
    String? transactionMethod,
    String? transactionStatus,
    bool? isInquiry,
  }) async {
    try {
      final queryParams = {
        'pageNumber': pageNumber.toString(),
        'pageSize': pageSize.toString(),
      };

      if (description != null && description.isNotEmpty) {
        queryParams['description'] = description;
      }
      if (transactionType != null && transactionType.isNotEmpty) {
        queryParams['transactionType'] = transactionType;
      }
      if (transactionMethod != null && transactionMethod.isNotEmpty) {
        queryParams['transactionMethod'] = transactionMethod;
      }
      if (transactionStatus != null && transactionStatus.isNotEmpty) {
        queryParams['transactionStatus'] = transactionStatus;
      }
      if (isInquiry != null) {
        queryParams['isInquiry'] = isInquiry.toString();
      }

      final response = await apiClient.get(
        ApiConstants.transactions,
        queryParameters: queryParams,
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

  Future<ApiResponse<DeleteBankResponse>> deleteBankAccount({
    required String token,
    required String bankAccountId,
  }) async {
    try {
      final endpoint = ApiConstants.deleteBank
          .replaceAll("{bankAccountId}", bankAccountId);

      final response = await apiClient.delete(
        endpoint,
        headers: {
          ApiConstants.headerAuthorization: "Bearer $token",
        },
      );

      final json = response.data as Map<String, dynamic>;

      return ApiResponse.fromJson(
        json,
            (data) => DeleteBankResponse.fromJson(data),
      );

    } on DioError catch (e) {
      if (e.response != null && e.response?.data != null) {
        return ApiResponse<DeleteBankResponse>(
          data: null,
          message: e.response?.data['message'] ?? e.message,
          statusCode: e.response?.statusCode,
        );
      }
      rethrow;
    }
  }

  Future<ApiResponse<AddBankResponse>> addBankAccount({
    required String token,
    required AddBankRequest request,
  }) async {
    try {
      final response = await apiClient.post(
        ApiConstants.addBank,
        data: request.toJson(),
        headers: {
          ApiConstants.headerAuthorization: "Bearer $token",
        },
      );

      final json = response.data as Map<String, dynamic>;
      return ApiResponse.fromJson(
        json,
            (data) => AddBankResponse.fromJson(data),
      );
    } on DioError catch (e) {
      if (e.response != null && e.response?.data != null) {
        return ApiResponse<AddBankResponse>(
          data: null,
          message: e.response?.data['message'] ?? e.message,
          statusCode: e.response?.statusCode,
        );
      }
      rethrow;
    }
  }

  Future<ApiResponse<WithdrawResponse>> createWithdrawRequest({
    required String token,
    required WithdrawRequestModel request,
  }) async {
    try {
      final response = await apiClient.post(
        ApiConstants.withdraw,
        data: request.toJson(),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final json = response.data as Map<String, dynamic>;
      return ApiResponse.fromJson(
        json,
            (data) => WithdrawResponse.fromJson(data),
      );
    } on DioError catch (e) {
      if (e.response != null && e.response?.data != null) {
        return ApiResponse<WithdrawResponse>(
          data: null,
          message: e.response?.data['message'] ?? e.message,
          statusCode: e.response?.statusCode,
        );
      }
      rethrow;
    }
  }

  Future<ApiResponse<WithdrawConfirmResponse>> confirmWithdrawal({
    required String token,
    required WithdrawConfirmRequest request,
  }) async {
    try {
      final response = await apiClient.post(
        ApiConstants.withdrawConfirm,
        data: request.toJson(),
        headers: {
          ApiConstants.headerAuthorization: "Bearer $token",
        },
      );

      final json = response.data as Map<String, dynamic>;
      return ApiResponse.fromJson(
        json,
            (data) => WithdrawConfirmResponse.fromJson(data),
      );
    } on DioError catch (e) {
      if (e.response != null && e.response?.data != null) {
        return ApiResponse<WithdrawConfirmResponse>(
          data: null,
          message: e.response?.data['message'] ?? e.message,
          statusCode: e.response?.statusCode,
        );
      }
      rethrow;
    }
  }

  Future<ApiResponse<SendInquiryResponse>> sendInquiry({
    required String token,
    required String transactionId,
    required SendInquiryRequest request,
  }) async {
    try {
      final endpoint = ApiConstants.sendInquiry.replaceAll("{id}", transactionId);

      final response = await apiClient.post(
        endpoint,
        data: request.toJson(),
        headers: {
          ApiConstants.headerAuthorization: "Bearer $token",
        },
      );

      final json = response.data as Map<String, dynamic>;
      return ApiResponse.fromJson(
        json,
            (data) => SendInquiryResponse.fromJson(data),
      );
    } on DioError catch (e) {
      if (e.response != null && e.response?.data != null) {
        return ApiResponse<SendInquiryResponse>(
          data: null,
          message: e.response?.data['message'] ?? e.message,
          statusCode: e.response?.statusCode,
        );
      }
      rethrow;
    }
  }

  Future<ApiResponse<WalletTransaction>> getTransactionById({
    required String token,
    required String transactionId,
  }) async {
    try {
      final endpoint = ApiConstants.transactionById.replaceAll("{id}", transactionId);

      final response = await apiClient.get(
        endpoint,
        headers: {
          ApiConstants.headerAuthorization: "Bearer $token",
        },
      );

      final json = response.data as Map<String, dynamic>;

      return ApiResponse.fromJson(
        json,
            (data) => WalletTransaction.fromJson(data as Map<String, dynamic>),
      );
    } on DioError catch (e) {
      if (e.response != null && e.response?.data != null) {
        return ApiResponse<WalletTransaction>(
          data: null,
          message: e.response?.data['message'] ?? e.message,
          statusCode: e.response?.statusCode,
        );
      }
      rethrow;
    }
  }

}
