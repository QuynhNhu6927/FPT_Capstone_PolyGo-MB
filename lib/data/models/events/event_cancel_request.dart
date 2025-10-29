class EventCancelRequest {
  final String eventId;
  final String reason;

  EventCancelRequest({
    required this.eventId,
    required this.reason,
  });

  Map<String, dynamic> toJson() => {
    'eventId': eventId,
    'reason': reason,
  };
}
