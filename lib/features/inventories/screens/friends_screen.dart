import 'package:flutter/material.dart';
import '../../shared/app_bottom_bar.dart';
import '../../shared/app_error_state.dart';
import '../widgets/friends_menu_bar.dart';
import '../widgets/friends.dart';
import '../widgets/requests.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  int _selectedTab = 0;
  bool _hasError = false;
  bool _isRetrying = false;

  void _onTabSelected(int index) {
    setState(() => _selectedTab = index);
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

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return Friends(
          key: ValueKey(_selectedTab),
        );
      case 1:
        return Requests(
          key: ValueKey(_selectedTab),
          isRetrying: _isRetrying,
          onError: () => setState(() => _hasError = true),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            FriendsMenuBar(
              currentIndex: _selectedTab,
              onItemSelected: _onTabSelected,
            ),
            Expanded(
              child: _hasError
                  ? AppErrorState(onRetry: _onRetry)
                  : _buildTabContent(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const SafeArea(
        top: false,
        child: AppBottomBar(currentIndex: 5),
      ),
    );
  }
}
