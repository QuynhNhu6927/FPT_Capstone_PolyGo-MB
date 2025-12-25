import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../shared/app_bottom_bar.dart';
import '../../shared/app_error_state.dart';
import '../widgets/events/events_content.dart';
import '../widgets/games/games_content.dart';
import '../widgets/social/post_content.dart';
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

  final ScrollController _scrollController = ScrollController();
  bool _showHeader = true;
  double _lastOffset = 0;

  Map<int, int> _reloadCounter = {};

  void _onMenuSelected(int index) {
    setState(() {
      _menuIndex = index;
      _reloadCounter[index] = (_reloadCounter[index] ?? 0) + 1;
    });
  }

  // void _onMenuSelected(int index) {
  //   setState(() => _menuIndex = index);
  // }

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

    _scrollController.addListener(() {
      final currentOffset = _scrollController.offset;

      if (currentOffset > _lastOffset && _showHeader) {
        // scroll xuống
        setState(() => _showHeader = false);
      } else if (currentOffset < _lastOffset && !_showHeader) {
        // scroll lên
        setState(() => _showHeader = true);
      }

      _lastOffset = currentOffset;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final List<Widget> pages = [
      EventsContent(
        key: ValueKey('events_${_reloadCounter[0] ?? 0}'),
        searchQuery: _searchQuery,
        controller: _scrollController,
      ),
      Users(
        key: ValueKey('users_${_reloadCounter[1] ?? 0}'),
        onLoaded: _onChildLoaded,
        onError: _onChildError,
        isRetrying: _isRetrying,
        searchQuery: _searchQuery,
        controller: _scrollController,
      ),
      WordSetContent(
        key: ValueKey('games_${_reloadCounter[2] ?? 0}'),
        searchQuery: _searchQuery,
        controller: _scrollController,

      ),
      PostContent(
        // key: const ValueKey('social'),
        key: ValueKey('social_${_reloadCounter[3] ?? 0}'),
        searchQuery: _searchQuery,
        controller: _scrollController,
      ),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? Colors.black : Colors.white,
        body: SafeArea(
          child: _hasError
              ? AppErrorState(onRetry: _onRetry)
              : Column(
                  children: [
                    AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      child: _showHeader
                          ? HomeHeader(
                        currentIndex: _menuIndex,
                        onItemSelected: _onMenuSelected,
                        onSearchChanged: (query) {
                          setState(() => _searchQuery = query);
                        },
                      )
                          : const SizedBox.shrink(),
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
          child: AppBottomBar(currentIndex: 0),
        ),
      ),
    );
  }
}
