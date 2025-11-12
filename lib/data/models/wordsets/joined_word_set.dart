// =================== PLAYED WORDSET MODELS ===================

class PlayedCreator {
  final String id;
  final String name;
  final String? avatarUrl;

  PlayedCreator({
    required this.id,
    required this.name,
    this.avatarUrl,
  });

  factory PlayedCreator.fromJson(Map<String, dynamic> json) => PlayedCreator(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    avatarUrl: json['avatarUrl'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'avatarUrl': avatarUrl,
  };
}

class PlayedWordSet {
  final String id;
  final String title;
  final String description;
  final String difficulty;
  final String category;
  final int bestTime;
  final int bestScore;
  final int playCount;
  final DateTime lastPlayed;
  final PlayedCreator creator;

  PlayedWordSet({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.category,
    required this.bestTime,
    required this.bestScore,
    required this.playCount,
    required this.lastPlayed,
    required this.creator,
  });

  factory PlayedWordSet.fromJson(Map<String, dynamic> json) => PlayedWordSet(
    id: json['id'] ?? '',
    title: json['title'] ?? '',
    description: json['description'] ?? '',
    difficulty: json['difficulty'] ?? '',
    category: json['category'] ?? '',
    bestTime: (json['bestTime'] ?? 0) as int,
    bestScore: (json['bestScore'] ?? 0) as int,
    playCount: (json['playCount'] ?? 0) as int,
    lastPlayed: DateTime.parse(json['lastPlayed']),
    creator: PlayedCreator.fromJson(json['creator']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'difficulty': difficulty,
    'category': category,
    'bestTime': bestTime,
    'bestScore': bestScore,
    'playCount': playCount,
    'lastPlayed': lastPlayed.toIso8601String(),
    'creator': creator.toJson(),
  };
}

class PlayedWordSetListResponse {
  final List<PlayedWordSet> items;
  final int totalItems;
  final int currentPage;
  final int totalPages;
  final int pageSize;
  final bool hasPreviousPage;
  final bool hasNextPage;

  PlayedWordSetListResponse({
    required this.items,
    required this.totalItems,
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });

  factory PlayedWordSetListResponse.fromJson(Map<String, dynamic> json) =>
      PlayedWordSetListResponse(
        items: (json['items'] as List<dynamic>)
            .map((e) => PlayedWordSet.fromJson(e))
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
