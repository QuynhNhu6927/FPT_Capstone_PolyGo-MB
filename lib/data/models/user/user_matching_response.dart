class UserMatchingResponse {
  final List<UserMatchingItem> items;
  final int totalItems;
  final int currentPage;
  final int totalPages;
  final int pageSize;
  final bool hasPreviousPage;
  final bool hasNextPage;

  UserMatchingResponse({
    required this.items,
    required this.totalItems,
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });

  factory UserMatchingResponse.fromJson(Map<String, dynamic> json) {
    return UserMatchingResponse(
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => UserMatchingItem.fromJson(e))
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

class UserMatchingItem {
  final String? id;
  final String? name;
  final String? avatarUrl;
  final String? planType;
  final int experiencePoints;
  final int merit;
  final List<UserLang> speakingLanguages;
  final List<UserLang> learningLanguages;
  final List<UserInterest> interests;

  UserMatchingItem({
    this.id,
    this.name,
    this.avatarUrl,
    this.planType,
    required this.experiencePoints,
    required this.merit,
    required this.speakingLanguages,
    required this.learningLanguages,
    required this.interests,
  });

  factory UserMatchingItem.fromJson(Map<String, dynamic> json) {
    return UserMatchingItem(
      id: json['id'],
      name: json['name'],
      avatarUrl: json['avatarUrl'],
      planType: json['planType'],
      experiencePoints: json['experiencePoints'] ?? 0,
      merit: json['merit'] ?? 0,
      speakingLanguages: (json['speakingLanguages'] as List<dynamic>?)
          ?.map((e) => UserLang.fromJson(e))
          .toList() ??
          [],
      learningLanguages: (json['learningLanguages'] as List<dynamic>?)
          ?.map((e) => UserLang.fromJson(e))
          .toList() ??
          [],
      interests: (json['interests'] as List<dynamic>?)
          ?.map((e) => UserInterest.fromJson(e))
          .toList() ??
          [],
    );
  }
}

class UserLang {
  final String id;
  final String name;
  final String iconUrl;

  UserLang({
    required this.id,
    required this.name,
    required this.iconUrl,
  });

  factory UserLang.fromJson(Map<String, dynamic> json) {
    return UserLang(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      iconUrl: json['iconUrl'] ?? '',
    );
  }
}

class UserInterest {
  final String id;
  final String name;
  final String iconUrl;

  UserInterest({
    required this.id,
    required this.name,
    required this.iconUrl,
  });

  factory UserInterest.fromJson(Map<String, dynamic> json) {
    return UserInterest(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      iconUrl: json['iconUrl'] ?? '',
    );
  }
}
