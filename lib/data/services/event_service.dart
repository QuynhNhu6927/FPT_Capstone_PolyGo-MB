import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../../core/config/api_constants.dart';
import '../models/api_response.dart';
import '../models/events/coming_event_list_response.dart';
import '../models/events/event_list_response.dart';
import '../models/events/event_register_request.dart';

class EventService {
  final ApiClient apiClient;

  EventService(this.apiClient);

  Future<ApiResponse<EventListResponse>> getMatchingEvents({
    required String token,
    String lang = 'en',
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await apiClient.get(
        '${ApiConstants.eventsMatching}?lang=$lang&pageNumber=$pageNumber&pageSize=$pageSize',
        headers: {ApiConstants.headerAuthorization: 'Bearer $token'},
      );

      final json = response.data as Map<String, dynamic>;
      return ApiResponse.fromJson(
        json,
            (data) => EventListResponse.fromJson(data),
      );
    } on DioError catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<ComingEventListResponse>> getUpcomingEvents({
    required String token,
    String lang = 'en',
    int pageNumber = 1,
    int pageSize = 10,
    List<String>? languageIds,
    List<String>? interestIds,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'lang': lang,
        'pageNumber': pageNumber,
        'pageSize': pageSize,
      };

      if (languageIds != null && languageIds.isNotEmpty) {
        queryParameters['languageIds'] = languageIds;
      }
      if (interestIds != null && interestIds.isNotEmpty) {
        queryParameters['interestIds'] = interestIds;
      }

      final response = await apiClient.get(
        ApiConstants.eventsComing,
        queryParameters: queryParameters,
        headers: {ApiConstants.headerAuthorization: 'Bearer $token'},
      );

      final json = response.data as Map<String, dynamic>;
      return ApiResponse.fromJson(
        json,
            (data) => ComingEventListResponse.fromJson(data),
      );
    } on DioError catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<EventRegisterResponse>> registerEvent({
    required String token,
    required EventRegisterRequest request,
  }) async {
    try {
      final response = await apiClient.post(
        ApiConstants.eventRegister,
        data: request.toJson(),
        headers: {ApiConstants.headerAuthorization: 'Bearer $token'},
      );

      final json = response.data as Map<String, dynamic>;
      return ApiResponse.fromJson(
        json,
            (data) => EventRegisterResponse.fromJson(data),
      );
    } on DioError catch (e) {
      rethrow;
    }
  }
}
