// models/events/update_event_status_request.dart
class UpdateEventStatusRequest {
  final String eventId;
  final String status; // "Live", "Completed", "Pending", ...
  final String? adminNote; // optional

  UpdateEventStatusRequest({
    required this.eventId,
    required this.status,
    this.adminNote,
  });

  Map<String, dynamic> toJson() => {
    'eventId': eventId,
    'status': status,
    if (adminNote != null) 'adminNote': adminNote,
  };
}
