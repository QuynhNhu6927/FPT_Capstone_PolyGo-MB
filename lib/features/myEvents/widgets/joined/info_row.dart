import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../../../core/utils/responsive.dart';

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isClickable;
  final VoidCallback? onTap;

  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.isClickable = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.brightness == Brightness.dark
        ? Colors.white70
        : Colors.black87;
    final secondaryText = theme.brightness == Brightness.dark
        ? Colors.grey[400]
        : Colors.black;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: secondaryText),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                text: "$label: ",
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: secondaryText,
                  fontSize: 14,
                ),
                children: [
                  TextSpan(
                    text: value,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isClickable
                          ? theme.colorScheme.primary
                          : textColor,
                      fontSize: 14,
                      decoration: isClickable
                          ? TextDecoration.underline
                          : TextDecoration.none,
                    ),
                    recognizer: isClickable && onTap != null
                        ? (TapGestureRecognizer()..onTap = onTap)
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
