import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:polygo_mobile/features/shop/widgets/subscription/plan_card.dart';
import 'package:polygo_mobile/features/shop/widgets/subscription/subscription_actions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/utils/responsive.dart';
import '../../../../core/api/api_client.dart';
import '../../../../data/models/api_response.dart';
import '../../../../data/models/subscription/subscription_cancel_request.dart';
import '../../../../data/models/subscription/subscription_current_response.dart';
import '../../../../data/models/subscription/subscription_plan_model.dart';
import '../../../../data/models/subscription/subscription_request.dart';
import '../../../../data/models/subscription/subscription_response.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/subscription_repository.dart';
import '../../../../data/services/apis/auth_service.dart';
import '../../../../data/services/apis/subscription_service.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../main.dart';
import '../../../shared/app_error_state.dart';

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
  late final SubscriptionRepository _repo = SubscriptionRepository(
      SubscriptionService(ApiClient()));
  late final SubscriptionActions _actions = SubscriptionActions(
      repository: _repo);


  @override
  void initState() {
    super.initState();
    _loadCurrentSubscription();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = InheritedLocale
        .of(context)
        .locale;
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
      barrierDismissible: false,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final loc = AppLocalizations.of(context);

        String formatMoney(num amount) {
          final formatter = NumberFormat("#,##0.##", "de_DE");
          return '${formatter.format(amount)} đ';
        }

        Gradient cardBackground = isDark
            ? const LinearGradient(
          colors: [Color(0xFF1E1E1E), Color(0xFF2C2C2C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : const LinearGradient(
          colors: [Colors.white, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        String? errorText;

        return StatefulBuilder(
          builder: (context, setState) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: cardBackground,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.translate("confirm_subscription"),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Hiển thị số dư khả dụng
                  Text(
                    '${loc.translate("available_balance")}: ${formatMoney(balance)}',
                    style: TextStyle(
                      color: isDark ? Colors.grey[300] : Colors.grey[800],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Giá gói
                  Text(
                    '${loc.translate("plan_price")}: ${formatMoney(plan.price)}',
                    style: TextStyle(
                      color: isDark ? Colors.grey[300] : Colors.grey[800],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (errorText != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        errorText!,
                        style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                      ),
                    ),
                  Row(
                    children: [
                      Checkbox(
                        value: autoRenew,
                        onChanged: (v) => setState(() => autoRenew = v ?? true),
                      ),
                      Expanded(
                        child: Text(
                          loc.translate("auto_renew"),
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(loc.translate("cancel")),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          try {
                            await _repo.subscribe(
                              token: token,
                              request: SubscriptionRequest(
                                subscriptionPlanId: plan.id,
                                autoRenew: autoRenew,
                              ),
                            );
                            if (context.mounted) Navigator.pop(context, true);
                          } catch (_) {
                            setState(() {
                              errorText = loc.translate("subscription_failed");
                            });
                          }
                        },
                        child: Text(loc.translate("confirm")),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
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
                Wrap(
                  alignment: WrapAlignment.start,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: sw(context, 8),
                  children: [
                    Text(
                      _currentSubscription!.planName,
                      style: t.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "${_currentSubscription!.daysRemaining} ${loc.translate("days_remaining")}",
                      style: t.bodyMedium?.copyWith(color: Colors.white70),
                    ),
                  ],
                ),

                SizedBox(height: sh(context, 8)),
                Text(
                  "${loc.translate("start_at")}: ${_currentSubscription!.startAt
                      .toLocal().toString().split(' ')[0]}",
                  style: t.bodySmall?.copyWith(color: Colors.white70),
                ),
                Text(
                  "${loc.translate("end_at")}: ${_currentSubscription!.endAt
                      .toLocal().toString().split(' ')[0]}",
                  style: t.bodySmall?.copyWith(color: Colors.white70),
                ),
                SizedBox(height: sh(context, 16)),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          _actions.showCancelDialog(
                            context: context,
                            currentSubscription: _currentSubscription,
                            onSuccess: () async {
                              await _loadCurrentSubscription();
                              await _fetchPlans(
                                  lang: _currentLocale?.languageCode);
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: sh(context, 8),
                            horizontal: sw(context, 12),
                          ),
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
                      flex: 3,
                      child: ElevatedButton(
                        onPressed: () {
                          _actions.showAutoRenewDialog(
                            context: context,
                            currentSubscription: _currentSubscription,
                            onSuccess: () async {
                              await _loadCurrentSubscription();
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: sh(context, 8),
                            horizontal: sw(context, 12),
                          ),
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
        MediaQuery
            .of(context)
            .size
            .width >= 600;

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
          style: Theme
              .of(context)
              .textTheme
              .titleMedium,
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
                  return SubscriptionPlanCard(
                    plan: plan,
                    onSubscribe: _subscribePlan,
                  );
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
            return SubscriptionPlanCard(
              plan: plan,
              onSubscribe: _subscribePlan,
            );
          },
        ),
      );
    }
  }
}