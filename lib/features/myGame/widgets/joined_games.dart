import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/models/wordsets/joined_word_set.dart';
import '../../../core/api/api_client.dart';
import '../../../data/repositories/wordset_repository.dart';
import '../../../data/services/apis/wordset_service.dart';
import '../../shared/app_error_state.dart';
import 'joined_game_card.dart';
import 'my_game_filter.dart';

class JoinedGames extends StatefulWidget {
  const JoinedGames({super.key});

  @override
  State<JoinedGames> createState() => _JoinedGamesState();
}

class _JoinedGamesState extends State<JoinedGames> {
  late final WordSetRepository _repository;
  final ScrollController _scrollController = ScrollController();
  bool _showFilterBar = true;
  double _lastOffset = 0;
  bool _loading = true;
  bool _hasError = false;

  List<PlayedWordSet> _wordSets = [];
  List<PlayedWordSet> _filteredWordSets = [];

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';
  bool _isSearching = false;

  // Filter data
  List<Map<String, String>> _filterLanguages = [];
  String? _filterDifficulty;
  String? _filterCategory;

  @override
  void initState() {
    super.initState();

    final apiClient = ApiClient();
    final service = WordSetService(apiClient);
    _repository = WordSetRepository(service);

    _loadGames();

    _searchFocusNode.addListener(() {
      setState(() {
        _isSearching = _searchFocusNode.hasFocus;
      });
    });
    _scrollController.addListener(() {
      final offset = _scrollController.offset;

      if (offset > _lastOffset && offset - _lastOffset > 10) {
        if (_showFilterBar) setState(() => _showFilterBar = false);
      } else if (offset < _lastOffset && _lastOffset - offset > 10) {
        if (!_showFilterBar) setState(() => _showFilterBar = true);
      }

      _lastOffset = offset;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadGames() async {
    setState(() {
      _loading = true;
      _hasError = false;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      if (token.isEmpty) throw Exception("Missing token");

      final response = await _repository.getPlayedWordSetsPaged(token);

      if (!mounted) return;
      setState(() {
        _wordSets = response.items;
        _applyFilters();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _loading = false;
      });
    }
  }

  void _applyFilters() {
    var list = _wordSets;

    // Filter by languages
    if (_filterLanguages.isNotEmpty) {
      list = list.where((ws) =>
          _filterLanguages.any((f) => ws.language.id == f['id'])).toList();
    }

    // Filter by difficulty
    if (_filterDifficulty != null && _filterDifficulty!.isNotEmpty) {
      list = list.where((ws) => ws.difficulty == _filterDifficulty).toList();
    }

    // Filter by search query
    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.trim().toLowerCase();
      list = list
          .where((ws) => ws.title.toLowerCase().contains(query))
          .toList();
    }

    _filteredWordSets = list;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width < 600 ? 1 : 2;
    final theme = Theme.of(context);

    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_hasError) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        child: AppErrorState(onRetry: _loadGames),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, animation) => SizeTransition(
              sizeFactor: animation,
              axisAlignment: -1,
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: _showFilterBar
                ? Column(
              key: const ValueKey('searchAndFilter'),
              children: [
                // --- SEARCH FIELD ROW ---
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    height: 42,
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF2C2C2C)
                          : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _isSearching
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 10),
                        Icon(
                          Icons.search_rounded,
                          color: _isSearching
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            focusNode: _searchFocusNode,
                            style: TextStyle(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                            decoration: InputDecoration(
                              hintText: "Search...",
                              hintStyle: TextStyle(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey
                                    : Colors.grey[600],
                              ),
                              border: InputBorder.none,
                              isCollapsed: true,
                            ),
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value;
                                _applyFilters();
                              });
                            },
                          ),
                        ),
                        if (_isSearching)
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            color: Colors.grey,
                            onPressed: () {
                              _searchController.clear();
                              _searchFocusNode.unfocus();
                              setState(() {
                                _isSearching = false;
                                _searchQuery = '';
                                _applyFilters();
                              });
                            },
                          ),
                      ],
                    ),
                  ),
                ),

                // --- FILTER + TAGS ROW ---
                if (_filterLanguages.isNotEmpty ||
                    (_filterDifficulty?.isNotEmpty ?? false) ||
                    (_filterCategory?.isNotEmpty ?? false) ||
                    true)
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount:
                      1 +
                          _filterLanguages.length +
                          (_filterDifficulty != null ? 1 : 0) +
                          (_filterCategory != null ? 1 : 0),
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        // Filter button
                        if (index == 0) {
                          return ElevatedButton.icon(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const MyGameFilter()),
                              );
                              if (result != null && result is Map<String, dynamic>) {
                                setState(() {
                                  _filterLanguages = List<Map<String, String>>.from(
                                      result['languages'] ?? []);
                                  _filterDifficulty = result['difficulty'];
                                  _filterCategory = result['category'];
                                  _applyFilters();
                                });
                              }
                            },
                            icon: const Icon(Icons.filter_alt_outlined, size: 18),
                            label: const Text("Filter"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                              foregroundColor:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              elevation: 1,
                            ),
                          );
                        }

                        // Tags
                        final tagIndex = index - 1;
                        String label = '';
                        VoidCallback? onRemove;

                        if (tagIndex < _filterLanguages.length) {
                          final lang = _filterLanguages[tagIndex];
                          label = lang['name'] ?? '';
                          onRemove = () {
                            setState(() {
                              _filterLanguages.removeAt(tagIndex);
                              _applyFilters();
                            });
                          };
                        } else if (tagIndex == _filterLanguages.length &&
                            _filterDifficulty != null) {
                          label = _filterDifficulty!;
                          onRemove = () {
                            setState(() {
                              _filterDifficulty = null;
                              _applyFilters();
                            });
                          };
                        } else {
                          label = _filterCategory!;
                          onRemove = () {
                            setState(() {
                              _filterCategory = null;
                              _applyFilters();
                            });
                          };
                        }

                        return Container(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.5)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                label,
                                style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: onRemove,
                                child: const Icon(Icons.close_rounded,
                                    size: 16, color: Colors.grey),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
              ],
            )
                : const SizedBox.shrink(),
          ),

          const SizedBox(height: 16),

          // --- GRID VIEW ---
          Expanded(
            child: _filteredWordSets.isEmpty
                ? const Center(child: Text("No games found"))
                : MasonryGridView.count(
                    controller: _scrollController,
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    itemCount: _filteredWordSets.length,
                    itemBuilder: (context, index) =>
                        JoinedGameCard(wordSet: _filteredWordSets[index]),
                  ),
          ),
        ],
      ),
    );
  }
}
