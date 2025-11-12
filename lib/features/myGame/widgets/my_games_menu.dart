import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MyGameMenu extends StatefulWidget {
  final int currentIndex;
  final Function(int) onItemSelected;

  const MyGameMenu({
    super.key,
    this.currentIndex = 0,
    required this.onItemSelected,
  });

  @override
  State<MyGameMenu> createState() => _MyGameMenuState();
}

class _MyGameMenuState extends State<MyGameMenu> {
  late int _selectedIndex;

  final _items = const [
    {'icon': Icons.videogame_asset},
    {'icon': Icons.group},
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.currentIndex;
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    widget.onItemSelected(index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    const colorPrimary = Color(0xFF2563EB);
    final colorActive = colorPrimary;
    final colorInactive =
        theme.iconTheme.color?.withOpacity(0.6) ?? Colors.grey;

    final bgColor = isDark ? Colors.black : Colors.white;
    final shadowColor =
    isDark ? Colors.grey.withOpacity(0.1) : Colors.black.withOpacity(0.08);

    final screenWidth = MediaQuery.of(context).size.width;
    final scale = screenWidth < 400
        ? 1.0
        : screenWidth < 800
        ? 1.2
        : 1.5;

    final iconSize = 28 * scale;

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
    ).animate().fadeIn(duration: 300.ms);
  }
}
