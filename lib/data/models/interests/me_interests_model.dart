class MeInterestModel {
  final String id;
  final String lang;
  final String name;
  final String description;
  final String iconUrl;
  final bool has;

  MeInterestModel({
    required this.id,
    required this.lang,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.has,
  });

  factory MeInterestModel.fromJson(Map<String, dynamic> json) {
    return MeInterestModel(
      id: json['id'] ?? '',
      lang: json['lang'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      iconUrl: json['iconUrl'] ?? '',
      has: json['has'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lang': lang,
      'name': name,
      'description': description,
      'iconUrl': iconUrl,
      'has': has,
    };
  }
}
