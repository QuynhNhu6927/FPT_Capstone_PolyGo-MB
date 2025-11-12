import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/localization/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:device_preview/device_preview.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/size_config.dart';
import 'core/utils/jwt_helper.dart';
import 'data/services/signalr/chat_signalr_service.dart';
import 'data/services/signalr/user_presence.dart';
import 'routes/app_routes.dart';

void main() {
  runApp(DevicePreview(enabled: false, builder: (context) => const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en');
  ThemeMode _themeMode = ThemeMode.system;
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', locale.languageCode);
    setState(() => _locale = locale);
  }

  Future<void> _setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', mode.name);
    setState(() => _themeMode = mode);
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // Language
    final langCode = prefs.getString('locale') ?? 'en';
    _locale = Locale(langCode);

    // Theme mode
    final themeString = prefs.getString('themeMode') ?? 'system';
    _themeMode = ThemeMode.values.firstWhere(
      (e) => e.name == themeString,
      orElse: () => ThemeMode.system,
    );

    // token
    _token = prefs.getString('token');

    if (_token != null && JwtHelper.isExpired(_token!)) {
      await prefs.remove('token');
      _token = null;
    }

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    final initialRoute = _token != null ? AppRoutes.home : AppRoutes.login;

    return HubManager(
      child: ChatHubManager(
        child: MaterialApp(
          title: 'PolyGo App',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: _themeMode,
          initialRoute: initialRoute,
          onGenerateRoute: AppRoutes.generateRoute,
          locale: _locale,
          supportedLocales: const [Locale('en'), Locale('vi')],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) {
            return InheritedLocale(
              locale: _locale,
              setLocale: _setLocale,
              child: InheritedThemeMode(
                themeMode: _themeMode,
                setThemeMode: _setThemeMode,
                child: child!,
              ),
            );
          },
        ),
      ),
    );
  }
}

class InheritedLocale extends InheritedWidget {
  final Locale locale;
  final void Function(Locale) setLocale;

  const InheritedLocale({
    super.key,
    required super.child,
    required this.locale,
    required this.setLocale,
  });

  static InheritedLocale of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<InheritedLocale>()!;
  }

  @override
  bool updateShouldNotify(InheritedLocale oldWidget) =>
      locale != oldWidget.locale;
}

class InheritedThemeMode extends InheritedWidget {
  final ThemeMode themeMode;
  final void Function(ThemeMode) setThemeMode;

  const InheritedThemeMode({
    super.key,
    required super.child,
    required this.themeMode,
    required this.setThemeMode,
  });

  static InheritedThemeMode of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<InheritedThemeMode>()!;
  }

  @override
  bool updateShouldNotify(InheritedThemeMode oldWidget) =>
      themeMode != oldWidget.themeMode;
}
