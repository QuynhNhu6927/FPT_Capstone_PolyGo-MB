class ConversationMessage {
  String id;
  String conversationId;
  String type;
  Sender sender;
  String content;
  String sentAt;
  final List<String> _images;

  ConversationMessage({
    required this.id,
    required this.conversationId,
    required this.type,
    required this.sender,
    required this.content,
    required this.sentAt,
    List<String> images = const [],
  }) : _images = images;

  /// Trả về list URL nếu type là Image/Images
  List<String> get images {
    if (_images.isNotEmpty) return _images;
    if (type == "Images" || type == "Image") {
      return _parseImageContent(content);
    }
    return [];
  }

  /// Tách chuỗi image theo "keyword"
  List<String> _parseImageContent(String content) {
    if (content.contains('<<~IMG~>>')) {
      return content.split('<<~IMG~>>');
    } else {
      return [content];
    }
  }

  factory ConversationMessage.fromJson(Map<String, dynamic> json) {
    return ConversationMessage(
      id: json['id'] ?? '',
      conversationId: json['conversationId'] ?? '',
      type: json['type'] ?? 'Text',
      sender: Sender.fromJson(json['sender'] ?? {}),
      content: json['content'] ?? '',
      sentAt: json['sentAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'type': type,
      'sender': sender.toJson(),
      'content': content,
      'sentAt': sentAt,
    };
  }
}

class Sender {
  String id;
  String name;
  String? avatarUrl;

  // ✅ Thêm các biến còn thiếu từ swagger:
  bool? isOnline;
  String? lastActiveAt;

  Sender({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.isOnline,
    this.lastActiveAt,
  });

  factory Sender.fromJson(Map<String, dynamic> json) {
    return Sender(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      avatarUrl: json['avatarUrl'],
      isOnline: json['isOnline'],
      lastActiveAt: json['lastActiveAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatarUrl': avatarUrl,
      'isOnline': isOnline,
      'lastActiveAt': lastActiveAt,
    };
  }
}

class ConversationMessageListResponse {
  List<ConversationMessage> items;
  int totalItems;
  int currentPage;
  int totalPages;
  int pageSize;
  bool hasPreviousPage;
  bool hasNextPage;

  ConversationMessageListResponse({
    required this.items,
    required this.totalItems,
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });

  factory ConversationMessageListResponse.fromJson(Map<String, dynamic> json) {
    var itemsJson = json['items'] as List? ?? [];
    List<ConversationMessage> items =
    itemsJson.map((item) => ConversationMessage.fromJson(item)).toList();

    return ConversationMessageListResponse(
      items: items,
      totalItems: json['totalItems'] ?? 0,
      currentPage: json['currentPage'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
      pageSize: json['pageSize'] ?? 20,
      hasPreviousPage: json['hasPreviousPage'] ?? false,
      hasNextPage: json['hasNextPage'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((e) => e.toJson()).toList(),
      'totalItems': totalItems,
      'currentPage': currentPage,
      'totalPages': totalPages,
      'pageSize': pageSize,
      'hasPreviousPage': hasPreviousPage,
      'hasNextPage': hasNextPage,
    };
  }
}
