import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../shared/app_bottom_bar.dart';
import '../widgets/calendar.dart';
import '../widgets/my_events_menu.dart';
import '../widgets/my_events.dart';
import '../widgets/joined_events.dart';
import '../../shared/app_error_state.dart';

class MyEventsScreen extends StatefulWidget {
  final int initialTab;

  const MyEventsScreen({super.key, this.initialTab = 0});

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen> {
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
          return const MyEvents();
        case 1:
          return const JoinedEvents();
        case 2:
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
