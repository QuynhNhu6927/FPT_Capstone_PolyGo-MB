import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:polygo_mobile/core/utils/string_extensions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../data/models/wordsets/word_sets_model.dart';
import '../../../../data/repositories/wordset_repository.dart';
import '../../../../data/services/apis/wordset_service.dart';
import '../../../shared/app_error_state.dart';
import 'game_filter_bar.dart';
import 'games_card.dart';
import 'games_filter.dart';

class WordSetContent extends StatefulWidget {
  final String searchQuery;
  const WordSetContent({super.key, this.searchQuery = ''});

  @override
  State<WordSetContent> createState() => _WordSetContentState();
}

class _WordSetContentState extends State<WordSetContent> {
  late final WordSetRepository _repository;

  bool _loading = true;
  bool _hasError = false;
  bool _isLoadingMore = false;

  List<WordSetModel> _wordSets = [];
  int _currentPage = 1;
  int _totalPages = 1;
  int _pageSize = 10;

  List<Map<String, String>> _filterLanguages = [];
  String? _filterDifficulty;
  List<Map<String, String>> _filterInterests = [];

  Locale? _currentLocale;
  bool _initialized = false;
  bool _isInitializing = false;

  final ScrollController _scrollController = ScrollController();
  bool _showFilterBar = true;
  double _lastOffset = 0;

  List<String> get _selectedFilters => [
    ..._filterLanguages.map((e) => e['name'] ?? ''),
    if (_filterDifficulty != null) _filterDifficulty!,
    ..._filterInterests.map((e) => e['name'] ?? ''),
  ];

