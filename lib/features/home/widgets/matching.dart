import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/models/user/user_matching_response.dart';
import '../../../data/services/user_service.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../core/api/api_client.dart';
import '../../../core/utils/string_extensions.dart';
import '../../shared/app_error_state.dart';

class Matching extends StatefulWidget {
  final VoidCallback? onLoaded;
  final VoidCallback? onError;
  final bool isRetrying;
  final String searchQuery;

  const Matching({
    super.key,
    this.onLoaded,
    this.onError,
    this.isRetrying = false,
    this.searchQuery = '',
  });

  @override
  State<Matching> createState() => _MatchingState();
}

class _MatchingState extends State<Matching> {
  late final UserRepository _repository;
  bool _loading = true;
  bool _hasError = false;
  List<UserMatchingItem> _users = [];

  @override
  void initState() {
    super.initState();
    _repository = UserRepository(UserService(ApiClient()));
    _loadUsers();
  }

  @override
  void didUpdateWidget(covariant Matching oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRetrying && !oldWidget.isRetrying) {
      _loadUsers();
    }
  }

  Future<void> _loadUsers() async {
    setState(() {
      _loading = true;
      _hasError = false;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null || token.isEmpty) {
        setState(() {
          _hasError = true;
          _loading = false;
        });
        widget.onError?.call();
        return;
      }

      final response = await _repository.getMatchingUsers(token, lang: "vi");

      if (!mounted) return;

      setState(() {
        _users = response;
        _loading = false;
        _hasError = false;
      });
      widget.onLoaded?.call();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _loading = false;
      });
      widget.onError?.call();
    }
  }

  List<UserMatchingItem> get _filteredUsers {
    final query = widget.searchQuery.trim().normalize();
    if (query.isEmpty) return _users;

    return _users.where((user) {
      final name = (user.name ?? '').normalize();
      return name.fuzzyContains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width < 600 ? 2 : width < 1000 ? 3 : 4;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        child: AppErrorState(onRetry: _loadUsers),
      );
    }

    final usersToShow = _filteredUsers;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: MasonryGridView.count(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        itemCount: usersToShow.length,
        itemBuilder: (context, index) {
          final user = usersToShow[index];
          return _buildUserCard(context, user);
        },
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, UserMatchingItem user) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBackground = isDark
        ? const LinearGradient(
      colors: [Color(0xFF1E1E1E), Color(0xFF2C2C2C)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    )
        : const LinearGradient(colors: [Colors.white, Colors.white]);

    final tags = [
      ...user.interests.map((e) => e.name),
      ...user.speakingLanguages.map((e) => e.name),
      ...user.learningLanguages.map((e) => e.name),
    ];

    // ✅ Kiểm tra xem người dùng có avatar không
    final hasAvatar = (user.avatarUrl != null && user.avatarUrl!.isNotEmpty);

    return Container(
      decoration: BoxDecoration(
        gradient: cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.3) : Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: hasAvatar
                  ? Image.network(
                user.avatarUrl!,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.person,
                      size: 80, color: Colors.white70),
                ),
              )
                  : Container(
                color: Colors.grey[400],
                child: const Center(
                  child: Icon(
                    Icons.person,
                    size: 80,
                    color: Colors.white70,
                  ),
                ),
              ),
            ),
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name ?? 'Unknown',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "XP: ${user.experiencePoints}",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SizedBox(
                height: 28,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: tags.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, tagIndex) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary
                            .withOpacity(isDark ? 0.25 : 0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        tags[tagIndex],
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

}
