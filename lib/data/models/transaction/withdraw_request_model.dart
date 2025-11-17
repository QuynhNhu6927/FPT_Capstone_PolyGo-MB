class WithdrawRequestModel {
  final int amount;
  final String bankName;
  final String bankNumber;
  final String accountName;

  WithdrawRequestModel({
    required this.amount,
    required this.bankName,
    required this.bankNumber,
    required this.accountName,
  });

  Map<String, dynamic> toJson() => {
    "amount": amount,
    "bankName": bankName,
    "bankNumber": bankNumber,
    "accountName": accountName,
  };
}

class WithdrawResponse {
  final String message;

  WithdrawResponse({required this.message});

  factory WithdrawResponse.fromJson(Map<String, dynamic> json) =>
      WithdrawResponse(message: json['message'] ?? '');
}
