import 'package:flutter/material.dart';
import '../../../routes/app_routes.dart';
import '../../shared/app_header_actions.dart';
import '../widgets/setup_language_learn.dart';
import '../widgets/setup_language_known.dart';
import '../widgets/setup_interests.dart';
import '../widgets/welcome.dart';

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
  List<String> _selectedInterests = [];

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void _nextStep() {
    if (_currentStep < 3) {
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
    final theme = Theme.of(context);

    final steps = [
      WelcomeStep(
        onNext: _nextStep,
        onSkip: () {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        },
      ),

      SetupLanguageLearn(
        initialSelected: _learningLangs,
        onNext: (langs) {
          _learningLangs = langs;
          _nextStep();
        },
      ),

      SetupLanguageKnown(
        initialSelected: _speakingLangs,
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
        initialSelected: _selectedInterests,
        onFinish: (selected) {
          _selectedInterests = selected;
        },
      ),
    ];

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
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