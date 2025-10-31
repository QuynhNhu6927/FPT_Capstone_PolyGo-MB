class EventDetailsModel {
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
  final String? password;
  final int numberOfParticipants;
  final String planType;
  final DateTime createdAt;
  final DateTime lastUpdatedAt;
  final HostModel host;
  final LanguageModel language;
  final List<CategoryModel> categories;
  final List<ParticipantModel> participants;

  EventDetailsModel({
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
    required this.password,
    required this.numberOfParticipants,
    required this.planType,
    required this.createdAt,
    required this.lastUpdatedAt,
    required this.host,
    required this.language,
    required this.categories,
    required this.participants,
  });

  factory EventDetailsModel.fromJson(Map<String, dynamic> json) {
    return EventDetailsModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      status: json['status'],
      startAt: DateTime.parse(json['startAt']),
      expectedDurationInMinutes: json['expectedDurationInMinutes'],
      registerDeadline: DateTime.parse(json['registerDeadline']),
      allowLateRegister: json['allowLateRegister'],
      capacity: json['capacity'],
      fee: json['fee'],
      bannerUrl: json['bannerUrl'],
      isPublic: json['isPublic'],
      password: json['password'],
      numberOfParticipants: json['numberOfParticipants'],
      planType: json['planType'],
      createdAt: DateTime.parse(json['createdAt']),
      lastUpdatedAt: DateTime.parse(json['lastUpdatedAt']),
      host: HostModel.fromJson(json['host']),
      language: LanguageModel.fromJson(json['language']),
      categories: (json['categories'] as List)
          .map((e) => CategoryModel.fromJson(e))
          .toList(),
      participants: (json['participants'] as List)
          .map((e) => ParticipantModel.fromJson(e))
          .toList(),
    );
  }
}

class HostModel {
  final String id;
  final String name;
  final String avatarUrl;

  HostModel({
    required this.id,
    required this.name,
    required this.avatarUrl,
  });

  factory HostModel.fromJson(Map<String, dynamic> json) {
    return HostModel(
      id: json['id'],
      name: json['name'],
      avatarUrl: json['avatarUrl'],
    );
  }
}

class LanguageModel {
  final String id;
  final String code;
  final String lang;
  final String name;
  final String iconUrl;

  LanguageModel({
    required this.id,
    required this.code,
    required this.lang,
    required this.name,
    required this.iconUrl,
  });

  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    return LanguageModel(
      id: json['id'],
      code: json['code'],
      lang: json['lang'],
      name: json['name'],
      iconUrl: json['iconUrl'],
    );
  }
}

class CategoryModel {
  final String id;
  final String lang;
  final String name;
  final String iconUrl;

  CategoryModel({
    required this.id,
    required this.lang,
    required this.name,
    required this.iconUrl,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      lang: json['lang'],
      name: json['name'],
      iconUrl: json['iconUrl'],
    );
  }
}

class ParticipantModel {
  final String id;
  final String name;
  final int role;
  final int status;
  final String avatarUrl;
  final DateTime registeredAt;
  final String? userEventRatingId;

  ParticipantModel({
    required this.id,
    required this.name,
    required this.role,
    required this.status,
    required this.avatarUrl,
    required this.registeredAt,
    this.userEventRatingId,
  });

  factory ParticipantModel.fromJson(Map<String, dynamic> json) {
    return ParticipantModel(
      id: json['id'],
      name: json['name'],
      role: json['role'],
      status: json['status'],
      avatarUrl: json['avatarUrl'],
      registeredAt: DateTime.parse(json['registeredAt']),
      userEventRatingId: json['userEventRatingId'],
    );
  }

}

extension ParticipantModelCopy on ParticipantModel {
  ParticipantModel copyWith({
    String? id,
    String? name,
    int? role,
    int? status,
    String? avatarUrl,
    DateTime? registeredAt,
    String? userEventRatingId,
  }) {
    return ParticipantModel(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      status: status ?? this.status,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      registeredAt: registeredAt ?? this.registeredAt,
      userEventRatingId: userEventRatingId ?? this.userEventRatingId,
    );
  }
}

