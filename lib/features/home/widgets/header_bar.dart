import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HeaderBar extends StatefulWidget implements PreferredSizeWidget {
  const HeaderBar({super.key});

  @override
  State<HeaderBar> createState() => _HeaderBarState();

  @override
  Size get preferredSize => const Size.fromHeight(60);
}

class _HeaderBarState extends State<HeaderBar> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorPrimary = const Color(0xFF2563EB);
    final colorLight = const Color(0xFFDBEAFE);

    final screenWidth = MediaQuery.of(context).size.width;
    final searchWidth = _isSearching ? screenWidth * 0.9 : screenWidth * 0.6;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        children: [
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
              child: Text(
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

          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: searchWidth,
              height: 42,
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark
                    ? Colors.grey[850]
                    : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _isSearching ? colorPrimary : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  Icon(Icons.search_rounded,
                      color: _isSearching ? colorPrimary : Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _focusNode,
                      style: const TextStyle(fontSize: 16),
                      decoration: const InputDecoration(
                        hintText: "Search...",
                        border: InputBorder.none,
                      ),
                      onSubmitted: (value) {
                        // TODO: hehe
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
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}
