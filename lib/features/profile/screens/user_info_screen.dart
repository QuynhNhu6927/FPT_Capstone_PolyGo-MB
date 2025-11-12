
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../inventories/widgets/friend_social.dart';
import '../../shared/app_bottom_bar.dart';
import '../../shared/app_error_state.dart';
import '../../shared/app_header_actions.dart';
import '../widgets/user_info.dart';
import '../../inventories/widgets/achievements_gifts.dart';
import '../../../routes/app_routes.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({super.key});

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  ThemeMode _themeMode = ThemeMode.system;

  bool _hasError = false;
  bool _isRetrying = false;

  void _toggleTheme() {
    setState(() {
      _themeMode =
      _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void _onChildError() {
    if (!_hasError) {
      setState(() {
        _hasError = true;
      });
    }
  }

  void _onRetry() {
    setState(() {
      _hasError = false;
      _isRetrying = true;
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => _isRetrying = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    final isDesktop = screenWidth >= 1024;
    double maxFormWidth =
    isDesktop ? 500 : isTablet ? 450 : screenWidth * 0.9;

    return Scaffold(
      body: SafeArea(
        child: _hasError
            ? AppErrorState(onRetry: _onRetry)
            : SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.all(
                    isDesktop
                        ? 32
                        : isTablet
                        ? 24
                        : 16,
                  ),
                  child: AppHeaderActions(onThemeToggle: _toggleTheme),
                ),
              ),
              UserInfo(
                onError: _onChildError,
                isRetrying: _isRetrying,
              ),
              AchievementsAndGiftsSection(),
              FriendSocialSection(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const SafeArea(
        top: false,
        child: AppBottomBar(currentIndex: 4),
      ),
    );
  }
}
