// services/gift_service.dart
import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/config/api_constants.dart';
import '../../models/api_response.dart';
import '../../models/gift/gift_accept_response.dart';
import '../../models/gift/gift_list_response.dart';
import '../../models/gift/gift_me_response.dart';
import '../../models/gift/gift_present_request.dart';
import '../../models/gift/gift_present_response.dart';
import '../../models/gift/gift_purchase_request.dart';
import '../../models/gift/gift_purchase_response.dart';
import '../../models/gift/gift_received_response.dart';

class GiftService {
  final ApiClient apiClient;

  GiftService(this.apiClient);

  Future<ApiResponse<GiftListResponse>> getGifts({
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
        ApiConstants.gifts,
        queryParameters: query,
        headers: {
          ApiConstants.headerAuthorization: 'Bearer $token',
        },
      );

      final json = response.data as Map<String, dynamic>;
      return ApiResponse.fromJson(
        json,
            (data) => GiftListResponse.fromJson(json),
      );
    } on DioError catch (e) {
      if (e.response != null) {
        //
      }
      rethrow;
    }
  }

  Future<ApiResponse<GiftPurchaseResponse>> purchaseGift({
    required String token,
    required GiftPurchaseRequest request,
  }) async {
    try {
      final response = await apiClient.post(
        ApiConstants.purchaseGift,
        data: request.toJson(),
        headers: {
          ApiConstants.headerAuthorization: 'Bearer $token',
          ApiConstants.headerContentType: ApiConstants.contentTypeJson,
        },
      );
      final json = response.data as Map<String, dynamic>;

      return ApiResponse.fromJson(
        json,
            (data) => GiftPurchaseResponse.fromJson(json['data']),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<GiftMeResponse>> getMyGifts({
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
        ApiConstants.myGifts,
        queryParameters: query,
        headers: {
          ApiConstants.headerAuthorization: 'Bearer $token',
        },
      );

      final json = response.data as Map<String, dynamic>;
      return ApiResponse.fromJson(
        json,
            (data) => GiftMeResponse.fromJson(json),
      );
    } on DioError catch (e) {
      if (e.response != null) {
        //
      }
      rethrow;
    }
  }

  Future<ApiResponse<GiftPresentResponse>> presentGift({
    required String token,
    required GiftPresentRequest request,
  }) async {
    try {
      final response = await apiClient.post(
        ApiConstants.presentGift,
        data: request.toJson(),
        headers: {
          ApiConstants.headerAuthorization: 'Bearer $token',
          ApiConstants.headerContentType: ApiConstants.contentTypeJson,
        },
      );

      final json = response.data as Map<String, dynamic>;
      return ApiResponse.fromJson(
        json,
            (data) => GiftPresentResponse.fromJson(json['data']),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<GiftReceivedResponse>> getReceivedGifts({
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
        ApiConstants.giftsReceived,
        queryParameters: query,
        headers: {
          ApiConstants.headerAuthorization: 'Bearer $token',
        },
      );

      final json = response.data as Map<String, dynamic>;
      return ApiResponse.fromJson(
        json,
            (data) => GiftReceivedResponse.fromJson(json),
      );
    } on DioError catch (e) {
      if (e.response != null) {
        //
      }
      rethrow;
    }
  }

  Future<ApiResponse<GiftAcceptResponse>> acceptReceivedGift({
    required String token,
    required String presentationId,
  }) async {
    try {
      final url = ApiConstants.giftsReceivedAccept.replaceAll("{presentationId}", presentationId);

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
            (data) => GiftAcceptResponse.fromJson(json['data']),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<GiftAcceptResponse>> rejectReceivedGift({
    required String token,
    required String presentationId,
  }) async {
    try {
      final url = ApiConstants.giftsReceivedReject.replaceAll("{presentationId}", presentationId);

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
            (data) => GiftAcceptResponse.fromJson(json['data']),
      );
    } catch (e) {
      rethrow;
    }
  }


}
