import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../data/models/subscription/usage_item.dart';
import '../../../../data/repositories/subscription_repository.dart';
import '../../../../data/services/apis/subscription_service.dart';
import '../../../../core/api/api_client.dart';
import '../../../../routes/app_routes.dart';

class FreeUserLimitCard extends StatefulWidget {
  const FreeUserLimitCard({super.key});

  @override
  State<FreeUserLimitCard> createState() => _FreeUserLimitCardState();
}

class _FreeUserLimitCardState extends State<FreeUserLimitCard> {
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
      final repo = SubscriptionRepository(SubscriptionService(ApiClient()));
      final res = await repo.getUsage(token: token);
      if (res.data != null) {
        setState(() {
          usageItems = res.data!.items;
        });
      }
    } catch (e) {
      debugPrint("Error loading usage: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorPrimary = const Color(0xFF2563EB);
    final colorRed = Colors.red;
    final t = Theme.of(context).textTheme;
    final loc = AppLocalizations.of(context);

    final screenWidth = MediaQuery.of(context).size.width;
    final containerWidth = screenWidth < 500
        ? screenWidth * 0.9
        : screenWidth < 800
        ? 450.0
        : 500.0;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          top: sh(context, 40),
          bottom: MediaQuery.of(context).viewInsets.bottom + sh(context, 40),
          left: sw(context, 16),
          right: sw(context, 16),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: containerWidth),
          child: Container(
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
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  loc.translate("limited_free_title"),
                  style: t.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: st(context, 20),
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: sh(context, 8)),
                Text(
                  loc.translate("limited_free_des"),
                  style: t.bodyMedium?.copyWith(
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                    fontSize: st(context, 14),
                  ),
                ),
                SizedBox(height: sh(context, 16)),
                // Features title
                Text(
                  loc.translate("limited_free_feature"),
                  style: t.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: st(context, 16),
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: sh(context, 8)),
                // Dynamic usage items
                ...usageItems.map((item) => Padding(
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
                          "${loc.translate(item.featureName.toLowerCase())}: ${item.limitValue} / ${loc.translate(item.limitType.toLowerCase())}",
                          style: t.bodyMedium?.copyWith(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: st(context, 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
                // Restricted features
                Padding(
                  padding: EdgeInsets.symmetric(vertical: sh(context, 4)),
                  child: Row(
                    children: [
                      Icon(Icons.close_rounded, color: colorRed, size: sw(context, 18)),
                      SizedBox(width: sw(context, 8)),
                      Expanded(
                        child: Text(
                          loc.translate("send_image"),
                          style: t.bodyMedium?.copyWith(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: st(context, 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: sh(context, 4)),
                  child: Row(
                    children: [
                      Icon(Icons.close_rounded, color: colorRed, size: sw(context, 18)),
                      SizedBox(width: sw(context, 8)),
                      Expanded(
                        child: Text(
                          loc.translate("send_voice_audio"),
                          style: t.bodyMedium?.copyWith(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: st(context, 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: sh(context, 20)),
                // Subscribe Plus button
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, AppRoutes.shop);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorPrimary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: sh(context, 12),
                        horizontal: sw(context, 24),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(sw(context, 12)),
                      ),
                      textStyle: TextStyle(
                        fontSize: st(context, 16),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: Text("Đăng ký Plus ngay"),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 350.ms),
        ),
      ),
    );
  }
}
