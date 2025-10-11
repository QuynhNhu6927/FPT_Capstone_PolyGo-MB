import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class AppLocalizations {
  final Locale locale;
  late Map<String, String> _localizedStrings;

  AppLocalizations(this.locale);

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  Future<bool> load() async {
    // print('🔵 Loading localization for: ${locale.languageCode}');

    final files = [
      'auth.json',
      'profile.json',
      'shared.json'
    ];

    _localizedStrings = {};

    for (var file in files) {
      final String jsonString =
      await rootBundle.loadString('lib/core/localization/${locale.languageCode}/$file');
      final Map<String, dynamic> jsonMap = json.decode(jsonString);

      // Merge vào _localizedStrings
      _localizedStrings.addAll(jsonMap.map((key, value) => MapEntry(key, value.toString())));
    }

    return true;
  }

  String translate(String key) => _localizedStrings[key] ?? key;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'vi'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
