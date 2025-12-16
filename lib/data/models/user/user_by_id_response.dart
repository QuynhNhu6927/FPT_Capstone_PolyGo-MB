class UserByIdResponse {
  final String id;
  final String name;
  final String? avatarUrl;
  final String? introduction;
  final String? mail;
  final int? merit;
  final String? gender;
  final String friendStatus;
  final int? experiencePoints;
  final String? planType;

  final int? level;
  final int? xpInCurrentLevel;
  final int? xpToNextLevel;
  final bool? isOnline;

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
    this.merit,
    this.gender,
    required this.friendStatus,
    this.experiencePoints,
    this.planType,

    this.level,
    this.xpInCurrentLevel,
    this.xpToNextLevel,
    this.isOnline,

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
      merit: json['merit'],
      gender: json['gender'],
      friendStatus: json['friendStatus'] ?? '',
      experiencePoints: json['experiencePoints'],
      planType: json['planType'],

      level: json['level'],
      xpInCurrentLevel: json['xpInCurrentLevel'],
      xpToNextLevel: json['xpToNextLevel'],
      isOnline: json['isOnline'],

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
    'merit': merit,
    'gender': gender,
    'friendStatus': friendStatus,
    'experiencePoints': experiencePoints,
    'planType': planType,

    'level': level,
    'xpInCurrentLevel': xpInCurrentLevel,
    'xpToNextLevel': xpToNextLevel,
    'isOnline': isOnline,

    'speakingLanguages': speakingLanguages,
    'learningLanguages': learningLanguages,
    'interests': interests,
    'badges': badges,
    'gifts': gifts,
  };
}
