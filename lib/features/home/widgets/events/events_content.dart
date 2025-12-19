import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../data/models/events/event_model.dart';
import '../../../../data/repositories/event_repository.dart';
import '../../../../data/services/apis/event_service.dart';
import '../../../shared/app_error_state.dart';
import 'event_card.dart';
import 'event_filter.dart';
import 'event_filter_bar.dart';
import '../../../../core/utils/string_extensions.dart';

class EventsContent extends StatefulWidget {
  final String searchQuery;
  final ScrollController controller;
  const EventsContent({
    super.key,
    this.searchQuery = '',
    required this.controller,
  });

  @override
  State<EventsContent> createState() => _EventsContentState();
}

class _EventsContentState extends State<EventsContent> {
  late final EventRepository _repository;

  bool _loading = true;
  bool _hasError = false;

  List<EventModel> _matchingEvents = [];
  List<EventModel> _searchMatchingEvents = [];

  List<EventModel> _filteredUpcomingEvents = [];

  List<Map<String, String>> _filterLanguages = [];
  List<Map<String, String>> _filterInterests = [];
  bool? _selectedIsFree;
  Locale? _currentLocale;
  bool _initialized = false;

  // final ScrollController _scrollController = ScrollController();
  bool _showFilterBar = true;
  double _lastOffset = 0;

  bool get _hasActiveFilter =>
      _filterLanguages.isNotEmpty || _filterInterests.isNotEmpty || _selectedIsFree != null;

