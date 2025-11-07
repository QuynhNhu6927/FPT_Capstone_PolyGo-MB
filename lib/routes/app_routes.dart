import 'package:flutter/material.dart';
import 'package:polygo_mobile/features/chat/screens/conversation_list_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/auth/screens/forget_password_screen.dart';
import '../features/chat/screens/conversation_screen.dart';
import '../features/home/screens/notification_screen.dart';
import '../features/inventories/screens/all_badges_screen.dart';
import '../features/inventories/screens/all_gifts_screen.dart';
import '../features/inventories/screens/friends_screen.dart';
import '../features/myEvents/screens/my_events_screen.dart';
import '../features/myEvents/screens/event_waiting_screen.dart';
import '../features/profile/screens/profile_setup_screen.dart';
import '../features/profile/screens/user_info_screen.dart';
import '../features/profile/screens/update_profile_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/rating/screens/end_meeting_sceen.dart';
import '../features/rating/screens/rates_screen.dart';
import '../features/rating/screens/rating_screen.dart';
import '../features/shop/screens/shop_screen.dart';
import '../features/users/screens/users_profile_screen.dart';
import '../features/myEvents/screens/event_room_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String forgetPassword = '/forget-password';
  static const String userInfo = '/user-information';
  static const String profileSetup = '/profile-setup';
  static const String updateProfile = '/update-profile';
  static const String allBadges = '/badges';
  static const String myEvents = '/my-events';
  static const String shop = '/shop';
  static const String allGifts = '/gifts';
  static const String notifications = '/notifications';
  static const String userProfile = '/user-profile';
  static const String eventWaiting = '/event-waiting';
  static const String eventRoom = '/event-room';
  static const String friends = '/friend-list';
  static const String endMeeting = '/end-meeting';
  static const String rating = '/rating';
  static const String rates = '/rates';
  static const String conversations = '/conversations';
  static const String conversation = '/conversation';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case forgetPassword:
        return MaterialPageRoute(builder: (_) => const ForgetPasswordScreen());
      case userInfo:
        return MaterialPageRoute(builder: (_) => const UserInfoScreen());
      case profileSetup:
        return MaterialPageRoute(builder: (_) => const ProfileSetupScreen());
      case updateProfile:
        return MaterialPageRoute(builder: (_) => const UpdateProfileScreen());
      case allBadges:
        return MaterialPageRoute(builder: (_) => const AllBadgesScreen());
      case myEvents:
        return MaterialPageRoute(builder: (_) => const MyEventsScreen());
      case shop:
        return MaterialPageRoute(builder: (_) => const ShopScreen());
      case allGifts:
        return MaterialPageRoute(builder: (_) => const AllGiftsScreen());
      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationScreen());
      case userProfile:
        final args = settings.arguments as Map<String, dynamic>?;
        final userId = args?['id'] as String?;
        return MaterialPageRoute(
          builder: (_) => UserProfileScreen(userId: userId),
        );
      case eventWaiting:
        final args = settings.arguments as Map<String, dynamic>?;

        final eventId = args?['eventId'] as String? ?? '';
        final eventTitle = args?['eventTitle'] as String? ?? '';
        final eventStatus = args?['eventStatus'] as String? ?? '';
        final hostId = args?['hostId'] as String? ?? '';
        final hostName = args?['hostName'] as String? ?? '';
        final startAt = args?['startAt'] as DateTime? ?? DateTime.now();

        return MaterialPageRoute(
          builder: (_) => WaitingRoomScreen(
            eventId: eventId,
            eventTitle: eventTitle,
            hostId: hostId,
            hostName: hostName,
            eventStartAt: startAt,
            eventStatus: eventStatus,
          ),
        );

      case eventRoom:
        final args = settings.arguments as Map<String, dynamic>?;
        final eventId = args?['eventId'] as String? ?? '';
        final eventTitle = args?['eventTitle'] as String? ?? '';
        final eventStatus = args?['eventStatus'] as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => MeetingRoomScreen(
            eventId: eventId,
            eventTitle: eventTitle,
            eventStatus: eventStatus,
          ),
        );
      case friends:
        return MaterialPageRoute(builder: (_) => const FriendsScreen());
      case endMeeting:
        final args = settings.arguments as Map<String, dynamic>?;
        final eventId = args?['eventId'] as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => EndMeetingScreen(
            eventId: eventId,
          ),
        );
      case rating:
        final args = settings.arguments as Map<String, dynamic>?;
        final eventId = args?['eventId'] as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => RatingScreen(
            eventId: eventId,
          )
        );
      case rates:
        final args = settings.arguments as Map<String, dynamic>?;
        final eventId = args?['eventId'] as String? ?? '';
        return MaterialPageRoute(
            builder: (_) => RatesScreen(
              eventId: eventId,
            )
        );
      case conversations:
        return MaterialPageRoute(builder: (_) => const ConversationListScreen());
      case conversation:
        final args = settings.arguments as Map<String, dynamic>?;
        final eventId = args?['eventId'] as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => EndMeetingScreen(
            eventId: eventId,
          ),
        );
      case rating:
        final args = settings.arguments as Map<String, dynamic>?;
        final conversationId = args?['conversationId'] as String? ?? '';
        final userName = args?['userName'] as String? ?? '';
        final avatarHeader = args?['avatarHeader'] as String? ?? '';
        return MaterialPageRoute(
            builder: (_) => ConversationScreen(
              conversationId: conversationId,
              userName: userName,
              avatarHeader: avatarHeader,
            )
        );
      default:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
    }
  }
}
