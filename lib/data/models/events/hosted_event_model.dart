class HostedEventModel {
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
  final HostedEventHost host;
  final HostedEventLanguage language;
  final List<HostedEventCategory> categories;

  HostedEventModel({
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
    required this.host,
    required this.language,
    required this.categories,
  });

  factory HostedEventModel.fromJson(Map<String, dynamic> json) {
    return HostedEventModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? '',
      startAt: DateTime.parse(json['startAt']),
      expectedDurationInMinutes: json['expectedDurationInMinutes'] ?? 0,
      registerDeadline: DateTime.parse(json['registerDeadline']),
      allowLateRegister: json['allowLateRegister'] ?? false,
      capacity: json['capacity'] ?? 0,
      fee: json['fee'] ?? 0,
      bannerUrl: json['bannerUrl'] ?? '',
      isPublic: json['isPublic'] ?? true,
      numberOfParticipants: json['numberOfParticipants'] ?? 0,
      planType: json['planType'] ?? 'Free',
      host: HostedEventHost.fromJson(json['host']),
      language: HostedEventLanguage.fromJson(json['language']),
      categories: (json['categories'] as List<dynamic>? ?? [])
          .map((e) => HostedEventCategory.fromJson(e))
          .toList(),
    );
  }
}

class HostedEventHost {
  final String id;
  final String name;
  final String? avatarUrl;

  HostedEventHost({required this.id, required this.name, this.avatarUrl});

  factory HostedEventHost.fromJson(Map<String, dynamic> json) {
    return HostedEventHost(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      avatarUrl: json['avatarUrl'],
    );
  }
}

class HostedEventLanguage {
  final String id;
  final String code;
  final String lang;
  final String name;
  final String iconUrl;

  HostedEventLanguage({
    required this.id,
    required this.code,
    required this.lang,
    required this.name,
    required this.iconUrl,
  });

  factory HostedEventLanguage.fromJson(Map<String, dynamic> json) {
    return HostedEventLanguage(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      lang: json['lang'] ?? '',
      name: json['name'] ?? '',
      iconUrl: json['iconUrl'] ?? '',
    );
  }
}

class HostedEventCategory {
  final String id;
  final String lang;
  final String name;
  final String iconUrl;

  HostedEventCategory({
    required this.id,
    required this.lang,
    required this.name,
    required this.iconUrl,
  });

  factory HostedEventCategory.fromJson(Map<String, dynamic> json) {
    return HostedEventCategory(
      id: json['id'] ?? '',
      lang: json['lang'] ?? '',
      name: json['name'] ?? '',
      iconUrl: json['iconUrl'] ?? '',
    );
  }
}

class HostedEventListResponse {
  final List<HostedEventModel> items;
  final int totalItems;
  final int currentPage;
  final int totalPages;
  final int pageSize;

  HostedEventListResponse({
    required this.items,
    required this.totalItems,
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
  });

  factory HostedEventListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['items'] as List<dynamic>? ?? [];
    return HostedEventListResponse(
      items: data.map((e) => HostedEventModel.fromJson(e)).toList(),
      totalItems: json['totalItems'] ?? 0,
      currentPage: json['currentPage'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
      pageSize: json['pageSize'] ?? 10,
    );
  }
}