  bool get _hasActiveFilter =>
      _filterLanguages.isNotEmpty ||
          _filterDifficulty != null ||
          _filterInterests.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _repository = WordSetRepository(WordSetService(ApiClient()));

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
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context);

    if (!_initialized) {
      _initialized = true;
      _currentLocale = locale;
      _initLoadWordSets();
    } else if (_currentLocale!.languageCode != locale.languageCode) {
      _currentLocale = locale;
      _initLoadWordSets();
    }
  }

  void _initLoadWordSets() {
    if (_isInitializing) return;
    _isInitializing = true;

    Future.microtask(() async {
      await _loadWordSets(reset: true);
      _isInitializing = false;
    });
  }

  Future<void> _loadWordSets({bool reset = false}) async {
    if (reset) {
      setState(() {
        _loading = true;
        _hasError = false;
        _currentPage = 1;
        _wordSets.clear();
      });
    } else {
      setState(() => _isLoadingMore = true);
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      if (token.isEmpty) throw Exception("Missing token");

      final response = await _repository.getWordSetsPaged(
        token,
        lang: _currentLocale?.languageCode,
        languageIds: _filterLanguages.map((e) => e['id']!).toList(),
        difficulty: _filterDifficulty,
        interestIds: _filterInterests.map((e) => e['id']!).toList(),
        pageNumber: _currentPage,
        pageSize: _pageSize,
      );

      if (!mounted) return;
      setState(() {
        _wordSets.addAll(response.items);
        _totalPages = response.totalPages;
        _loading = false;
        _isLoadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _loading = false;
        _isLoadingMore = false;
      });
    }
  }


  List<WordSetModel> get _displayedWordSets {
    final query = widget.searchQuery.trim();
    if (query.isEmpty) return _wordSets;
    return _wordSets.where((e) => e.title.fuzzyContains(query)).toList();
  }

  bool get _canLoadMore => _currentPage < _totalPages && !_isLoadingMore;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width < 600 ? 1 : 2;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_loading) return const Center(child: CircularProgressIndicator());

    if (_hasError) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        child: AppErrorState(onRetry: () => _loadWordSets(reset: true)),
      );
    }

    final wordSetsToShow = _displayedWordSets;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Filter bar (ẩn/hiện animation)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) => SizeTransition(
              sizeFactor: animation,
              axisAlignment: -1,
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: _showFilterBar
                ? Container(
              key: const ValueKey('filterBar'),
              margin: const EdgeInsets.only(bottom: 2),
              child: WordSetFilterBar(
                selectedFilters: _selectedFilters,
                onOpenFilter: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const WordSetFilter()),
                  );
                  if (result != null && result is Map<String, dynamic>) {
                    setState(() {
                      _filterLanguages =
                      List<Map<String, String>>.from(result['languages'] ?? []);
                      _filterDifficulty = result['difficulty'];
                      _filterInterests =
                      List<Map<String, String>>.from(result['interests'] ?? []);
                    });
                    _loadWordSets(reset: true);
                  }
                },
                onRemoveFilter: (tag) {
                  setState(() {
                    _filterLanguages.removeWhere((f) => f['name'] == tag);
                    if (_filterDifficulty == tag) _filterDifficulty = null;
                    _filterInterests.removeWhere((f) => f['name'] == tag);
                  });
                  _loadWordSets(reset: true);
                },
              ),
            )
                : const SizedBox.shrink(),
          ),

          if (_showFilterBar && _selectedFilters.isEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    loc.translate("wordsets_fit_you"),
                    softWrap: true,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),

                IconButton(
                  icon: Icon(Icons.help_outline,
                      color: isDark ? Colors.white70 : Colors.grey[700]),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) {
                        final PageController controller = PageController();
                        int pageIndex = 0;

                        return StatefulBuilder(
                          builder: (context, setState) {
                            final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
                            final textColor = isDark ? Colors.white70 : Colors.black87;
                            final secondaryText = isDark ? Colors.grey[400] : Colors.grey[600];
                            final theme = Theme.of(context);

                            return Dialog(
                              insetPadding: const EdgeInsets.all(16),
                              backgroundColor: bgColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // TITLE CENTERED
                                    Text(
                                      pageIndex == 0
                                          ? loc.translate("how_to_play")
                                          : loc.translate("scoring"),
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),

                                    const SizedBox(height: 8),

                                    // DIVIDER
                                    Divider(color: secondaryText, thickness: 0.5),

                                    const SizedBox(height: 12),

                                    // CONTENT - PageView (Swipe to navigate)
                                    SizedBox(
                                      height: 220,
                                      child: PageView(
                                        controller: controller,
                                        onPageChanged: (i) {
                                          setState(() => pageIndex = i);
                                        },
                                        children: [
                                          // PAGE 1
                                          SingleChildScrollView(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                _helpText(loc.translate("how_to_play_1"), textColor),
                                                _helpText(loc.translate("how_to_play_2"), textColor),
                                                _helpText(loc.translate("how_to_play_3"), textColor),
                                                _helpText(loc.translate("how_to_play_4"), textColor),
                                                _helpText(loc.translate("how_to_play_5"), textColor),
                                              ],
                                            ),
                                          ),

                                          // PAGE 2
                                          SingleChildScrollView(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                _helpText(loc.translate("scoring_1"), textColor),
                                                _helpText(loc.translate("scoring_2"), textColor),
                                                _helpText(loc.translate("scoring_3"), textColor),
                                                _helpText(loc.translate("scoring_4"), textColor),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 12),

                                    // PAGE INDICATOR (2 dots)
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        _dot(isActive: pageIndex == 0, color: secondaryText!),
                                        const SizedBox(width: 8),
                                        _dot(isActive: pageIndex == 1, color: secondaryText),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 1),
          ],

          /// Main content grid
          Expanded(
              child: wordSetsToShow.isEmpty
                  ? Center(child: Text(loc.translate("no_wordsets_found")))
                  : SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                  MasonryGridView.count(
                  crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 2,
                      crossAxisSpacing: 12,
                      itemCount: wordSetsToShow.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) =>
                          WordSetCard(wordSet: wordSetsToShow[index]),
                  ),
                  if (_canLoadMore)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() => _currentPage++);
                          _loadWordSets(reset: false);
                        },
                        child: _isLoadingMore
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                            : Text(loc.translate("load_more")),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _helpText(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          height: 1.4,
          color: color,
        ),
      ),
    );
  }

  Widget _dot({required bool isActive, required Color color}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: isActive ? 10 : 8,
      height: isActive ? 10 : 8,
      decoration: BoxDecoration(
        color: isActive ? color : color.withOpacity(0.4),
        shape: BoxShape.circle,
      ),
    );
  }

}
