class WithdrawConfirmRequest {
  final String otp;

  WithdrawConfirmRequest({required this.otp});

  Map<String, dynamic> toJson() => {
    'otp': otp,
  };
}
class WithdrawConfirmResponse {
  final String message;

  WithdrawConfirmResponse({required this.message});

  factory WithdrawConfirmResponse.fromJson(Map<String, dynamic> json) {
    return WithdrawConfirmResponse(
      message: json['message'] ?? '',
    );
  }
}
