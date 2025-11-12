import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/responsive.dart';
import '../../../core/api/api_client.dart';
import '../../../data/models/api_response.dart';
import '../../../data/models/subscription/subscription_cancel_request.dart';
import '../../../data/models/subscription/subscription_current_response.dart';
import '../../../data/models/subscription/subscription_plan_model.dart';
import '../../../data/models/subscription/subscription_request.dart';
import '../../../data/models/subscription/subscription_response.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/subscription_repository.dart';
import '../../../data/services/apis/auth_service.dart';
import '../../../data/services/apis/subscription_service.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../main.dart';
import '../../shared/app_error_state.dart';

class Subscriptions extends StatefulWidget {
  final bool isRetrying;
  final VoidCallback? onError;

  const Subscriptions({super.key, required this.isRetrying, this.onError});

  @override
  State<Subscriptions> createState() => _SubscriptionsState();
}

class _SubscriptionsState extends State<Subscriptions> {
  bool _isLoading = true;
  List<SubscriptionPlan> _plans = [];
  String? _error;
  Locale? _currentLocale;
  CurrentSubscription? _currentSubscription;
  bool _isCurrentLoading = true;

  late final SubscriptionRepository _repo;

  @override
  void initState() {
    super.initState();
    _repo = SubscriptionRepository(SubscriptionService(ApiClient()));
    _loadCurrentSubscription();
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

  @override
  void didUpdateWidget(covariant Subscriptions oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRetrying && !oldWidget.isRetrying) {
      _fetchPlans(lang: _currentLocale?.languageCode);
    }
  }

  Future<void> _updateAutoRenewDialog() async {
    if (_currentSubscription == null) return;

    bool autoRenew = _currentSubscription!.autoRenew;
    final loc = AppLocalizations.of(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(loc.translate("auto_renew")),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(loc.translate("enable_auto_renew"))),
                      Switch(
                        value: autoRenew,
                        activeColor: Theme.of(context).colorScheme.primary,
                        onChanged: (value) => setState(() => autoRenew = value),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(loc.translate("cancel")),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(loc.translate("save")),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirm != true) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) return;

