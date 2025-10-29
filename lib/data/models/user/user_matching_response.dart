class UserMatchingResponse {
  final List<UserMatchingItem> items;

  UserMatchingResponse({required this.items});

  factory UserMatchingResponse.fromJson(Map<String, dynamic> json) {

    final items = (json['items'] as List<dynamic>?)
        ?.map((e) => UserMatchingItem.fromJson(e))
        .toList() ??
        [];
    return UserMatchingResponse(items: items);
  }
}

class UserMatchingItem {
  final String? id;
  final String? name;
  final String? avatarUrl;
  final int experiencePoints;
  final List<UserLang> speakingLanguages;
  final List<UserLang> learningLanguages;
  final List<UserInterest> interests;

  UserMatchingItem({
    this.id,
    this.name,
    this.avatarUrl,
    required this.experiencePoints,
    required this.speakingLanguages,
    required this.learningLanguages,
    required this.interests,
  });

  factory UserMatchingItem.fromJson(Map<String, dynamic> json) {
    return UserMatchingItem(
      id: json['id'],
      name: json['name'],
      avatarUrl: json['avatarUrl'],
      experiencePoints: json['experiencePoints'] ?? 0,
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
