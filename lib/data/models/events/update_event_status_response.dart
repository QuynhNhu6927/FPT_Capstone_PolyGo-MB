// models/events/update_event_status_response.dart
class UpdateEventStatusResponse {
  final String message;

  UpdateEventStatusResponse({required this.message});

  factory UpdateEventStatusResponse.fromJson(Map<String, dynamic> json) {
    return UpdateEventStatusResponse(
      message: json['message'] ?? '',
    );
  }
}
