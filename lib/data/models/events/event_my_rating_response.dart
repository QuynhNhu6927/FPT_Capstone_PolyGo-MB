class EventMyRatingModel {
  final String id;
  final int rating;
  final String comment;
  final bool hasRating;
  final DateTime createdAt;

  EventMyRatingModel({
    required this.id,
    required this.rating,
    required this.comment,
    required this.hasRating,
    required this.createdAt,
  });

  factory EventMyRatingModel.fromJson(Map<String, dynamic> json) {
    return EventMyRatingModel(
      id: json['id'] ?? '',
      rating: json['rating'] ?? 0,
      comment: json['comment'] ?? '',
      hasRating: json['hasRating'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
