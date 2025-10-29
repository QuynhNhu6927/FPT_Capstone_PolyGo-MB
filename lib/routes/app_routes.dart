import 'package:flutter/material.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/auth/screens/forget_password_screen.dart';
import '../features/home/screens/notification_screen.dart';
import '../features/inventories/screens/all_badges_screen.dart';
import '../features/inventories/screens/all_gifts_screen.dart';
import '../features/myEvents/screens/my_events_screen.dart';
import '../features/profile/screens/profile_setup_screen.dart';
import '../features/profile/screens/user_info_screen.dart';
import '../features/profile/screens/update_profile_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/shop/screens/shop_screen.dart';
import '../features/users/screens/users_profile_screen.dart';

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
      default:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
    }
  }
}
