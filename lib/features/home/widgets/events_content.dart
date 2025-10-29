import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import 'package:polygo_mobile/core/utils/string_extensions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/api/api_client.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../data/models/events/event_model.dart';
import '../../../data/repositories/event_repository.dart';
import '../../../data/services/event_service.dart';
import '../../shared/app_error_state.dart';
import 'event_details.dart';
import 'event_filter.dart';

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

  List<EventModel> _allEvents = [];
  List<EventModel> _matchingEvents = [];

  bool _isShowingMatching = true;

  List<Map<String, String>> _filterLanguages = [];
  List<Map<String, String>> _filterInterests = [];

  Locale? _currentLocale;

  List<String> get _selectedFilters => [
    ..._filterLanguages.map((e) => e['name'] ?? ''),
    ..._filterInterests.map((e) => e['name'] ?? ''),
  ];

  bool get _hasActiveFilter => _filterLanguages.isNotEmpty || _filterInterests.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _repository = EventRepository(EventService(ApiClient()));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context);
    if (_currentLocale == null || _currentLocale!.languageCode != locale.languageCode) {
      _currentLocale = locale;
      _loadMatchingEvents(lang: locale.languageCode);
    }
  }

  Future<void> _loadMatchingEvents({String? lang}) async {
    setState(() {
      _loading = true;
      _hasError = false;
      _isShowingMatching = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      if (token.isEmpty) throw Exception("Missing token");

      final languageIds = _filterLanguages.map((e) => e['id']!).toList();
      final interestIds = _filterInterests.map((e) => e['id']!).toList();

      final comingEvents = await _repository.getUpcomingEvents(
        token,
        lang: lang ?? 'vi',
        pageNumber: 1,
        pageSize: 50,
        languageIds: languageIds,
        interestIds: interestIds,
      );

      final events = comingEvents.map((e) => EventModel(
        id: e.id,
        title: e.title,
        description: e.description,
        status: e.status,
        startAt: e.startAt,
        expectedDurationInMinutes: e.expectedDurationInMinutes,
        registerDeadline: e.registerDeadline,
        allowLateRegister: e.allowLateRegister,
        capacity: e.capacity,
        fee: e.fee.toInt(),
        bannerUrl: e.bannerUrl,
        isPublic: e.isPublic,
        numberOfParticipants: e.numberOfParticipants,
        planType: e.planType,
        host: HostModel(
          id: e.host.id,
          name: e.host.name,
          avatarUrl: e.host.avatarUrl,
        ),
        language: LanguageModel(
          id: e.language.id,
          code: e.language.code,
          name: e.language.name,
          iconUrl: e.language.iconUrl,
        ),
        categories: e.categories.map((c) => CategoryModel(
          id: c.id,
          name: c.name,
          iconUrl: c.iconUrl,
        )).toList(),
      )).toList();

      if (!mounted) return;
      setState(() {
        _matchingEvents = events;
        _loading = false;
        _hasError = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _loading = false;
      });
    }
  }

  Future<void> _loadAllEvents({String? lang}) async {
    setState(() {
      _loading = true;
      _hasError = false;
      _isShowingMatching = false;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      if (token.isEmpty) throw Exception("Missing token");

      final events = await _repository.getMatchingEvents(
        token,
        lang: lang ?? 'vi',
        pageNumber: 1,
        pageSize: 50,
      );

      if (!mounted) return;
      setState(() {
        _allEvents = events;
        _loading = false;
        _hasError = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _loading = false;
      });
    }
  }

  List<EventModel> get _filteredEvents {
    final query = widget.searchQuery.trim();
    final source = _hasActiveFilter ? _matchingEvents : (_isShowingMatching ? _matchingEvents : _allEvents);

    if (query.isEmpty) return source;

    return source.where((e) => e.title.fuzzyContains(query)).toList();
  }

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
              _loadMatchingEvents(lang: _currentLocale?.languageCode);
            } else {
              _loadAllEvents(lang: _currentLocale?.languageCode);
            }
          },
        ),
      );
    }

    final eventsToShow = _filteredEvents;
    if (eventsToShow.isEmpty) return Center(child: Text(loc.translate("no_events_found")));

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EventFilter()),
                  );

                  if (result != null && result is Map<String, dynamic>) {
                    setState(() {
                      _filterLanguages = List<Map<String, String>>.from(result['languages'] ?? []);
                      _filterInterests = List<Map<String, String>>.from(result['interests'] ?? []);
                    });
                    _loadMatchingEvents(lang: _currentLocale?.languageCode);
                  }
                },
                icon: const Icon(Icons.filter_alt_outlined),
                label: Text(loc.translate("filter")),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  foregroundColor: theme.colorScheme.onPrimaryContainer,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                          border: Border.all(color: theme.colorScheme.primary.withOpacity(0.5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(tag, style: TextStyle(color: theme.colorScheme.primary, fontSize: 13, fontWeight: FontWeight.w500)),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _filterLanguages.removeWhere((f) => f['name'] == tag);
                                  _filterInterests.removeWhere((f) => f['name'] == tag);
                                });
                                _hasActiveFilter ? _loadMatchingEvents(lang: _currentLocale?.languageCode) : _loadAllEvents(lang: _currentLocale?.languageCode);
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
          const SizedBox(height: 16),
          Expanded(
            child: MasonryGridView.count(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              itemCount: eventsToShow.length,
              itemBuilder: (context, index) => _buildEventCard(context, eventsToShow[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, EventModel event) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBackground = isDark
        ? const LinearGradient(colors: [Color(0xFF1E1E1E), Color(0xFF2C2C2C)], begin: Alignment.topLeft, end: Alignment.bottomRight)
        : const LinearGradient(colors: [Colors.white, Colors.white]);

    final textColor = isDark ? Colors.white70 : Colors.black87;
    final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(event.startAt);

    return GestureDetector(
      onTap: () => showDialog(context: context, barrierDismissible: true, builder: (_) => EventDetail(event: event)),
      child: Container(
        decoration: BoxDecoration(
          gradient: cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: isDark ? Colors.black.withOpacity(0.3) : Colors.black12, blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 10,
                child: event.bannerUrl.isNotEmpty
                    ? Image.network(event.bannerUrl, fit: BoxFit.cover, width: double.infinity, errorBuilder: (_, __, ___) => Container(color: Colors.grey[300], child: const Center(child: Icon(Icons.event_note_rounded, size: 64, color: Colors.white70))))
                    : Container(color: Colors.grey[400], child: const Center(child: Icon(Icons.event_note_rounded, size: 64, color: Colors.white70))),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SizedBox(
                    height: 36,
                    child: Text(event.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, height: 1.3, color: textColor)),
                  ),
                  const SizedBox(height: 4),
                  Text(formattedDate, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.grey[500])),
                ]),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SizedBox(
                  height: 28,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: event.categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, tagIndex) {
                      final category = event.categories[tagIndex];
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(isDark ? 0.25 : 0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(category.name, style: TextStyle(color: theme.colorScheme.primary, fontSize: 12, fontWeight: FontWeight.w500)),
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
