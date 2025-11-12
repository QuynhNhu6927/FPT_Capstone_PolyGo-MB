// lib/data/models/user/user_all_response.dart
class UserAllResponse {
  final List<UserItem> items;
  final int totalItems;
  final int currentPage;
  final int totalPages;
  final int pageSize;
  final bool hasPreviousPage;
  final bool hasNextPage;

  UserAllResponse({
    required this.items,
    required this.totalItems,
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });

  factory UserAllResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    final items = (data['items'] as List<dynamic>? ?? [])
        .map((e) => UserItem.fromJson(e))
        .toList();

    return UserAllResponse(
      items: items,
      totalItems: data['totalItems'] ?? 0,
      currentPage: data['currentPage'] ?? 1,
      totalPages: data['totalPages'] ?? 1,
      pageSize: data['pageSize'] ?? 0,
      hasPreviousPage: data['hasPreviousPage'] ?? false,
      hasNextPage: data['hasNextPage'] ?? false,
    );
  }
}

class UserItem {
  final String id;
  final String name;
  final String avatarUrl;
  final String introduction;
  final String mail;
  final int merit;
  final String gender;
  final int experiencePoints;
  // final int streakDays;
  final String planType;
  final List<UserLanguage> speakingLanguages;
  final List<UserLanguage> learningLanguages;
  final List<UserInterest> interests;
  final List<UserGift> gifts;

  UserItem({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.introduction,
    required this.mail,
    required this.merit,
    required this.gender,
    required this.experiencePoints,
    // required this.streakDays,
    required this.planType,
    required this.speakingLanguages,
    required this.learningLanguages,
    required this.interests,
    required this.gifts,
  });

  factory UserItem.fromJson(Map<String, dynamic> json) => UserItem(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    avatarUrl: json['avatarUrl'] ?? '',
    introduction: json['introduction'] ?? '',
    mail: json['mail'] ?? '',
    merit: json['merit'] ?? '',
    gender: json['gender'] ?? '',
    experiencePoints: json['experiencePoints'] ?? 0,
    planType: json['planType'] ?? '',
    speakingLanguages: (json['speakingLanguages'] as List<dynamic>? ?? [])
        .map((e) => UserLanguage.fromJson(e))
        .toList(),
    learningLanguages: (json['learningLanguages'] as List<dynamic>? ?? [])
        .map((e) => UserLanguage.fromJson(e))
        .toList(),
    // streakDays: (json['streakDays'] is int)
    //     ? json['streakDays'] as int
    //     : int.tryParse(json['streakDays']?.toString() ?? '0') ?? 0,
    interests: (json['interests'] as List<dynamic>? ?? [])
        .map((e) => UserInterest.fromJson(e))
        .toList(),
    gifts: (json['gifts'] as List<dynamic>? ?? [])
        .map((e) => UserGift.fromJson(e))
        .toList(),
  );
}

class UserLanguage {
  final String id;
  final String code;
  final String lang;
  final String name;
  final String iconUrl;

  UserLanguage({
    required this.id,
    required this.code,
    required this.lang,
    required this.name,
    required this.iconUrl,
  });

  factory UserLanguage.fromJson(Map<String, dynamic> json) => UserLanguage(
    id: json['id'] ?? '',
    code: json['code'] ?? '',
    lang: json['lang'] ?? '',
    name: json['name'] ?? '',
    iconUrl: json['iconUrl'] ?? '',
  );
}

class UserInterest {
  final String id;
  final String lang;
  final String name;
  final String iconUrl;

  UserInterest({
    required this.id,
    required this.lang,
    required this.name,
    required this.iconUrl,
  });

  factory UserInterest.fromJson(Map<String, dynamic> json) => UserInterest(
    id: json['id'] ?? '',
    lang: json['lang'] ?? '',
    name: json['name'] ?? '',
    iconUrl: json['iconUrl'] ?? '',
  );
}

class UserGift {
  final String id;
  final String lang;
  final String name;
  final String iconUrl;
  final int quantity;

  UserGift({
    required this.id,
    required this.lang,
    required this.name,
    required this.iconUrl,
    required this.quantity,
  });

  factory UserGift.fromJson(Map<String, dynamic> json) => UserGift(
    id: json['id'] ?? '',
    lang: json['lang'] ?? '',
    name: json['name'] ?? '',
    iconUrl: json['iconUrl'] ?? '',
    quantity: json['quantity'] ?? 0,
  );
}
