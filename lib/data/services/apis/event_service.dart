import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import '../../../core/api/api_client.dart';
import '../../../core/config/api_constants.dart';
import '../../models/api_response.dart';
import '../../models/events/coming_event_list_response.dart';
import '../../models/events/event_cancel_request.dart';
import '../../models/events/event_cancel_response.dart';
import '../../models/events/event_details_response.dart';
import '../../models/events/event_kick_request.dart';
import '../../models/events/event_list_response.dart';
import '../../models/events/event_model.dart';
import '../../models/events/event_my_rating_response.dart';
import '../../models/events/event_rating_item.dart';
import '../../models/events/event_rating_request.dart';
import '../../models/events/event_rating_response.dart';
import '../../models/events/event_register_request.dart';
import '../../models/events/event_update_rating_request.dart';
import '../../models/events/hosted_event_model.dart';
import '../../models/events/joined_event_list_response.dart';
import '../../models/events/update_event_status_request.dart';
import '../../models/events/update_event_status_response.dart';

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

  Future<ApiResponse<EventListResponse>> getUpcomingEvents({
    required String token,
    String lang = 'en',
    int pageNumber = 1,
    int pageSize = 10,
    List<String>? languageIds,
    List<String>? interestIds,
    bool? isFree,
  }) async {
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
    if (isFree != null) {
      queryParameters['isFree'] = isFree;
    }

    final response = await apiClient.get(
      ApiConstants.eventsComing,
      queryParameters: queryParameters,
      headers: {ApiConstants.headerAuthorization: 'Bearer $token'},
    );

    final json = response.data as Map<String, dynamic>;
    return ApiResponse.fromJson(
      json,
          (data) => EventListResponse.fromJson(data),
    );
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

  Future<ApiResponse<HostedEventListResponse>> getHostedEvents({
    required String token,
    String lang = 'en',
    int pageNumber = 1,
    int pageSize = 10,
    String? name,
    List<String>? languageIds,
    List<String>? interestIds,
  }) async {
    try {
      final queryParameters = {
        'lang': lang,
        'pageNumber': pageNumber,
        'pageSize': pageSize,
        if (name != null) 'name': name,
        if (languageIds != null && languageIds.isNotEmpty) 'languageIds': languageIds,
        if (interestIds != null && interestIds.isNotEmpty) 'interestIds': interestIds,
      };

      final response = await apiClient.get(
        ApiConstants.eventsHosted,
        queryParameters: queryParameters,
        headers: {ApiConstants.headerAuthorization: 'Bearer $token'},
      );

      final json = response.data as Map<String, dynamic>;
      final data = json['data'] as Map<String, dynamic>? ?? {}; // an toàn với null

      return ApiResponse.fromJson(
        json,
            (_) => HostedEventListResponse.fromJson(data), // chỉ dùng data một lần
      );
    } on DioError catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<EventCancelResponse>> cancelEvent({
    required String token,
    required EventCancelRequest request,
  }) async {
    try {
      final response = await apiClient.post(
        ApiConstants.eventsCancel,
        data: request.toJson(),
        headers: {ApiConstants.headerAuthorization: 'Bearer $token'},
      );

      final json = response.data as Map<String, dynamic>;
      return ApiResponse.fromJson(
        json,
            (data) => EventCancelResponse.fromJson(data),
      );
    } on DioError catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<EventCancelResponse>> unregisterEvent({
    required String token,
    required EventCancelRequest request,
  }) async {
    try {
      final response = await apiClient.post(
        ApiConstants.eventsUnregister,
        data: request.toJson(),
        headers: {ApiConstants.headerAuthorization: 'Bearer $token'},
      );

      final json = response.data as Map<String, dynamic>;
      return ApiResponse.fromJson(
        json,
            (data) => EventCancelResponse.fromJson(data),
      );
    } on DioError catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<JoinedEventListResponse>> getJoinedEvents({
    required String token,
    String lang = 'en',
    int pageNumber = 1,
    int pageSize = 10,
    String? name,
    List<String>? languageIds,
    List<String>? interestIds,
  }) async {
    try {
      final queryParameters = {
        'lang': lang,
        'pageNumber': pageNumber,
        'pageSize': pageSize,
        if (name != null) 'name': name,
        if (languageIds != null && languageIds.isNotEmpty) 'languageIds': languageIds,
        if (interestIds != null && interestIds.isNotEmpty) 'interestIds': interestIds,
      };

      final response = await apiClient.get(
        ApiConstants.eventsJoined,
        queryParameters: queryParameters,
        headers: {ApiConstants.headerAuthorization: 'Bearer $token'},
      );

      final json = response.data as Map<String, dynamic>;
      return ApiResponse.fromJson(
        json,
            (_) => JoinedEventListResponse.fromJson(json),
      );
    } on DioError catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<EventDetailsResponse>> getEventDetails({
    required String token,
    required String eventId,
    String lang = 'en',
  }) async {
    try {
      final endpoint = ApiConstants.eventsDetails.replaceFirst('{id}', eventId);
      final response = await apiClient.get(
        '$endpoint?lang=$lang',
        headers: {ApiConstants.headerAuthorization: 'Bearer $token'},
      );

      final json = response.data as Map<String, dynamic>;
      return ApiResponse.fromJson(
        json,
            (data) => EventDetailsResponse.fromJson(json),
      );
    } on DioError catch (e) {
      rethrow;
    }
  }

  Future<EventModel?> getEventDetail({
    required String token,
    required String eventId,
    String lang = 'en',
  }) async {
    try {
      final endpoint = ApiConstants.eventDetail.replaceFirst('{id}', eventId);
      final response = await apiClient.get(
        '$endpoint?lang=$lang',
        headers: {ApiConstants.headerAuthorization: 'Bearer $token'},
      );

      final json = response.data as Map<String, dynamic>;

      if (json['data'] != null) {
        return EventModel.fromJson(json['data']);
      }

      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<EventKickResponse>> kickUser({
    required String token,
    required EventKickRequest request,
  }) async {
    try {
      final response = await apiClient.post(
        ApiConstants.eventsKick,
        data: request.toJson(),
        headers: {ApiConstants.headerAuthorization: 'Bearer $token'},
      );

      final json = response.data as Map<String, dynamic>;
      return ApiResponse.fromJson(
        json,
            (data) => EventKickResponse.fromJson(data),
      );
    } on DioError catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<UpdateEventStatusResponse>> updateEventStatus({
    required String token,
    required UpdateEventStatusRequest request,
  }) async {
    try {
      final response = await apiClient.put(
        ApiConstants.updateStatusAdmin,
        data: request.toJson(),
        headers: {
          ApiConstants.headerAuthorization: 'Bearer $token',
          ApiConstants.headerContentType: ApiConstants.contentTypeJson,
        },
      );

      final json = response.data as Map<String, dynamic>;
      return ApiResponse.fromJson(
        json,
            (data) => UpdateEventStatusResponse.fromJson(data),
      );
    } on DioError catch (e) {

      rethrow;
    }
  }

  Future<ApiResponse<EventRatingResponse>> rateEvent({
    required String token,
    required EventRatingRequest request,
  }) async {
    try {
      final response = await apiClient.post(
        ApiConstants.ratingEvent,
        data: request.toJson(),
        headers: {ApiConstants.headerAuthorization: 'Bearer $token'},
      );

      final json = response.data as Map<String, dynamic>;
      return ApiResponse.fromJson(
        json,
            (data) => EventRatingResponse.fromJson(data),
      );
    } on DioError catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<EventMyRatingModel>> getMyRating({
    required String token,
    required String eventId,
  }) async {
    final endpoint = ApiConstants.getMyRating.replaceFirst('{eventId}', eventId);

    final response = await apiClient.get(
      endpoint,
      headers: {ApiConstants.headerAuthorization: 'Bearer $token'},
    );

    final json = response.data as Map<String, dynamic>?;

    if (json == null) {
      return ApiResponse<EventMyRatingModel>(
        data: null,
        message: 'No data',
      );
    }

    final dataMap = json['data'] as Map<String, dynamic>?;
    final model = dataMap != null ? EventMyRatingModel.fromJson(dataMap) : null;

    return ApiResponse<EventMyRatingModel>(
      data: model,
      message: json['message'] ?? '',
    );
  }

  Future<EventRatingListResponse> getAllRatings({
    required String token,
    required String eventId,
    String lang = 'en',
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await apiClient.get(
        ApiConstants.getAllRating.replaceFirst('{eventId}', eventId),
        queryParameters: {
          'lang': lang,
          'pageNumber': pageNumber,
          'pageSize': pageSize,
        },
        headers: {ApiConstants.headerAuthorization: 'Bearer $token'},
      );

      final json = response.data as Map<String, dynamic>;
      return EventRatingListResponse.fromJson(json);
    } on DioError catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<EventRatingResponse>> updateRating({
    required String token,
    required EventUpdateRatingRequest request,
  }) async {
    try {
      final response = await apiClient.put(
        ApiConstants.updateRating,
        data: request.toJson(),
        headers: {
          ApiConstants.headerAuthorization: 'Bearer $token',
          ApiConstants.headerContentType: ApiConstants.contentTypeJson,
        },
      );

      final json = response.data as Map<String, dynamic>;
      return ApiResponse.fromJson(
        json,
            (data) => EventRatingResponse.fromJson(data),
      );
    } on DioError catch (e) {
      rethrow;
    }
  }

}
