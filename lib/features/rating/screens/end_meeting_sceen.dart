import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:polygo_mobile/features/rating/screens/rating_screen.dart';
import '../../../data/models/events/event_model.dart';
import '../../../routes/app_routes.dart';
import '../../../data/repositories/event_repository.dart';
import '../../../data/services/apis/event_service.dart';
import '../../../core/api/api_client.dart';
import '../../../../../core/localization/app_localizations.dart';

class EndMeetingScreen extends StatefulWidget {
  final String eventId;

  const EndMeetingScreen({super.key, required this.eventId});

  @override
  State<EndMeetingScreen> createState() => _EndMeetingScreenState();
}

class _EndMeetingScreenState extends State<EndMeetingScreen> {
  EventModel? _eventDetail;
  bool _loading = true;
  late final EventRepository _eventRepository;

  @override
  void initState() {
    super.initState();
    final apiClient = ApiClient();
    final eventService = EventService(apiClient);
    _eventRepository = EventRepository(eventService);

    _loadEventDetail();
  }

  Future<void> _loadEventDetail() async {
    setState(() {
      _loading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final detail = await _eventRepository.getEventDetail(
        token: token,
        eventId: widget.eventId,
      );

      setState(() {
        _eventDetail = detail;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: _loading
                ? const CircularProgressIndicator()
                : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${loc.translate('event')} \"${_eventDetail?.title ?? ''}\" "
                      "${loc.translate('hosted_by')} ${_eventDetail?.host.name ?? ''} "
                      "${loc.translate('event_has_ended')}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  "${loc.translate('thanks_for_joining')} "
                      "${loc.translate('please_rate_host')} ${_eventDetail?.host.name ?? ''}.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),

                const SizedBox(height: 32),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Rating button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                RatingScreen(eventId: widget.eventId),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        loc.translate('rating'),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Home button
                    OutlinedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.home,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0xFF2563EB),
                          width: 2,
                        ),
                        foregroundColor: const Color(0xFF2563EB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        loc.translate('home'),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
