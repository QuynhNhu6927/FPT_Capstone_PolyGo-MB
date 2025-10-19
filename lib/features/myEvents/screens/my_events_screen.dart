import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../shared/app_bottom_bar.dart';
import '../widgets/my_events_menu.dart';
import '../widgets/my_events.dart';
import '../widgets/calendar.dart';
import '../../shared/app_error_state.dart';

class MyEventsScreen extends StatefulWidget {
  const MyEventsScreen({super.key});

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen> {
  int _selectedTab = 0;
  bool _hasError = false;

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
          return const MyEvents();
        case 1:
          return const Calendar();
        default:
          return const SizedBox.shrink();
      }
    } catch (e, st) {
      debugPrint("Error in MyEventsScreen tab: $e\n$st");
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
            MyEventsMenu(
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
        child: const AppBottomBar(currentIndex: 1),
      ),
    );
  }
}
