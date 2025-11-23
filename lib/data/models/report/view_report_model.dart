import 'package:polygo_mobile/data/models/report/report_request.dart';

class ViewReportsResponse {
  final List<ReportResponse> items;
  final int totalItems;
  final int currentPage;
  final int totalPages;
  final int pageSize;
  final bool hasPreviousPage;
  final bool hasNextPage;

  ViewReportsResponse({
    required this.items,
    required this.totalItems,
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });

  factory ViewReportsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return ViewReportsResponse(
      items: (data['items'] as List<dynamic>?)
          ?.map((e) => ReportResponse.fromJson(e))
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
