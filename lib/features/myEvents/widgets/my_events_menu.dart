import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/localization/app_localizations.dart';

class MyEventsMenu extends StatefulWidget {
  final int currentIndex;
  final Function(int) onItemSelected;

  const MyEventsMenu({
    super.key,
    this.currentIndex = 0,
    required this.onItemSelected,
  });

  @override
  State<MyEventsMenu> createState() => _MyEventsMenuState();
}

class _MyEventsMenuState extends State<MyEventsMenu>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSearching = false;
  late int _selectedIndex;

  final _items = const [
    {'icon': Icons.edit_calendar, 'label': 'my_events'},
    {'icon': Icons.event_available, 'label': 'joined'},
    {'icon': Icons.calendar_month, 'label': 'calendar'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.currentIndex;
    _focusNode.addListener(() {
      setState(() => _isSearching = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    widget.onItemSelected(index);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    const colorPrimary = Color(0xFF2563EB);
    final colorActive = colorPrimary;
    final colorInactive =
        theme.iconTheme.color?.withOpacity(0.6) ?? Colors.grey;

    final bgColor = isDark ? Colors.black : Colors.white;
    final shadowColor =
    isDark ? Colors.grey.withOpacity(0.1) : Colors.black.withOpacity(0.08);
    final searchBgColor = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF3F4F6);
    final searchTextColor = isDark ? Colors.white : Colors.black87;
    final searchHintColor = isDark ? Colors.grey : Colors.grey[600];

    final screenWidth = MediaQuery.of(context).size.width;
    final scale = screenWidth < 400
        ? 1.0
        : screenWidth < 800
        ? 1.2
        : 1.5;

    final iconSize = 28 * scale;
    final paddingV = 10 * scale;
    final paddingH = 8 * scale;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6, top: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_items.length, (index) {
                final item = _items[index];
                final selected = _selectedIndex == index;

                return GestureDetector(
                  onTap: () => _onItemTapped(index),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item['icon'] as IconData,
                        color: selected ? colorActive : colorInactive,
                        size: iconSize,
                      ),
                      const SizedBox(height: 4),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        height: 3,
                        width: 18,
                        decoration: BoxDecoration(
                          color: selected ? colorActive : Colors.transparent,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}
