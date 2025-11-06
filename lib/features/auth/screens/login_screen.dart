import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../shared/app_header_actions.dart';
import '../widgets/login_form.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme() {
    setState(() {
      _themeMode =
      _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    final isDesktop = screenWidth >= 1024;

    double maxFormWidth = isDesktop
        ? 500
        : isTablet
        ? 450
        : screenWidth * 0.9;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top header actions
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.all(isDesktop
                    ? 32
                    : isTablet
                    ? 24
                    : 16),
                child: AppHeaderActions(onThemeToggle: _toggleTheme),
              ),
            ),

            // Login form
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop
                        ? 64
                        : isTablet
                        ? 48
                        : 24,
                    vertical: isDesktop
                        ? 64
                        : isTablet
                        ? 48
                        : 32,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxFormWidth),
                    child: LoginForm(
                      isTablet: isTablet,
                      isDesktop: isDesktop,
                    ),
                  ).animate().fadeIn(duration: 400.ms),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
