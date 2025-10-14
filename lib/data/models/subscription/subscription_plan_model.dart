class SubscriptionFeature {
  final String featureType;
  final String featureName;
  final int limitValue;
  final String limitType;
  final bool isEnabled;

  SubscriptionFeature({
    required this.featureType,
    required this.featureName,
    required this.limitValue,
    required this.limitType,
    required this.isEnabled,
  });

  factory SubscriptionFeature.fromJson(Map<String, dynamic> json) {
    return SubscriptionFeature(
      featureType: json['featureType'] ?? '',
      featureName: json['featureName'] ?? '',
      limitValue: json['limitValue'] ?? 0,
      limitType: json['limitType'] ?? '',
      isEnabled: json['isEnabled'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'featureType': featureType,
    'featureName': featureName,
    'limitValue': limitValue,
    'limitType': limitType,
    'isEnabled': isEnabled,
  };
}

class SubscriptionPlan {
  final String id;
  final String planType;
  final String name;
  final String description;
  final double price;
  final int durationInDays;
  final bool isActive;
  final String createdAt;
  final String lastUpdatedAt;
  final List<SubscriptionFeature> features;

  SubscriptionPlan({
    required this.id,
    required this.planType,
    required this.name,
    required this.description,
    required this.price,
    required this.durationInDays,
    required this.isActive,
    required this.createdAt,
    required this.lastUpdatedAt,
    required this.features,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    final List<dynamic> featureList = json['features'] ?? [];
    return SubscriptionPlan(
      id: json['id'] ?? '',
      planType: json['planType'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      durationInDays: json['durationInDays'] ?? 0,
      isActive: json['isActive'] ?? false,
      createdAt: json['createdAt'] ?? '',
      lastUpdatedAt: json['lastUpdatedAt'] ?? '',
      features: featureList.map((f) => SubscriptionFeature.fromJson(f)).toList(),
    );
  }
}
