import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/config/api_constants.dart';
import '../../models/api_response.dart';
import '../../models/notifications/notification_model.dart';

class NotificationService {
  final ApiClient apiClient;

  NotificationService(this.apiClient);

  Future<ApiResponse<NotificationListResponse>> getAllNotifications({
    required String token,
    String lang = 'en',
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await apiClient.get(
        '${ApiConstants.allNotification}?lang=$lang&pageNumber=$pageNumber&pageSize=$pageSize',
        headers: {ApiConstants.headerAuthorization: 'Bearer $token'},
      );

      final json = response.data as Map<String, dynamic>;

      return ApiResponse.fromJson(
        json,
            (data) => NotificationListResponse.fromJson(data),
      );
    } on DioError catch (e) {
      rethrow;
    }
  }

  Future<bool> markAsRead({
    required String token,
    required String id,
  }) async {
    try {
      final response = await apiClient.put(
        ApiConstants.readNotification.replaceFirst("{id}", id),
        headers: {
          ApiConstants.headerAuthorization: 'Bearer $token',
        },
      );

      final json = response.data as Map<String, dynamic>;

      return json["message"] == "Success.MarkAsRead";
    } on DioError catch (e) {
      rethrow;
    }
  }

}
