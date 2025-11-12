import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/responsive.dart';
import '../../../core/api/api_client.dart';
import '../../../data/models/gift/gift_model.dart';
import '../../../data/models/gift/gift_purchase_request.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/gift_repository.dart';
import '../../../data/services/apis/auth_service.dart';
import '../../../data/services/apis/gift_service.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../main.dart';
import '../../shared/app_error_state.dart';

class Gifts extends StatefulWidget {
  final bool isRetrying;
  final VoidCallback? onError;

  const Gifts({super.key, this.isRetrying = false, this.onError});

  @override
  State<Gifts> createState() => _GiftsState();
}

class _GiftsState extends State<Gifts> {
  Map<String, int> _ownedGiftQuantities = {};
  List<GiftModel> _gifts = [];
  Map<String, int> _quantities = {};
  List<GiftModel> _filteredGifts = [];
  bool _loading = true;
  String? _error;
  String _search = '';
  Locale? _currentLocale;
  final _searchController = TextEditingController();
  late final GiftRepository _repo;


  final List<String> fallbackImages = [
    "https://img.icons8.com/fluency/96/gift.png",
    "https://img.icons8.com/fluency/96/present.png",
  ];

  @override
  void initState() {
    super.initState();
    _repo = GiftRepository(GiftService(ApiClient()));
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredGifts = _gifts
          .where((g) => g.name.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = InheritedLocale.of(context).locale;
    if (_currentLocale == null ||
        _currentLocale!.languageCode != locale.languageCode) {
      _currentLocale = locale;
      _loadGiftsData(lang: locale.languageCode);
      _loadMyGifts();

    }
  }

  @override
  void didUpdateWidget(covariant Gifts oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRetrying && !oldWidget.isRetrying) {
      _loadGiftsData();
    }
  }

  Future<void> _loadMyGifts() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    try {
      final giftRepo = GiftRepository(GiftService(ApiClient()));
      final res = await giftRepo.getMyGifts(token: token);

      if (res != null && res.items.isNotEmpty) {
        setState(() {
          _ownedGiftQuantities = {
            for (var item in res.items) item.id: item.quantity,
          };
        });
      }
    } catch (e) {

    }
  }
  Future<void> _loadGiftsData({String? lang}) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = "Token missing";
      });
      widget.onError?.call();
      return;
    }

    try {
      final res = await _repo.getGifts(token: token, lang: lang ?? 'vi');
      if (!mounted) return;
      setState(() {
        _gifts = res?.items ?? [];
        _filteredGifts = _gifts;
        _loading = false;
      });
      await _loadMyGifts();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
      widget.onError?.call();
    }
  }


  Future<void> _purchaseGiftWithQuantity(GiftModel gift, int quantity) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final loc = AppLocalizations.of(context);

    if (token == null || token.isEmpty) {
      return;
    }

    final authRepo = AuthRepository(AuthService(ApiClient()));
    final user = await authRepo.me(token);
    final balance = user.balance;

    final totalCost = gift.price * quantity;

    if (balance < totalCost) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${loc.translate("not_enough_buy")} '
              '${gift.name}!'
          ),
          duration: const Duration(seconds: 3),
        ),
      );

      await _loadMyGifts();
      return;
    }

    bool confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.translate("confirm_purchase")),
        content: Text(
          '${loc.translate("purchase_gift_question")} '
          '${gift.name} '
          'x$quantity '
          '${loc.translate("with_price")} '
          '$totalCost đ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(loc.translate("cancel")),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(loc.translate("confirm")),
          ),
        ],
      ),
    ) ?? false;

    if (!confirmed) return;

    try {
      final request = GiftPurchaseRequest(
        giftId: gift.id,
        quantity: quantity,
        paymentMethod: "System",
        notes: "",
      );

      final res = await _repo.purchaseGift(token: token, request: request);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.translate("purchase_success")),
          duration: const Duration(seconds: 2),
        ),
      );

      await _loadGiftsData(lang: _currentLocale?.languageCode);
      await _loadMyGifts();

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.translate("purchase_failed")),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorPrimary = const Color(0xFF2563EB);

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        child: AppErrorState(
          onRetry: () => _loadGiftsData(lang: _currentLocale?.languageCode),
        ),
      );
    }
    if (_gifts.isEmpty) {
      return Center(
        child: Text(
          loc.translate("no_gifts_available"),
          style: theme.textTheme.titleMedium,
        ),
      );
    }

    return Column(
      children: [
        // Search bar
        Padding(
          padding: EdgeInsets.all(sw(context, 16)),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: loc.translate("search_gifts"),
              prefixIcon: Icon(Icons.search,
                  color: _searchController.text.isNotEmpty
                      ? colorPrimary
                      : Colors.grey),
              filled: true,
              fillColor: isDark ? Colors.grey[850] : const Color(0xFFF3F4F6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(sw(context, 12)),
                borderSide: BorderSide(
                  color: _searchController.text.isNotEmpty
                      ? colorPrimary
                      : Colors.transparent,
                  width: 1.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(sw(context, 12)),
                borderSide: BorderSide(color: Colors.transparent, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(sw(context, 12)),
                borderSide: BorderSide(color: colorPrimary, width: 1.5),
              ),
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _loadGiftsData(lang: _currentLocale?.languageCode),
            child: GridView.builder(
              padding: EdgeInsets.symmetric(horizontal: sw(context, 16), vertical: sh(context, 16)),
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 500,
                mainAxisSpacing: sh(context, 16),
                crossAxisSpacing: sw(context, 16),
                childAspectRatio: 3,
              ),
              itemCount: _filteredGifts.length,
              itemBuilder: (context, index) {
                final gift = _filteredGifts[index];
                final imageUrl = gift.iconUrl.isNotEmpty
                    ? gift.iconUrl
                    : fallbackImages[index % fallbackImages.length];
                int quantity = _quantities[gift.id] ?? 1;

                return _buildGiftCard(gift, imageUrl, quantity, isDark, theme, colorPrimary, loc);
              },
            ),
          ),
        )
      ],
    );
  }

  Widget _buildGiftCard(GiftModel gift, String imageUrl, int quantity, bool isDark, ThemeData theme, Color colorPrimary, AppLocalizations loc) {
    return Container(
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
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Ảnh
          ClipRRect(
            borderRadius: BorderRadius.circular(sw(context, 12)),
            child: Image.network(
              imageUrl,
              width: sw(context, 60),
              height: sw(context, 60),
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: sw(context, 12)),

          // Info gift
          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gift.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: sh(context, 4)),
                Text("${gift.price} đ",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.grey.shade400 : Colors.grey,
                    )),
                if (_ownedGiftQuantities.containsKey(gift.id))
                  Text(
                    '${loc.translate("owned")}: ${_ownedGiftQuantities[gift.id]}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.green.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),

          // Quantity + buy
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (quantity > 1) {
                          setState(() {
                            _quantities[gift.id] = quantity - 1;
                          });
                        }
                      },
                      child: _buildQtyButton(Icons.remove, isDark),
                    ),
                    SizedBox(width: sw(context, 8)),
                    Text(
                      "$quantity",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: st(context, 16),
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    SizedBox(width: sw(context, 8)),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _quantities[gift.id] = quantity + 1;
                        });
                      },
                      child: _buildQtyButton(Icons.add, isDark),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => _purchaseGiftWithQuantity(gift, quantity),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorPrimary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: sh(context, 10)),
                  ),
                  child: Text(loc.translate("buy")),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildQtyButton(IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? Colors.black : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(icon, size: 16, color: isDark ? Colors.white : Colors.black),
    );
  }

}
