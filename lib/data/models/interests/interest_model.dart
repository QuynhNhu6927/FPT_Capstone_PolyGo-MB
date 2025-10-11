import '../../../core/config/api_constants.dart';

class InterestModel {
  final String id;
  final String code;
  final String name;
  final String description;
  final String iconUrl;

  InterestModel({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.iconUrl,
  });

  factory InterestModel.fromJson(Map<String, dynamic> json) {
    return InterestModel(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      iconUrl: json['iconUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'description': description,
      'iconUrl': iconUrl,
    };
  }

  // String get fullIconUrl => '${ApiConstants.baseUrl}/$iconUrl';
}
