class BadgeDetailData {
  final String id;
  final String lang;
  final String code;
  final String name;
  final String description;
  final String iconUrl;
  final String badgeCategory;
  final String createdAt;
  final String lastUpdatedAt;

  BadgeDetailData({
    required this.id,
    required this.lang,
    required this.code,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.badgeCategory,
    required this.createdAt,
    required this.lastUpdatedAt,
  });

  factory BadgeDetailData.fromJson(Map<String, dynamic> json) {
    return BadgeDetailData(
      id: json['id'] ?? '',
      lang: json['lang'] ?? '',
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      iconUrl: json['iconUrl'] ?? '',
      badgeCategory: json['badgeCategory']?.toString() ?? '',
      createdAt: json['createdAt'] ?? '',
      lastUpdatedAt: json['lastUpdatedAt'] ?? '',
    );
  }
}

class BadgeDetailResponse {
  final BadgeDetailData data;
  final String message;

  BadgeDetailResponse({
    required this.data,
    required this.message,
  });

  factory BadgeDetailResponse.fromJson(Map<String, dynamic> json) {
    return BadgeDetailResponse(
      data: BadgeDetailData.fromJson(json['data']),
      message: json['message'] ?? '',
    );
  }
}