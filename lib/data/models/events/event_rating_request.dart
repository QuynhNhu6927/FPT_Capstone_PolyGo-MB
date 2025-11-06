class EventRatingRequest {
  final String eventId;
  final int rating;
  final String comment;
  final String giftId;
  final int giftQuantity;

  EventRatingRequest({
    required this.eventId,
    required this.rating,
    this.comment = '',
    this.giftId = '',
    this.giftQuantity = 0,
  });

  Map<String, dynamic> toJson() => {
    'eventId': eventId,
    'rating': rating,
    'comment': comment,
    'giftId': giftId,
    'giftQuantity': giftQuantity,
  };
}
