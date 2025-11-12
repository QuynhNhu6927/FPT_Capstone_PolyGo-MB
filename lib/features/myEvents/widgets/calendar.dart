import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/api/api_client.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../data/models/events/joined_event_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/event_repository.dart';
import '../../../data/services/apis/auth_service.dart';
import '../../../data/services/apis/event_service.dart';
import '../../shared/app_error_state.dart';
import 'joined_event_details.dart';

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  String? _id;
  late final EventRepository _repository;
  bool _loading = true;
  bool _hasError = false;
  List<JoinedEventModel> _joinedEvents = [];

  Locale? _currentLocale;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _repository = EventRepository(EventService(ApiClient()));
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadUser();
    await _loadJoinedEvents();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context);
    if (_currentLocale == null ||
        _currentLocale!.languageCode != locale.languageCode) {
      _currentLocale = locale;
      _loadJoinedEvents(lang: locale.languageCode);
    }
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    try {
      final user = await AuthRepository(AuthService(ApiClient())).me(token);
      if (!mounted) return;
      setState(() {
        _id = user.id;
      });
    } catch (e) {
      //
    }
  }

  Future<void> _loadJoinedEvents({String? lang}) async {
    setState(() {
      _loading = true;
      _hasError = false;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      if (token.isEmpty) throw Exception("Missing token");

      final events = await _repository.getJoinedEvents(
        lang: lang ?? 'vi',
        pageNumber: 1,
        pageSize: 100,
        token: token,
      );

      if (!mounted) return;
      setState(() {
        _joinedEvents = events.toList();
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

  List<JoinedEventModel> _getEventsForDay(DateTime day) {
    return _joinedEvents.where((e) {
      return e.status.toLowerCase() != 'cancelled'  && e.userEvent.status != 2 &&
          e.startAt.year == day.year &&
          e.startAt.month == day.month &&
          e.startAt.day == day.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_loading) return const Center(child: CircularProgressIndicator());

    if (_hasError) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: AppErrorState(
          onRetry: () => _loadJoinedEvents(lang: _currentLocale?.languageCode),
        ),
      );
    }

    final selectedEvents = _selectedDay != null
        ? _getEventsForDay(_selectedDay!)
        : _getEventsForDay(_focusedDay);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TableCalendar<JoinedEventModel>(
            locale: _currentLocale?.languageCode ?? 'vi',
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
            onDaySelected: (selected, focused) {
              setState(() {
                _selectedDay = selected;
                _focusedDay = focused;
              });
            },
            eventLoader: _getEventsForDay,
            calendarFormat: CalendarFormat.month,
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                color: isDark ? Colors.white70 : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              weekendStyle: TextStyle(
                color: isDark ? Colors.white70 : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
              ),
              outsideTextStyle: TextStyle(
                color: isDark ? Colors.grey[700]! : Colors.grey[400]!,
              ),
              defaultTextStyle: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
              ),
              weekendTextStyle: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
              ),
              markerDecoration: const BoxDecoration(shape: BoxShape.circle),
            ),

            calendarBuilders: CalendarBuilders<JoinedEventModel>(
              markerBuilder: (context, date, events) {
                if (events.isEmpty) return null;

                final filtered = events
                    .where((e) => e.status.toLowerCase() != 'cancelled')
                    .toList();
                if (filtered.isEmpty) return null;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: filtered.take(3).map((e) {
                    Color color;
                    switch (e.status.toLowerCase()) {
                      case 'approved':
                        color = Colors.blueAccent;
                        break;
                      case 'rejected':
                        color = Colors.amber;
                        break;
                      case 'live':
                        color = Colors.green;
                        break;
                      case 'completed':
                        color = Colors.grey;
                        break;
                      default:
                        color = Colors.grey;
                    }

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 1.5),
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: selectedEvents.isEmpty
                ? Center(
                    child: Text(
                      loc.translate("no_events_found"),
                      style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: selectedEvents.length,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemBuilder: (context, index) {
                      final event = selectedEvents[index];
                      return _buildEventCard(
                        event,
                        isDark,
                      ).animate().fadeIn(duration: 300.ms);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(JoinedEventModel event, bool isDark) {
    final formattedDate =
        "${event.startAt.day.toString().padLeft(2, '0')}/${event.startAt.month.toString().padLeft(2, '0')}/${event.startAt.year} "
        "${event.startAt.hour.toString().padLeft(2, '0')}:${event.startAt.minute.toString().padLeft(2, '0')}";

    final cardBackground = isDark
        ? const LinearGradient(
            colors: [Color(0xFF1E1E1E), Color(0xFF2C2C2C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(colors: [Colors.white, Colors.white]);

    final textColor = isDark ? Colors.white70 : Colors.black87;

    return GestureDetector(
      onTap: () async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token') ?? '';

        if (token.isEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Bạn chưa đăng nhập')));
          return;
        }
        showDialog(
          context: context,
          builder: (context) => JoinedEventDetails(
            event: event,
            currentUserId: _id,
            eventRepository: _repository,
            token: token,
            parentContext: context,
            onEventCanceled: () {
              setState(() {
                _joinedEvents.removeWhere((e) => e.id == event.id);
              });
            },
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
        child: ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: event.bannerUrl.isNotEmpty
                ? Image.network(
                    event.bannerUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[400],
                    child: const Icon(
                      Icons.event_note_rounded,
                      size: 32,
                      color: Colors.white70,
                    ),
                  ),
          ),
          title: Text(
            event.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          subtitle: Text(
            formattedDate,
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
        ),
      ),
    );
  }
}
