class CreatedWordSet {
  final String id;
  final String title;
  final String description;
  final String status;
  final String difficulty;
  final int estimatedTimeInMinutes;
  final int playCount;
  final int averageTimeInSeconds;
  final double averageRating;
  final int wordCount;
  final int totalPlays;
  final Language language;
  final DateTime createdAt;

  CreatedWordSet({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.difficulty,
    required this.estimatedTimeInMinutes,
    required this.playCount,
    required this.averageTimeInSeconds,
    required this.averageRating,
    required this.wordCount,
    required this.totalPlays,
    required this.language,
    required this.createdAt,
  });

  factory CreatedWordSet.fromJson(Map<String, dynamic> json) => CreatedWordSet(
    id: json['id'] ?? '',
    title: json['title'] ?? '',
    description: json['description'] ?? '',
    status: json['status'] ?? '',
    difficulty: json['difficulty'] ?? '',

    estimatedTimeInMinutes:
    (json['estimatedTimeInMinutes'] as num?)?.toInt() ?? 0,

    playCount:
    (json['playCount'] as num?)?.toInt() ?? 0,

    averageTimeInSeconds:
    (json['averageTimeInSeconds'] as num?)?.toInt() ?? 0,

    averageRating:
    (json['averageRating'] as num?)?.toDouble() ?? 0.0,

    wordCount:
    (json['wordCount'] as num?)?.toInt() ?? 0,

    totalPlays:
    (json['totalPlays'] as num?)?.toInt() ?? 0,

    language: json['language'] != null
        ? Language.fromJson(json['language'])
        : Language(id: '', code: '', name: 'Unknown', iconUrl: ''),

    createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'status': status,
    'difficulty': difficulty,
    'estimatedTimeInMinutes': estimatedTimeInMinutes,
    'playCount': playCount,
    'averageTimeInSeconds': averageTimeInSeconds,
    'averageRating': averageRating,
    'wordCount': wordCount,
    'totalPlays': totalPlays,
    'language': language.toJson(),
    'createdAt': createdAt.toIso8601String(),
  };
}

class CreatedWordSetListResponse {
  final List<CreatedWordSet> items;
  final int totalItems;
  final int currentPage;
  final int totalPages;
  final int pageSize;
  final bool hasPreviousPage;
  final bool hasNextPage;

  CreatedWordSetListResponse({
    required this.items,
    required this.totalItems,
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });

  factory CreatedWordSetListResponse.fromJson(Map<String, dynamic> json) =>
      CreatedWordSetListResponse(
        items: (json['items'] as List<dynamic>)
            .map((e) => CreatedWordSet.fromJson(e))
            .toList(),
        totalItems: json['totalItems'] ?? 0,
        currentPage: json['currentPage'] ?? 1,
        totalPages: json['totalPages'] ?? 1,
        pageSize: json['pageSize'] ?? 10,
        hasPreviousPage: json['hasPreviousPage'] ?? false,
        hasNextPage: json['hasNextPage'] ?? false,
      );

  Map<String, dynamic> toJson() => {
    'items': items.map((e) => e.toJson()).toList(),
    'totalItems': totalItems,
    'currentPage': currentPage,
    'totalPages': totalPages,
    'pageSize': pageSize,
    'hasPreviousPage': hasPreviousPage,
    'hasNextPage': hasNextPage,
  };
}

class Language {
  final String id;
  final String code;
  final String name;
  final String iconUrl;

  Language({
    required this.id,
    required this.code,
    required this.name,
    required this.iconUrl,
  });

  factory Language.fromJson(Map<String, dynamic> json) => Language(
    id: json['id'] ?? '',
    code: json['code'] ?? '',
    name: json['name'] ?? '',
    iconUrl: json['iconUrl'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'name': name,
    'iconUrl': iconUrl,
  };
}
