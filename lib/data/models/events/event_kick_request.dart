class EventKickRequest {
  final String eventId;
  final String userId;
  final String reason;
  final bool allowRejoin;

  EventKickRequest({
    required this.eventId,
    required this.userId,
    required this.reason,
    required this.allowRejoin,
  });

  Map<String, dynamic> toJson() => {
    'eventId': eventId,
    'userId': userId,
    'reason': reason,
    'allowRejoin': allowRejoin,
  };
}

class EventKickResponse {
  final String message;

  EventKickResponse({required this.message});

  factory EventKickResponse.fromJson(Map<String, dynamic> json) {
    return EventKickResponse(
      message: json['message'] as String? ?? 'Success',
    );
  }
}
