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

  void _showGiftDialog() {
    showDialog(
      context: context,
      builder: (context) {
        int quantity = _giftQuantity;
        String selectedGift = _selectedGift;
        return AlertDialog(
          title: const Text("Chọn quà"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedGift.isEmpty ? null : selectedGift,
                items: ['Hoa', 'Socola', 'Gấu bông']
                    .map((gift) => DropdownMenuItem(
                  value: gift,
                  child: Text(gift),
                ))
                    .toList(),
                onChanged: (v) => selectedGift = v ?? '',
                decoration: const InputDecoration(
                  labelText: "Chọn quà",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Số lượng",
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) => quantity = int.tryParse(v) ?? 1,
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Hủy")),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedGift = selectedGift;
                  _giftQuantity = quantity;
                });
                Navigator.of(context).pop();
              },
              child: const Text("Xác nhận"),
            )
          ],
        );
      },
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

                    // --- Host info ---
                    Row(
                      children: [
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _eventDetail!.host.name,
                              style: t.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: st(context, 16),
                                  color: textColor),
                            ),
                            Text(
                              "Host",
                              style: t.bodySmall?.copyWith(
                                  fontSize: st(context, 14),
                                  color: isDark ? Colors.grey[400] : Colors.grey[600]),
                            ),
                          ],
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

                    // --- Gift ---
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _showGiftDialog,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: colorPrimary, width: 2),
                          foregroundColor: colorPrimary,
                          padding: EdgeInsets.symmetric(vertical: sh(context, 12)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(sw(context, 10)),
                          ),
                        ),
                        child: Text(
                          _selectedGift.isEmpty
                              ? "Chọn quà"
                              : "$_selectedGift x$_giftQuantity",
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    SizedBox(height: sh(context, 20)),

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