class GiftModel {
  final String id;
  final String lang;
  final String name;
  final String description;
  final String iconUrl;
  final int price;
  final String createdAt;
  final String lastUpdatedAt;

  GiftModel({
    required this.id,
    required this.lang,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.price,
    required this.createdAt,
    required this.lastUpdatedAt,
  });

  factory GiftModel.fromJson(Map<String, dynamic> json) {
    return GiftModel(
      id: json['id'] ?? '',
      lang: json['lang'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      iconUrl: json['iconUrl'] ?? '',
      price: json['price'] ?? 0,
      createdAt: json['createdAt'] ?? '',
      lastUpdatedAt: json['lastUpdatedAt'] ?? '',
    );
  }
}
