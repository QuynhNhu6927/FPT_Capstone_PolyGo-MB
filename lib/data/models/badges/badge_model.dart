import '../../../core/config/api_constants.dart';

class BadgeModel {
  final String id;
  final String lang;
  final String code;
  final String name;
  final String description;
  final String iconUrl;
  final String badgeCategory;
  final String createdAt;
  final String lastUpdatedAt;
  final bool has;

  BadgeModel({
    required this.id,
    required this.lang,
    required this.code,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.badgeCategory,
    required this.createdAt,
    required this.lastUpdatedAt,
    this.has = true,
  });

  factory BadgeModel.fromJson(Map<String, dynamic> json) {
    return BadgeModel(
      id: json['id'] ?? '',
      lang: json['lang'] ?? '',
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      iconUrl: json['iconUrl'] ?? '',
      badgeCategory: json['badgeCategory'] ?? '',
      createdAt: json['createdAt'] ?? '',
      lastUpdatedAt: json['lastUpdatedAt'] ?? '',
      has: json['has'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lang': lang,
      'code': code,
      'name': name,
      'description': description,
      'iconUrl': iconUrl,
      'badgeCategory': badgeCategory,
      'createdAt': createdAt,
      'lastUpdatedAt': lastUpdatedAt,
      'has': has,
    };
  }

}
