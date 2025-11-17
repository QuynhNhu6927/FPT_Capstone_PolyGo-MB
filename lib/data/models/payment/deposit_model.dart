class DepositUrlRequest {
  final int amount;
  final String returnUrl;
  final String cancelUrl;

  DepositUrlRequest({
    required this.amount,
    required this.returnUrl,
    required this.cancelUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      "amount": amount,
      "returnUrl": returnUrl,
      "cancelUrl": cancelUrl,
    };
  }
}

class DepositUrlResponse {
  final String depositUrl;
  final int orderCode;

  DepositUrlResponse({
    required this.depositUrl,
    required this.orderCode,
  });

  factory DepositUrlResponse.fromJson(Map<String, dynamic> json) {
    return DepositUrlResponse(
      depositUrl: json["depositUrl"] ?? "",
      orderCode: json["orderCode"] ?? 0,
    );
  }
}