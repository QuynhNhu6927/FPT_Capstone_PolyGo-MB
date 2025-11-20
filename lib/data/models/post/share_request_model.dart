class SharePostRequest {
  final String shareType;
  final String targetId;
  final String content;

  SharePostRequest({
    required this.shareType,
    required this.targetId,
    this.content = "",
  });

  Map<String, dynamic> toJson() {
    return {
      "shareType": shareType,
      "targetId": targetId,
      "content": content,
    };
  }

  factory SharePostRequest.fromJson(Map<String, dynamic> json) {
    return SharePostRequest(
      shareType: json["shareType"] ?? "",
      targetId: json["targetId"] ?? "",
      content: json["content"] ?? "",
    );
  }
}
