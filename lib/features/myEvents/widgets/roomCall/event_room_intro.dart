import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../data/models/events/event_model.dart';
import '../../../../data/repositories/event_repository.dart';
import '../../../../data/services/apis/event_service.dart';

class EventRoomIntro extends StatefulWidget {
  final String eventId;

  const EventRoomIntro({super.key, required this.eventId});

  @override
  State<EventRoomIntro> createState() => _EventRoomIntroState();
}

class _EventRoomIntroState extends State<EventRoomIntro> {
  EventModel? _event;
  bool _loading = true;
  late final EventRepository _repo;

  @override
  void initState() {
    super.initState();
    _repo = EventRepository(EventService(ApiClient()));
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final detail = await _repo.getEventDetail(
        token: token,
        eventId: widget.eventId,
      );

      setState(() {
        _event = detail;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      elevation: 12,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(20),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _event == null
            ? const Text('Failed to load event')
            : SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Title + close
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _event!.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(),

              /// Banner
              const SizedBox(height: 12),
              AspectRatio(
                aspectRatio: 16 / 9,
                child: _event!.bannerUrl.isNotEmpty
                    ? Image.network(
                  _event!.bannerUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      _bannerFallback(),
                )
                    : _bannerFallback(),
              ),

              const SizedBox(height: 16),

              /// Description
              Text(
                _event!.description.isNotEmpty
                    ? _event!.description
                    : loc.translate('no_description'),
                style: theme.textTheme.bodyMedium,
              ),

              const SizedBox(height: 20),

              _infoRow(
                context,
                Icons.language,
                loc.translate('language'),
                _event!.language.name,
              ),
              _infoRow(
                context,
                Icons.category_outlined,
                loc.translate('categories'),
                _event!.categories.isNotEmpty
                    ? _event!.categories.map((e) => e.name).join(', ')
                    : loc.translate('none'),
              ),
              _infoRow(
                context,
                Icons.timer_outlined,
                loc.translate('duration'),
                "${_event!.expectedDurationInMinutes} min",
              ),
              _infoRow(
                context,
                Icons.monetization_on_outlined,
                loc.translate('fee'),
                _event!.fee > 0
                    ? _event!.fee.toString()
                    : loc.translate('free'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(
      BuildContext context,
      IconData icon,
      String label,
      String value,
      ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: theme.textTheme.bodySmall
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bannerFallback() {
    return Container(
      color: Colors.grey[400],
      child: const Center(
        child: Icon(Icons.event_note_rounded, size: 64, color: Colors.white70),
      ),
    );
  }
}
