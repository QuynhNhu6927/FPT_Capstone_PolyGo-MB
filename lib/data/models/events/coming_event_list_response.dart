import 'coming_event_model.dart';

class ComingEventListResponse {
  final List<ComingEventModel> items;
  final int totalItems;
  final int currentPage;
  final int totalPages;
  final int pageSize;
  final bool hasPreviousPage;
  final bool hasNextPage;

  ComingEventListResponse({
    required this.items,
    required this.totalItems,
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });

  factory ComingEventListResponse.fromJson(Map<String, dynamic> json) =>
      ComingEventListResponse(
        items: (json['items'] as List)
            .map((e) => ComingEventModel.fromJson(e))
            .toList(),
        totalItems: json['totalItems'],
        currentPage: json['currentPage'],
        totalPages: json['totalPages'],
        pageSize: json['pageSize'],
        hasPreviousPage: json['hasPreviousPage'],
        hasNextPage: json['hasNextPage'],
      );
}
