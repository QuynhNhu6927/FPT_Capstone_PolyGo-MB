import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:polygo_mobile/core/utils/string_extensions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/api/api_client.dart';
import '../../../../data/models/user/user_all_response.dart';
import '../../../../data/models/user/user_matching_response.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../data/services/apis/user_service.dart';
import '../../../../main.dart';
import '../../../../routes/app_routes.dart';
import '../../../shared/app_error_state.dart';
import 'filter_pop_up.dart';

class Users extends StatefulWidget {
  final VoidCallback? onLoaded;
  final VoidCallback? onError;
  final bool isRetrying;
  final String searchQuery;

  const Users({
    super.key,
    this.onLoaded,
    this.onError,
    this.isRetrying = false,
    this.searchQuery = '',
  });

  @override
  State<Users> createState() => _UsersState();
}

class _UsersState extends State<Users> {
  late final UserRepository _repository;
  bool _loading = true;
  bool _hasError = false;

  List<UserItem> _allUsers = [];
  List<UserMatchingItem> _matchingUsers = [];

  bool _isShowingMatching = true;

  List<Map<String, String>> _filterLearn = [];
  List<Map<String, String>> _filterKnown = [];
  List<Map<String, String>> _filterInterests = [];

  Locale? _currentLocale;

  List<String> get _selectedFilters => [
    ..._filterLearn.map((e) => e['name'] ?? ''),
    ..._filterKnown.map((e) => e['name'] ?? ''),
    ..._filterInterests.map((e) => e['name'] ?? ''),
  ];

  final ScrollController _scrollController = ScrollController();
  bool _showFilterBar = true;
  double _lastOffset = 0;

