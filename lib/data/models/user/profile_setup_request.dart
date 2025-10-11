class ProfileSetupRequest {
  final List<String> learningLanguageIds;
  final List<String> speakingLanguageIds;
  final List<String> interestIds;

  ProfileSetupRequest({
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
