import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_button.dart';

class WelcomeStep extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const WelcomeStep({
    super.key,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = theme.textTheme;
    final loc = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    final containerWidth = screenWidth < 500
        ? screenWidth * 0.9
        : screenWidth < 800
        ? 450.0
        : 500.0;

    return Center(
      child: Container(
        width: containerWidth,
        padding: EdgeInsets.all(sw(context, 24)),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(sw(context, 16)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x11000000),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(sw(context, 12)),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(sw(context, 12)),
              ),
              child: Icon(
                Icons.travel_explore_rounded,
                size: sw(context, 48),
                color: const Color(0xFF2563EB),
              ),
            ),
            SizedBox(height: sh(context, 20)),

            Text(
              loc.translate("welcome_to") + " PolyGo!",
              textAlign: TextAlign.center,
              style: t.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: st(context, 26),
              ),
            ),
            SizedBox(height: sh(context, 12)),

            Text(
              loc.translate("welcome_description"),
              textAlign: TextAlign.center,
              style: t.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
                fontSize: st(context, 15),
                height: 1.5,
              ),
            ),
            SizedBox(height: sh(context, 36)),

            AppButton(
              text: loc.translate("get_started"),
              size: ButtonSize.lg,
              variant: ButtonVariant.primary,
              onPressed: onNext,
            ),
            SizedBox(height: sh(context, 16)),

            AppButton(
              text: loc.translate("maybe_later"),
              size: ButtonSize.lg,
              variant: ButtonVariant.outline,
              onPressed: onSkip,
            ),
          ],
        ),
      ).animate().fadeIn(duration: 500.ms, curve: Curves.easeInOut),
    );
  }
}
