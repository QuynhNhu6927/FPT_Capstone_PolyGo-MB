import 'package:flutter/material.dart';
import '../../shared/app_bottom_bar.dart';
import '../widgets/shop_menu_bar.dart';
import '../widgets/subscriptions.dart';
import '../widgets/gifts.dart';
import '../../../../core/localization/app_localizations.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  int _selectedTab = 0;

  void _onTabSelected(int index) {
    setState(() => _selectedTab = index);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
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
              child: IndexedStack(
                index: _selectedTab,
                children: [
                  const Subscriptions(),
                  const Gifts(),
                  Center(
                    child: Text(
                      loc.translate('wallet_content_coming') ??
                          'Wallet Content (coming soon)',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomBar(currentIndex: 2),
    );
  }
}
