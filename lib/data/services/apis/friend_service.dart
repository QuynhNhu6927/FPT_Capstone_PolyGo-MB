import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/config/api_constants.dart';
import '../../models/api_response.dart';
import '../../models/friends/friend_model.dart';
import '../../models/friends/friend_request_model.dart';

class FriendService {
  final ApiClient apiClient;

  FriendService(this.apiClient);

  /// Send friend request
  Future<ApiResponse<FriendRequestResponse>> sendFriendRequest({
    required String token,
    required FriendRequestModel request,
  }) async {
    try {
      final response = await apiClient.post(
        ApiConstants.requestFriend,
        data: request.toJson(),
        headers: {
          ApiConstants.headerAuthorization: 'Bearer $token',
          ApiConstants.headerContentType: ApiConstants.contentTypeJson,
        },
      );

      final json = response.data as Map<String, dynamic>;
      return ApiResponse.fromJson(
        json,
            (data) => FriendRequestResponse.fromJson(json['data'] ?? {}),
      );
    } on DioError catch (e) {
      rethrow;
    }
  }

  /// Cancel friend request
  Future<ApiResponse<FriendRequestResponse>> cancelFriendRequest({
    required String token,
    required String receiverId,
  }) async {
    try {
      final url = ApiConstants.requestCancel.replaceAll("{receiverId}", receiverId);

      final response = await apiClient.delete(
        url,
        headers: {
          ApiConstants.headerAuthorization: 'Bearer $token',
        },
      );

      final json = response.data as Map<String, dynamic>;
      return ApiResponse.fromJson(
        json,
            (data) => FriendRequestResponse.fromJson(json),
      );
    } on DioError catch (e) {
      rethrow;
    }
  }

  /// Accept friend request
  Future<ApiResponse<dynamic>> acceptFriendRequest({
    required String token,
    required String senderId,
  }) async {
    try {
      final response = await apiClient.post(
        ApiConstants.requestAccept,
        data: {'senderId': senderId},
        headers: {
          ApiConstants.headerAuthorization: 'Bearer $token',
          ApiConstants.headerContentType: ApiConstants.contentTypeJson,
        },
      );

      final json = response.data as Map<String, dynamic>;
      return ApiResponse.fromJson(json, (data) => data);
    } on DioError catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<dynamic>> rejectFriendRequest({
    required String token,
    required String senderId,
  }) async {
    try {
      final response = await apiClient.post(
        ApiConstants.requestReject,
        data: {'senderId': senderId},
        headers: {
          ApiConstants.headerAuthorization: 'Bearer $token',
          ApiConstants.headerContentType: ApiConstants.contentTypeJson,
        },
      );

      final json = response.data as Map<String, dynamic>;
      return ApiResponse.fromJson(json, (data) => data);
    } on DioError catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<dynamic>> unfriend({
    required String token,
    required String friendId,
  }) async {
    final url = ApiConstants.unFriend.replaceAll("{friendId}", friendId);

    final response = await apiClient.delete(
      url,
      headers: {
        ApiConstants.headerAuthorization: 'Bearer $token',
      },
    );

    final json = response.data as Map<String, dynamic>;
    return ApiResponse.fromJson(json, (data) => data);
  }


  Future<ApiResponse<List<FriendModel>>> getAllFriends({
    required String token,
    int? pageNumber,
    int? pageSize,
    String? name,
    String? lang,
  }) async {
    try {
      final response = await apiClient.get(
        ApiConstants.allFriends,
        queryParameters: {
          if (pageNumber != null) 'pageNumber': pageNumber,
          if (pageSize != null) 'pageSize': pageSize,
          if (name != null && name.isNotEmpty) 'name': name,
          if (lang != null && lang.isNotEmpty) 'lang': lang,
        },
        headers: {
          ApiConstants.headerAuthorization: 'Bearer $token',
        },
      );

      final json = response.data as Map<String, dynamic>;
      final items = (json['data']?['items'] as List<dynamic>?)
          ?.map((e) => FriendModel.fromJson(e))
          .toList() ??
          [];

      return ApiResponse.fromJson(json, (data) => items);
    } on DioError catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<List<FriendModel>>> getAllRequest({
    required String token,
    int? pageNumber,
    int? pageSize,
    String? name,
    String? lang,
  }) async {
    try {
      final response = await apiClient.get(
        ApiConstants.allRequest,
        queryParameters: {
          if (pageNumber != null) 'pageNumber': pageNumber,
          if (pageSize != null) 'pageSize': pageSize,
          if (name != null && name.isNotEmpty) 'name': name,
          if (lang != null && lang.isNotEmpty) 'lang': lang,
        },
        headers: {
          ApiConstants.headerAuthorization: 'Bearer $token',
        },
      );

      final json = response.data as Map<String, dynamic>;
      final items = (json['data']?['items'] as List<dynamic>?)
          ?.map((e) => FriendModel.fromJson(e))
          .toList() ??
          [];

      return ApiResponse.fromJson(json, (data) => items);
    } on DioError catch (e) {
      rethrow;
    }
  }
}
