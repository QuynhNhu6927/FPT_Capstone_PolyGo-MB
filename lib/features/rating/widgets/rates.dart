import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/responsive.dart';
import '../../../core/api/api_client.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/app_button.dart';
import '../../../data/models/events/event_model.dart';
import '../../../data/models/events/event_my_rating_response.dart';
import '../../../data/models/events/event_rating_item.dart';
import '../../../data/repositories/event_repository.dart';
import '../../../data/services/apis/event_service.dart';

class Rates extends StatefulWidget {
  final String eventId;

  const Rates({super.key, required this.eventId});

  @override
  State<Rates> createState() => _RatesState();
}

class _RatesState extends State<Rates> {
  bool _loading = true;
  EventModel? _eventDetail;
  EventMyRatingModel? _myRating;

  late final EventRepository _eventRepository;
  List<EventRatingItem> _ratings = [];

  @override
  void initState() {
    super.initState();
    final apiClient = ApiClient();
    final eventService = EventService(apiClient);
    _eventRepository = EventRepository(eventService);
    _loadEventDetail();
    _loadMyRating();
    _loadOtherRatings();
  }

  Future<void> _loadEventDetail() async {
    setState(() => _loading = true);
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
      setState(() => _loading = false);
    }
  }

  Future<void> _loadMyRating() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final rating = await _eventRepository.getMyRating(
        token: token,
        eventId: widget.eventId,
      );

      setState(() {
        _myRating = rating;
      });
    } catch (e) {
      setState(() {
        _myRating = null;
      });
    }
  }

  Future<void> _loadOtherRatings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final ratings = await _eventRepository.getAllRatings(
        token: token,
        eventId: widget.eventId,
        pageNumber: 1,
        pageSize: 20,
      );

      setState(() {
        _ratings = ratings;
      });
    } catch (e) {
      setState(() {
        _ratings = [];
      });
    }
  }

  Future<void> _updateMyRating(int newRating, String newComment) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      await _eventRepository.updateRating(
        token: token,
        eventId: widget.eventId,
        rating: newRating,
        comment: newComment,
      );

      if (mounted) {
        final loc = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.translate("update_rating_success")),
          ),
        );
      }

      // Reload lại dữ liệu
      await _loadMyRating();
      await _loadOtherRatings();
    } catch (e) {
      if (mounted) {
        final loc = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.translate("error")),
          ),
        );
      }
    }
  }


  Widget _buildStar(int rating, Color colorPrimary) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: colorPrimary,
          size: sw(context, 20),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final loc = AppLocalizations.of(context);
    final colorPrimary = theme.colorScheme.primary;
    final backgroundColor = theme.colorScheme.background;
    final textColor = isDark ? Colors.white : Colors.black87;
    final Gradient cardBackground = isDark
        ? const LinearGradient(
      colors: [Color(0xFF1E1E1E), Color(0xFF2C2C2C)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    )
        : const LinearGradient(colors: [Colors.white, Colors.white]);

    if (_loading) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(child: CircularProgressIndicator(color: colorPrimary)),
      );
    }

    if (_eventDetail == null) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: Text(loc.translate("no_events_found"), style: theme.textTheme.bodyMedium),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Event title ---
            Padding(
              padding: EdgeInsets.all(sw(context, 20)),
              child: Text(
                _eventDetail!.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: st(context, 20),
                  color: textColor,
                ),
              ),
            ),
            // Banner
            Padding(
              padding: EdgeInsets.symmetric(horizontal: sw(context, 20)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: _eventDetail!.bannerUrl.isNotEmpty
                    ? Image.network(
                  _eventDetail!.bannerUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey[400],
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
            ),


            SizedBox(height: sh(context, 25)),

            // --- Scrollable content ---
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: sw(context, 20)),
                children: [
                  // --- My rating  ---
                  if (_myRating != null && _myRating!.hasRating) ...[
                    Text(
                      loc.translate("your_event_rating"),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: sh(context, 8)),
                    Container(
                      decoration: BoxDecoration(
                        gradient: cardBackground,
                        borderRadius: BorderRadius.circular(sw(context, 10)),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(sw(context, 12)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildStar(_myRating!.rating, colorPrimary),
                            SizedBox(height: sh(context, 8)),
                            Text(
                              _myRating!.comment,
                              style: TextStyle(color: textColor),
                            ),
                            ...[
                            SizedBox(height: sh(context, 4)),
                            Text(
                              '${loc.translate('at')} ${DateFormat('dd/MM/yyyy, HH:mm').format(_myRating!.createdAt.toLocal())}',
                              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                            ),
                          ],
                            SizedBox(height: sh(context, 8)),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  final ratingController = TextEditingController(text: _myRating!.comment);
                                  int tempRating = _myRating!.rating;

                                  final theme = Theme.of(context);
                                  final colorPrimary = theme.colorScheme.primary;
                                  final textColor = theme.textTheme.bodyMedium?.color ?? Colors.black87;
                                  final backgroundColor = theme.colorScheme.surface;
                                  final isDark = theme.brightness == Brightness.dark;

                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return Dialog(
                                        backgroundColor: Colors.transparent,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: cardBackground,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                loc.translate("fix_rating"),
                                                style: theme.textTheme.titleMedium?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: textColor,
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              StatefulBuilder(
                                                builder: (context, setStateDialog) {
                                                  return Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      // --- Stars picker ---
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: List.generate(5, (index) {
                                                          return IconButton(
                                                            icon: Icon(
                                                              index < tempRating
                                                                  ? Icons.star
                                                                  : Icons.star_border,
                                                              color: colorPrimary,
                                                            ),
                                                            onPressed: () {
                                                              setStateDialog(() {
                                                                tempRating = index + 1;
                                                              });
                                                            },
                                                          );
                                                        }),
                                                      ),
                                                      const SizedBox(height: 12),
                                                      // --- Comment field ---
                                                      TextField(
                                                        controller: ratingController,
                                                        maxLines: 3,
                                                        style: TextStyle(color: textColor),
                                                        decoration: InputDecoration(
                                                          labelText: loc.translate("your_event_rating"),
                                                          labelStyle: TextStyle(
                                                            color: isDark ? Colors.grey[400] : Colors.grey[700],
                                                          ),
                                                          enabledBorder: OutlineInputBorder(
                                                            borderSide: BorderSide(
                                                              color: isDark ? Colors.grey[700]! : Colors.grey[400]!,
                                                            ),
                                                            borderRadius: BorderRadius.circular(8),
                                                          ),
                                                          focusedBorder: OutlineInputBorder(
                                                            borderSide: BorderSide(
                                                              color: colorPrimary,
                                                              width: 2,
                                                            ),
                                                            borderRadius: BorderRadius.circular(8),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              ),
                                              const SizedBox(height: 16),
                                              Align(
                                                alignment: Alignment.centerRight,
                                                child: AppButton(
                                                  text: loc.translate("confirm"),
                                                  onPressed: () async {
                                                    Navigator.pop(context);
                                                    await _updateMyRating(tempRating, ratingController.text);
                                                  },
                                                  size: ButtonSize.sm,
                                                  variant: ButtonVariant.primary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );

                                },
                                child: Text(
                                  loc.translate("fix_rating"),
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),

                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: sh(context, 20)),
                  ],

                  // --- Other ratings ---
                  Text(
                    loc.translate("others_rating"),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  SizedBox(height: sh(context, 8)),
                  ..._ratings.map((rate) => Container(
                    decoration: BoxDecoration(
                      gradient: cardBackground,
                      borderRadius: BorderRadius.circular(sw(context, 10)),
                    ),
                    margin: EdgeInsets.only(bottom: sh(context, 12)),
                    child: Padding(
                      padding: EdgeInsets.all(sw(context, 12)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: sw(context, 20),
                            backgroundImage: (rate.user.avatarUrl.isNotEmpty)
                                ? NetworkImage(rate.user.avatarUrl)
                                : null,
                            backgroundColor: Colors.grey[800],
                            child: (rate.user.avatarUrl.isEmpty)
                                ? Icon(Icons.person, size: 24, color: Colors.white70)
                                : null,
                          ),
                          SizedBox(width: sw(context, 12)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  rate.user.name,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                ),
                                _buildStar(rate.rating, colorPrimary),
                                SizedBox(height: sh(context, 4)),
                                Text(
                                  rate.comment,
                                  style: TextStyle(color: textColor),
                                ),
                                if (rate.createdAt != null) ...[
                                  SizedBox(height: sh(context, 4)),
                                  Text(
                                    '${loc.translate("at")}: ${DateFormat('dd/MM/yyyy, HH:mm').format(rate.createdAt.toLocal())}',
                                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