  bool get _shouldLoadUpcoming =>
      _hasActiveFilter || widget.searchQuery.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _repository = EventRepository(EventService(ApiClient()));
    // _scrollController.addListener(_handleScroll);
    widget.controller.addListener(_handleScroll);

  }

  // void _handleScroll() {
  //   final offset = _scrollController.offset;
  //
  //   if (offset > _lastOffset && offset - _lastOffset > 10) {
  //     if (_showFilterBar) setState(() => _showFilterBar = false);
  //   } else if (offset < _lastOffset && _lastOffset - offset > 10) {
  //     if (!_showFilterBar) setState(() => _showFilterBar = true);
  //   }
  //   _lastOffset = offset;
  //
  //   if (_scrollController.position.pixels >=
  //       _scrollController.position.maxScrollExtent - 200) {
  //     if (_shouldLoadUpcoming) return;
  //     _loadMatchingEvents(lang: _currentLocale?.languageCode);
  //   }
  // }

  void _handleScroll() {
    final controller = widget.controller;

    if (controller.position.pixels >=
        controller.position.maxScrollExtent - 200) {
      if (_shouldLoadUpcoming) return;
      _loadMatchingEvents(lang: _currentLocale?.languageCode);
    }
  }


  @override
  void didUpdateWidget(covariant EventsContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery) {
      _initLoadEvents();
    }
  }

  @override
  void dispose() {
    // _scrollController.dispose();
    widget.controller.removeListener(_handleScroll);
    super.dispose();
  }

  bool _isInitializing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context);
    if (!_initialized || _currentLocale?.languageCode != locale.languageCode) {
      _initialized = true;
      _currentLocale = locale;
      _initLoadEvents();
    }
  }

  void _initLoadEvents() {
    if (_isInitializing) return;
    _isInitializing = true;

    Future.microtask(() async {
      if (_shouldLoadUpcoming) {
        await _loadUpcomingEvents(
            lang: _currentLocale?.languageCode, name: widget.searchQuery);
      } else {
        await _loadMatchingEvents(reset: true, lang: _currentLocale?.languageCode);
      }
      _isInitializing = false;
    });
  }

  int _getPageSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 900) return 40;
    return 10;
  }

  int _matchingEventsPage = 1;
  bool _isLoadingMore = false;
  bool _hasMoreMatchingEvents = true;

  Future<void> _loadMatchingEvents({bool reset = false, String? lang}) async {
    final pageSize = _getPageSize(context);

    if (reset) {
      setState(() {
        _loading = true;
        _hasError = false;
        _matchingEvents.clear();
        _searchMatchingEvents.clear();
        _matchingEventsPage = 1;
        _hasMoreMatchingEvents = true;
      });
    }

    if (!_hasMoreMatchingEvents || _isLoadingMore) return;

    _isLoadingMore = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      if (token.isEmpty) throw Exception("Missing token");

      final response = await _repository.getMatchingEventsPaged(
        token,
        lang: lang ?? 'vi',
        pageNumber: _matchingEventsPage,
        pageSize: pageSize,
      );

      if (!mounted) return;

      setState(() {
        _matchingEvents.addAll(response.items);
        _applyLocalSearch(widget.searchQuery);

        _hasMoreMatchingEvents = _matchingEventsPage < response.totalPages;
        _matchingEventsPage++;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _loading = false;
      });
    } finally {
      _isLoadingMore = false;
    }
  }

  void _applyLocalSearch(String query) {
    final q = query.trim();
    setState(() {
      if (q.isEmpty) {
        _searchMatchingEvents = List.from(_matchingEvents);
      } else {
        _searchMatchingEvents =
            _matchingEvents.where((e) => (e.title ?? '').fuzzyContains(q)).toList();
      }
    });
  }

  Future<void> _loadUpcomingEvents({String? lang, String? name}) async {
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
        pageSize: 500,
        languageIds: languageIds,
        interestIds: interestIds,
        isFree: _selectedIsFree,
        name: name?.trim().isEmpty ?? true ? null : name,
      );

      if (!mounted) return;
      setState(() {
        _filteredUpcomingEvents = response.items;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _loading = false;
      });
    }
  }

  List<EventModel> get _displayedEvents =>
      _shouldLoadUpcoming ? _filteredUpcomingEvents : _searchMatchingEvents;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width < 600 ? 2 : width < 1000 ? 3 : 4;
    final loc = AppLocalizations.of(context);

    final selectedFilters = [
      ..._filterLanguages.map((e) => e['name'] ?? ''),
      ..._filterInterests.map((e) => e['name'] ?? ''),
      if (_selectedIsFree != null)
        _selectedIsFree!
            ? (loc.translate("free") ?? "Miễn phí")
            : (loc.translate("paid") ?? "Trả phí"),
    ];

    if (_loading) return const Center(child: CircularProgressIndicator());

    if (_hasError) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        child: AppErrorState(
          onRetry: _initLoadEvents,
        ),
      );
    }

    final eventsToShow = _displayedEvents;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                    selectedFilters: selectedFilters,
                    onOpenFilter: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EventFilter()),
                      );
                      if (result != null && result is Map<String, dynamic>) {
                        setState(() {
                          _filterLanguages =
                          List<Map<String, String>>.from(result['languages'] ?? []);
                          _filterInterests =
                          List<Map<String, String>>.from(result['interests'] ?? []);
                          _selectedIsFree = result['isFree'];
                        });
                        _initLoadEvents();
                      }
                    },
                    onRemoveFilter: (tag) {
                      setState(() {
                        _filterLanguages.removeWhere((f) => f['name'] == tag);
                        _filterInterests.removeWhere((f) => f['name'] == tag);
                        if (tag == (loc.translate("free")) ||
                            tag == (loc.translate("paid"))) {
                          _selectedIsFree = null;
                        }
                      });
                      _initLoadEvents();
                    },
                  ),
                  if (!_hasActiveFilter) ...[
                    const SizedBox(height: 14),
                    Text(
                      loc.translate("events_matching_you"),
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
                : MasonryGridView.count(
              // controller: _scrollController,
              controller: widget.controller,

              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: eventsToShow.length,
              itemBuilder: (context, index) => EventCard(event: eventsToShow[index]),
            ),
          ),
        ],
      ),
    );
  }
}
