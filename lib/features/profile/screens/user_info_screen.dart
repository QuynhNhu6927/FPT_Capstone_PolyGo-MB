
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (r) => false);
  }

  // Callback nhận lỗi từ widget con
  void _onChildError() {
    if (!_hasError) {
      setState(() {
        _hasError = true;
      });
    }
  }

  // Khi nhấn retry
  void _onRetry() {
    setState(() {
      _hasError = false;
      _isRetrying = true;
    });

    // cho widget con reload
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

              // --- hai widget con ---
              UserInfo(
                onError: _onChildError,
                isRetrying: _isRetrying,
              ),
              AchievementsAndGiftsSection(
                onLoaded: () => setState(() => _hasError = false),
                onError: () {
                  setState(() => _hasError = true);
                },
              ),

              const SizedBox(height: 260),

              // --- Logout button ---
              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxFormWidth),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 8),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _logout(context),
                        icon: const Icon(Icons.logout,
                            color: Colors.white, size: 20),
                        label: const Text(
                          "Logout",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .error
                              .withOpacity(0.9),
                          padding:
                          const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                          shadowColor: Colors.black26,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const SafeArea(
        top: false,
        child: AppBottomBar(currentIndex: 3),
      ),
    );
  }
}
