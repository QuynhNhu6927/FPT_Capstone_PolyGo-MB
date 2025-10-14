import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/responsive.dart';
import '../../../core/api/api_client.dart';
import '../../../data/models/subscription/subscription_plan_model.dart';
import '../../../data/repositories/subscription_repository.dart';
import '../../../data/services/subscription_service.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../main.dart';

class Subscriptions extends StatefulWidget {
  const Subscriptions({super.key});

  @override
  State<Subscriptions> createState() => _SubscriptionsState();
}

class _SubscriptionsState extends State<Subscriptions> {
  bool _isLoading = true;
  List<SubscriptionPlan> _plans = [];
  String? _error;
  Locale? _currentLocale;

  late final SubscriptionRepository _repo;

  @override
  void initState() {
    super.initState();
    _repo = SubscriptionRepository(SubscriptionService(ApiClient()));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = InheritedLocale.of(context).locale;
    if (_currentLocale == null ||
        _currentLocale!.languageCode != locale.languageCode) {
      _currentLocale = locale;
      _fetchPlans(lang: locale.languageCode);
    }
  }

  Future<void> _fetchPlans({String? lang}) async {
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

      final res = await _repo.getSubscriptionPlans(
        token: token,
        lang: lang ?? 'vi',
      );

      if (!mounted) return;
      setState(() {
        _plans = res?.items ?? [];
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
              '${loc.translate("failed_to_load_subscription_plans") ?? "Failed to load subscription plans"}: $_error',
              textAlign: TextAlign.center,
              style: t.bodyMedium?.copyWith(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _fetchPlans(lang: _currentLocale?.languageCode),
              child: Text(loc.translate("retry") ?? "Retry"),
            ),
          ],
        ),
      );
    }

    if (_plans.isEmpty) {
      return Center(
        child: Text(
          loc.translate("no_subscription_plans_available") ??
              "No subscription plans available.",
          style: t.titleMedium,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _fetchPlans(lang: _currentLocale?.languageCode),
      child: ListView.separated(
        padding: EdgeInsets.symmetric(
          horizontal: sw(context, 16),
          vertical: sh(context, 16),
        ),
        itemCount: _plans.length,
        separatorBuilder: (_, __) => SizedBox(height: sh(context, 16)),
        itemBuilder: (context, index) {
          final plan = _plans[index];
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final colorPrimary = const Color(0xFF2563EB);
          final loc = AppLocalizations.of(context);
          final t = Theme.of(context).textTheme;

          return Container(
            padding: EdgeInsets.all(sw(context, 20)),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [const Color(0xFF1E1E1E), const Color(0xFF2C2C2C)]
                    : [const Color(0xFFFFFFFF), const Color(0xFFFFFFFF)],
              ),
              borderRadius: BorderRadius.circular(sw(context, 16)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: icon + name
                Row(
                  children: [
                    Icon(
                      plan.planType.toLowerCase() == "premium"
                          ? Icons.workspace_premium_rounded
                          : Icons.star_outline_rounded,
                      color: colorPrimary,
                      size: sw(context, 28),
                    ),
                    SizedBox(width: sw(context, 10)),
                    Expanded(
                      child: Text(
                        plan.name,
                        style: t.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: st(context, 20),
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: sh(context, 8)),

                // Description
                Text(
                  plan.description,
                  style: t.bodyMedium?.copyWith(
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                    fontSize: st(context, 14),
                  ),
                ),
                SizedBox(height: sh(context, 16)),

                // Price & Duration
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "\$${plan.price.toStringAsFixed(2)}",
                      style: t.headlineSmall?.copyWith(
                        color: colorPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: st(context, 22),
                      ),
                    ),
                    Text(
                      "${plan.durationInDays} ${loc.translate("days") ?? "days"}",
                      style: t.bodyMedium?.copyWith(
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: sh(context, 16)),

                // Features
                if (plan.features.isNotEmpty &&
                    plan.features.any((f) => f.isEnabled)) ...[
                  Text(
                    loc.translate("features") ?? "Features",
                    style: t.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: st(context, 16),
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  SizedBox(height: sh(context, 8)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: plan.features
                        .where((f) => f.isEnabled)
                        .map(
                          (f) => Padding(
                        padding: EdgeInsets.symmetric(vertical: sh(context, 4)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.check_circle_outline_rounded,
                              color: colorPrimary,
                              size: sw(context, 18),
                            ),
                            SizedBox(width: sw(context, 8)),
                            Expanded(
                              child: Text(
                                f.featureName +
                                    (f.limitValue > 0
                                        ? " (${f.limitValue} ${f.limitType})"
                                        : ""),
                                style: t.bodyMedium?.copyWith(
                                  color: isDark ? Colors.white : Colors.black87,
                                  fontSize: st(context, 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                        .toList(),
                  ),
                  SizedBox(height: sh(context, 20)),
                ],

                // Subscribe button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorPrimary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: sh(context, 12)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(sw(context, 10)),
                      ),
                    ),
                    child: Text(
                      loc.translate("subscribe") ?? "Subscribe",
                      style: TextStyle(
                        fontSize: st(context, 16),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.2, end: 0);
        },
      ),
    );
  }
}
