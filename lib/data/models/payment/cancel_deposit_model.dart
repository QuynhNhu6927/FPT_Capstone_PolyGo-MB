class CancelDepositRequest {
  final int orderCode;

  CancelDepositRequest({required this.orderCode});

  Map<String, dynamic> toJson() => {
    "orderCode": orderCode,
  };
}

class CancelDepositResponse {
  final String message;

  CancelDepositResponse({required this.message});

  factory CancelDepositResponse.fromJson(Map<String, dynamic> json) {
    return CancelDepositResponse(
      message: json["message"] ?? "",
    );
  }
}
