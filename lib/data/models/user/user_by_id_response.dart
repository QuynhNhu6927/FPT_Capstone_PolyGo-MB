class UserByIdResponse {
  final String id;
  final String name;
  final String? avatarUrl;
  final String? introduction;
  final String? mail;
  final String? meritLevel;
  final String? gender;
  final int? experiencePoints;
  final String? planType;
  final List<dynamic>? speakingLanguages;
  final List<dynamic>? learningLanguages;
  final List<dynamic>? interests;
  final List<dynamic>? badges;
  final List<dynamic>? gifts;

  UserByIdResponse({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.introduction,
    this.mail,
    this.meritLevel,
    this.gender,
    this.experiencePoints,
    this.planType,
    this.speakingLanguages,
    this.learningLanguages,
    this.interests,
    this.badges,
    this.gifts,
  });
  factory UserByIdResponse.fromJson(Map<String, dynamic> json) {
    return UserByIdResponse(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      avatarUrl: json['avatarUrl'],
      introduction: json['introduction'],
      mail: json['mail'],
      meritLevel: json['meritLevel'],
      gender: json['gender'],
      experiencePoints: json['experiencePoints'],
      planType: json['planType'],
      speakingLanguages: List<dynamic>.from(json['speakingLanguages'] ?? []),
      learningLanguages: List<dynamic>.from(json['learningLanguages'] ?? []),
      interests: List<dynamic>.from(json['interests'] ?? []),
      badges: List<dynamic>.from(json['badges'] ?? []),
      gifts: List<dynamic>.from(json['gifts'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'avatarUrl': avatarUrl,
    'introduction': introduction,
    'mail': mail,
    'meritLevel': meritLevel,
    'gender': gender,
    'experiencePoints': experiencePoints,
    'planType': planType,
    'speakingLanguages': speakingLanguages,
    'learningLanguages': learningLanguages,
    'interests': interests,
    'badges': badges,
    'gifts': gifts,
  };
}
