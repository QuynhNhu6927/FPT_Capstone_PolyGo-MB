class EventRatingResponse {
  final String message;

  EventRatingResponse({required this.message});

  factory EventRatingResponse.fromJson(Map<String, dynamic> json) {
    return EventRatingResponse(
      message: json['message'] ?? '',
    );
  }
}
