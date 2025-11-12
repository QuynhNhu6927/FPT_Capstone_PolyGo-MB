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

class UnreadGifts extends StatefulWidget {
  const UnreadGifts({super.key});

  @override
  State<UnreadGifts> createState() => _UnreadGiftsState();
}

class _UnreadGiftsState extends State<UnreadGifts> {
  bool _loading = true;
  List<GiftItem> _gifts = [];
  String? _error;
  Locale? _currentLocale;
  late final GiftRepository _repo;
  final Set<String> _loadingAccept = {};

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

      final unreadGifts = res?.items.where((g) => !g.isRead).toList() ?? [];

      if (!mounted) return;
      setState(() {
        _gifts = unreadGifts;
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
    final colorPrimary = const Color(0xFF2563EB);
    final loc = AppLocalizations.of(context);

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_gifts.isEmpty) {
      return Center(
        child: Text(
          loc.translate("no_unread_gifts"),
          style: theme.textTheme.bodyMedium,
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: sw(context, 16), vertical: sh(context, 8)),
      itemCount: _gifts.length,
      itemBuilder: (context, index) {
        final gift = _gifts[index];
        final isAccepting = _loadingAccept.contains(gift.presentationId);

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
                        if (gift.createdAt != null) ...[
                          SizedBox(height: sh(context, 4)),
                          Text(
                            '${loc.translate("at_time")} ${formatDateTime(gift.createdAt)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark ? Colors.white54 : Colors.black45,
                            ),
                          ),
                        ],
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

              SizedBox(height: sh(context, 20)),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    width: sw(context, 80),
                    child: OutlinedButton(
                      onPressed: isAccepting
                          ? null
                          : () async {
                        final loc = AppLocalizations.of(context);

                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(loc.translate("confirm")),
                            content: Text(loc.translate("reject_gift_confirm")),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: Text(loc.translate("cancel")),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: Text(loc.translate("confirm")),
                              ),
                            ],
                          ),
                        );

                        if (confirm != true) return;

                        setState(() {
                          _loadingAccept.add(gift.presentationId);
                        });

                        final prefs = await SharedPreferences.getInstance();
                        final token = prefs.getString('token');
                        if (token == null || token.isEmpty) return;

                        try {
                          final result = await _repo.rejectReceivedGift(
                            token: token,
                            presentationId: gift.presentationId,
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(AppLocalizations.of(context).translate("rejected_gift")),
                              duration: const Duration(seconds: 2),
                            ),
                          );

                          _loadGifts(lang: _currentLocale?.languageCode);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(AppLocalizations.of(context).translate("rejected_failed")),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        } finally {
                          setState(() {
                            _loadingAccept.remove(gift.presentationId);
                          });
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey),
                        padding: EdgeInsets.symmetric(vertical: sh(context, 6)),
                      ),
                      child: isAccepting
                          ? SizedBox(
                        height: sh(context, 12),
                        width: sh(context, 12),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : Text(loc.translate("reject"), style: TextStyle(fontSize: st(context, 12))),
                    ),
                  ),

                  SizedBox(width: sw(context, 8)),
                  SizedBox(
                    width: sw(context, 80),
                    child: ElevatedButton(
                      onPressed: isAccepting
                          ? null
                          : () async {
                        setState(() {
                          _loadingAccept.add(gift.presentationId);
                        });

                        final prefs = await SharedPreferences.getInstance();
                        final token = prefs.getString('token');
                        if (token == null || token.isEmpty) return;

                        try {
                          final result = await _repo.acceptReceivedGift(
                            token: token,
                            presentationId: gift.presentationId,
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  '${loc.translate("accepted_gift")} '
                                  'x${result?.quantity} '
                                  '${result?.giftName} '
                                  '+${result?.cashReceived}đ'
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );


                          _loadGifts(lang: _currentLocale?.languageCode);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(loc.translate("accepted_failed")),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        } finally {
                          setState(() {
                            _loadingAccept.remove(gift.presentationId);
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorPrimary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: sh(context, 6)),
                      ),
                      child: isAccepting
                          ? SizedBox(
                        height: sh(context, 12),
                        width: sh(context, 12),
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                          : Text(loc.translate("accept"), style: TextStyle(fontSize: st(context, 12))),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);

      },
    );
  }
}
