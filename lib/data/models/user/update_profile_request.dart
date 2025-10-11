class UpdateProfileRequest {
  final List<String> learningLanguageIds;
  final List<String> speakingLanguageIds;
  final List<String> interestIds;

  UpdateProfileRequest({
    required this.learningLanguageIds,
    required this.speakingLanguageIds,
    required this.interestIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'learningLanguageIds': learningLanguageIds,
      'speakingLanguageIds': speakingLanguageIds,
      'interestIds': interestIds,
    };
  }
}
