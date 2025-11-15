import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

enum ButtonVariant { primary, secondary, outline, ghost, destructive, link }
enum ButtonSize { sm, md, lg, iconSm, icon, iconLg }

class AppButton extends StatelessWidget {
  final String? text;
  final Widget? icon;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool disabled;

  const AppButton({
    super.key,
    this.text,
    this.icon,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.md,
    this.disabled = false, Color? color,
  });

  double get _height {
    switch (size) {
      case ButtonSize.sm:
        return 36;
      case ButtonSize.lg:
      case ButtonSize.iconLg:
        return 52;
      case ButtonSize.iconSm:
        return 36;
      default:
        return 44; // md & icon
    }
  }

  double get _fontSize {
    switch (size) {
      case ButtonSize.sm:
        return 14;
      case ButtonSize.lg:
        return 16;
      default:
        return 15;
    }
  }

  double get _horizontalPadding {
    switch (size) {
      case ButtonSize.sm:
        return 12;
      case ButtonSize.lg:
        return 20;
      default:
        return 16;
    }
  }

  Color _backgroundColor(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    switch (variant) {
      case ButtonVariant.primary:
        return c.primary;
      case ButtonVariant.secondary:
        return c.secondaryContainer;
      case ButtonVariant.destructive:
        return Colors.red.shade600;
      case ButtonVariant.outline:
      case ButtonVariant.ghost:
      case ButtonVariant.link:
        return Colors.transparent;
    }
  }

  Color _textColor(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final c = theme.colorScheme;

    switch (variant) {
      case ButtonVariant.primary:
        return isDark ? Colors.white : c.onPrimary;
      case ButtonVariant.secondary:
        return isDark ? Colors.white : c.onSecondaryContainer;
      case ButtonVariant.destructive:
        return Colors.white;
      case ButtonVariant.outline:
      case ButtonVariant.ghost:
      case ButtonVariant.link:
        return isDark ? Colors.white : c.primary;
    }
  }

  BoxBorder? _border(BuildContext context) {
    if (variant == ButtonVariant.outline) {
      return Border.all(
        color: Theme.of(context).colorScheme.outline.withOpacity(0.4),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final bool isIconOnly = text == null && icon != null;

    return GestureDetector(
      onTap: disabled ? null : onPressed,
      child: AnimatedContainer(
        duration: 200.ms,
        height: _height,
        padding: isIconOnly
            ? EdgeInsets.all(10)
            : EdgeInsets.symmetric(horizontal: _horizontalPadding),
        decoration: BoxDecoration(
          color: disabled
              ? Colors.grey.withOpacity(0.3)
              : _backgroundColor(context),
          border: _border(context),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null)
              Padding(
                padding: EdgeInsets.only(
                    right: (text != null && !isIconOnly) ? 8 : 0),
                child: IconTheme(
                  data: IconThemeData(
                    size: _fontSize + 3,
                    color: _textColor(context),
                  ),
                  child: icon!,
                ),
              ),
            if (text != null)
              Text(
                text!,
                style: TextStyle(
                  fontSize: _fontSize,
                  fontWeight: FontWeight.w500,
                  color: _textColor(context),
                ),
              ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 250.ms)
        .scale(begin: const Offset(0.95, 0.95), curve: Curves.easeOut);
  }
}
