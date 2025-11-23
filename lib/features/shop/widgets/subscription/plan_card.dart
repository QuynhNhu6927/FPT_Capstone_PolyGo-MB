import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../data/models/subscription/subscription_plan_model.dart';
import '../../../../core/localization/app_localizations.dart';

class SubscriptionPlanCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final void Function(SubscriptionPlan plan) onSubscribe;

  const SubscriptionPlanCard({
    super.key,
    required this.plan,
    required this.onSubscribe,
  });

  @override
  Widget build(BuildContext context) {
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
          // Header: name
          Text(
            plan.name,
            style: t.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: st(context, 20),
              color: isDark ? Colors.white : Colors.black87,
            ),
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
              onPressed: () => onSubscribe(plan),
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
