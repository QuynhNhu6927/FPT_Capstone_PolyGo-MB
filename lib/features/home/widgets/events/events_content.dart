import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:polygo_mobile/core/utils/string_extensions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../data/models/events/coming_event_model.dart';
import '../../../../data/models/events/event_model.dart';
import '../../../../data/repositories/event_repository.dart';
import '../../../../data/services/apis/event_service.dart';
import '../../../shared/app_error_state.dart';
import 'event_card.dart';
import 'event_filter.dart';
import 'event_filter_bar.dart';

class EventsContent extends StatefulWidget {
  final String searchQuery;
  const EventsContent({super.key, this.searchQuery = ''});

  @override
  State<EventsContent> createState() => _EventsContentState();
}

class _EventsContentState extends State<EventsContent> {
  late final EventRepository _repository;

  bool _loading = true;
  bool _hasError = false;
  bool _isLoadingMore = false;

  List<EventModel> _matchingEvents = [];
  int _currentPage = 1;
  int _totalPages = 1;
  int _pageSize = 8;

  List<EventModel> _filteredUpcomingEvents = [];

  List<Map<String, String>> _filterLanguages = [];
  List<Map<String, String>> _filterInterests = [];
  bool? _selectedIsFree;
  Locale? _currentLocale;
  bool _initialized = false;

  final ScrollController _scrollController = ScrollController();
  bool _showFilterBar = true;
  double _lastOffset = 0;

  List<String> get _selectedFilters => [
    ..._filterLanguages.map((e) => e['name'] ?? ''),
    ..._filterInterests.map((e) => e['name'] ?? ''),
    if (_selectedIsFree != null)
      _selectedIsFree! ? "Miễn phí" : "Trả phí",
  ];

  bool get _hasActiveFilter =>
      _filterLanguages.isNotEmpty || _filterInterests.isNotEmpty || _selectedIsFree != null;

  @override
  void initState() {
    super.initState();
    _repository = EventRepository(EventService(ApiClient()));

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
  bool _isInitializing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context);

    if (!_initialized) {
      _initialized = true;
      _currentLocale = locale;
      _initLoadEvents();
    } else if (_currentLocale!.languageCode != locale.languageCode) {
      _currentLocale = locale;
      _initLoadEvents();
    }
  }

  void _initLoadEvents() {
    if (_isInitializing) return;
    _isInitializing = true;

    // Chạy async
    Future.microtask(() async {
      if (_hasActiveFilter) {
        await _loadUpcomingEvents(lang: _currentLocale?.languageCode);
      } else {
        await _loadMatchingEvents(reset: true, lang: _currentLocale?.languageCode);
      }
      _isInitializing = false;
    });
  }

  Future<void> _loadMatchingEvents({bool reset = false, String? lang}) async {
    if (reset) {
      setState(() {
        _loading = true;
        _hasError = false;
        _currentPage = 1;
        _matchingEvents.clear();
      });
    } else {
      setState(() => _isLoadingMore = true);
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      if (token.isEmpty) throw Exception("Missing token");

      final response = await _repository.getMatchingEventsPaged(
        token,
        lang: lang ?? 'vi',
        pageNumber: _currentPage,
        pageSize: _pageSize,
      );

      if (!mounted) return;
      setState(() {
        _matchingEvents.addAll(response.items);
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

  Future<void> _loadUpcomingEvents({String? lang}) async {
    setState(() {
      _loading = true;
      _hasError = false;
      _filteredUpcomingEvents.clear();
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      if (token.isEmpty) throw Exception("Missing token");

      final languageIds = _filterLanguages.map((e) => e['id']!).toList();
      final interestIds = _filterInterests.map((e) => e['id']!).toList();

      final response = await _repository.getUpcomingEventsPaged(
        token,
        lang: lang ?? 'vi',
        pageNumber: 1,
        pageSize: _pageSize,
        languageIds: languageIds,
        interestIds: interestIds,
        isFree: _selectedIsFree,
      );

      if (!mounted) return;
      setState(() {
        _filteredUpcomingEvents = response.items;
        _totalPages = response.totalPages;
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

  List<dynamic> get _displayedEvents {
    final query = widget.searchQuery.trim();
    final source =
    _hasActiveFilter ? _filteredUpcomingEvents : _matchingEvents;

    if (query.isEmpty) return source;

    return source.where((e) {
      if (e is EventModel) {
        return e.title.fuzzyContains(query);
      } else if (e is ComingEventModel) {
        return e.title.fuzzyContains(query);
      }
      return false;
    }).toList();
  }

  bool get _canLoadMore =>
      !_hasActiveFilter && _currentPage < _totalPages && !_isLoadingMore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width < 600 ? 2 : width < 1000 ? 3 : 4;
    final loc = AppLocalizations.of(context);

    if (_loading) return const Center(child: CircularProgressIndicator());

    if (_hasError) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        child: AppErrorState(
          onRetry: () {
            if (_hasActiveFilter) {
              _loadUpcomingEvents(lang: _currentLocale?.languageCode);
            } else {
              _loadMatchingEvents(
                  reset: true, lang: _currentLocale?.languageCode);
            }
          },
        ),
      );
    }

    final eventsToShow = _displayedEvents;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter bar ẩn/hiện có animation
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
              margin: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                EventFilterBar(
                selectedFilters: _selectedFilters,
                onOpenFilter: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EventFilter()),
                  );
                  if (result != null && result is Map<String, dynamic>) {
                    setState(() {
                      _filterLanguages = List<Map<String, String>>.from(
                          result['languages'] ?? []);
                      _filterInterests = List<Map<String, String>>.from(
                          result['interests'] ?? []);
                      _selectedIsFree = result['isFree'];
                    });
                    if (_hasActiveFilter) {
                      _loadUpcomingEvents(
                          lang: _currentLocale?.languageCode);
                    } else {
                      _loadMatchingEvents(
                          reset: true,
                          lang: _currentLocale?.languageCode);
                    }
                  }
                },
                onRemoveFilter: (tag) {
                  setState(() {
                    _filterLanguages
                        .removeWhere((f) => f['name'] == tag);
                    _filterInterests
                        .removeWhere((f) => f['name'] == tag);
                    if (tag == "Miễn phí" || tag == "Trả phí") {
                      _selectedIsFree = null;
                    }
                  });
                  _hasActiveFilter
                      ? _loadUpcomingEvents(
                      lang: _currentLocale?.languageCode)
                      : _loadMatchingEvents(
                      reset: true,
                      lang: _currentLocale?.languageCode);
                },
                ),
                  if (!_hasActiveFilter) ...[
                    const SizedBox(height: 14),
                    Text(
                      "Những sự kiện phù hợp với bạn",
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
            child: eventsToShow.isEmpty
                ? Center(child: Text(loc.translate("no_events_found")))
                : SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  MasonryGridView.count(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    itemCount: eventsToShow.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) =>
                        EventCard(event: eventsToShow[index]),
                  ),
                  if (_canLoadMore)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() => _currentPage++);
                          _loadMatchingEvents(
                            reset: false,
                            lang: _currentLocale?.languageCode,
                          );
                        },
                        child: _isLoadingMore
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2),
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
