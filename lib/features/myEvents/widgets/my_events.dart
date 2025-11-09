import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:polygo_mobile/core/utils/string_extensions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/api/api_client.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../data/models/events/hosted_event_model.dart';
import '../../../data/repositories/event_repository.dart';
import '../../../data/services/apis/event_service.dart';
import '../../shared/app_error_state.dart';
import 'hosted_event_details.dart';
import 'hosted_filter.dart';

enum EventStatus { upcoming, live, canceled, pending, completed }

class MyEvents extends StatefulWidget {
  const MyEvents({super.key});

  @override
  State<MyEvents> createState() => _MyEventsState();
}

class _MyEventsState extends State<MyEvents> {
  String _token = '';
  late final EventRepository _repository;
  bool _loading = true;
  bool _hasError = false;
  List<HostedEventModel> _hostedEvents = [];
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';
  bool _isSearching = false;

  EventStatus? _selectedStatus = EventStatus.upcoming;
  Locale? _currentLocale;

  List<Map<String, String>> _filterLanguages = [];
  List<Map<String, String>> _filterInterests = [];

  @override
  void initState() {
    super.initState();
    _repository = EventRepository(EventService(ApiClient()));
    _loadHostedEvents();
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearching = _searchFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context);
    if (_currentLocale == null || _currentLocale!.languageCode != locale.languageCode) {
      _currentLocale = locale;
      _loadHostedEvents(lang: locale.languageCode);
    }
  }

  Future<void> _loadHostedEvents({String? lang}) async {
    setState(() {
      _loading = true;
      _hasError = false;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      if (token.isEmpty) throw Exception("Missing token");

      final events = await _repository.getHostedEvents(
        lang: lang ?? 'vi',
        pageNumber: 1,
        pageSize: 50,
        languageIds: _filterLanguages.map((e) => e['id']!).toList(),
        interestIds: _filterInterests.map((e) => e['id']!).toList(),
        token: token,
      );

      if (!mounted) return;
      setState(() {
        _hostedEvents = events;
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

  List<HostedEventModel> get _filteredEvents {
    final query = _searchQuery.trim().toLowerCase();
    final source = (_selectedStatus == null)
        ? _hostedEvents
        : _hostedEvents.where((e) {
      switch (_selectedStatus) {
        case EventStatus.upcoming:
          return e.status == "Approved";
        case EventStatus.live:
          return e.status == "Live";
        case EventStatus.canceled:
          return e.status == "Cancelled" || e.status == "Rejected";
        case EventStatus.pending:
          return e.status == "Pending";
        case EventStatus.completed:
          return e.status == "Completed";
        default:
          return false;
      }
    }).toList();

    if (query.isEmpty) return source;

    return source.where((e) => e.title.fuzzyContains(query)).toList();
  }

  List<String> get _selectedFilters => [
    ..._filterLanguages.map((e) => e['name'] ?? ''),
    ..._filterInterests.map((e) => e['name'] ?? ''),
  ];

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
          onRetry: () => _loadHostedEvents(lang: _currentLocale?.languageCode),
        ),
      );
    }

    final eventsToShow = _filteredEvents;

    return Padding(
      padding: const EdgeInsets.all(16),
      child:
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildStatusButton(EventStatus.upcoming, "Sắp diễn ra"),
                const SizedBox(width: 8),
                _buildStatusButton(EventStatus.live, "Đang diễn ra"),
                const SizedBox(width: 8),
                _buildStatusButton(EventStatus.pending, "Chờ duyệt"),
                const SizedBox(width: 8),
                _buildStatusButton(EventStatus.canceled, "Đã hủy"),
                const SizedBox(width: 8),
                _buildStatusButton(EventStatus.completed, "Đã kết thúc"),
              ],
            ),
          ),

          const SizedBox(height: 12),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 42,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2C2C2C) : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _isSearching ? Theme.of(context).colorScheme.primary : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 10),
                Icon(Icons.search_rounded, color: _isSearching ? Theme.of(context).colorScheme.primary : Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      hintText: "Search...",
                      hintStyle: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey : Colors.grey[600]),
                      border: InputBorder.none,
                      isCollapsed: true,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
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
                      });
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (_selectedStatus != EventStatus.canceled)
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HostedFilter()),
                  );

                  if (result != null && result is Map<String, dynamic>) {
                    setState(() {
                      _filterLanguages = List<Map<String, String>>.from(result['languages'] ?? []);
                      _filterInterests = List<Map<String, String>>.from(result['interests'] ?? []);
                    });
                    _loadHostedEvents(lang: _currentLocale?.languageCode);
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
                                _loadHostedEvents(lang: _currentLocale?.languageCode);
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
            child: eventsToShow.isEmpty
                ? Center(child: Text("Không có event nào phù hợp với filter hiện tại"))
                : MasonryGridView.count(
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

  Widget _buildStatusButton(EventStatus status, String label) {
    final theme = Theme.of(context);
    final isSelected = _selectedStatus == status;

    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedStatus = isSelected ? null : status;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? theme.colorScheme.primary : theme.colorScheme.surface,
        foregroundColor: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        elevation: 1,
      ),
      child: Text(label, style: const TextStyle(fontSize: 14)),
    );
  }

  Widget _buildEventCard(BuildContext context, HostedEventModel event) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBackground = isDark
        ? const LinearGradient(colors: [Color(0xFF1E1E1E), Color(0xFF2C2C2C)], begin: Alignment.topLeft, end: Alignment.bottomRight)
        : const LinearGradient(colors: [Colors.white, Colors.white]);

    final textColor = isDark ? Colors.white70 : Colors.black87;
    final formattedDate = event.startAt != null
        ? DateFormat('dd MMM yyyy, HH:mm').format(event.startAt.toLocal())
        : "";

    return GestureDetector(
      onTap: () async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token') ?? '';

        if (token.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bạn chưa đăng nhập')),
          );
          return;
        }

        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (_) => HostedEventDetails(
            event: event,
            eventRepository: _repository,
            token: token,
            parentContext: context,
            onCancel: () => _loadHostedEvents(lang: _currentLocale?.languageCode),
          ),
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
                aspectRatio: 16 / 10,
                child: event.bannerUrl.isNotEmpty
                    ? Image.network(
                  event.bannerUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.event_note_rounded, size: 64, color: Colors.white70),
                    ),
                  ),
                )
                    : Container(
                  color: Colors.grey[400],
                  child: const Center(
                    child: Icon(Icons.event_note_rounded, size: 64, color: Colors.white70),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 36,
                      child: Text(
                        event.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, height: 1.3, color: textColor),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedDate,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.grey[500]),
                    ),
                  ],
                ),
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
                        child: Text(
                          category.name,
                          style: TextStyle(color: theme.colorScheme.primary, fontSize: 12, fontWeight: FontWeight.w500),
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
