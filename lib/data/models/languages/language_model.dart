class LanguageModel {
  final String id;
  final String code;
  final String name;
  final String flagIconUrl;

  LanguageModel({
    required this.id,
    required this.code,
    required this.name,
    required this.flagIconUrl,
  });

  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    return LanguageModel(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      flagIconUrl: json['flagIconUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'flagIconUrl': flagIconUrl,
    };
  }
}
