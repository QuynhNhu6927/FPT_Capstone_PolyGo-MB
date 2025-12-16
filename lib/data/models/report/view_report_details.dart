class ViewReportModel {
  final String? id;
  final String? reportType;
  final String? targetId;
  final String? reporterId;
  final String? reason;
  final String? description;
  final List<String>? imageUrls;
  final String? status;
  final DateTime? createdAt;
  final Reporter? reporter;
  final TargetInfo? targetInfo;

  ViewReportModel({
    this.id,
    this.reportType,
    this.targetId,
    this.reporterId,
    this.reason,
    this.description,
    this.imageUrls,
    this.status,
    this.createdAt,
    this.reporter,
    this.targetInfo,
  });

  factory ViewReportModel.fromJson(Map<String, dynamic> json) {
    return ViewReportModel(
      id: json['id']?.toString(),
      reportType: json['reportType']?.toString(),
      targetId: json['targetId']?.toString(),
      reporterId: json['reporterId']?.toString(),
      reason: json['reason']?.toString(),
      description: json['description']?.toString(),
      imageUrls: (json['imageUrls'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      status: json['status']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      reporter: json['reporter'] != null
          ? Reporter.fromJson(json['reporter'])
          : null,
      targetInfo: json['targetInfo'] != null
          ? TargetInfo.fromJson(json['targetInfo'])
          : null,
    );
  }
}

class Reporter {
  final String? id;
  final String? name;
  final String? mail;
  final String? avatarUrl;

  Reporter({this.id, this.name, this.mail, this.avatarUrl});

  factory Reporter.fromJson(Map<String, dynamic> json) {
    return Reporter(
      id: json['id']?.toString(),
      name: json['name']?.toString(),
      mail: json['mail']?.toString(),
      avatarUrl: json['avatarUrl']?.toString(),
    );
  }
}

class TargetInfo {
  final String? id;
  final String? name; // User
  final String? mail; // User
  final String? content; // Post
  final Creator? creator; // Post
  final String? title; // Event
  final String? description; // Event
  final String? status; // Event

  TargetInfo({
    this.id,
    this.name,
    this.mail,
    this.content,
    this.creator,
    this.title,
    this.description,
    this.status,
  });

  factory TargetInfo.fromJson(Map<String, dynamic> json) {
    return TargetInfo(
      id: json['id']?.toString(),
      name: json['name']?.toString(),
      mail: json['mail']?.toString(),
      content: json['content']?.toString(),
      creator: json['creator'] != null ? Creator.fromJson(json['creator']) : null,
      title: json['title']?.toString(),
      description: json['description']?.toString(),
      status: json['status']?.toString(),
    );
  }
}

class Creator {
  final String? id;
  final String? name;

  Creator({this.id, this.name});

  factory Creator.fromJson(Map<String, dynamic> json) {
    return Creator(
      id: json['id']?.toString(),
      name: json['name']?.toString(),
    );
  }
}
