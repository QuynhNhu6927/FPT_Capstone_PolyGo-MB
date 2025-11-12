// =================== WORDSET MODEL ===================
class WordSetModel {
  final String id;
  final String title;
  final String description;
  final String status;
  final String difficulty;
  final String category;
  final int estimatedTimeInMinutes;
  final int playCount;
  final double averageTimeInSeconds;
  final double averageRating;
  final int wordCount;
  final Language language;
  final Creator creator;
  final List<Word>? words;
  final DateTime createdAt;
  final DateTime? lastUpdatedAt;

  WordSetModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.difficulty,
    required this.category,
    required this.estimatedTimeInMinutes,
    required this.playCount,
    required this.averageTimeInSeconds,
    required this.averageRating,
    required this.wordCount,
    required this.language,
    required this.creator,
    this.words,
    required this.createdAt,
    this.lastUpdatedAt,
  });

  factory WordSetModel.fromJson(Map<String, dynamic> json) => WordSetModel(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    status: json['status'],
    difficulty: json['difficulty'],
    category: json['category'],
    estimatedTimeInMinutes: (json['estimatedTimeInMinutes'] ?? 0) as int,
    playCount: (json['playCount'] ?? 0) as int,
    averageTimeInSeconds: (json['averageTimeInSeconds'] ?? 0).toDouble(),
    averageRating: (json['averageRating'] ?? 0).toDouble(),
    wordCount: (json['wordCount'] ?? 0) as int,
    language: json['language'] != null
        ? Language.fromJson(json['language'])
        : Language(id: '', code: '', name: 'Unknown', iconUrl: ''),
    creator: json['creator'] != null
        ? Creator.fromJson(json['creator'])
        : Creator(id: '', name: 'Unknown'),
    words: json['words'] != null
        ? (json['words'] as List<dynamic>)
        .map((e) => Word.fromJson(e))
        .toList()
        : null,
    createdAt: DateTime.parse(json['createdAt']),
    lastUpdatedAt: json['lastUpdatedAt'] != null
        ? DateTime.parse(json['lastUpdatedAt'])
        : null,
  );
}

// =================== LANGUAGE MODEL ===================
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
    id: json['id'],
    code: json['code'],
    name: json['name'],
    iconUrl: json['iconUrl'],
  );
}

// =================== CREATOR MODEL ===================
class Creator {
  final String id;
  final String name;
  final String? avatarUrl;

  Creator({
    required this.id,
    required this.name,
    this.avatarUrl,
  });

  factory Creator.fromJson(Map<String, dynamic> json) => Creator(
    id: json['id'],
    name: json['name'],
    avatarUrl: json['avatarUrl'],
  );
}

// =================== WORD MODEL ===================
class Word {
  final String id;
  final String word;
  final String definition;
  final String? hint;

  Word({
    required this.id,
    required this.word,
    required this.definition,
    this.hint,
  });

  factory Word.fromJson(Map<String, dynamic> json) => Word(
    id: json['id'],
    word: json['word'],
    definition: json['definition'],
  );
}

// =================== PAGED RESPONSE MODEL ===================
class WordSetListResponse {
  final List<WordSetModel> items;
  final int totalItems;
  final int currentPage;
  final int totalPages;
  final int pageSize;
  final bool hasPreviousPage;
  final bool hasNextPage;

  WordSetListResponse({
    required this.items,
    required this.totalItems,
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });

  factory WordSetListResponse.fromJson(Map<String, dynamic> json) =>
      WordSetListResponse(
        items: (json['items'] as List<dynamic>)
            .map((e) => WordSetModel.fromJson(e))
            .toList(),
        totalItems: json['totalItems'],
        currentPage: json['currentPage'],
        totalPages: json['totalPages'],
        pageSize: json['pageSize'],
        hasPreviousPage: json['hasPreviousPage'],
        hasNextPage: json['hasNextPage'],
      );
}
