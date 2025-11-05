class unFriendRequestModel {
  final String friendId;

  unFriendRequestModel({required this.friendId});

  Map<String, dynamic> toJson() => {
    'friendId': friendId,
  };
}

class unFriendResponse {
  final String? status;
  final String? message;

  unFriendResponse({this.status, this.message});

  factory unFriendResponse.fromJson(Map<String, dynamic> json) {
    return unFriendResponse(
      status: json['status']?.toString(),
      message: json['message']?.toString(),
    );
  }
}
