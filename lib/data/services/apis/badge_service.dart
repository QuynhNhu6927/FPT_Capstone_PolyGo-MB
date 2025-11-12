import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/config/api_constants.dart';
import '../../models/api_response.dart';
import '../../models/badges/badge_list_response.dart';

class BadgeService {
  final ApiClient apiClient;

  BadgeService(this.apiClient);

  /// Get all badges (me-all)
  Future<ApiResponse<BadgeListResponse>> getMyBadgesAll({
    required String token,
    String lang = 'en',
    int pageNumber = -1,
    int pageSize = -1,
  }) async {
    try {
      final response = await apiClient.get(
        '${ApiConstants.badgesMeAll}?lang=$lang&pageNumber=$pageNumber&pageSize=$pageSize',
        headers: {ApiConstants.headerAuthorization: 'Bearer $token'},
      );

      final json = response.data as Map<String, dynamic>;
      return ApiResponse.fromJson(
        json,
            (data) => BadgeListResponse.fromJson(json),
      );
    } on DioError catch (e) {
      rethrow;
    }
  }

  /// Get badges that user already owns (me)
  Future<ApiResponse<BadgeListResponse>> getMyBadges({
    required String token,
    String lang = 'en',
    int pageNumber = -1,
    int pageSize = -1,
  }) async {
    try {
      final response = await apiClient.get(
        '${ApiConstants.badgesMe}?lang=$lang&pageNumber=$pageNumber&pageSize=$pageSize',
        headers: {ApiConstants.headerAuthorization: 'Bearer $token'},
      );

      final json = response.data as Map<String, dynamic>;
      return ApiResponse.fromJson(
        json,
            (data) => BadgeListResponse.fromJson(json),
      );
    } on DioError catch (e) {
      rethrow;
    }
  }
}
