import 'subscription_plan_model.dart';

class SubscriptionPlanListResponse {
  final List<SubscriptionPlan> items;
  final int totalItems;
  final int currentPage;
  final int totalPages;
  final int pageSize;

  SubscriptionPlanListResponse({
    required this.items,
    required this.totalItems,
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
  });

  factory SubscriptionPlanListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    final List<dynamic> list = data['items'] ?? [];

    return SubscriptionPlanListResponse(
      items: list.map((e) => SubscriptionPlan.fromJson(e)).toList(),
      totalItems: data['totalItems'] ?? 0,
      currentPage: data['currentPage'] ?? 1,
      totalPages: data['totalPages'] ?? 1,
      pageSize: data['pageSize'] ?? 0,
    );
  }
}
