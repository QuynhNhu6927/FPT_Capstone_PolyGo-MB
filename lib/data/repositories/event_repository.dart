import 'package:flutter/cupertino.dart';

import '../models/api_response.dart';
import '../models/events/coming_event_list_response.dart';
import '../models/events/coming_event_model.dart';
import '../models/events/event_cancel_request.dart';
import '../models/events/event_cancel_response.dart';
import '../models/events/event_details_model.dart';
import '../models/events/event_kick_request.dart';
import '../models/events/event_list_response.dart';
import '../models/events/event_model.dart';
import '../models/events/event_my_rating_response.dart';
import '../models/events/event_rating_item.dart';
import '../models/events/event_rating_request.dart';
import '../models/events/event_rating_response.dart';
import '../models/events/event_register_request.dart';
import '../models/events/event_update_rating_request.dart';
import '../models/events/hosted_event_model.dart';
import '../models/events/joined_event_model.dart';
import '../models/events/update_event_status_request.dart';
import '../models/events/update_event_status_response.dart';
import '../services/apis/event_service.dart';

class EventRepository {
  final EventService _service;

  EventRepository(this._service);

  Future<List<EventModel>> getMatchingEvents(
      String token, {
        String lang = 'en',
        int pageNumber = 1,
        int pageSize = 10,
      }) async {
    final res = await _service.getMatchingEvents(
      token: token,
      lang: lang,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );

    if (res.data == null) return [];
    return res.data!.items;
  }

  Future<EventListResponse> getMatchingEventsPaged(
      String token, {
        String lang = 'en',
        int pageNumber = 1,
        int pageSize = 8,
      }) async {
    final res = await _service.getMatchingEvents(
      token: token,
      lang: lang,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );

    return res.data ?? EventListResponse(
      items: [],
      totalItems: 0,
      currentPage: 1,
      totalPages: 1,
      pageSize: pageSize,
      hasPreviousPage: false,
      hasNextPage: false,
    );
  }

  Future<List<EventModel>> getUpcomingEvents(
      String token, {
        String lang = 'en',
        int pageNumber = 1,
        int pageSize = 10,
        List<String>? languageIds,
        List<String>? interestIds,
      }) async {
    final res = await _service.getUpcomingEvents(
      token: token,
      lang: lang,
      pageNumber: pageNumber,
      pageSize: pageSize,
      languageIds: languageIds,
      interestIds: interestIds,
    );

    if (res.data == null) return [];
    return res.data!.items;
  }

  Future<EventListResponse> getUpcomingEventsPaged(
      String token, {
        String lang = 'en',
        int pageNumber = 1,
        int pageSize = 10,
        List<String>? languageIds,
        List<String>? interestIds,
        bool? isFree,
      }) async {
    final res = await _service.getUpcomingEvents(
      token: token,
      lang: lang,
      pageNumber: pageNumber,
      pageSize: pageSize,
      languageIds: languageIds,
      interestIds: interestIds,
      isFree: isFree,
    );

    if (res.data == null) {
      return EventListResponse(
        items: [],
        totalItems: 0,
        currentPage: 1,
        totalPages: 1,
        pageSize: pageSize,
        hasPreviousPage: false,
        hasNextPage: false,
      );
    }

    return res.data!;
  }

  Future<EventRegisterResponse?> registerEvent({
    required String token,
    required String eventId,
    String password = '',
  }) async {
    final request = EventRegisterRequest(eventId: eventId, password: password);
    final res = await _service.registerEvent(token: token, request: request);
    return res.data;
  }

  Future<List<HostedEventModel>> getHostedEvents({
    required String token,
    String lang = 'en',
    int pageNumber = 1,
    int pageSize = 10,
    String? name,
    List<String>? languageIds,
    List<String>? interestIds,
  }) async {
    final res = await _service.getHostedEvents(
      token: token,
      lang: lang,
      pageNumber: pageNumber,
      pageSize: pageSize,
      name: name,
      languageIds: languageIds,
      interestIds: interestIds,
    );

    if (res.data == null) return [];
    return res.data!.items;
  }

