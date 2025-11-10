import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/responsive.dart';
import '../../../core/api/api_client.dart';
import '../../../data/models/events/event_model.dart';
import '../../../data/repositories/event_repository.dart';
import '../../../data/services/apis/event_service.dart';
import '../../myEvents/screens/my_events_screen.dart';
import 'inven_gifts.dart';

class RatingWidget extends StatefulWidget {
  final String eventId;

  const RatingWidget({super.key, required this.eventId});

  @override
  State<RatingWidget> createState() => _RatingWidgetState();
}

class _RatingWidgetState extends State<RatingWidget> {
  int _rating = 0;
  bool _ratingError = false;
  EventModel? _eventDetail;
  bool _loading = true;
  late final EventRepository _eventRepository;

  final TextEditingController _commentController = TextEditingController();

  String _selectedGift = '';
  String _selectedGiftName = '';
  int _giftQuantity = 1;

  @override
  void initState() {
    super.initState();
    final apiClient = ApiClient();
    final eventService = EventService(apiClient);
    _eventRepository = EventRepository(eventService);

    _loadEventDetail();
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

  Widget _buildStar(int index, Color colorPrimary) {
    return IconButton(
      onPressed: () => setState(() => _rating = index),
      icon: Icon(
        index <= _rating ? Icons.star : Icons.star_border,
        color: colorPrimary,
        size: sw(context, 32),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final colorPrimary = theme.colorScheme.primary;
    final backgroundColor = theme.colorScheme.background;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black87;

    if (_loading) {
      return Center(
          child: CircularProgressIndicator(color: colorPrimary)
      );
    }

    if (_eventDetail == null) {
      return Center(
          child: Text("Không tải được thông tin event", style: t.bodyMedium)
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(sw(context, 20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Event name ---
                    Text(
                      _eventDetail!.title,
                      style: t.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: st(context, 20),
                          color: textColor),
                    ),
                    SizedBox(height: sh(context, 8)),

                    // --- Banner ---
                    if (_eventDetail!.bannerUrl.isNotEmpty)
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.network(
                          _eventDetail!.bannerUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    SizedBox(height: sh(context, 16)),

                    // --- Host info + Gift button ---
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Avatar
                        CircleAvatar(
                          radius: sw(context, 28),
                          backgroundImage: (_eventDetail!.host.avatarUrl != null &&
                              _eventDetail!.host.avatarUrl!.isNotEmpty)
                              ? NetworkImage(_eventDetail!.host.avatarUrl!)
                              : null,
                          backgroundColor: Colors.grey[300],
                          child: (_eventDetail!.host.avatarUrl == null ||
                              _eventDetail!.host.avatarUrl!.isEmpty)
                              ? Icon(Icons.person, size: 36, color: Colors.white70)
                              : null,
                        ),

                        SizedBox(width: sw(context, 12)),

                        // Host name + role
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _eventDetail!.host.name,
                                style: t.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: st(context, 16),
                                  color: textColor,
                                ),
                              ),
                              Text(
                                "Host",
                                style: t.bodySmall?.copyWith(
                                  fontSize: st(context, 14),
                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // --- Gift button ---
                        OutlinedButton(
                          onPressed: () async {
                            final result = await showDialog(
                              context: context,
                              builder: (context) => const InvenGifts(),
                            );

                            if (result != null && mounted) {
                              setState(() {
                                _selectedGift = result['giftId'];
                                _selectedGiftName = result['giftName'] ?? '';
                                _giftQuantity = result['quantity'] ?? 1;
                              });
                              print('[RatingWidget] Gift selected: ${result['giftName']} '
                                  '(ID: ${result['giftId']}) | Quantity: ${result['quantity']}');
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: colorPrimary, width: 2),
                            foregroundColor: colorPrimary,
                            padding: EdgeInsets.symmetric(
                              vertical: sh(context, 8),
                              horizontal: sw(context, 12),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(sw(context, 10)),
                            ),
                          ),
                          child: Text(
                            _selectedGift.isEmpty
                                ? "Tặng quà"
                                : "$_selectedGiftName x$_giftQuantity",
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: sh(context, 16)),

                    // --- Rating stars ---
                    _buildRatingStars(colorPrimary),
                    SizedBox(height: sh(context, 16)),

                    // --- Comment ---
                    TextField(
                      controller: _commentController,
                      maxLines: 4,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        labelText: "Viết nhận xét",
                        labelStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700]),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(sw(context, 10))),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: sh(context, 12), horizontal: sw(context, 12)),
                      ),
                    ),
                    SizedBox(height: sh(context, 16)),

                  ],
                ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.2, end: 0),
              ),
            ),

            Container(
              width: double.infinity,
              padding: EdgeInsets.all(sw(context, 20)),
              color: backgroundColor,
              child: ElevatedButton(
                onPressed: () async {
                  if (_rating < 1) {
                    setState(() => _ratingError = true);
                    return;
                  }
                  setState(() => _ratingError = false);

                  final prefs = await SharedPreferences.getInstance();
                  final token = prefs.getString('token') ?? '';

                  if (token.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Bạn chưa đăng nhập")),
                    );
                    return;
                  }

                  final comment = _commentController.text;
                  final giftId = _selectedGift.isEmpty ? '' : _selectedGift;
                  final giftQuantity = _selectedGift.isEmpty ? 0 : _giftQuantity;

                  try {
                    final res = await _eventRepository.rateEvent(
                      token: token,
                      eventId: widget.eventId,
                      rating: _rating,
                      comment: comment,
                      giftId: giftId,
                      giftQuantity: giftQuantity,
                    );

                    final msg = (res.message ?? '').trim().toLowerCase();

                    if (msg == 'success.create') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Gửi đánh giá thành công!")),
                      );
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const MyEventsScreen(initialTab: 2),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Không gửi được đánh giá${res.message != null ? ': ${res.message}' : ''}",
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Đã có lỗi xảy ra")),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorPrimary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: sh(context, 14)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(sw(context, 10))),
                ),
                child: const Text(
                  "Gửi đánh giá",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ),

            ),

          ],
        ),
      ),
    );
  }

  Widget _buildRatingStars(Color colorPrimary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(5, (index) => _buildStar(index + 1, colorPrimary)),
        ),
        if (_ratingError)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              "Vui lòng chọn đánh giá",
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}