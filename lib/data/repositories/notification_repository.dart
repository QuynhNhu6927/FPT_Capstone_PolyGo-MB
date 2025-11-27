

import '../models/notifications/notification_model.dart';
import '../services/apis/notification_service.dart';

class NotificationRepository {
  final NotificationService _service;

  NotificationRepository(this._service);

  Future<NotificationListResponse> getNotificationsPaged(
      String token, {
        String lang = 'en',
        int pageNumber = 1,
        int pageSize = 10,
      }) async {
    final res = await _service.getAllNotifications(
      token: token,
      lang: lang,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );

    return res.data ??
        NotificationListResponse(
          items: [],
          totalItems: 0,
          currentPage: 1,
          totalPages: 1,
          pageSize: pageSize,
          hasPreviousPage: false,
          hasNextPage: false,
        );
  }

  Future<bool> markAsRead(String token, String id) async {
    return await _service.markAsRead(token: token, id: id);
  }

}
