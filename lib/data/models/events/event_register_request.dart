
class EventRegisterRequest {
  final String eventId;
  final String password;

  EventRegisterRequest({required this.eventId, this.password = ''});

  Map<String, dynamic> toJson() => {
    'eventId': eventId,
    'password': password,
  };
}

// models/events/event_register_response.dart
class EventRegisterResponse {
  final String message;

  EventRegisterResponse({required this.message});

  factory EventRegisterResponse.fromJson(Map<String, dynamic> json) =>
      EventRegisterResponse(message: json['message']);
}
