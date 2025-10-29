class EventCancelResponse {
  final String message;

  EventCancelResponse({required this.message});

  factory EventCancelResponse.fromJson(Map<String, dynamic> json) {
    return EventCancelResponse(
      message: json['message'] ?? '',
    );
  }
}
