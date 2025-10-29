class ComingEventModel {
  final String id;
  final String title;
  final String description;
  final String status;
  final DateTime startAt;
  final int expectedDurationInMinutes;
  final DateTime registerDeadline;
  final bool allowLateRegister;
  final int capacity;
  final double fee;
  final String bannerUrl;
  final bool isPublic;
  final int numberOfParticipants;
  final String planType;
  final bool isParticipant;
  final Host host;
  final Language language;
  final List<Category> categories;

  ComingEventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.startAt,
    required this.expectedDurationInMinutes,
    required this.registerDeadline,
    required this.allowLateRegister,
    required this.capacity,
    required this.fee,
    required this.bannerUrl,
    required this.isPublic,
    required this.numberOfParticipants,
    required this.planType,
    required this.isParticipant,
    required this.host,
    required this.language,
    required this.categories,
  });

  factory ComingEventModel.fromJson(Map<String, dynamic> json) => ComingEventModel(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    status: json['status'],
    startAt: DateTime.parse(json['startAt']),
    expectedDurationInMinutes: json['expectedDurationInMinutes'],
    registerDeadline: DateTime.parse(json['registerDeadline']),
    allowLateRegister: json['allowLateRegister'],
    capacity: json['capacity'],
    fee: (json['fee'] as num).toDouble(),
    bannerUrl: json['bannerUrl'] ?? '',
    isPublic: json['isPublic'],
    numberOfParticipants: json['numberOfParticipants'],
    planType: json['planType'],
    isParticipant: json['isParticipant'],
    host: Host.fromJson(json['host']),
    language: Language.fromJson(json['language']),
    categories: (json['categories'] as List)
        .map((e) => Category.fromJson(e))
        .toList(),
  );
}

class Host {
  final String id;
  final String name;
  final String? avatarUrl;

  Host({required this.id, required this.name, this.avatarUrl});

  factory Host.fromJson(Map<String, dynamic> json) => Host(
    id: json['id'],
    name: json['name'],
    avatarUrl: json['avatarUrl'],
  );
}

class Language {
  final String id;
  final String code;
  final String lang;
  final String name;
  final String iconUrl;

  Language({
    required this.id,
    required this.code,
    required this.lang,
    required this.name,
    required this.iconUrl,
  });

  factory Language.fromJson(Map<String, dynamic> json) => Language(
    id: json['id'],
    code: json['code'],
    lang: json['lang'],
    name: json['name'],
    iconUrl: json['iconUrl'],
  );
}

class Category {
  final String id;
  final String lang;
  final String name;
  final String iconUrl;

  Category({
    required this.id,
    required this.lang,
    required this.name,
    required this.iconUrl,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json['id'],
    lang: json['lang'],
    name: json['name'],
    iconUrl: json['iconUrl'],
  );
}
