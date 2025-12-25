class SendSummaryMailResponse {
  final String message;

  SendSummaryMailResponse({required this.message});

  factory SendSummaryMailResponse.fromJson(Map<String, dynamic> json) {
    return SendSummaryMailResponse(
      message: json['message'] ?? '',
    );
  }
}
