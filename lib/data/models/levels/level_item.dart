class LevelItem {
  final String id;
  final String lang;
  final int order;
  final int requiredXP;
  final String description;
  final bool isClaimed;

  LevelItem({
    required this.id,
    required this.lang,
    required this.order,
    required this.requiredXP,
    required this.description,
    this.isClaimed = false,
  });

  factory LevelItem.fromJson(Map<String, dynamic> json) {
    return LevelItem(
      id: json['id'] ?? '',
      lang: json['lang'] ?? '',
      order: json['order'] ?? 0,
      requiredXP: json['requiredXP'] ?? 0,
      description: json['description'] ?? '',
      isClaimed: json['isClaimed'] ?? true,
    );
  }

  LevelItem copyWith({bool? isClaimed}) {
    return LevelItem(
      id: id,
      lang: lang,
      order: order,
      requiredXP: requiredXP,
      description: description,
      isClaimed: isClaimed ?? this.isClaimed,
    );
  }
}

class LevelListResponse {
  final List<LevelItem> items;
  final int totalItems;
  final int currentPage;
  final int totalPages;
  final int pageSize;
  final bool hasPreviousPage;
  final bool hasNextPage;

  LevelListResponse({
    required this.items,
    required this.totalItems,
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });

  factory LevelListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    final list = (data['items'] as List<dynamic>? ?? [])
        .map((e) => LevelItem.fromJson(e))
        .toList();

    return LevelListResponse(
      items: list,
      totalItems: data['totalItems'] ?? 0,
      currentPage: data['currentPage'] ?? 1,
      totalPages: data['totalPages'] ?? 1,
      pageSize: data['pageSize'] ?? 0,
      hasPreviousPage: data['hasPreviousPage'] ?? false,
      hasNextPage: data['hasNextPage'] ?? false,
    );
  }
}

class ClaimLevelResponse {
  final String message;

  ClaimLevelResponse({required this.message});

  factory ClaimLevelResponse.fromJson(Map<String, dynamic> json) {
    return ClaimLevelResponse(
      message: json['message'] ?? '',
    );
  }
}
