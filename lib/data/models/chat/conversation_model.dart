class LastMessage {
  int? type;
  String? sentAt;
  String? content;
  bool? isSentByYou;

  LastMessage({this.type, this.sentAt, this.content, this.isSentByYou});

  factory LastMessage.fromJson(Map<String, dynamic> json) {
    return LastMessage(
      type: json['type'],
      sentAt: json['sentAt'],
      content: json['content'],
      isSentByYou: json['isSentByYou'] ?? false,
    );
  }
}

class Conversation {
  final String id;
  bool hasSeen;
  LastMessage lastMessage;
  final User user;

  Conversation({
    required this.id,
    required this.hasSeen,
    required this.lastMessage,
    required this.user,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'],
      hasSeen: json['hasSeen'] ?? false,
      lastMessage: LastMessage.fromJson(json['lastMessage']),
      user: User.fromJson(json['user']),
    );
  }
}

class User {
  final String id;
  final String name;
  final String? avatarUrl;
  bool isOnline;
  String? lastActiveAt;

  User({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.isOnline = false,
    this.lastActiveAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    name: json['name'],
    avatarUrl: json['avatarUrl'],
    isOnline: json['isOnline'] ?? false,
    lastActiveAt: json['lastActiveAt'],
  );
}

class ConversationListResponse {
  final List<Conversation> items;
  final int totalItems;
  final int currentPage;
  final int totalPages;
  final int pageSize;
  final bool hasPreviousPage;
  final bool hasNextPage;

  ConversationListResponse({
    required this.items,
    required this.totalItems,
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });

  factory ConversationListResponse.fromJson(Map<String, dynamic> json) {
    return ConversationListResponse(
      items: (json['items'] as List)
          .map((e) => Conversation.fromJson(e))
          .toList(),
      totalItems: json['totalItems'],
      currentPage: json['currentPage'],
      totalPages: json['totalPages'],
      pageSize: json['pageSize'],
      hasPreviousPage: json['hasPreviousPage'],
      hasNextPage: json['hasNextPage'],
    );
  }
}
