import '../gift/gift_model.dart';
import '../languages/language_model.dart';
import '../interests/interest_model.dart';
import '../gift/gift_model.dart';

class FriendModel {
  final String id;
  final String name;
  final String avatarUrl;
  final String introduction;
  final String mail;
  final int merit;
  final String gender;
  final int experiencePoints;
  final String planType;
  final String acceptedAt;
  final List<LanguageModel> speakingLanguages;
  final List<LanguageModel> learningLanguages;
  final List<InterestModel> interests;
  final List<GiftModel> gifts;

  FriendModel({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.introduction,
    required this.mail,
    required this.merit,
    required this.gender,
    required this.experiencePoints,
    required this.planType,
    required this.acceptedAt,
    required this.speakingLanguages,
    required this.learningLanguages,
    required this.interests,
    required this.gifts,
  });

  factory FriendModel.fromJson(Map<String, dynamic> json) {
    return FriendModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      introduction: json['introduction'] ?? '',
      mail: json['mail'] ?? '',
      merit: json['merit'] ?? 0,
      gender: json['gender'] ?? '',
      experiencePoints: json['experiencePoints'] ?? 0,
      planType: json['planType'] ?? '',
      acceptedAt: json['acceptedAt'] ?? '',
      speakingLanguages: (json['speakingLanguages'] as List<dynamic>?)
          ?.map((e) => LanguageModel.fromJson(e))
          .toList() ??
          [],
      learningLanguages: (json['learningLanguages'] as List<dynamic>?)
          ?.map((e) => LanguageModel.fromJson(e))
          .toList() ??
          [],
      interests: (json['interests'] as List<dynamic>?)
          ?.map((e) => InterestModel.fromJson(e))
          .toList() ??
          [],
      gifts: (json['gifts'] as List<dynamic>?)
          ?.map((e) => GiftModel.fromJson(e))
          .toList() ??
          [],
    );
  }
}
