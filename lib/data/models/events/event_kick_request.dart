// event_kick_request.dart
class EventKickRequest {
  final String eventId;
  final String userId;
  final String reason;

  EventKickRequest({
    required this.eventId,
    required this.userId,
    required this.reason,
  });

  Map<String, dynamic> toJson() => {
    'eventId': eventId,
    'userId': userId,
    'reason': reason,
  };
}

// event_kick_response.dart
class EventKickResponse {
  final String message;

  EventKickResponse({required this.message});

  factory EventKickResponse.fromJson(Map<String, dynamic> json) {
    return EventKickResponse(
      message: json['message'] as String? ?? 'Success',
    );
  }
}
