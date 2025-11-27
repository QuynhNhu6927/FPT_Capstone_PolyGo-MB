import 'package:flutter/material.dart';
import '../../shared/app_bottom_bar.dart';
import '../../shared/app_error_state.dart';
import '../widgets/shop_menu_bar.dart';
import '../widgets/subscription/subscriptions.dart';
import '../widgets/gifts.dart';
import '../widgets/wallet/wallet.dart';

class ShopScreen extends StatefulWidget {
  final int initialTabIndex;
  const ShopScreen({super.key, this.initialTabIndex = 0});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  late int _selectedTab;
  bool _hasError = false;
  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTabIndex;
  }

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
        return Subscriptions(
            isRetrying: _isRetrying,
            onError: () => setState(() => _hasError = true));
      case 1:
        return Gifts();
      case 2:
        return Wallet(
            isRetrying: _isRetrying,
            onError: () => setState(() => _hasError = true));
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
            ShopMenuBar(
              currentIndex: _selectedTab,
              onItemSelected: _onTabSelected,
            ),
            Expanded(
              child: _hasError ? AppErrorState(onRetry: _onRetry) : _buildTabContent(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const SafeArea(
        top: false,
        child: AppBottomBar(currentIndex: 3),
      ),
    );
  }
}
