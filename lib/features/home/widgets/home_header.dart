import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/api/api_client.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/services/apis/auth_service.dart';
import '../../../routes/app_routes.dart';
import 'notification.dart';

class HomeHeader extends StatefulWidget {
  final int currentIndex;
  final Function(int) onItemSelected;
  final Function(String)? onSearchChanged;

  const HomeHeader({
    super.key,
    this.currentIndex = 0,
    required this.onItemSelected,
    this.onSearchChanged,
  });

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSearching = false;
  late int _selectedIndex;

  int numberOfUnreadNotifications = 0;
  int numberOfUnreadMessages = 0;

  final _items = const [
    {'icon': Icons.event_rounded},
    {'icon': Icons.person_search},
    {'icon': Icons.videogame_asset_rounded},
    {'icon': Icons.public_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.currentIndex;
    _focusNode.addListener(() {
      setState(() => _isSearching = _focusNode.hasFocus);
    });
    _loadUnreadCounts();
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

  Future<void> _loadUnreadCounts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return;

      final repo = AuthRepository(AuthService(ApiClient()));
      final user = await repo.me(token);

      if (!mounted) return;

      setState(() {
        numberOfUnreadNotifications = user.numberOfUnreadNotifications ?? 0;
        numberOfUnreadMessages = user.numberOfUnreadMessages ?? 0;
      });
    } catch (e) {
      // có thể log lỗi hoặc ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    const colorPrimary = Color(0xFF2563EB);
    const colorActive = colorPrimary;
    final loc = AppLocalizations.of(context);
    final bgColor = isDark ? Colors.black : Colors.white;
    final shadowColor = isDark ? Colors.grey.withOpacity(0.1) : Colors.black.withOpacity(0.08);
    final searchBgColor = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF3F4F6);
    final searchTextColor = isDark ? Colors.white : Colors.black87;
    final searchHintColor = isDark ? Colors.grey : Colors.grey[600];

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
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
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
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              children: [
                // Logo
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 250),
                  opacity: _isSearching ? 0.0 : 1.0,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: _isSearching ? 0 : 100,
                    height: 40,
                    alignment: Alignment.center,
                    child: Image.asset(
                      'assets/Primary.png',
                      fit: BoxFit.cover,
                      height: 48,
                      width: 75,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Search bar
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 42,
                    decoration: BoxDecoration(
                      color: searchBgColor,
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
                            style: TextStyle(fontSize: 16, color: searchTextColor),
                            textAlignVertical: TextAlignVertical.center,
                            decoration: InputDecoration(
                              hintText: loc.translate("search_placeholder") ?? "Search...",
                              hintStyle: TextStyle(color: searchHintColor),
                              border: InputBorder.none,
                              isCollapsed: true,
                            ),
                            onChanged: widget.onSearchChanged,
                            onSubmitted: widget.onSearchChanged,
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

                // Chat icon
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: _isSearching ? 0 : 42, 
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 250),
                    opacity: _isSearching ? 0.0 : 1.0,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        IconButton(
                          icon: Icon(Icons.chat_bubble_outline_rounded,
                              size: 26, color: searchTextColor),
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.conversations);
                          },
                        ),
                        if (numberOfUnreadMessages > 0)
                          Positioned(
                            right: 4,
                            top: 4,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  numberOfUnreadMessages > 99
                                      ? '99+'
                                      : numberOfUnreadMessages.toString(),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Notification icon
                // Notification icon
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: _isSearching ? 0 : 42, // width mặc định IconButton
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 250),
                    opacity: _isSearching ? 0.0 : 1.0,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        IconButton(
                          icon: Icon(Icons.notifications_none_rounded,
                              size: 26, color: searchTextColor),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const NotificationPage(),
                              ),
                            );
                          },
                        ),
                        if (numberOfUnreadNotifications > 0)
                          Positioned(
                            right: 4,
                            top: 4,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  numberOfUnreadNotifications > 99
                                      ? '99+'
                                      : numberOfUnreadNotifications.toString(),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // --- Menu Icons ---
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
