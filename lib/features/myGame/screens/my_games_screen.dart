import 'package:flutter/material.dart';
import '../../shared/app_bottom_bar.dart';
import '../../shared/app_error_state.dart';
import '../widgets/created_games.dart';
import '../widgets/joined_games.dart';
import '../widgets/my_games_menu.dart';

class MyGamesScreen extends StatefulWidget {
  final int initialTab;

  const MyGamesScreen({super.key, this.initialTab = 0});

  @override
  State<MyGamesScreen> createState() => _MyGamesScreenState();
}

class _MyGamesScreenState extends State<MyGamesScreen> {
  late int _selectedTab;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
  }

  void _onTabSelected(int index) {
    setState(() => _selectedTab = index);
  }

  void _retry() {
    setState(() {
      _hasError = false;
    });
  }

  Widget _buildTabContent() {
    try {
      switch (_selectedTab) {
        case 0:
          return const CreatedGames();
        case 1:
          return const JoinedGames();
        default:
          return const SizedBox.shrink();
      }
    } catch (e) {
      _hasError = true;
      return AppErrorState(onRetry: _retry);
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
            MyGameMenu(
              currentIndex: _selectedTab,
              onItemSelected: _onTabSelected,
            ),
            Expanded(
              child: _hasError
                  ? AppErrorState(onRetry: _retry)
                  : _buildTabContent(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: const AppBottomBar(currentIndex: 2),
      ),
    );
  }
}
