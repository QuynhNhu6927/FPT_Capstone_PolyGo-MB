import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/responsive.dart';
import '../../../core/api/api_client.dart';
import '../../../data/models/gift/gift_me_response.dart';
import '../../../data/repositories/gift_repository.dart';
import '../../../data/services/apis/gift_service.dart';
import '../../../core/localization/app_localizations.dart';

class MyGifts extends StatefulWidget {
  const MyGifts({super.key});

  @override
  State<MyGifts> createState() => _MyGiftsState();
}

class _MyGiftsState extends State<MyGifts> {
  List<GiftMeItem> _myGifts = [];
  bool _loading = true;
  String? _error;
  late final GiftRepository _repo;

  @override
  void initState() {
    super.initState();
    _repo = GiftRepository(GiftService(ApiClient()));
    _loadMyGifts();
  }

  Future<void> _loadMyGifts() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        setState(() {
          _loading = false;
          _error = "Token missing";
        });
        return;
      }

      final res = await _repo.getMyGifts(token: token, pageSize: 50);
      if (!mounted) return;

      setState(() {
        _myGifts = res?.items ?? [];
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final loc = AppLocalizations.of(context);

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              loc.translate("failed_to_load_gifts"),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadMyGifts,
              child: Text(loc.translate("retry")),
            ),
          ],
        ),
      );
    }

    if (_myGifts.isEmpty) {
      return Center(
        child: Text(
          loc.translate("no_gifts_available"),
          style: theme.textTheme.titleMedium,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMyGifts,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: sw(context, 16), vertical: sh(context, 8)),
        itemCount: _myGifts.length,
        itemBuilder: (context, index) {
          final gift = _myGifts[index];
          final imageUrl = gift.iconUrl.isNotEmpty
              ? gift.iconUrl
              : 'https://img.icons8.com/fluency/96/gift.png';

          return Container(
            margin: EdgeInsets.only(bottom: sh(context, 16)),
            padding: EdgeInsets.all(sw(context, 16)),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(sw(context, 12)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(sw(context, 12)),
                  child: Image.network(
                    imageUrl,
                    width: sw(context, 60),
                    height: sw(context, 60),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: sw(context, 60),
                      height: sw(context, 60),
                      color: Colors.grey[300],
                      child: Icon(Icons.card_giftcard,
                          size: sw(context, 30), color: Colors.grey[600]),
                    ),
                  ),
                ),
                SizedBox(width: sw(context, 12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        gift.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      SizedBox(height: sh(context, 4)),
                      Text(
                        '${gift.price} đ',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark ? Colors.grey.shade400 : Colors.grey,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: sh(context, 4)),
                        child: Text(
                          '${loc.translate("owned")}: ${gift.quantity}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.green.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
        },
      ),
    );
  }
}
