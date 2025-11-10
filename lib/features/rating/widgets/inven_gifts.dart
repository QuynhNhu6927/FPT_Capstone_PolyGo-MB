import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/responsive.dart';
import '../../../core/api/api_client.dart';
import '../../../data/models/gift/gift_me_response.dart';
import '../../../data/repositories/gift_repository.dart';
import '../../../data/services/apis/gift_service.dart';
import '../../../core/localization/app_localizations.dart';

class InvenGifts extends StatefulWidget {
  const InvenGifts({super.key});

  @override
  State<InvenGifts> createState() => _InvenGiftsState();
}

class _InvenGiftsState extends State<InvenGifts> {
  List<GiftMeItem> _myGifts = [];
  bool _loading = true;
  String? _error;
  late final GiftRepository _repo;
  int? _selectedIndex;
  int _quantity = 1;

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
      if (_myGifts.isNotEmpty) {
        print('[InvenGifts] ✅ Loaded ${_myGifts.length} gifts from server:');
        for (final gift in _myGifts) {
          print('   • ${gift.name} (ID: ${gift.id}) — Quantity: ${gift.quantity}');
        }
      } else {
        print('[InvenGifts] ⚠️ No gifts found for current user.');
      }
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

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      child: Padding(
        padding: EdgeInsets.all(sw(context, 16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with close (X)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  loc.translate("gifts"),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Main content
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(24.0),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
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
              )
            else if (_myGifts.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Center(
                    child: Text(
                      loc.translate("no_gifts_available"),
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                )
              else
                Flexible(
                  child: RefreshIndicator(
                    onRefresh: _loadMyGifts,
                    child: ListView.builder(
                      padding: EdgeInsets.only(top: sh(context, 8)),
                      shrinkWrap: true,
                      itemCount: _myGifts.length,
                      itemBuilder: (context, index) {
                        final gift = _myGifts[index];
                        final imageUrl = gift.iconUrl.isNotEmpty
                            ? gift.iconUrl
                            : 'https://img.icons8.com/fluency/96/gift.png';
                        final selected = _selectedIndex == index;

                        return Container(
                          margin: EdgeInsets.only(bottom: sh(context, 12)),
                          padding: EdgeInsets.all(sw(context, 14)),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                            borderRadius: BorderRadius.circular(sw(context, 12)),
                            border: Border.all(
                              color: selected ? const Color(0xFF2563EB) : Colors.transparent,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
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
                                      '${loc.translate("owned")}: ${gift.quantity}',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: Colors.green.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Circle select button
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedIndex = index;
                                    _quantity = 1;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: sw(context, 28),
                                  height: sw(context, 28),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: selected
                                          ? const Color(0xFF2563EB)
                                          : Colors.grey,
                                      width: 2,
                                    ),
                                    color:
                                    selected ? const Color(0xFF2563EB) : Colors.transparent,
                                  ),
                                  child: selected
                                      ? const Icon(Icons.check_rounded,
                                      color: Colors.white, size: 16)
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.1, end: 0);
                      },
                    ),
                  ),
                ),

            // --- Quantity selector & Confirm button ---
            if (_selectedIndex != null) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      if (_quantity > 1) {
                        setState(() => _quantity--);
                      }
                    },
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text(
                    '$_quantity',
                    style: theme.textTheme.titleMedium,
                  ),
                  IconButton(
                    onPressed: () {
                      final maxQty = _myGifts[_selectedIndex!].quantity;
                      if (_quantity < maxQty) {
                        setState(() => _quantity++);
                      }
                    },
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  final selectedGift = _myGifts[_selectedIndex!];
                  print('[InvenGifts] Selected gift: ${selectedGift.name} '
                      '(ID: ${selectedGift.id}) | Quantity: $_quantity');
                  Navigator.pop(context, {
                    'giftId': selectedGift.id,
                    'giftName': selectedGift.name,
                    'quantity': _quantity,
                  });
                },
                icon: const Icon(Icons.check_circle_outline),
                label: Text(loc.translate("confirm")),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding:
                  EdgeInsets.symmetric(horizontal: sw(context, 32), vertical: sh(context, 12)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
