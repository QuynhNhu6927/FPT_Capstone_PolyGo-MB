class SpeakLanguageModel {
  final String id;
  final String lang;
  final String name;
  final String iconUrl;
  final bool isSpeaking;

  SpeakLanguageModel({
    required this.id,
    required this.lang,
    required this.name,
    required this.iconUrl,
    required this.isSpeaking,
  });

  factory SpeakLanguageModel.fromJson(Map<String, dynamic> json) {
    return SpeakLanguageModel(
      id: json['id'] ?? '',
      lang: json['lang'] ?? '',
      name: json['name'] ?? '',
      iconUrl: json['iconUrl'] ?? '',
      isSpeaking: json['isSpeaking'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': lang,
      'name': name,
      'iconUrl': iconUrl,
      'isSpeaking': isSpeaking,
    };
  }
}
