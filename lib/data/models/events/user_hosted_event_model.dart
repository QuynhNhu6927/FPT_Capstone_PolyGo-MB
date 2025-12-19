class UserHostedEventModel {
  final String id;
  final String title;
  final String description;
  final String status;
  final DateTime startAt;
  final DateTime endAt;
  final int expectedDurationInMinutes;
  final DateTime registerDeadline;
  final bool allowLateRegister;
  final int capacity;
  final double fee;
  final String bannerUrl;
  final bool isPublic;
  final int numberOfParticipants;
  final String planType;
  final bool hostPayoutClaimed;
  final HostedEventHostModel host;
  final HostedEventLanguageModel language;
  final List<HostedEventCategoryModel> categories;

  UserHostedEventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.startAt,
    required this.endAt,
    required this.expectedDurationInMinutes,
    required this.registerDeadline,
    required this.allowLateRegister,
    required this.capacity,
    required this.fee,
    required this.bannerUrl,
    required this.isPublic,
    required this.numberOfParticipants,
    required this.planType,
    required this.hostPayoutClaimed,
    required this.host,
    required this.language,
    required this.categories,
  });

  factory UserHostedEventModel.fromJson(Map<String, dynamic> json) {
    return UserHostedEventModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? '',
      startAt: DateTime.tryParse(json['startAt'] ?? '') ?? DateTime.now(),
      endAt: DateTime.tryParse(json['endAt'] ?? '') ?? DateTime.now(),
      expectedDurationInMinutes: json['expectedDurationInMinutes'] ?? 0,
      registerDeadline:
      DateTime.tryParse(json['registerDeadline'] ?? '') ?? DateTime.now(),
      allowLateRegister: json['allowLateRegister'] ?? false,
      capacity: json['capacity'] ?? 0,
      fee: (json['fee'] as num?)?.toDouble() ?? 0,
      bannerUrl: json['bannerUrl'] ?? '',
      isPublic: json['isPublic'] ?? false,
      numberOfParticipants: json['numberOfParticipants'] ?? 0,
      planType: json['planType'] ?? '',
      hostPayoutClaimed: json['hostPayoutClaimed'] ?? false,
      host: HostedEventHostModel.fromJson(json['host'] ?? {}),
      language: HostedEventLanguageModel.fromJson(json['language'] ?? {}),
      categories: (json['categories'] as List<dynamic>? ?? [])
          .map((e) => HostedEventCategoryModel.fromJson(e))
          .toList(),
    );
  }
}

class HostedEventHostModel {
  final String id;
  final String name;
  final String? avatarUrl;

  HostedEventHostModel({
    required this.id,
    required this.name,
    this.avatarUrl,
  });

  factory HostedEventHostModel.fromJson(Map<String, dynamic> json) {
    return HostedEventHostModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      avatarUrl: json['avatarUrl'],
    );
  }
}

class HostedEventLanguageModel {
  final String id;
  final String code;
  final String name;
  final String? iconUrl;

  HostedEventLanguageModel({
    required this.id,
    required this.code,
    required this.name,
    this.iconUrl,
  });

  factory HostedEventLanguageModel.fromJson(Map<String, dynamic> json) {
    return HostedEventLanguageModel(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      iconUrl: json['iconUrl'],
    );
  }
}

class HostedEventCategoryModel {
  final String id;
  final String name;
  final String? iconUrl;

  HostedEventCategoryModel({
    required this.id,
    required this.name,
    this.iconUrl,
  });

  factory HostedEventCategoryModel.fromJson(Map<String, dynamic> json) {
    return HostedEventCategoryModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      iconUrl: json['iconUrl'],
    );
  }
}

class UserHostedEventListResponse {
  final List<UserHostedEventModel> items;
  final int totalItems;
  final int currentPage;
  final int totalPages;
  final int pageSize;
  final bool hasPreviousPage;
  final bool hasNextPage;

  UserHostedEventListResponse({
    required this.items,
    required this.totalItems,
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });

  factory UserHostedEventListResponse.fromJson(Map<String, dynamic> json) {
    return UserHostedEventListResponse(
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => UserHostedEventModel.fromJson(e))
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
