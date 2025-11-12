import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';

class EventFilterBar extends StatelessWidget {
  final List<String> selectedFilters;
  final VoidCallback onOpenFilter;
  final void Function(String tag) onRemoveFilter;

  const EventFilterBar({
    super.key,
    required this.selectedFilters,
    required this.onOpenFilter,
    required this.onRemoveFilter,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);

    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: onOpenFilter,
          icon: const Icon(Icons.filter_alt_outlined),
          label: Text(loc.translate("filter")),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primaryContainer,
            foregroundColor: theme.colorScheme.onPrimaryContainer,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            elevation: 1,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: selectedFilters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final tag = selectedFilters[index];
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: theme.colorScheme.primary.withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(tag,
                          style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => onRemoveFilter(tag),
                        child: const Icon(Icons.close_rounded,
                            size: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
