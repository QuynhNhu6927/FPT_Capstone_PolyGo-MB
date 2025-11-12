import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/responsive.dart';
import '../../../data/models/gift/gift_received_response.dart';
import '../../../data/repositories/gift_repository.dart';
import '../../../data/services/apis/gift_service.dart';

class AcceptedGifts extends StatefulWidget {
  const AcceptedGifts({super.key});

  @override
  State<AcceptedGifts> createState() => _AcceptedGiftsState();
}

class _AcceptedGiftsState extends State<AcceptedGifts> {
  bool _loading = true;
  List<GiftItem> _gifts = [];
  String? _error;
  Locale? _currentLocale;
  late final GiftRepository _repo;

  @override
  void initState() {
    super.initState();
    _repo = GiftRepository(GiftService(ApiClient()));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context);
    if (_currentLocale == null || _currentLocale!.languageCode != locale.languageCode) {
      _currentLocale = locale;
      _loadGifts(lang: locale.languageCode);
    }
  }

  Future<void> _loadGifts({String? lang}) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null || token.isEmpty) return;

      final res = await _repo.getReceivedGifts(
        token: token,
        pageNumber: 1,
        pageSize: 20,
        lang: lang ?? 'vi',
      );

      final acceptedGifts = res?.items.where((g) => g.isRead).toList() ?? [];

      if (!mounted) return;
      setState(() {
        _gifts = acceptedGifts;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
      final loc = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.translate("load_gifts_error")),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  String formatDateTime(DateTime dt) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final loc = AppLocalizations.of(context);

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_gifts.isEmpty) {
      return Center(
        child: Text(
          loc.translate("no_accepted_gifts"),
          style: theme.textTheme.bodyMedium,
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: sw(context, 16), vertical: sh(context, 8)),
      itemCount: _gifts.length,
      itemBuilder: (context, index) {
        final gift = _gifts[index];

        return Container(
          margin: EdgeInsets.only(bottom: sh(context, 16)),
          padding: EdgeInsets.all(sw(context, 16)),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [const Color(0xFF1E1E1E), const Color(0xFF2C2C2C)]
                  : [Colors.white, Colors.white],
            ),
            borderRadius: BorderRadius.circular(sw(context, 12)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar + tên + quà
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(sw(context, 30)),
                    child: Image.network(
                      gift.senderAvatarUrl ?? 'https://via.placeholder.com/150',
                      width: sw(context, 50),
                      height: sw(context, 50),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: sw(context, 50),
                        height: sw(context, 50),
                        color: Colors.grey[300],
                        child: Icon(Icons.person, color: Colors.grey[600]),
                      ),
                    ),
                  ),
                  SizedBox(width: sw(context, 12)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          gift.senderName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        SizedBox(height: sh(context, 4)),
                        Text(
                          '${loc.translate("has_gifted")} ${gift.giftName} x${gift.quantity}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Image.network(
                    gift.giftIconUrl,
                    width: sw(context, 50),
                    height: sw(context, 50),
                    errorBuilder: (_, __, ___) => Container(
                      width: sw(context, 50),
                      height: sw(context, 50),
                      color: Colors.grey[300],
                      child: Icon(Icons.card_giftcard, color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),

              SizedBox(height: sh(context, 20)),

              if (gift.message != null && gift.message!.isNotEmpty)
                Text(
                  '${loc.translate("message")} "${gift.message!}"',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: st(context, 14),
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),

              if (gift.message != null && gift.message!.isNotEmpty)
                SizedBox(height: sh(context, 20)),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (gift.createdAt != null)
                    Text(
                      '${loc.translate("gifted")} ${formatDateTime(gift.createdAt)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                    ),
                  if (gift.deliveredAt != null)
                    Text(
                      '${loc.translate("has_received")} ${formatDateTime(gift.deliveredAt!)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                    ),
                ],
              ),
            ],
          )

        ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
      },
    );
  }
}
