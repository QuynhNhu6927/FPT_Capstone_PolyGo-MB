class DeleteBankResponse {
  final String message;

  DeleteBankResponse({required this.message});

  factory DeleteBankResponse.fromJson(Map<String, dynamic> json) {
    return DeleteBankResponse(
      message: json['message'] ?? '',
    );
  }
}
