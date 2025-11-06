// event_rating_item.dart
class EventRatingItem {
  final String id;
  final int rating;
  final String comment;
  final DateTime createdAt;
  final EventRatingUser user;

  EventRatingItem({
    required this.id,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.user,
  });

  factory EventRatingItem.fromJson(Map<String, dynamic> json) {
    return EventRatingItem(
      id: json['id'] as String,
      rating: json['rating'] as int,
      comment: json['comment'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      user: EventRatingUser.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

class EventRatingUser {
  final String id;
  final String name;
  final String avatarUrl;

  EventRatingUser({
    required this.id,
    required this.name,
    required this.avatarUrl,
  });

  factory EventRatingUser.fromJson(Map<String, dynamic> json) {
    return EventRatingUser(
      id: json['id'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String,
    );
  }
}

// event_rating_list_response.dart
class EventRatingListResponse {
  final List<EventRatingItem> items;
  final int totalItems;
  final int currentPage;
  final int totalPages;
  final int pageSize;
  final bool hasPreviousPage;
  final bool hasNextPage;

  EventRatingListResponse({
    required this.items,
    required this.totalItems,
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });

  factory EventRatingListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final itemsJson = data['items'] as List<dynamic>;
    return EventRatingListResponse(
      items: itemsJson.map((e) => EventRatingItem.fromJson(e)).toList(),
      totalItems: data['totalItems'] as int,
      currentPage: data['currentPage'] as int,
      totalPages: data['totalPages'] as int,
      pageSize: data['pageSize'] as int,
      hasPreviousPage: data['hasPreviousPage'] as bool,
      hasNextPage: data['hasNextPage'] as bool,
    );
  }
}
