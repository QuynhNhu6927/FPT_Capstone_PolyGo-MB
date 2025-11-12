import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/api/api_client.dart';
import '../../../data/models/user/update_profile_request.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/services/apis/user_service.dart';
import '../widgets/update_learning_language.dart';
import '../widgets/update_speaking_language.dart';
import '../widgets/update_interests.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  int _currentStep = 0;
  List<String> _selectedLearning = [];
  List<String> _selectedSpeaking = [];
  List<String> _selectedInterests = [];

  List<String> _initialLearning = [];
  List<String> _initialSpeaking = [];
  List<String> _initialInterests = [];

  late final UserRepository _userRepo;

  @override
  void initState() {
    super.initState();
    _userRepo = UserRepository(UserService(ApiClient()));
    _loadInitialValues();
  }

  Future<void> _loadInitialValues() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    _selectedLearning = List.from(_initialLearning);
    _selectedSpeaking = List.from(_initialSpeaking);
    _selectedInterests = List.from(_initialInterests);

    setState(() {});
  }

  void _onNextLearning(List<String> selected) {
    _selectedLearning = selected;
    setState(() => _currentStep = 1);
  }

  void _onNextSpeaking(List<String> selected) {
    _selectedSpeaking = selected;
    setState(() => _currentStep = 2);
  }

  Future<void> _onFinishInterests(List<String> selected) async {
    _selectedInterests = selected;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final bool hasChange = _selectedLearning.toSet() != _initialLearning.toSet() ||
        _selectedSpeaking.toSet() != _initialSpeaking.toSet() ||
        _selectedInterests.toSet() != _initialInterests.toSet();

    if (!hasChange) {
      Navigator.of(context).pop(false);
      return;
    }

    final req = UpdateProfileRequest(
      learningLanguageIds: _selectedLearning,
      speakingLanguageIds: _selectedSpeaking,
      interestIds: _selectedInterests,
    );

    try {
      await _userRepo.updateProfile(token, req);

      _initialLearning = List.from(_selectedLearning);
      _initialSpeaking = List.from(_selectedSpeaking);
      _initialInterests = List.from(_selectedInterests);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );

        Navigator.of(context).pop(true);
      }
    } catch (e) {
      // show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update profile failed: $e')),
        );
      }
    }
  }

  void _onBack() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final steps = [
      UpdateLearningLanguage(
        initialSelected: _selectedLearning,
        onNext: _onNextLearning,
        onBack: _onBack,
      ),
      UpdateSpeakingLanguage(
        initialSelected: _selectedSpeaking,
        onNext: _onNextSpeaking,
        onBack: _onBack,
      ),
      UpdateInterests(
        initialSelected: _selectedInterests,
        onFinish: _onFinishInterests,
        onBack: _onBack,
      ),
    ];

    return Scaffold(
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
