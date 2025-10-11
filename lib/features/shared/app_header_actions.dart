  import 'package:flutter/material.dart';
  import '../../../core/localization/app_localizations.dart';
  import '../../core/widgets/app_dropdown.dart';
  import '../../main.dart';

  class AppHeaderActions extends StatelessWidget {
    final VoidCallback onThemeToggle;

    const AppHeaderActions({
      super.key,
      required this.onThemeToggle,
    });

    @override
    Widget build(BuildContext context) {
      final inherited = InheritedLocale.of(context);
      final lang = inherited.locale.languageCode;
      final theme = Theme.of(context);
      final isDark = theme.brightness == Brightness.dark;
      final loc = AppLocalizations.of(context);
      final inheritedTheme = InheritedThemeMode.of(context);

      final languageItems = ['English', 'Tiếng Việt'];
      final currentLangLabel = lang == 'vi' ? 'Tiếng Việt' : 'English';

      final themeItems = [
        loc.translate('light_mode'),
        loc.translate('dark_mode')
      ];
      final currentThemeLabel = isDark
          ? loc.translate('dark_mode')
          : loc.translate('light_mode');

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppDropdown(
            icon: Icons.language,
            currentValue: currentLangLabel,
            items: languageItems,
            onSelected: (value) {
              final newLang = (value == 'Tiếng Việt') ? 'vi' : 'en';
              if (newLang != lang) {
                inherited.setLocale(Locale(newLang));
              }
            },
          ),
          const SizedBox(width: 12),

          AppDropdown(
            icon: isDark ? Icons.nightlight_round : Icons.wb_sunny_outlined,
            currentValue: currentThemeLabel,
            items: themeItems,
            onSelected: (value) {
              if (value == loc.translate('dark_mode')) {
                inheritedTheme.setThemeMode(ThemeMode.dark);
              } else {
                inheritedTheme.setThemeMode(ThemeMode.light);
              }
            },
          ),
        ],
      );
    }
  }
