import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../routes/app_routes.dart';

class HomeHeader extends StatefulWidget {
  final int currentIndex;
  final Function(int) onItemSelected;

  const HomeHeader({
    super.key,
    this.currentIndex = 0,
    required this.onItemSelected,
  });

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSearching = false;
  late int _selectedIndex;

  final _items = const [
    {'icon': Icons.event_rounded},
    {'icon': Icons.favorite_rounded},
    {'icon': Icons.group_rounded},
    {'icon': Icons.public_rounded},
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const colorPrimary = Color(0xFF2563EB);
    const colorLight = Color(0xFFDBEAFE);

    final colorActive = colorPrimary;
    final colorInactive = theme.iconTheme.color?.withOpacity(0.6) ?? Colors.grey;

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
      width: double.infinity, // 🌟 Tràn full chiều ngang
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        // ❌ Bỏ bo góc
        // ❌ borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.4)
                : Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ---------- HEADER BAR ----------
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              children: [
                // --- Logo ---
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 250),
                  opacity: _isSearching ? 0.0 : 1.0,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: _isSearching ? 0 : 100,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colorLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      "PolyGo",
                      style: TextStyle(
                        color: colorPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // --- Search box ---
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 42,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _isSearching ? colorPrimary : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 10),
                        Icon(
                          Icons.search_rounded,
                          color: _isSearching ? colorPrimary : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            focusNode: _focusNode,
                            style: const TextStyle(fontSize: 16),
                            textAlignVertical: TextAlignVertical.center,
                            decoration: const InputDecoration(
                              hintText: "Search...",
                              border: InputBorder.none,
                              isCollapsed: true,
                            ),
                            onSubmitted: (value) {
                              debugPrint("Searching for: $value");
                            },
                          ),
                        ),
                        if (_isSearching)
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            color: Colors.grey,
                            onPressed: () {
                              _searchController.clear();
                              _focusNode.unfocus();
                              setState(() => _isSearching = false);
                            },
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // --- Notification Icon ---
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 250),
                  opacity: _isSearching ? 0.0 : 1.0,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: _isSearching ? 0 : 42,
                    child: IconButton(
                      icon: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Icon(Icons.notifications_none_rounded, size: 26),
                          Positioned(
                            right: -1,
                            top: -1,
                            child: Container(
                              width: 9,
                              height: 9,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.notifications);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ---------- BOTTOM MENU BAR ----------
          Padding(
            padding: const EdgeInsets.only(bottom: 6, top: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_items.length, (index) {
                final item = _items[index];
                final selected = _selectedIndex == index;

                return GestureDetector(
                  onTap: () => _onItemTapped(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: EdgeInsets.symmetric(
                      horizontal: paddingH,
                      vertical: paddingV,
                    ),
                    decoration: const BoxDecoration(),
                    child: Icon(
                      item['icon'] as IconData,
                      color: selected ? colorActive : colorInactive,
                      size: iconSize,
                    ),
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
