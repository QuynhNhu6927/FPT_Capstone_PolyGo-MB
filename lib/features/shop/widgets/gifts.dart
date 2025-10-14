import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/responsive.dart';
import '../../../core/api/api_client.dart';
import '../../../data/models/gift/gift_model.dart';
import '../../../data/repositories/gift_repository.dart';
import '../../../data/services/gift_service.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../main.dart';

class Gifts extends StatefulWidget {
  const Gifts({super.key});

  @override
  State<Gifts> createState() => _GiftsState();
}

class _GiftsState extends State<Gifts> {
  bool _isLoading = true;
  List<GiftModel> _gifts = [];
  List<GiftModel> _filteredGifts = [];
  String? _error;
  String _search = '';
  Locale? _currentLocale;

  late final GiftRepository _repo;
  final _searchController = TextEditingController();

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
      _fetchGifts(lang: locale.languageCode);
    }
  }

  Future<void> _fetchGifts({String? lang}) async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)
                  .translate("please_log_in_first") ??
                  'Please log in first.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final res = await _repo.getGifts(token: token, lang: lang ?? 'vi');

      if (!mounted) return;
      setState(() {
        _gifts = res?.items ?? [];
        _filteredGifts = _gifts;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final t = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;
    final colorPrimary = const Color(0xFF2563EB);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${loc.translate("failed_to_load_gifts") ?? "Failed to load gifts"}: $_error',
              textAlign: TextAlign.center,
              style: t.bodyMedium?.copyWith(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  _fetchGifts(lang: _currentLocale?.languageCode),
              child: Text(loc.translate("retry") ?? "Retry"),
            ),
          ],
        ),
      );
    }

    if (_gifts.isEmpty) {
      return Center(
        child: Text(
          loc.translate("no_gifts_available") ?? "No gifts available.",
          style: t.titleMedium,
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
              hintText: loc.translate("search_gifts") ?? "Search gifts",
              prefixIcon: Icon(Icons.search,
                  color: _searchController.text.isNotEmpty
                      ? colorPrimary
                      : Colors.grey),
              filled: true,
              fillColor: theme.brightness == Brightness.dark
                  ? Colors.grey[850]
                  : const Color(0xFFF3F4F6),
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
                borderSide: BorderSide(
                  color: Colors.transparent,
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(sw(context, 12)),
                borderSide: BorderSide(
                  color: colorPrimary,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () =>
                _fetchGifts(lang: _currentLocale?.languageCode),
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: sw(context, 16)),
              itemCount: _filteredGifts.length,
              itemBuilder: (context, index) {
                final gift = _filteredGifts[index];
                return Container(
                  margin: EdgeInsets.only(bottom: sh(context, 16)),
                  padding: EdgeInsets.all(sw(context, 16)),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [const Color(0xFF1E1E1E), const Color(0xFF2C2C2C)]
                          : [const Color(0xFFFFFFFF), const Color(0xFFFFFFFF)],
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
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(sw(context, 12)),
                        child: Image.network(
                          gift.iconUrl,
                          width: sw(context, 60),
                          height: sw(context, 60),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: sw(context, 60),
                            height: sw(context, 60),
                            color: Colors.grey[300],
                            child: Icon(
                              Icons.card_giftcard,
                              size: sw(context, 30),
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: sw(context, 12)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              gift.name,
                              style: t.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            SizedBox(height: sh(context, 4)),
                            Text(
                              "${gift.price} ${loc.translate("coins") ?? "coins"}",
                              style: t.bodyMedium?.copyWith(
                                color: isDark ? Colors.grey.shade400 : Colors.grey,
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
          ),
        ),
      ],
    );
  }
}
