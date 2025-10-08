import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';
import '../../shared/app_header_actions.dart';
import '../widgets/setup_language_learn.dart';
import '../widgets/setup_language_known.dart';
import '../widgets/setup_interests.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  int _currentStep = 0;
  ThemeMode _themeMode = ThemeMode.system;

  List<String> _learningLangs = [];
  List<String> _speakingLangs = [];

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final steps = [
      SetupLanguageLearn(
        onNext: (langs) {
          _learningLangs = langs;
          _nextStep();
        },
      ),
      SetupLanguageKnown(
        onNext: (langs) {
          _speakingLangs = langs;
          _nextStep();
        },
        onBack: _prevStep,
      ),
      SetupInterests(
        onBack: _prevStep,
        learningLangs: _learningLangs,
        speakingLangs: _speakingLangs,
      ),
    ];

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: AppHeaderActions(onThemeToggle: _toggleTheme),
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: steps[_currentStep],
              ),
            ),
          ],
        ),
      ),
    );
  }
}