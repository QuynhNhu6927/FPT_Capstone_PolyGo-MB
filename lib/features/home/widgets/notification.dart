import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:polygo_mobile/features/home/widgets/social/post_details_content.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../data/models/notifications/notification_model.dart';
import '../../../data/repositories/notification_repository.dart';
import '../../inventories/screens/all_gifts_screen.dart';
import '../../inventories/widgets/badges/all_badges.dart';
import '../../inventories/widgets/level/all_levels.dart';
import '../../shared/app_bottom_bar.dart';
import '../../../../core/api/api_client.dart';
import '../../../data/services/apis/notification_service.dart';
import '../../../../routes/app_routes.dart';
import '../../shop/screens/shop_screen.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  bool loading = true;
  List<NotificationModel> notifications = [];

  bool loadingMore = false;
  int currentPage = 1;
  final int pageSize = 40;
  bool hasNextPage = true;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotifications();
      _scrollController = ScrollController();
      _scrollController.addListener(_onScroll);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients || loadingMore || !hasNextPage) return;
    final thresholdPixels = 200.0;
    if (_scrollController.position.extentAfter < thresholdPixels) {
      _loadMoreNotifications();
    }
  }

  Future<void> _loadMoreNotifications() async {
    if (loadingMore) return;
    setState(() => loadingMore = true);
    await _fetchNotifications(page: currentPage + 1);
    setState(() => loadingMore = false);
  }

  Future<void> _loadNotifications() async {
    setState(() => loading = true);
    await _fetchNotifications(page: 1);
    setState(() => loading = false);
  }

  Future<void> _fetchNotifications({required int page}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    try {
      final loc = AppLocalizations.of(context);
      final lang = loc.locale.languageCode;

      final repo = NotificationRepository(NotificationService(ApiClient()));
      final result = await repo.getNotificationsPaged(
        token,
        lang: lang,
        pageNumber: page,
        pageSize: pageSize,
      );

      if (!mounted) return;

      setState(() {
        if (page == 1) {
          notifications = result.items;
        } else {
          notifications.addAll(result.items);
        }
        currentPage = page;
        hasNextPage = result.hasNextPage;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).translate("load_notifications_error"),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  String timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    final loc = AppLocalizations.of(context);

    if (diff.inSeconds < 60) return loc.translate("just_now");
    if (diff.inMinutes < 60)
      return '${diff.inMinutes} ${loc.translate("minutes_ago")}';
    if (diff.inHours < 24)
      return '${diff.inHours} ${loc.translate("hours_ago")}';
    if (diff.inDays < 7) return '${diff.inDays} ${loc.translate("days_ago")}';
    if (diff.inDays < 30)
      return '${(diff.inDays / 7).floor()} ${loc.translate("weeks_ago")}';
    if (diff.inDays < 365)
      return '${(diff.inDays / 30).floor()} ${loc.translate("months_ago")}';

    return '${(diff.inDays / 365).floor()} ${loc.translate("year_ago")}';
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final t = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
        appBar: AppBar(
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          elevation: 1,
          title: Text(loc.translate("notification")),
          centerTitle: true,
        ),
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : notifications.isEmpty
            ? Center(
                child: Text(
                  loc.translate("no_notifications"),
                  style: t.bodyMedium,
                ),
              )
            : ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount: notifications.length + (hasNextPage ? 1 : 0),
                // +1 để show loading indicator cuối
                itemBuilder: (context, index) {
                  if (index >= notifications.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  }
                  final item = notifications[index];

                  return GestureDetector(
                    onTap: () async {
                      final prefs = await SharedPreferences.getInstance();
                      final token = prefs.getString('token');

                      if (token == null) return;

                      if (!item.isRead) {
                        try {
                          final repo = NotificationRepository(
                            NotificationService(ApiClient()),
                          );
                          final success = await repo.markAsRead(token, item.id);
                          if (success && mounted) {
                            setState(() {
                              notifications[index] = notifications[index]
                                  .copyWith(isRead: true);
                            });
                          }
                        } catch (e) {
                          // handle error nếu cần
                        }
                      }

                      await switch (item.type) {
                        'Post' =>
                          item.objectId != null
                              ? Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PostDetailsContent(
                                      postId: item.objectId!,
                                    ),
                                  ),
                                )
                              : Future.value(),
                        'Friend' =>
                          item.objectId != null
                              ? Navigator.pushNamed(
                                  context,
                                  AppRoutes.userProfile,
                                  arguments: {'id': item.objectId},
                                )
                              : Future.value(),
                        'Badge' => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => AllBadges()),
                        ),
                        'Event' => Navigator.pushNamed(
                          context,
                          AppRoutes.myEvents,
                        ),
                        'Gift' => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const AllGiftsScreen(initialTabIndex: 1),
                          ),
                        ),
                        'Level' => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AllLevels()),
                        ),
                        'Transaction' => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const ShopScreen(initialTabIndex: 2),
                          ),
                        ),
                        _ => Future.value(),
                      };

                      if (!notifications[index].isRead && mounted) {
                        setState(() {
                          notifications[index] = notifications[index].copyWith(
                            isRead: true,
                          );
                        });
                      }
                    },

                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark
                              ? [
                                  const Color(0xFF1E1E1E),
                                  const Color(0xFF2C2C2C),
                                ]
                              : [Colors.white, Colors.white],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child:
                                item.imageUrl != null &&
                                    item.imageUrl!.isNotEmpty
                                ? Image.network(
                                    item.imageUrl!,
                                    width: 56,
                                    height: 56,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, _, __) {
                                      return Image.asset(
                                        'assets/Primary2.png',
                                        width: 56,
                                        height: 56,
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  )
                                : Image.asset(
                                    'assets/Primary2.png',
                                    width: 56,
                                    height: 56,
                                    fit: BoxFit.cover,
                                  ),
                          ),

                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.content,
                                  style: t.bodyMedium?.copyWith(
                                    fontSize: 16,
                                    height: 1.4,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.grey[800],
                                    fontWeight: item.isRead == false
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                Row(
                                  children: [
                                    Text(
                                      timeAgo(item.createdAt),
                                      style: t.bodySmall?.copyWith(
                                        fontSize: 13,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),

                                    const Spacer(),

                                    if (item.isRead == false)
                                      Container(
                                        width: 10,
                                        height: 10,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF3472FC),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: AppBottomBar(currentIndex: 5),
      ),
    );
  }
}
