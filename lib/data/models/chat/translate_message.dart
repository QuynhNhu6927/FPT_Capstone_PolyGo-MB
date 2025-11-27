class TranslatedMessage {
  final String id;
  final String conversationId;
  final String content;
  final String translatedContent;
  final String sourceLanguage;
  final String targetLanguage;
  final bool isAutoTranslated;
  final String sentAt;

  TranslatedMessage({
    required this.id,
    required this.conversationId,
    required this.content,
    required this.translatedContent,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.isAutoTranslated,
    required this.sentAt,
  });

  factory TranslatedMessage.fromJson(Map<String, dynamic> json) {
    return TranslatedMessage(
      id: json['id'] ?? '',
      conversationId: json['conversationId'] ?? '',
      content: json['content'] ?? '',
      translatedContent: json['translatedContent'] ?? '',
      sourceLanguage: json['sourceLanguage'] ?? '',
      targetLanguage: json['targetLanguage'] ?? '',
      isAutoTranslated: json['isAutoTranslated'] ?? false,
      sentAt: json['sentAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'conversationId': conversationId,
    'content': content,
    'translatedContent': translatedContent,
    'sourceLanguage': sourceLanguage,
    'targetLanguage': targetLanguage,
    'isAutoTranslated': isAutoTranslated,
    'sentAt': sentAt,
  };
}
