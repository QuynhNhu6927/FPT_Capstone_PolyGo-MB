// usage_item.dart
class UsageItem {
  final String featureType;
  final String featureName;
  final int usageCount;
  final int limitValue;
  final String limitType;
  final bool isUnlimited;
  final DateTime? lastUsedAt;
  final DateTime? resetAt;
  final bool canUse;

  UsageItem({
    required this.featureType,
    required this.featureName,
    required this.usageCount,
    required this.limitValue,
    required this.limitType,
    required this.isUnlimited,
    required this.lastUsedAt,
    required this.resetAt,
    required this.canUse,
  });

  factory UsageItem.fromJson(Map<String, dynamic> json) {
    return UsageItem(
      featureType: json['featureType'] ?? '',
      featureName: json['featureName'] ?? '',
      usageCount: json['usageCount'] ?? 0,
      limitValue: json['limitValue'] ?? 0,
      limitType: json['limitType'] ?? '',
      isUnlimited: json['isUnlimited'] ?? false,
      lastUsedAt: json['lastUsedAt'] != null
          ? DateTime.parse(json['lastUsedAt'])
          : null,
      resetAt: json['resetAt'] != null
          ? DateTime.parse(json['resetAt'])
          : null,
      canUse: json['canUse'] ?? false,
    );
  }
}

// subscription_usage_response.dart
class SubscriptionUsageResponse {
  final List<UsageItem> items;
  final int totalItems;
  final int currentPage;
  final int totalPages;
  final int pageSize;
  final bool hasPreviousPage;
  final bool hasNextPage;

  SubscriptionUsageResponse({
    required this.items,
    required this.totalItems,
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });

  factory SubscriptionUsageResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return SubscriptionUsageResponse(
      items: (data['items'] as List<dynamic>)
          .map((e) => UsageItem.fromJson(e))
          .toList(),
      totalItems: data['totalItems'] ?? 0,
      currentPage: data['currentPage'] ?? 1,
      totalPages: data['totalPages'] ?? 1,
      pageSize: data['pageSize'] ?? 10,
      hasPreviousPage: data['hasPreviousPage'] ?? false,
      hasNextPage: data['hasNextPage'] ?? false,
    );
  }
}
