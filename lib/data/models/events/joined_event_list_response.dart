// models/events/joined_event_list_response.dart
import 'joined_event_model.dart';

class JoinedEventListResponse {
  final List<JoinedEventModel> items;
  final int totalItems;
  final int currentPage;
  final int totalPages;
  final int pageSize;
  final bool hasPreviousPage;
  final bool hasNextPage;

  JoinedEventListResponse({
    required this.items,
    required this.totalItems,
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });

  factory JoinedEventListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return JoinedEventListResponse(
      items: (data['items'] as List<dynamic>?)
          ?.map((e) => JoinedEventModel.fromJson(e))
          .toList() ??
          [],
      totalItems: data['totalItems'] ?? 0,
      currentPage: data['currentPage'] ?? 1,
      totalPages: data['totalPages'] ?? 1,
      pageSize: data['pageSize'] ?? 10,
      hasPreviousPage: data['hasPreviousPage'] ?? false,
      hasNextPage: data['hasNextPage'] ?? false,
    );
  }
}
