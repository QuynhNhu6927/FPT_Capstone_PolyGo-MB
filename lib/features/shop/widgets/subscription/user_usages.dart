import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../data/models/subscription/usage_item.dart';
import '../../../../data/repositories/subscription_repository.dart';
import '../../../../data/services/apis/subscription_service.dart';

class UsageOverviewDialog extends StatefulWidget {
  const UsageOverviewDialog({super.key});

  @override
  State<UsageOverviewDialog> createState() => _UsageOverviewDialogState();
}

class _UsageOverviewDialogState extends State<UsageOverviewDialog> {
  List<UsageItem> usageItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsage();
  }

  Future<void> _loadUsage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null || token.isEmpty) return;

      final repo = SubscriptionRepository(
        SubscriptionService(ApiClient()),
      );

      final res = await repo.getUsage(token: token);
      if (res.data != null) {
        setState(() {
          usageItems = res.data!.items;
        });
      }
    } catch (e) {
      debugPrint("❌ Error loading usage: $e");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Gradient bg = isDark
        ? const LinearGradient(
      colors: [Color(0xFF1E1E1E), Color(0xFF2C2C2C)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    )
        : const LinearGradient(colors: [Colors.white, Colors.white]);
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: bg,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Title
                  Row(
                    children: [
                      Icon(Icons.bar_chart,
                          color: colorScheme.primary, size: 26),
                      const SizedBox(width: 8),
                      Text(
                        loc.translate('usage_overview'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  /// Content
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (usageItems.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(loc.translate('no_usage_data')),
                    )
                  else
                    ...usageItems
                        .map((item) => _UsageItemView(item: item)),
                ],
              ),
            ),

            /// Close button
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                icon: const Icon(Icons.close, size: 20),
                splashRadius: 18,
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class _UsageItemView extends StatelessWidget {
  final UsageItem item;

  const _UsageItemView({required this.item});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final bool unlimited = item.isUnlimited || item.limitValue == 0;

    final double progress = unlimited
        ? 1
        : (item.usageCount / item.limitValue).clamp(0, 1);

    final Color barColor = unlimited
        ? Colors.green
        : progress >= 1
        ? Colors.red
        : progress > 0.7
        ? Colors.orange
        : theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Feature name
          Text(
            loc.translate(item.featureType.toLowerCase()),
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 6),

          /// Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation(barColor),
            ),
          ),

          const SizedBox(height: 6),

          /// Info row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                unlimited
                    ? loc.translate('unlimited')
                    : '${item.usageCount} / ${item.limitValue}',
                style: const TextStyle(fontSize: 12),
              ),
              Text(
                _limitText(loc, item),
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _limitText(AppLocalizations loc, UsageItem item) {
    if (item.isUnlimited) {
      return loc.translate('no_limit');
    }

    switch (item.limitType.toLowerCase()) {
      case 'daily':
        return loc.translate('limit_daily');
      case 'weekly':
        return loc.translate('limit_weekly');
      case 'monthly':
        return loc.translate('limit_monthly');
      default:
        return item.limitType;
    }
  }
}
