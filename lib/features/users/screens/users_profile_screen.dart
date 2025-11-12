import 'package:flutter/material.dart';
import '../../shared/app_bottom_bar.dart';
import '../../shared/app_error_state.dart';
import '../../../routes/app_routes.dart';
import '../widgets/users_profile.dart';

class UserProfileScreen extends StatefulWidget {
  final String? userId;

  const UserProfileScreen({super.key, this.userId});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _hasError = false;
  bool _isRetrying = false;

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
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.all(
                    isDesktop
                        ? 32
                        : isTablet
                        ? 24
                        : 16,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    iconSize: 28,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              UserProfile(userId: widget.userId),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const SafeArea(
        top: false,
        child: AppBottomBar(currentIndex: 5),
      ),
    );
  }
}
