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

class _MyEventsMenuState extends State<MyEventsMenu> {
  late int _selectedIndex;

  final _items = const [
    {'icon': Icons.event_note_rounded, 'label': 'my_events'},
    {'icon': Icons.calendar_month_rounded, 'label': 'calendar'},
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
    final loc = AppLocalizations.of(context);
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

    final iconSize = 26 * scale;
    final fontSize = 15 * scale;
    final paddingV = 12 * scale;

    return Container(
      padding: EdgeInsets.symmetric(vertical: paddingV / 2),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: List.generate(_items.length, (index) {
          final item = _items[index];
          final selected = _selectedIndex == index;
          final iconColor = selected ? colorActive : colorInactive;

          return Expanded(
            child: GestureDetector(
              onTap: () => _onItemTapped(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: EdgeInsets.symmetric(vertical: paddingV),
                color: selected
                    ? colorActive.withOpacity(0.08)
                    : Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(item['icon'] as IconData,
                        color: iconColor, size: iconSize),
                    const SizedBox(height: 6),
                    Text(
                      loc.translate(item['label'] as String) ??
                          (item['label'] as String),
                      style: TextStyle(
                        color: selected ? colorActive : colorInactive,
                        fontSize: fontSize,
                        fontWeight:
                        selected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ).animate().fadeIn(duration: 250.ms),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}
