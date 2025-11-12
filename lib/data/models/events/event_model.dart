class EventModel {
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
  final HostModel host;
  final LanguageModel language;
  final List<CategoryModel> categories;

  EventModel({
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

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? '',
      startAt: DateTime.tryParse(json['startAt'] ?? '') ?? DateTime.now(),
      expectedDurationInMinutes: json['expectedDurationInMinutes'] ?? 0,
      registerDeadline: DateTime.tryParse(json['registerDeadline'] ?? '') ?? DateTime.now(),
      allowLateRegister: json['allowLateRegister'] ?? false,
      capacity: json['capacity'] ?? 0,
      fee: (json['fee'] as num).toDouble(),
      bannerUrl: json['bannerUrl'] ?? '',
      isPublic: json['isPublic'] ?? false,
      numberOfParticipants: json['numberOfParticipants'] ?? 0,
      planType: json['planType'] ?? '',
      isParticipant: json['isParticipant'] ?? false,
      host: HostModel.fromJson(json['host'] ?? {}),
      language: LanguageModel.fromJson(json['language'] ?? {}),
      categories: (json['categories'] as List<dynamic>? ?? [])
          .map((e) => CategoryModel.fromJson(e))
          .toList(),
    );
  }
}

class HostModel {
  final String id;
  final String name;
  final String? avatarUrl;

  HostModel({required this.id, required this.name, this.avatarUrl});

  factory HostModel.fromJson(Map<String, dynamic> json) {
    return HostModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      avatarUrl: json['avatarUrl'],
    );
  }
}

class LanguageModel {
  final String id;
  final String code;
  final String name;
  final String? iconUrl;

  LanguageModel({
    required this.id,
    required this.code,
    required this.name,
    this.iconUrl,
  });

  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    return LanguageModel(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      iconUrl: json['iconUrl'],
    );
  }
}

class CategoryModel {
  final String id;
  final String name;
  final String? iconUrl;

  CategoryModel({
    required this.id,
    required this.name,
    this.iconUrl,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      iconUrl: json['iconUrl'],
    );
  }
}

