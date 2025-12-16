class PostUser {
  final String id;
  final String name;
  final String avatarUrl;

  PostUser({
    required this.id,
    required this.name,
    required this.avatarUrl,
  });

  factory PostUser.fromJson(Map<String, dynamic> json) {
    return PostUser(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
    );
  }
}

class PostComment {
  final String id;
  final String content;
  final DateTime createdAt;
  final PostUser user;
  final bool isMyComment;

  PostComment({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.user,
    required this.isMyComment,
  });

  factory PostComment.fromJson(Map<String, dynamic> json) {
    return PostComment(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      isMyComment: json['isMyComment'] ?? false,
      user: PostUser.fromJson(json['user']),
    );
  }
}

class PostReaction {
  final String reactionType;
  final int count;
  final List<PostUser> users;

  PostReaction({
    required this.reactionType,
    required this.count,
    required this.users,
  });

  factory PostReaction.fromJson(Map<String, dynamic> json) {
    return PostReaction(
      reactionType: json['reactionType'] ?? '',
      count: json['count'] ?? 0,
      users: (json['users'] as List<dynamic>?)
          ?.map((e) => PostUser.fromJson(e))
          .toList() ??
          [],
    );
  }
}

class PostModel {
  final String id;
  final String content;
  final List<String> imageUrls;
  final DateTime createdAt;
  final PostUser creator;
  final int commentsCount;
  final int reactionsCount;
  final bool isMyPost;
  final List<PostComment> comments;
  final List<PostReaction> reactions;
  final String? myReaction;

  final bool isShare;
  final String? shareType;
  final String? sharedPostId;
  final String? sharedEventId;
  final SharedPostModel? sharedPost;
  final SharedEventModel? sharedEvent;

  PostModel({
    required this.id,
    required this.content,
    required this.imageUrls,
    required this.createdAt,
    required this.creator,
    required this.isMyPost,
    required this.commentsCount,
    required this.reactionsCount,
    required this.comments,
    required this.reactions,
    this.myReaction,
    required this.isShare,
    this.shareType,
    this.sharedPostId,
    this.sharedEventId,
    this.sharedPost,
    this.sharedEvent,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      creator: PostUser.fromJson(json['creator']),
      isMyPost: json['isMyPost'] ?? false,
      commentsCount: json['commentsCount'] ?? 0,
      reactionsCount: json['reactionsCount'] ?? 0,
      comments: (json['comments'] as List<dynamic>? ?? [])
          .map((e) => PostComment.fromJson(e))
          .toList(),
      reactions: (json['reactions'] as List<dynamic>? ?? [])
          .map((e) => PostReaction.fromJson(e))
          .toList(),
      myReaction: json['myReaction'],

      isShare: json['isShare'] ?? false,
      shareType: json['shareType'],
      sharedPostId: json['sharedPostId'],
      sharedEventId: json['sharedEventId'],
      sharedPost: json['sharedPost'] != null
          ? SharedPostModel.fromJson(json['sharedPost'])
          : null,
      sharedEvent: json['sharedEvent'] != null
          ? SharedEventModel.fromJson(json['sharedEvent'])
          : null,
    );
  }
}

class PostPaginationResponse {
  final List<PostModel> items;
  final int totalItems;
  final int currentPage;
  final int totalPages;
  final int pageSize;
  final bool hasPreviousPage;
  final bool hasNextPage;

  PostPaginationResponse({
    required this.items,
    required this.totalItems,
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });

  factory PostPaginationResponse.fromJson(Map<String, dynamic> json) {
    return PostPaginationResponse(
      items: (json['items'] as List<dynamic>)
          .map((e) => PostModel.fromJson(e))
          .toList(),
      totalItems: json['totalItems'] ?? 0,
      currentPage: json['currentPage'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
      pageSize: json['pageSize'] ?? 10,
      hasPreviousPage: json['hasPreviousPage'] ?? false,
      hasNextPage: json['hasNextPage'] ?? false,
    );
  }
}

class PostListResponse {
  final PostPaginationResponse data;
  final String? message;

  PostListResponse({required this.data, this.message});

  factory PostListResponse.fromJson(Map<String, dynamic> json) {
    return PostListResponse(
      data: PostPaginationResponse.fromJson(json['data']),
      message: json['message'],
    );
  }
}

class SharedPostModel {
  final String id;
  final String content;
  final List<String> imageUrls;
  final DateTime createdAt;
  final PostUser creator;

  SharedPostModel({
    required this.id,
    required this.content,
    required this.imageUrls,
    required this.createdAt,
    required this.creator,
  });

  factory SharedPostModel.fromJson(Map<String, dynamic> json) {
    return SharedPostModel(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      creator: PostUser.fromJson(json['creator']),
    );
  }
}

class SharedEventModel {
  final String id;
  final String title;
  final String description;
  final DateTime startAt;
  final double fee;
  final String bannerUrl;
  final String status;
  final PostUser host;

  SharedEventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.startAt,
    required this.fee,
    required this.bannerUrl,
    required this.status,
    required this.host,
  });

  factory SharedEventModel.fromJson(Map<String, dynamic> json) {
    return SharedEventModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      startAt: DateTime.parse(json['startAt']),
      fee: (json['fee'] ?? 0).toDouble(),
      bannerUrl: json['bannerUrl'] ?? '',
      status: json['status'] ?? '',
      host: PostUser.fromJson(json['host']),
    );
  }
}