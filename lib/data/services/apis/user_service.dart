import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/config/api_constants.dart';
import '../../models/api_response.dart';
import '../../models/user/profile_setup_request.dart';
import '../../models/user/update_profile_request.dart';
import '../../models/user/update_userinfo_request.dart';
import '../../models/user/user_all_response.dart';
import '../../models/user/user_by_id_response.dart';
import '../../models/user/user_matching_response.dart';

class UserService {
  final ApiClient apiClient;

  UserService(this.apiClient);

  /// profile-setup
  Future<ApiResponse<void>> profileSetup(String token, ProfileSetupRequest req) async {
    try {
      final response = await apiClient.put(
        ApiConstants.profileSetup,
        data: req.toJson(),
        headers: {
          ApiConstants.headerAuthorization: 'Bearer $token',
        },
      );

      final json = response.data as Map<String, dynamic>;
      return ApiResponse.fromJson(json, (_) => null);
    } on DioError catch (e) {
      if (e.response != null) {
        // print('Profile setup error: ${e.response?.data}');
      }
      rethrow;
    }
  }

  Future<ApiResponse<void>> updateProfile({
    required String token,
    required UpdateProfileRequest req,
  }) async {
    try {
      final response = await apiClient.put(
        ApiConstants.updateProfile,
        data: req.toJson(),
        headers: {ApiConstants.headerAuthorization: 'Bearer $token'},
      );
      return ApiResponse.fromJson(response.data as Map<String, dynamic>, (_) => null);
    } on DioError catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<void>> updateUserInfo({
    required String token,
    required UpdateInfoRequest req,
  }) async {
    try {
      final response = await apiClient.put(
        ApiConstants.userInfo,
        data: req.toJson(),
        headers: {
          ApiConstants.headerAuthorization: 'Bearer $token',
          ApiConstants.headerContentType: ApiConstants.contentTypeJson,
        },
      );

      return ApiResponse.fromJson(response.data as Map<String, dynamic>, (_) => null);
    } on DioError catch (e) {
      if (e.response != null) {
        //
      }
      rethrow;
    }
  }

  Future<ApiResponse<UserMatchingResponse>> getMatchingUsers(String token, {String lang = 'vi'}) async {
    try {
      final response = await apiClient.get(
        ApiConstants.userMatching,
        queryParameters: {'lang': lang},
        headers: {
          ApiConstants.headerAuthorization: 'Bearer $token',
        },
      );

      final json = response.data as Map<String, dynamic>;
      return ApiResponse.fromJson(json, (data) => UserMatchingResponse.fromJson(data));
    } on DioError catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<UserAllResponse>> getAllUsers(
      String token, {
        String lang = 'en',
        int pageNumber = 1,
        int pageSize = 20,
        String? name,
      }) async {
    try {
      final response = await apiClient.get(
        ApiConstants.usersAll,
        queryParameters: {
          'lang': lang,
          'pageNumber': pageNumber,
          'pageSize': pageSize,
          if (name != null && name.isNotEmpty) 'name': name,
        },
        headers: {
          ApiConstants.headerAuthorization: 'Bearer $token',
        },
      );

      final json = response.data as Map<String, dynamic>;
      return ApiResponse.fromJson(json, (data) => UserAllResponse.fromJson(json));
    } on DioError catch (e) {
      rethrow;
    }
  }

  /// Get user by id
  Future<ApiResponse<UserByIdResponse>> getUserById(String token, String id, {String lang = 'en'}) async {
    try {
      final endpoint = ApiConstants.userById.replaceFirst('{id}', id);
      final response = await apiClient.get(
        endpoint,
        queryParameters: {'lang': lang},
        headers: {
          ApiConstants.headerAuthorization: 'Bearer $token',
        },
      );

      final json = response.data as Map<String, dynamic>;
      return ApiResponse.fromJson(json, (data) => UserByIdResponse.fromJson(data));
    } on DioError catch (e) {
      rethrow;
    }
  }

}
