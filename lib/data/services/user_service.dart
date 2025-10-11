import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../../core/config/api_constants.dart';
import '../models/api_response.dart';
import '../models/user/profile_setup_request.dart';
import '../models/user/update_profile_request.dart';

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
        print('Profile setup error: ${e.response?.data}');
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
}
