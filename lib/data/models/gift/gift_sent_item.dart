class GiftSentItem {
  final String presentationId;
  final String lang;
  final String receiverName;
  final String receiverAvatarUrl;
  final String giftName;
  final String giftIconUrl;
  final int quantity;
  final String? message;
  final bool isAnonymous;
  final DateTime createdAt;
  final bool isRead;

  GiftSentItem({
    required this.presentationId,
    required this.lang,
    required this.receiverName,
    required this.receiverAvatarUrl,
    required this.giftName,
    required this.giftIconUrl,
    required this.quantity,
    this.message,
    required this.isAnonymous,
    required this.createdAt,
    required this.isRead,
  });

  factory GiftSentItem.fromJson(Map<String, dynamic> json) {
    return GiftSentItem(
      presentationId: json['presentationId'] ?? '',
      lang: json['lang'] ?? '',
      receiverName: json['receiverName'] ?? '',
      receiverAvatarUrl: json['receiverAvatarUrl'] ?? '',
      giftName: json['giftName'] ?? '',
      giftIconUrl: json['giftIconUrl'] ?? '',
      quantity: json['quantity'] ?? 1,
      message: json['message'],
      isAnonymous: json['isAnonymous'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      isRead: json['isRead'] ?? false,
    );
  }
}

class GiftSentResponse {
  final List<GiftSentItem> items;
  final int totalItems;
  final int currentPage;
  final int totalPages;
  final int pageSize;
  final bool hasPreviousPage;
  final bool hasNextPage;

  GiftSentResponse({
    required this.items,
    required this.totalItems,
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });

  factory GiftSentResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return GiftSentResponse(
      items: (data['items'] as List<dynamic>?)
          ?.map((e) => GiftSentItem.fromJson(e))
          .toList() ??
          [],
      totalItems: data['totalItems'] ?? 0,
      currentPage: data['currentPage'] ?? 1,
      totalPages: data['totalPages'] ?? 1,
      pageSize: data['pageSize'] ?? 10,
      hasPreviousPage: data['hasPreviousPage'] ?? false,
      hasNextPage: data['hasNextPage'] ?? false,
    );
  }
}
