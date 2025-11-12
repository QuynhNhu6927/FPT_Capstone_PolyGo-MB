import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
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
  String? _filterCategory;

  Locale? _currentLocale;
  bool _initialized = false;
  bool _isInitializing = false;

  final ScrollController _scrollController = ScrollController();
  bool _showFilterBar = true;
  double _lastOffset = 0;

  List<String> get _selectedFilters => [
    ..._filterLanguages.map((e) => e['name'] ?? ''),
    if (_filterDifficulty != null) _filterDifficulty!,
    if (_filterCategory != null) _filterCategory!,
  ];

  bool get _hasActiveFilter =>
      _filterLanguages.isNotEmpty ||
          _filterDifficulty != null ||
          _filterCategory != null;

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
        category: _filterCategory,
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
    return _wordSets
        .where((e) => e.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  bool get _canLoadMore => _currentPage < _totalPages && !_isLoadingMore;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width < 600 ? 1 : 2;

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
              margin: const EdgeInsets.only(bottom: 16),
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
                      _filterCategory = result['category'];
                    });
                    _loadWordSets(reset: true);
                  }
                },
                onRemoveFilter: (tag) {
                  setState(() {
                    _filterLanguages.removeWhere((f) => f['name'] == tag);
                    if (_filterDifficulty == tag) _filterDifficulty = null;
                    if (_filterCategory == tag) _filterCategory = null;
                  });
                  _loadWordSets(reset: true);
                },
              ),
            )
                : const SizedBox.shrink(),
          ),

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
}
