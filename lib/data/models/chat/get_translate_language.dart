class ConversationTranslationLanguage {
  String conversationId;
  String effectiveLanguageCode;
  String fallbackLanguageCode;

  ConversationTranslationLanguage({
    required this.conversationId,
    required this.effectiveLanguageCode,
    required this.fallbackLanguageCode,
  });

  factory ConversationTranslationLanguage.fromJson(Map<String, dynamic> json) {
    return ConversationTranslationLanguage(
      conversationId: json['conversationId'] ?? '',
      effectiveLanguageCode: json['effectiveLanguageCode'] ?? 'en',
      fallbackLanguageCode: json['fallbackLanguageCode'] ?? 'en',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conversationId': conversationId,
      'effectiveLanguageCode': effectiveLanguageCode,
      'fallbackLanguageCode': fallbackLanguageCode,
    };
  }
}
