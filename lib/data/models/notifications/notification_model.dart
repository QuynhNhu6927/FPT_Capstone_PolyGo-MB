class NotificationModel {
  final String id;
  final String lang;
  final String content;
  final bool isRead;
  final String type;
  final String? objectId;
  final String? imageUrl;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.lang,
    required this.content,
    required this.isRead,
    required this.type,
    this.objectId,
    this.imageUrl,
    required this.createdAt,
  });

  NotificationModel copyWith({
    bool? isRead,
    String? id,
    String? lang,
    String? content,
    String? type,
    String? objectId,
    String? imageUrl,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      lang: lang ?? this.lang,
      content: content ?? this.content,
      type: type ?? this.type,
      objectId: objectId ?? this.objectId,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      lang: json['lang'] ?? '',
      content: json['content'] ?? '',
      isRead: json['isRead'] ?? false,
      type: json['type'] ?? '',
      objectId: json['objectId'],
      imageUrl: json['imageUrl'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class NotificationListResponse {
  final List<NotificationModel> items;
  final int totalItems;
  final int currentPage;
  final int totalPages;
  final int pageSize;
  final bool hasPreviousPage;
  final bool hasNextPage;

  NotificationListResponse({
    required this.items,
    required this.totalItems,
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });

  factory NotificationListResponse.fromJson(Map<String, dynamic> json) {
    return NotificationListResponse(
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => NotificationModel.fromJson(e))
          .toList(),
      totalItems: json['totalItems'] ?? 0,
      currentPage: json['currentPage'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
      pageSize: json['pageSize'] ?? 0,
      hasPreviousPage: json['hasPreviousPage'] ?? false,
      hasNextPage: json['hasNextPage'] ?? false,
    );
  }
}
