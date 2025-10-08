import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../../core/config/api_constants.dart';
import '../models/api_response.dart';
import '../models/profile/profile_setup_request.dart';

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
}
