class FriendRequestModel {
  final String receiverId;

  FriendRequestModel({required this.receiverId});

  Map<String, dynamic> toJson() => {
    'receiverId': receiverId,
  };
}

class FriendRequestResponse {
  final String? status;
  final String? message;

  FriendRequestResponse({this.status, this.message});

  factory FriendRequestResponse.fromJson(Map<String, dynamic> json) {
    return FriendRequestResponse(
      status: json['status']?.toString(),
      message: json['message']?.toString(),
    );
  }
}
