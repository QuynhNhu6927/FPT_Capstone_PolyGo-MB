class SendInquiryRequest {
  final String userNotes;

  SendInquiryRequest({required this.userNotes});

  Map<String, dynamic> toJson() => {
    'userNotes': userNotes,
  };
}

class SendInquiryResponse {
  final String message;

  SendInquiryResponse({required this.message});

  factory SendInquiryResponse.fromJson(Map<String, dynamic> json) {
    return SendInquiryResponse(
      message: json['message'] as String? ?? '',
    );
  }
}