  Future<EventCancelResponse?> cancelEvent({
    required String token,
    required String eventId,
    required String reason,
  }) async {
    final request = EventCancelRequest(eventId: eventId, reason: reason);
    final res = await _service.cancelEvent(token: token, request: request);
    return res.data;
  }

  Future<EventCancelResponse?> unregisterEvent({
    required String token,
    required String eventId,
    required String reason,
  }) async {
    final request = EventCancelRequest(eventId: eventId, reason: reason);
    final res = await _service.unregisterEvent(token: token, request: request);
    return res.data;
  }

  Future<List<JoinedEventModel>> getJoinedEvents({
    required String token,
    String lang = 'en',
    int pageNumber = 1,
    int pageSize = 10,
    String? name,
    List<String>? languageIds,
    List<String>? interestIds,
  }) async {
    final res = await _service.getJoinedEvents(
      token: token,
      lang: lang,
      pageNumber: pageNumber,
      pageSize: pageSize,
      name: name,
      languageIds: languageIds,
      interestIds: interestIds,
    );

    if (res.data == null) return [];
    return res.data!.items;
  }

  Future<EventDetailsModel?> getEventDetails({
    required String token,
    required String eventId,
    String lang = 'en',
  }) async {
    final res = await _service.getEventDetails(
      token: token,
      eventId: eventId,
      lang: lang,
    );

    return res.data?.data;
  }

  Future<EventModel?> getEventDetail({
    required String token,
    required String eventId,
    String lang = 'en',
  }) async {
    return await _service.getEventDetail(
      token: token,
      eventId: eventId,
      lang: lang,
    );
  }

  Future<EventKickResponse?> kickUser({
    required String token,
    required String eventId,
    required String userId,
    String reason = '',
  }) async {
    final request = EventKickRequest(
      eventId: eventId,
      userId: userId,
      reason: reason,
    );

    final res = await _service.kickUser(token: token, request: request);
    return res.data;
  }

  Future<bool> updateEventStatus({
    required String token,
    required String eventId,
    required String status,
    String? adminNote,
  }) async {
    final request = UpdateEventStatusRequest(
      eventId: eventId,
      status: status,
      adminNote: adminNote,
    );

    final res = await _service.updateEventStatus(
      token: token,
      request: request,
    );

    if (res.data != null && res.data!.message.contains("Success")) {
      return true;
    }
    return false;
  }

  Future<ApiResponse<EventRatingResponse>> rateEvent({
    required String token,
    required String eventId,
    int rating = 5,
    String comment = '',
    String giftId = '',
    int giftQuantity = 0,
  }) async {
    final request = EventRatingRequest(
      eventId: eventId,
      rating: rating,
      comment: comment,
      giftId: giftId,
      giftQuantity: giftQuantity,
    );

    return await _service.rateEvent(token: token, request: request);
  }

  Future<EventMyRatingModel?> getMyRating({
    required String token,
    required String eventId,
  }) async {
    try {
      final res = await _service.getMyRating(token: token, eventId: eventId);
      return res.data;
    } catch (e) {
      return null;
    }
  }

  Future<List<EventRatingItem>> getAllRatings({
    required String token,
    required String eventId,
    String lang = 'en',
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      final res = await _service.getAllRatings(
        token: token,
        eventId: eventId,
        lang: lang,
        pageNumber: pageNumber,
        pageSize: pageSize,
      );

      return res.items;
    } catch (e) {
      return [];
    }
  }

  Future<ApiResponse<EventRatingResponse>> updateRating({
    required String token,
    required String eventId,
    required int rating,
    required String comment,
  }) async {
    final request = EventUpdateRatingRequest(
      eventId: eventId,
      rating: rating,
      comment: comment,
    );

    return await _service.updateRating(token: token, request: request);
  }


}
