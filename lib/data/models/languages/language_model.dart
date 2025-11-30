import '../../../core/config/api_constants.dart';

class LanguageModel {
  final String id;
  final String code;
  final String name;
  final String iconUrl;

  LanguageModel({
    required this.id,
    required this.code,
    required this.name,
    required this.iconUrl,
  });

  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    return LanguageModel(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      iconUrl: json['iconUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'flagIconUrl': iconUrl,
    };
  }

}
