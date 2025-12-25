import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';
import '../../core/widgets/app_dropdown.dart';
import '../../main.dart';

class AppHeaderActions extends StatelessWidget {
  final VoidCallback onThemeToggle;

  const AppHeaderActions({super.key, required this.onThemeToggle});

  @override
  Widget build(BuildContext context) {
    final inherited = InheritedLocale.of(context);
    final lang = inherited.locale.languageCode;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final loc = AppLocalizations.of(context);
    final inheritedTheme = InheritedThemeMode.of(context);

    /// ===== LANGUAGE CONFIG =====
    final Map<String, String> langMap = {
      'English': 'en',
      'Tiếng Việt': 'vi',
      '日本語': 'ja',
    };

    final languageItems = langMap.keys.toList();

    final currentLangLabel = langMap.entries
        .firstWhere(
          (e) => e.value == lang,
          orElse: () => const MapEntry('English', 'en'),
        )
        .key;

    /// ===== THEME CONFIG =====
    final themeItems = [
      loc.translate('light_mode'),
      loc.translate('dark_mode'),
    ];

    final currentThemeLabel = isDark
        ? loc.translate('dark_mode')
        : loc.translate('light_mode');

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        /// ===== LANGUAGE DROPDOWN =====
        AppDropdown(
          icon: Icons.language,
          currentValue: currentLangLabel,
          items: languageItems,
          onSelected: (value) {
            final newLang = langMap[value];
            if (newLang != null && newLang != lang) {
              inherited.setLocale(Locale(newLang));
            }
          },
        ),

        const SizedBox(width: 12),

        /// ===== THEME DROPDOWN =====
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
