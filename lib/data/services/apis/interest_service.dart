import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/config/api_constants.dart';
import '../../models/api_response.dart';
import '../../models/interests/interest_model.dart';
import '../../models/interests/interest_list_response.dart';
import '../../models/interests/me_interests_list_response.dart';

class InterestService {
  final ApiClient apiClient;

  InterestService(this.apiClient);

  /// Get all interests
  Future<ApiResponse<InterestListResponse>> getInterests({
    String lang = 'vi',
    int pageNumber = -1,
    int pageSize = -1,
    required String token,
  }) async {
    try {
      final response = await apiClient.get(
        '${ApiConstants.interests}?lang=$lang&pageNumber=$pageNumber&pageSize=$pageSize',
        headers: {ApiConstants.headerAuthorization: 'Bearer $token'},
      );

      final json = response.data as Map<String, dynamic>;
      return ApiResponse.fromJson(
        json,
            (data) => InterestListResponse.fromJson(json),
      );
    } on DioError catch (e) {
      rethrow;
    }
  }

  /// Get interest by ID
  Future<ApiResponse<InterestModel>> getInterestById(String id, String token) async {
    try {
      final url = ApiConstants.interestById.replaceAll('{id}', id);
      final response = await apiClient.get(
        url,
        headers: {ApiConstants.headerAuthorization: 'Bearer $token'},
      );

      final json = response.data as Map<String, dynamic>;
      return ApiResponse.fromJson(json, (data) => InterestModel.fromJson(json['data']));
    } on DioError catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<MeInterestListResponse>> getMeInterests({
    required String token,
    String lang = 'vi',
    int pageNumber = -1,
    int pageSize = -1,
  }) async {
    try {
      final response = await apiClient.get(
        '${ApiConstants.interestsMeAll}?lang=$lang&pageNumber=$pageNumber&pageSize=$pageSize',
        headers: {ApiConstants.headerAuthorization: 'Bearer $token'},
      );

      final json = response.data as Map<String, dynamic>;
      return ApiResponse.fromJson(
        json,
            (data) => MeInterestListResponse.fromJson(json),
      );
    } on DioError catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<MeInterestListResponse>> getInterestsMe({
    required String token,
    String lang = 'vi',
    int pageNumber = -1,
    int pageSize = -1,
  }) async {
    try {
      final response = await apiClient.get(
        '${ApiConstants.interestsMe}?lang=$lang&pageNumber=$pageNumber&pageSize=$pageSize',
        headers: {ApiConstants.headerAuthorization: 'Bearer $token'},
      );

      final json = response.data as Map<String, dynamic>;
      return ApiResponse.fromJson(
        json,
            (data) => MeInterestListResponse.fromJson(json),
      );
    } on DioError catch (e) {
      rethrow;
    }
  }

}

