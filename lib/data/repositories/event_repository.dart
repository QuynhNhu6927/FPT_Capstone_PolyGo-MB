import '../models/events/coming_event_model.dart';
import '../models/events/event_model.dart';
import '../models/events/event_register_request.dart';
import '../services/event_service.dart';

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

  Future<List<ComingEventModel>> getUpcomingEvents(
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

  Future<EventRegisterResponse?> registerEvent({
    required String token,
    required String eventId,
    String password = '',
  }) async {
    final request = EventRegisterRequest(eventId: eventId, password: password);
    final res = await _service.registerEvent(token: token, request: request);
    return res.data;
  }

}