    try {
      final res = await _repo.updateAutoRenew(
        token: token,
        autoRenew: autoRenew,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.translate("update_enable_success")),
          duration: const Duration(seconds: 2),
        ),
      );

      // Refresh current subscription
      await _loadCurrentSubscription();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.translate("update_enable_failed")),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _loadCurrentSubscription() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) return;

    try {
      final res = await _repo.getCurrentSubscription(token: token);
      if (!mounted) return;
      setState(() {
        _currentSubscription = res.data;
        _isCurrentLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isCurrentLoading = false;
      });
    }
  }

  Future<void> _subscribePlan(SubscriptionPlan plan) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final loc = AppLocalizations.of(context);

    if (token == null || token.isEmpty) return;

    bool autoRenew = true;

    final authRepo = AuthRepository(AuthService(ApiClient()));
    final user = await authRepo.me(token);
    final balance = user.balance;
    final planCost = plan.price;

    if (balance < planCost) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${loc.translate("not_enough_buy")} '
            '${plan.name} '
            '${loc.translate("please_add_money")} ',
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      return;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(loc.translate("confirm_registration_sub")),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${loc.translate("confirm_plan_use")} ${plan.name} ${loc.translate("with_price")} ${plan.price.toStringAsFixed(2)} đ?',
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Checkbox(
                        value: autoRenew,
                        onChanged: (v) => setState(() => autoRenew = v ?? true),
                      ),
                      Expanded(child: Text(loc.translate("auto_renew"))),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(loc.translate("cancel")),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(loc.translate("confirm")),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != true) return;

    try {
      final repo = SubscriptionRepository(SubscriptionService(ApiClient()));
      final request = SubscriptionRequest(
        subscriptionPlanId: plan.id,
        autoRenew: autoRenew,
      );

      final ApiResponse<SubscriptionResponse> res = await repo.subscribe(
        token: token,
        request: request,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).translate("sub_success")),
          duration: const Duration(seconds: 2),
        ),
      );

      await Future.wait([
        _fetchPlans(lang: _currentLocale?.languageCode),
        _loadCurrentSubscription(),
      ]);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).translate("sub_failed")),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _cancelCurrentSubscription() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty || _currentSubscription == null) {
      return;
    }

    final reasonController = TextEditingController();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).translate("cancel")),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).translate("cancel_warning"),
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reasonController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).translate("reason"),
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 12,
                  ),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(AppLocalizations.of(context).translate("cancel")),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(AppLocalizations.of(context).translate("confirm")),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      final reason = reasonController.text.isEmpty
          ? "User requested cancellation"
          : reasonController.text;

      final request = SubscriptionCancelRequest(reason: reason);

      final res = await _repo.cancelSubscription(
        token: token,
        request: request,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).translate("cancel_success"),
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      await _loadCurrentSubscription();
      await _fetchPlans(lang: _currentLocale?.languageCode);
    } catch (e, st) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).translate("cancel_failed"),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
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
              AppLocalizations.of(context).translate("please_log_in_first"),
            ),
            backgroundColor: Colors.red,
          ),
        );
        widget.onError?.call();
        return;
      }

      final res = await _repo.getSubscriptionPlans(
        token: token,
        lang: lang ?? 'vi',
      );

      if (!mounted) return;
      setState(() {
        _plans = (res?.items?.where((plan) => plan.price > 0).toList() ?? [])
          ..sort((a, b) => a.price.compareTo(b.price));
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
      widget.onError?.call();
    }
  }

  Widget? _buildCurrentSubscriptionSection() {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final t = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;
    final colorPrimary = const Color(0xFF2563EB);

    if (_isCurrentLoading || _currentSubscription == null) {
      return null;
    }

    if (_currentSubscription!.planType.toLowerCase() == "free") {
      return null;
    }

    return Container(
      padding: EdgeInsets.all(sw(context, 16)),
      decoration: BoxDecoration(
        gradient: isDark
            ? LinearGradient(
                colors: [Color(0xFF1E1E1E), Color(0xFF2C2C2C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(colors: [Colors.white, Colors.white]),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            loc.translate("current_subscription"),
            style: t.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: st(context, 20),
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: sh(context, 12)),
          Container(
            padding: EdgeInsets.all(sw(context, 16)),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorPrimary, colorPrimary.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(sw(context, 12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _currentSubscription!.planName,
                        style: t.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Text(
                      "${_currentSubscription!.daysRemaining} ${loc.translate("days_remaining")}",
                      style: t.bodyMedium?.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
                SizedBox(height: sh(context, 8)),
                Text(
                  "${loc.translate("start_at")}: ${_currentSubscription!.startAt.toLocal().toString().split(' ')[0]}",
                  style: t.bodySmall?.copyWith(color: Colors.white70),
                ),
                Text(
                  "${loc.translate("end_at")}: ${_currentSubscription!.endAt.toLocal().toString().split(' ')[0]}",
                  style: t.bodySmall?.copyWith(color: Colors.white70),
                ),
                SizedBox(height: sh(context, 16)),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _cancelCurrentSubscription,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: colorPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(sw(context, 8)),
                          ),
                        ),
                        child: Text(loc.translate("cancel")),
                      ),
                    ),
                    SizedBox(width: sw(context, 12)),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _updateAutoRenewDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: colorPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(sw(context, 8)),
                          ),
                        ),
                        child: Text(loc.translate("auto_renew")),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.2, end: 0);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isWideScreen =
        MediaQuery.of(context).size.width >= 600;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        child: AppErrorState(
          onRetry: () => _fetchPlans(lang: _currentLocale?.languageCode),
        ),
      );
    }

    if (_plans.isEmpty) {
      return Center(
        child: Text(
          loc.translate("no_subscription_plans_available"),
          style: Theme.of(context).textTheme.titleMedium,
        ),
      );
    }

    final currentSection = _buildCurrentSubscriptionSection();

    if (isWideScreen && currentSection != null) {
      // Tablet: show side by side
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: sw(context, 16),
          vertical: sh(context, 16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: currentSection,
            ),
            SizedBox(width: sw(context, 16)),
            // Plans list (hẹp hơn)
            Expanded(
              flex: 3,
              child: ListView.separated(
                shrinkWrap: true,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: _plans.length,
                separatorBuilder: (_, __) => SizedBox(height: sh(context, 16)),
                itemBuilder: (context, index) {
                  final plan = _plans[index];
                  return _buildPlanCard(plan);
                },
              ),
            ),
          ],
        ),
      );
    } else {
      // Mobile: show vertically
      return RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            _fetchPlans(lang: _currentLocale?.languageCode),
            _loadCurrentSubscription(),
          ]);
        },
        child: ListView.separated(
          padding: EdgeInsets.symmetric(
            horizontal: sw(context, 16),
            vertical: sh(context, 16),
          ),
          itemCount: _plans.length + (currentSection != null ? 1 : 0),
          separatorBuilder: (_, __) => SizedBox(height: sh(context, 16)),
          itemBuilder: (context, index) {
            if (currentSection != null && index == 0) return currentSection;

            final planIndex = index - (currentSection != null ? 1 : 0);
            final plan = _plans[planIndex];
            return _buildPlanCard(plan);
          },
        ),
      );
    }
  }

  // Tách riêng widget plan card để dùng cho cả mobile và tablet
  Widget _buildPlanCard(SubscriptionPlan plan) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorPrimary = const Color(0xFF2563EB);
    final t = Theme.of(context).textTheme;
    final loc = AppLocalizations.of(context);

    final formattedPrice = plan.price < 1000
        ? NumberFormat("#,##0.##", "vi_VN").format(plan.price)
        : NumberFormat("#,##0", "vi_VN").format(plan.price);

    return Container(
      padding: EdgeInsets.all(sw(context, 20)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1E1E1E), const Color(0xFF2C2C2C)]
              : [Colors.white, Colors.white],
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
                "$formattedPriceđ",
                style: t.headlineSmall?.copyWith(
                  color: colorPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: st(context, 22),
                ),
              ),
              Text(
                "${plan.durationInDays} ${loc.translate("days")}",
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
              loc.translate("features"),
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
              onPressed: () => _subscribePlan(plan),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorPrimary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: sh(context, 12)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(sw(context, 10)),
                ),
              ),
              child: Text(
                loc.translate("subscribe"),
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
  }
}
