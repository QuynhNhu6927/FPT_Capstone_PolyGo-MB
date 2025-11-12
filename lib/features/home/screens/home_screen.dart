import 'package:flutter/material.dart';
import '../../shared/app_bottom_bar.dart';
import '../../shared/app_error_state.dart';
import '../widgets/events/events_content.dart';
import '../widgets/games/games_content.dart';
import '../widgets/users/users.dart';
import '../widgets/home_header.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex;
  const HomeScreen({super.key, this.initialIndex = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _menuIndex = 0;
  bool _hasError = false;
  bool _isRetrying = false;
  String _searchQuery = '';

  void _onMenuSelected(int index) {
    setState(() => _menuIndex = index);
  }

  void _onChildError() {
    if (!_hasError) {
      setState(() => _hasError = true);
    }
  }

  void _onChildLoaded() {
    if (_hasError) {
      setState(() => _hasError = false);
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
  void initState() {
    super.initState();
    _menuIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final List<Widget> pages = [
      EventsContent(
        key: const ValueKey('events'),
        searchQuery: _searchQuery,
      ),
      Users(
        key: const ValueKey('users'),
        onLoaded: _onChildLoaded,
        onError: _onChildError,
        isRetrying: _isRetrying,
        searchQuery: _searchQuery,
      ),
      WordSetContent(
        key: const ValueKey('games'),
        searchQuery: _searchQuery,
      ),
      const Center(
        child: Text('Explore', style: TextStyle(fontSize: 24)),
      ),
    ];

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: SafeArea(
        child: _hasError
            ? AppErrorState(onRetry: _onRetry)
            : Column(
          children: [
            HomeHeader(
              currentIndex: _menuIndex,
              onItemSelected: _onMenuSelected,
              onSearchChanged: (query) {
                setState(() => _searchQuery = query);
              },
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: pages[_menuIndex],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: AppBottomBar(currentIndex: _menuIndex),
      ),
    );
  }
}
