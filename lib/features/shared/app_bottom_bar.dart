import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../routes/app_routes.dart';
import '../../../../core/localization/app_localizations.dart';


class AppBottomBar extends StatefulWidget {
  final int currentIndex;
  const AppBottomBar({super.key, this.currentIndex = 0});

  @override
  State<AppBottomBar> createState() => _AppBottomBarState();
}

class _AppBottomBarState extends State<AppBottomBar> {
  late int _selectedIndex;

  final _items = const [
    {'icon': Icons.home_rounded, 'labelKey': 'bottom_home'},
    {'icon': Icons.edit_calendar, 'labelKey': 'bottom_my_events'},
    {'icon': Icons.videogame_asset_rounded, 'labelKey': 'bottom_my_games'},
    {'icon': Icons.storefront_rounded, 'labelKey': 'bottom_shop'},
    {'icon': Icons.person_rounded, 'labelKey': 'bottom_me'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.currentIndex;
  }

  void _onItemTapped(BuildContext context, int index) {
    setState(() => _selectedIndex = index);

    switch (index) {
      case 0:
        Navigator.pushNamed(context, AppRoutes.home);
        break;
      case 1:
        Navigator.pushNamed(context, AppRoutes.myEvents);
        break;
      case 2:
        Navigator.pushNamed(context, AppRoutes.myGames);
        break;
      case 3:
        Navigator.pushNamed(context, AppRoutes.shop);
        break;
      case 4:
        Navigator.pushNamed(context, AppRoutes.userInfo);
        break;
      case 5:

        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorActive = const Color(0xFF2563EB);
    final colorInactive = theme.iconTheme.color?.withOpacity(0.6) ?? Colors.grey;

    final screenWidth = MediaQuery.of(context).size.width;
    final scale = screenWidth < 400
        ? 1.0
        : screenWidth < 800
        ? 1.2
        : 1.5;

    final iconSize = 26 * scale;
    final fontSize = 14 * scale;
    final paddingV = 10 * scale;
    final paddingH = 12 * scale;

    return Container(
      padding: EdgeInsets.symmetric(vertical: paddingV / 1.5, horizontal: 8 * scale),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: theme.brightness == Brightness.dark
                ? Colors.grey.withOpacity(0.1)
                : const Color(0x22000000),
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_items.length, (index) {
          final item = _items[index];
          final selected = _selectedIndex == index;
          final iconColor = selected ? colorActive : colorInactive;

          return GestureDetector(
            onTap: () => _onItemTapped(context, index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: EdgeInsets.symmetric(horizontal: paddingH, vertical: paddingV),
              decoration: BoxDecoration(
                color: selected ? colorActive.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(12 * scale),
              ),
              child: Row(
                children: [
                  Icon(item['icon'] as IconData, color: iconColor, size: iconSize),
                  // if (selected) ...[
                  //   SizedBox(width: 6 * scale),
                  //   Text(
                  //     loc.translate(item['labelKey'] as String),
                  //     style: TextStyle(
                  //       color: colorActive,
                  //       fontWeight: FontWeight.w600,
                  //       fontSize: fontSize,
                  //     ),
                  //   ).animate().fadeIn(duration: 250.ms),
                  // ],
                ],
              ),
            ),
          );
        }),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}
