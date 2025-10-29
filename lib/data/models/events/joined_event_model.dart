// models/events/joined_event_model.dart

class JoinedEventModel {
  final String id;
  final String title;
  final String description;
  final String status;
  final DateTime startAt;
  final int expectedDurationInMinutes;
  final DateTime registerDeadline;
  final bool allowLateRegister;
  final int capacity;
  final int fee;
  final String bannerUrl;
  final bool isPublic;
  final int numberOfParticipants;
  final String planType;
  final UserEvent userEvent;
  final Host host;
  final Language language;
  final List<Category> categories;

  JoinedEventModel({
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
    required this.userEvent,
    required this.host,
    required this.language,
    required this.categories,
  });

  factory JoinedEventModel.fromJson(Map<String, dynamic> json) {
    return JoinedEventModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      status: json['status'],
      startAt: DateTime.parse(json['startAt']),
      expectedDurationInMinutes: json['expectedDurationInMinutes'],
      registerDeadline: DateTime.parse(json['registerDeadline']),
      allowLateRegister: json['allowLateRegister'] ?? false,
      capacity: json['capacity'],
      fee: json['fee'],
      bannerUrl: json['bannerUrl'] ?? '',
      isPublic: json['isPublic'] ?? true,
      numberOfParticipants: json['numberOfParticipants'],
      planType: json['planType'],
      userEvent: UserEvent.fromJson(json['userEvent'] ?? {}),
      host: Host.fromJson(json['host']),
      language: Language.fromJson(json['language']),
      categories: (json['categories'] as List<dynamic>?)
          ?.map((e) => Category.fromJson(e))
          .toList() ??
          [],
    );
  }
}

class UserEvent {
  final int role;
  final int status;
  final DateTime registeredAt;
  final String? userEventRatingId;

  UserEvent({
    required this.role,
    required this.status,
    required this.registeredAt,
    this.userEventRatingId,
  });

  factory UserEvent.fromJson(Map<String, dynamic> json) {
    return UserEvent(
      role: json['role'] ?? 0,
      status: json['status'] ?? 0,
      registeredAt:
      DateTime.parse(json['registeredAt'] ?? DateTime.now().toIso8601String()),
      userEventRatingId: json['userEventRatingId'],
    );
  }
}

class Host {
  final String id;
  final String name;
  final String? avatarUrl;

  Host({
    required this.id,
    required this.name,
    this.avatarUrl,
  });

  factory Host.fromJson(Map<String, dynamic> json) {
    return Host(
      id: json['id'],
      name: json['name'],
      avatarUrl: json['avatarUrl'],
    );
  }
}

class Language {
  final String id;
  final String code;
  final String lang;
  final String name;
  final String? iconUrl;

  Language({
    required this.id,
    required this.code,
    required this.lang,
    required this.name,
    this.iconUrl,
  });

  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(
      id: json['id'],
      code: json['code'],
      lang: json['lang'],
      name: json['name'],
      iconUrl: json['iconUrl'],
    );
  }
}

class Category {
  final String id;
  final String lang;
  final String name;
  final String? iconUrl;

  Category({
    required this.id,
    required this.lang,
    required this.name,
    this.iconUrl,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      lang: json['lang'],
      name: json['name'],
      iconUrl: json['iconUrl'],
    );
  }
}
