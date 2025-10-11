import 'package:flutter/material.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/auth/screens/forget_password_screen.dart';
import '../features/profile/screens/profile_setup_screen.dart';
import '../features/profile/screens/user_info_screen.dart';
import '../features/profile/screens/update_profile_screen.dart';
import '../features/shared/temp.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String forgetPassword = '/forget-password';
  static const String userInfo = '/user-information';
  static const String profileSetup = '/profile-setup';
  static const String updateProfile = '/update-profile';

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
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Route không tồn tại')),
          ),
        );
    }
  }
}