  @override
  void initState() {
    super.initState();
    _repository = UserRepository(UserService(ApiClient()));

    _scrollController.addListener(() {
      final offset = _scrollController.offset;

      if (offset > _lastOffset && offset - _lastOffset > 10) {
        if (_showFilterBar) {
          setState(() => _showFilterBar = false);
        }
      } else if (offset < _lastOffset && _lastOffset - offset > 10) {
        if (!_showFilterBar) {
          setState(() => _showFilterBar = true);
        }
      }

      _lastOffset = offset;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final locale = InheritedLocale.of(context).locale;

    if (_currentLocale == null ||
        _currentLocale!.languageCode != locale.languageCode) {
      _currentLocale = locale;
      _loadMatchingUsers(lang: locale.languageCode);
    }
  }

  @override
  void didUpdateWidget(covariant Users oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRetrying && !oldWidget.isRetrying) {
      if (_isShowingMatching) {
        _loadMatchingUsers(lang: _currentLocale?.languageCode);
      } else {
        _loadAllUsers(lang: _currentLocale?.languageCode);
      }
    }
  }

  Future<void> _loadMatchingUsers({String? lang}) async {
    setState(() {
      _loading = true;
      _hasError = false;
      _isShowingMatching = true;
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

      final response = await _repository.getMatchingUsers(token, lang: lang ?? "vi");

      if (!mounted) return;

      setState(() {
        _matchingUsers = response;
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

  Future<void> _loadAllUsers({String? lang}) async {
    setState(() {
      _loading = true;
      _hasError = false;
      _isShowingMatching = false;
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

      final response = await _repository.getAllUsers(token, lang: lang ?? "vi");
      if (!mounted) return;

      setState(() {
        _allUsers = response;
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

  bool get _hasActiveFilter =>
      _filterLearn.isNotEmpty ||
          _filterKnown.isNotEmpty ||
          _filterInterests.isNotEmpty;

  List<dynamic> get _filteredUsers {
    final query = widget.searchQuery.trim().normalize();

    if (_hasActiveFilter) {
      return _allUsers.where((user) {
        final learnMatch = _filterLearn.isEmpty ||
            user.learningLanguages.any(
                    (l) => _filterLearn.any((f) => f['id'] == l.id));

        final knownMatch = _filterKnown.isEmpty ||
            user.speakingLanguages
                .any((l) => _filterKnown.any((f) => f['id'] == l.id));

        final interestMatch = _filterInterests.isEmpty ||
            user.interests.any((i) => _filterInterests.any((f) => f['id'] == i.id));

        final nameMatch =
            query.isEmpty || user.name.fuzzyContains(query);

        return learnMatch && knownMatch && interestMatch && nameMatch;
      }).toList();
    } else {
      final sourceList = _isShowingMatching ? _matchingUsers : _allUsers;

      if (query.isEmpty) return sourceList;

      return sourceList.where((user) {
        if (user is UserMatchingItem) {
          final name = (user.name ?? '').normalize();
          return name.fuzzyContains(query);
        } else if (user is UserItem) {
          final name = (user.name ?? '').normalize();
          return name.fuzzyContains(query);
        }
        return false;
      }).toList();
    }
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
        child: AppErrorState(
          onRetry: () {
            if (_hasActiveFilter) {
              _loadAllUsers(lang: _currentLocale?.languageCode);
            } else {
              _loadMatchingUsers(lang: _currentLocale?.languageCode);
            }
          },
        ),
      );
    }

    final usersToShow = _filteredUsers;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) => SizeTransition(
              sizeFactor: animation,
              axisAlignment: -1, // thu nhỏ từ trên xuống
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: _showFilterBar
                ? Container(
              key: const ValueKey('filterBar'),
              padding: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const FilterPopUp()),
                          );
                          if (result != null && result is Map<String, dynamic>) {
                            setState(() {
                              _filterLearn = List<Map<String, String>>.from(result['learn'] ?? []);
                              _filterKnown = List<Map<String, String>>.from(result['known'] ?? []);
                              _filterInterests = List<Map<String, String>>.from(result['interests'] ?? []);
                            });
                            _loadAllUsers(lang: _currentLocale?.languageCode);
                          }
                        },
                        icon: const Icon(Icons.filter_alt_outlined),
                        label: const Text('Filter'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primaryContainer,
                          foregroundColor: theme.colorScheme.onPrimaryContainer,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          elevation: 1,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 38,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _selectedFilters.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final tag = _selectedFilters[index];
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: theme.colorScheme.primary.withOpacity(0.5),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      tag,
                                      style: TextStyle(
                                        color: theme.colorScheme.primary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _filterLearn.removeWhere((f) => f['name'] == tag);
                                          _filterKnown.removeWhere((f) => f['name'] == tag);
                                          _filterInterests.removeWhere((f) => f['name'] == tag);
                                        });
                                        if (_hasActiveFilter) {
                                          _loadAllUsers(lang: _currentLocale?.languageCode);
                                        } else {
                                          _loadMatchingUsers(lang: _currentLocale?.languageCode);
                                        }
                                      },
                                      child: const Icon(Icons.close_rounded, size: 16, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_isShowingMatching && !_hasActiveFilter) ...[
                    const SizedBox(height: 12),
                    Text(
                      "Những người phù hợp với bạn",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ],
              ),
            )
                : const SizedBox.shrink(),
          ),

          Expanded(
            child: MasonryGridView.count(
              controller: _scrollController,
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              itemCount: usersToShow.length,
              itemBuilder: (context, index) {
                final user = usersToShow[index];
                return _buildUserCard(context, user);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, dynamic user) {
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

    final hasAvatar = (user.avatarUrl != null && user.avatarUrl.isNotEmpty);

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.userProfile,
          arguments: {'id': user.id},
        );
      },
      child: Container(
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
                  user.avatarUrl,
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
                    child: Icon(Icons.person,
                        size: 80, color: Colors.white70),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: SizedBox(
                  height: 48,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        user.name ?? 'Unknown',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          height: 1,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "XP: ${user.experiencePoints}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, height: 1, color: Colors.grey[500]),
                      ),
                    ],
                  ),
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
      ).animate().fadeIn(duration: 300.ms),
    );
  }
}
