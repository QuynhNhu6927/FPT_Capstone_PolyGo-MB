import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/localization/app_localizations.dart';

class FriendsMenuBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onItemSelected;

  const FriendsMenuBar({
    super.key,
    this.currentIndex = 0,
    required this.onItemSelected,
  });

  @override
  State<FriendsMenuBar> createState() => _FriendsMenuBarState();
}

class _FriendsMenuBarState extends State<FriendsMenuBar> {
  late int _selectedIndex;

  final _items = const [
    {'icon': Icons.people_alt_rounded},
    {'icon': Icons.mail_outline_rounded},
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

    final colorActive = const Color(0xFF2563EB);
    final colorInactive =
        theme.iconTheme.color?.withOpacity(0.6) ?? Colors.grey;

    final screenWidth = MediaQuery.of(context).size.width;
    final scale = screenWidth < 400
        ? 1.0
        : screenWidth < 800
        ? 1.2
        : 1.5;

    final iconSize = 28 * scale;
    final paddingV = 10 * scale;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: paddingV),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
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
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}
