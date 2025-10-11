import 'package:flutter/material.dart';

class AppDropdown extends StatelessWidget {
  static bool _menuOpen = false;

  final String currentValue;
  final List<String> items;
  final ValueChanged<String>? onSelected;
  final VoidCallback? onTap;
  final double borderRadius;
  final IconData? icon;
  final bool showIcon;   // hiển thị icon button
  final bool showValue;  // hiển thị text currentValue
  final bool showArrow;  // hiển thị mũi tên

  const AppDropdown({
    super.key,
    required this.currentValue,
    required this.items,
    this.onSelected,
    this.onTap,
    this.borderRadius = 8.0,
    this.icon,
    this.showIcon = true,
    this.showValue = true,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = (screenWidth / 400).clamp(1.0, 1.6);

    return Builder(builder: (innerContext) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Material(
          color: theme.colorScheme.surfaceVariant,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(borderRadius),
            onTap: () async {
              if (_menuOpen) return;
              _menuOpen = true;

              final RenderBox button =
              innerContext.findRenderObject() as RenderBox;
              final RenderBox overlay =
              Overlay.of(innerContext).context.findRenderObject() as RenderBox;

              final Offset position =
              button.localToGlobal(Offset.zero, ancestor: overlay);

              final RelativeRect positionRect = RelativeRect.fromRect(
                Rect.fromLTWH(
                  position.dx,
                  position.dy + button.size.height + 4,
                  button.size.width,
                  button.size.height,
                ),
                Offset.zero & overlay.size,
              );

              final selected = await showMenu<String>(
                context: innerContext,
                position: positionRect,
                items: items.map((item) {
                  final bool isSelected = item == currentValue;
                  return PopupMenuItem<String>(
                    value: item,
                    child: Row(
                      children: [
                        if (isSelected)
                          Icon(
                            Icons.check,
                            size: 18 * scale,
                            color: theme.colorScheme.primary,
                          )
                        else
                          SizedBox(width: 18 * scale),
                        SizedBox(width: 8 * scale),
                        Flexible(
                          child: Text(
                            item,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14 * scale,
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface,
                              fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: theme.colorScheme.surface,
              );

              _menuOpen = false;

              if (!innerContext.mounted) return;

              if (selected != null) {
                if (onSelected != null) {
                  onSelected!(selected);
                } else if (onTap != null) {
                  onTap!();
                }
              }
            },
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 12 * scale,
                vertical: 8 * scale,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showIcon)
                    Icon(
                      icon ?? Icons.arrow_drop_down,
                      size: 20 * scale,
                      color: theme.colorScheme.onSurface,
                    ),
                  if (showIcon && (showValue || showArrow))
                    SizedBox(width: 6 * scale),
                  if (showValue)
                    Flexible(
                      child: Text(
                        currentValue,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14 * scale,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  if (showArrow)
                    Icon(
                      Icons.arrow_drop_down,
                      size: 20 * scale,
                      color: theme.colorScheme.onSurface,
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
