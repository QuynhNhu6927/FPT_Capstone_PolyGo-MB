import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  // static const String baseUrl = "http://160.25.81.144:8080";
  static String get baseUrl => dotenv.env['BASE_URL'] ?? '';
  static String get androidId => dotenv.env['ANDROID_CLIENT_ID'] ?? '';

  // Auth endpoints
  static const String sendOtp = "/api/auth/otp";
  static const String login = "/api/auth/login";
  static const String register = "/api/auth/register";
  static const String resetPassword = "/api/auth/reset-password";
  static const String me = "/api/auth/me";
  static const String changePassword = "/api/auth/change-password";
  static const googleLogin = '/api/auth/google-login';

  // Interests endpoints
  static const String interests = "/api/interests";
  static const String interestById = "/api/interests/{id}";
  static const String interestsMeAll = "/api/interests/me-all";
  static const String interestsMe = "/api/interests/me";

  // Languages endpoints
  static const String languages = "/api/languages";
  static const String languageById = "/api/languages/{id}";
  static const String speakingLanguagesMeAll = "/api/languages/speaking/me-all";
  static const String learningLanguagesMeAll = "/api/languages/learning/me-all";
  static const String learningLanguagesMe = "/api/languages/learning/me";
  static const String speakingLanguagesMe = "/api/languages/speaking/me";

  // Users endpoints
  static const String profileSetup = "/api/users/profile-setup";
  static const String updateProfile = "/api/users/profile/me";
  static const String userInfo = "/api/users/me";
  static const String usersAll = "/api/users";
  static const String userMatching = "/api/users/matching";
  static const String userById = "/api/users/{id}";

  // Media
  static const String uploadFile = "/api/media/upload-image";
  static const String uploadFiles = "/api/media/upload-images";
  static const String uploadAudio = "/api/media/upload-file";

  // Badges endpoints
  static const String badgesMe = "/api/badges/me";
  static const String badgesMeAll = "/api/badges/me-all";
  static const String badgeById = "/api/badges/{id}";
  static const String claimBadge = "/api/badges/claim/{id}";

  // Subscription endpoints
  static const String subscriptionPlans = "/api/subscriptions/plans";
  static const String subscribe = "/api/subscriptions/subscribe";
  static const String currentSubscription = "/api/subscriptions/current";
  static const String cancelSubscription = "/api/subscriptions/cancel";
  static const String updateAutoRenew = "/api/subscriptions/auto-renew";
  static const String currentUsage = "/api/subscriptions/usage";

  // Transaction endpoints
  static const String transactions = "/api/transactions/";
  static const String transactionById = "/api/transactions/{id}";
  static const String transactionWallet = "/api/wallet";
  static const String deleteBank = "/api/wallet/accounts/{bankAccountId}";
  static const String addBank = "/api/wallet/accounts";
  static const String withdraw = "/api/transactions/withdrawal-request";
  static const String withdrawConfirm = "/api/transactions/withdrawal-confirm";
  static const String sendInquiry = "/api/inquiry/transactions/{id}";

  // Payment
  static const String deposit = "/api/payment/deposit-url";
  static const String cancelDeposit = "/api/payment/cancel";

  // Gift endpoints
  static const String gifts = "/api/gifts";
  static const String purchaseGift = "/api/gifts/purchase";
  static const String myGifts = "/api/gifts/me";
  static const String presentGift = "/api/gifts/present";
  static const String giftsReceived = "/api/gifts/received";
  static const String giftsSent = "/api/gifts/sent";
  static const String giftsReceivedAccept = "/api/gifts/received/{presentationId}/accept";
  static const String giftsReceivedReject = "/api/gifts/received/{presentationId}/reject";

  // Conversation endpoints
  static const String allConversations = "/api/conversations";
  static const String getConversation = "/api/conversations/messages/{id}";
  static const String getConversationById = "/api/conversations/{id}";
  static const String getConversationByUser = "/api/conversations/user/{userId}";
  static const String transMessage = "/api/conversations/messages/{messageId}/translate";
  static const String getTransLang = "/api/conversations/{conversationId}/translation-language";
  static const String updateTransLang = "/api/conversations/{conversationId}/translation-language";
  static const String getImages = "/api/conversations/images/{id}";

  // Event endpoints
  static const String eventsMatching = "/api/events/matching";
  static const String eventsComing = "/api/events/upcoming";
  static const String eventRegister = "/api/events/register";
  static const String eventsHosted = "/api/events/hosted";
  static const String eventsCancel = "/api/events/cancel";
  static const String eventsUnregister = "/api/events/unregister";
  static const String eventsJoined = "/api/events/joined";
  static const String eventsDetails = "/api/events/stats/{id}";
  static const String eventDetail = "/api/events/{id}";
  static const String eventsKick = "/api/events/kick";
  static const String updateStatusAdmin = "/api/events/admin/status";
  static const String ratingEvent = "/api/events/rating";
  static const String getMyRating = "/api/events/ratings/{eventId}/my";
  static const String getAllRating = "/api/events/ratings/{eventId}";
  static const String updateRating = "/api/events/rating";
  static const String hostPayout = "/api/events/{eventId}/host-payout";
  static const String getSummary = "/api/events/{eventId}/summary";
  static const String genSummary = "/api/events/{eventId}/summary/generate";
  static const String userEvent = "/api/events/hostedby/{hostId}";
  static const String publicSummary = "/api/events/{eventId}/summary/send-mail";

  // Friend endpoints
  static const String requestFriend = "/api/friends/request";
  static const String requestCancel = "/api/friends/request/{receiverId}";
  static const String requestAccept = "/api/friends/request/accept";
  static const String requestReject = "/api/friends/request/reject";
  static const String unFriend = "/api/friends/{friendId}";
  static const String allFriends = "/api/friends";
  static const String allRequest = "/api/friends/request/received";

  // WordSets endpoints
  static const String allWordSets = "/api/wordsets";
  static const String wordSetsById = "/api/wordsets/{id}";
  static const String wordSetLeaderBoard = "/api/wordsets/{wordSetId}/leaderboard";
  static const String startGame = "/api/wordsets/{wordSetId}/start";
  static const String playGame = "/api/wordsets/play";
  static const String hintGame = "/api/wordsets/{wordSetId}/game-state";
  static const String plusHint = "/api/wordsets/{wordSetId}/hint";
  static const String createdGame = "/api/wordsets/my/created";
  static const String joinedGame = "/api/wordsets/my/played";

  // Post endpoints
  static const String allPosts = "/api/posts";
  static const String reactPost = "/api/posts/{postId}/reactions";
  static const String unReactPost = "/api/posts/{postId}/reactions";
  static const String getPostDetail = "/api/posts/{postId}";
  static const String createPost = "/api/posts";
  static const String deletePost = "/api/posts/{postId}";
  static const String commentPost = "/api/posts/{postId}/comments";
  static const String deleteCommentPost = "/api/posts/comments/{commentId}";
  static const String updateCommentPost = "/api/posts/comments/{commentId}";
  static const String updatePost = "/api/posts/{postId}";
  static const String myPost = "/api/posts/me";
  static const String userPosts = "/api/posts/user/{userId}";
  static const String sharePosts = "/api/posts/share";

  // Level endpoints
  static const String levels = "/api/levels/me";
  static const String claimLevel = "/api/levels/claim/{id}";

  // Report endpoints
  static const String postReport = "/api/reports";
  static const String viewReports = "/api/reports/me";
  static const String viewReportDetail = "/api/reports/{reportId}";

  // Notification endpoints
  static const String allNotification = "/api/notifications";
  static const String readNotification = "/api/notifications/{id}";

  // Header keys
  static const String headerContentType = "Content-Type";
  static const String headerAuthorization = "Authorization";
  static const String contentTypeJson = "application/json";


}