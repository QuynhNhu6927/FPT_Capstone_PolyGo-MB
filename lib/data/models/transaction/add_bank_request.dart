// add_bank_request.dart
class AddBankRequest {
  final String bankName;
  final String bankNumber;
  final String accountName;

  AddBankRequest({
    required this.bankName,
    required this.bankNumber,
    required this.accountName,
  });

  Map<String, dynamic> toJson() {
    return {
      "bankName": bankName,
      "bankNumber": bankNumber,
      "accountName": accountName,
    };
  }
}
class AddBankResponse {
  final String message;

  AddBankResponse({required this.message});

  factory AddBankResponse.fromJson(Map<String, dynamic> json) {
    return AddBankResponse(
      message: json['message'] as String,
    );
  }
}
