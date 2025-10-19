import 'package:flutter/material.dart';
import '../../shared/app_bottom_bar.dart';
import '../widgets/events_content.dart';
import '../widgets/users.dart';
import '../widgets/home_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _menuIndex = 0;

  void _onMenuSelected(int index) {
    setState(() => _menuIndex = index);
  }

  final List<Widget> _pages = const [
    EventsContent(),
    Center(child: Text('Favorites', style: TextStyle(fontSize: 24))),
    Users(),
    Center(child: Text('Explore', style: TextStyle(fontSize: 24))),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            HomeHeader(
              currentIndex: _menuIndex,
              onItemSelected: _onMenuSelected,
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _pages[_menuIndex],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: const AppBottomBar(currentIndex: 0),
      ),
    );
  }
}
