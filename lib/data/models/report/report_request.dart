class ReportRequestModel {
  final String reportType;
  final String targetId;
  final String reason;
  final String description;
  final List<String> imageUrls;

  ReportRequestModel({
    required this.reportType,
    required this.targetId,
    required this.reason,
    required this.description,
    required this.imageUrls,
  });

  Map<String, dynamic> toJson() => {
    'reportType': reportType,
    'targetId': targetId,
    'reason': reason,
    'description': description,
    'imageUrls': imageUrls,
  };
}

class ReportResponse {
  final String? id;
  final String? reportType;
  final String? targetId;
  final String? reason;
  final String? description;
  final List<String>? imageUrls;
  final String? status;
  final DateTime? createdAt;

  ReportResponse({
    this.id,
    this.reportType,
    this.targetId,
    this.reason,
    this.description,
    this.imageUrls,
    this.status,
    this.createdAt,
  });

  factory ReportResponse.fromJson(Map<String, dynamic> json) {
    return ReportResponse(
      id: json['id']?.toString(),
      reportType: json['reportType']?.toString(),
      targetId: json['targetId']?.toString(),
      reason: json['reason']?.toString(),
      description: json['description']?.toString(),
      imageUrls: (json['imageUrls'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      status: json['status']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }
}
