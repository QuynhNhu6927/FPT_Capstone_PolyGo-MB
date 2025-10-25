import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/responsive.dart';
import '../../../core/widgets/app_button.dart';

class EventDetail extends StatelessWidget {
  final Map<String, dynamic> event;

  const EventDetail({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final t = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;

    final dividerColor = isDark ? Colors.grey[700] : Colors.grey[300];
    final textColor = isDark ? Colors.white70 : Colors.black87;
    final secondaryText = isDark ? Colors.grey[400] : Colors.grey[600];

    return Dialog(
      elevation: 12,
      backgroundColor: isDark
          ? const Color(0xFF1E1E1E)
          : theme.cardColor, // darker background for dark mode
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(sw(context, 16)),
      ),
      shadowColor: Colors.black.withOpacity(0.3),
      child: Container(
        padding: EdgeInsets.all(sw(context, 20)),
        width: sw(context, 500),
        constraints: BoxConstraints(maxHeight: sh(context, 650)),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "${event['title'] ?? ''}",
                      style: t.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: st(context, 18),
                        color: textColor,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close,
                        size: 24, color: secondaryText ?? Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Divider(color: dividerColor, thickness: 1),

              const SizedBox(height: 16),

              // --- Host info ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: sw(context, 28),
                    backgroundImage: NetworkImage(
                      event['hostAvatar'] ?? 'https://i.pravatar.cc/100?img=3',
                    ),
                  ),
                  SizedBox(width: sw(context, 12)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event['hostName'] ?? 'John Doe',
                        style: t.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: st(context, 15),
                          color: textColor,
                        ),
                      ),
                      Text(
                        loc.translate('host'),
                        style: t.bodySmall?.copyWith(
                          color: secondaryText,
                          fontSize: st(context, 13),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // --- Event Info ---
              Text(
                event['description'] ?? loc.translate('no_description'),
                style: t.bodyMedium?.copyWith(
                  fontSize: st(context, 14),
                  height: 1.4,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 16),

              _buildInfoRow(
                context,
                Icons.language,
                loc.translate('language'),
                event['language'] ?? 'English',
                textColor,
                secondaryText,
              ),
              _buildInfoRow(
                context,
                Icons.favorite_border,
                loc.translate('interest'),
                event['interest'] ?? 'Technology',
                textColor,
                secondaryText,
              ),
              _buildInfoRow(
                context,
                Icons.people_alt_outlined,
                loc.translate('participants'),
                "${event['joined'] ?? 45}/${event['max'] ?? 100}",
                textColor,
                secondaryText,
              ),
              _buildInfoRow(
                context,
                Icons.access_time,
                loc.translate('time'),
                event['startTime'] ?? '25 Oct 2025, 09:00 AM',
                textColor,
                secondaryText,
              ),
              _buildInfoRow(
                context,
                Icons.timer_outlined,
                loc.translate('duration'),
                event['duration'] ?? '3 hours',
                textColor,
                secondaryText,
              ),

              const SizedBox(height: 16),
              Divider(color: dividerColor, thickness: 1),

              const SizedBox(height: 16),

              // --- Buttons ---
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton(
                    text: loc.translate('share'),
                    variant: ButtonVariant.outline,
                    size: ButtonSize.md,
                    icon: const Icon(Icons.share_outlined, size: 18),
                    onPressed: () {},
                  ),
                  SizedBox(width: sw(context, 12)),
                  AppButton(
                    text: loc.translate('join'),
                    variant: ButtonVariant.primary,
                    size: ButtonSize.md,
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 250.ms)
        .slide(begin: const Offset(0, 0.08), duration: 300.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildInfoRow(
      BuildContext context,
      IconData icon,
      String label,
      String value,
      Color textColor,
      Color? secondaryText,
      ) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: secondaryText),
          const SizedBox(width: 8),
          Text(
            "$label: ",
            style: t.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: secondaryText,
              fontSize: st(context, 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: t.bodyMedium?.copyWith(
                color: textColor,
                fontSize: st(context, 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
