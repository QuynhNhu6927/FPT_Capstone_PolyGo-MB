class UpdateTranslationLanguageRequest {
  final String languageCode;

  UpdateTranslationLanguageRequest({required this.languageCode});

  Map<String, dynamic> toJson() => {
    'languageCode': languageCode,
  };
}
