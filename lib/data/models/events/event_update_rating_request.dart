class EventUpdateRatingRequest {
  final String eventId;
  final int rating;
  final String comment;

  EventUpdateRatingRequest({
    required this.eventId,
    required this.rating,
    required this.comment,
  });

  Map<String, dynamic> toJson() => {
    'eventId': eventId,
    'rating': rating,
    'comment': comment,
  };
}
