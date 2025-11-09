import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/config/api_constants.dart';
import '../../models/api_response.dart';
import '../../models/languages/language_model.dart';
import '../../models/languages/language_list_response.dart';
import '../../models/languages/learn_language_list_response.dart';
import '../../models/languages/speak_language_list_response.dart';

class LanguageService {
  final ApiClient apiClient;

  LanguageService(this.apiClient);

  /// all languages
  Future<ApiResponse<LanguageListResponse>> getLanguages({
    String lang = 'vi',
    int pageNumber = -1,
    int pageSize = -1,
    required String token,
  }) async {
    try {
      final response = await apiClient.get(
        '${ApiConstants.languages}?lang=$lang&pageNumber=$pageNumber&pageSize=$pageSize',
        headers: {ApiConstants.headerAuthorization: 'Bearer $token'},
      );

      final json = response.data as Map<String, dynamic>;
      return ApiResponse.fromJson(
        json,
            (data) => LanguageListResponse.fromJson(json),
      );
    } on DioError catch (e) {
      rethrow;
    }
  }

  /// language by id
  Future<ApiResponse<LanguageModel>> getLanguageById(String id, String token) async {
    try {
      final url = ApiConstants.languageById.replaceAll('{id}', id);
      final response = await apiClient.get(
        url,
        headers: {ApiConstants.headerAuthorization: 'Bearer $token'},
      );

      final json = response.data as Map<String, dynamic>;
      return ApiResponse.fromJson(json, (data) => LanguageModel.fromJson(json['data']));
    } on DioError catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<SpeakLanguageListResponse>> getSpeakingLanguagesMeAll({
    String lang = 'vi',
    int pageNumber = -1,
    int pageSize = -1,
    required String token,
  }) async {
    final response = await apiClient.get(
      '${ApiConstants.speakingLanguagesMeAll}?lang=$lang&pageNumber=$pageNumber&pageSize=$pageSize',
      headers: {ApiConstants.headerAuthorization: 'Bearer $token'},
    );

    final json = response.data as Map<String, dynamic>;
    return ApiResponse.fromJson(
      json,
          (data) => SpeakLanguageListResponse.fromJson(json),
    );
  }

  Future<ApiResponse<LearnLanguageListResponse>> getLearningLanguagesMeAll({
    String lang = 'vi',
    int pageNumber = -1,
    int pageSize = -1,
    required String token,
  }) async {
    final response = await apiClient.get(
      '${ApiConstants.learningLanguagesMeAll}?lang=$lang&pageNumber=$pageNumber&pageSize=$pageSize',
      headers: {ApiConstants.headerAuthorization: 'Bearer $token'},
    );

    final json = response.data as Map<String, dynamic>;
    return ApiResponse.fromJson(
      json,
          (data) => LearnLanguageListResponse.fromJson(json),
    );
  }

  Future<ApiResponse<LearnLanguageListResponse>> getLearningLanguagesMe({
    String lang = 'vi',
    int pageNumber = -1,
    int pageSize = -1,
    required String token,
  }) async {
    final response = await apiClient.get(
      '${ApiConstants.learningLanguagesMe}?lang=$lang&pageNumber=$pageNumber&pageSize=$pageSize',
      headers: {ApiConstants.headerAuthorization: 'Bearer $token'},
    );

    final json = response.data as Map<String, dynamic>;
    return ApiResponse.fromJson(
      json,
          (data) => LearnLanguageListResponse.fromJson(json),
    );
  }

  Future<ApiResponse<SpeakLanguageListResponse>> getSpeakingLanguagesMe({
    String lang = 'vi',
    int pageNumber = -1,
    int pageSize = -1,
    required String token,
  }) async {
    try {
      final response = await apiClient.get(
        '${ApiConstants.speakingLanguagesMe}?lang=$lang&pageNumber=$pageNumber&pageSize=$pageSize',
        headers: {ApiConstants.headerAuthorization: 'Bearer $token'},
      );

      final json = response.data as Map<String, dynamic>;
      return ApiResponse.fromJson(
        json,
            (data) => SpeakLanguageListResponse.fromJson(json),
      );
    } on DioError catch (e) {
      rethrow;
    }
  }

}
