class ConversationImagesResponse {
  final List<String> items;
  final int totalItems;
  final int currentPage;
  final int totalPages;
  final int pageSize;
  final bool hasPreviousPage;
  final bool hasNextPage;

  ConversationImagesResponse({
    required this.items,
    required this.totalItems,
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });

  /// Tách chuỗi image theo "keyword"
  static List<String> _parseItem(String content) {
    if (content.contains('keyword')) {
      return content.split('keyword').where((e) => e.isNotEmpty).toList();
    } else {
      return [content];
    }
  }

  factory ConversationImagesResponse.fromJson(Map<String, dynamic> json) {
    final rawItems = List<String>.from(json['items'] ?? []);
    final parsedItems = rawItems.expand((e) => _parseItem(e)).toList();

    return ConversationImagesResponse(
      items: parsedItems,
      totalItems: json['totalItems'] ?? 0,
      currentPage: json['currentPage'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
      pageSize: json['pageSize'] ?? 0,
      hasPreviousPage: json['hasPreviousPage'] ?? false,
      hasNextPage: json['hasNextPage'] ?? false,
    );
  }
}
