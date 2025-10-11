class LearnLanguageModel {
  final String id;
  final String lang;
  final String name;
  final String iconUrl;
  final bool isLearning;

  LearnLanguageModel({
    required this.id,
    required this.lang,
    required this.name,
    required this.iconUrl,
    required this.isLearning,
  });

  factory LearnLanguageModel.fromJson(Map<String, dynamic> json) {
    return LearnLanguageModel(
      id: json['id'] ?? '',
      lang: json['lang'] ?? '',
      name: json['name'] ?? '',
      iconUrl: json['iconUrl'] ?? '',
      isLearning: json['isLearning'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': lang,
      'name': name,
      'iconUrl': iconUrl,
      'isSpeaking': isLearning,
    };
  }
}
