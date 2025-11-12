import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../data/models/languages/language_model.dart';
import '../../../../data/models/interests/interest_model.dart';
import '../../../../data/repositories/language_repository.dart';
import '../../../../data/repositories/interest_repository.dart';
import '../../../../data/services/apis/language_service.dart';
import '../../../../data/services/apis/interest_service.dart';
import '../../../shared/app_error_state.dart';

class FilterPopUp extends StatefulWidget {
  const FilterPopUp({super.key});

  @override
  State<FilterPopUp> createState() => _FilterPopUpState();
}

class _FilterPopUpState extends State<FilterPopUp> {
  late final LanguageRepository _languageRepo;
  late final InterestRepository _interestRepo;

  bool _loading = true;
  String? _error;

  List<LanguageModel> _languages = [];
  List<InterestModel> _interests = [];

  final Set<String> _selectedLearn = {};
  final Set<String> _selectedKnown = {};
  final Set<String> _selectedInterests = {};

  @override
  void initState() {
    super.initState();
    _languageRepo = LanguageRepository(LanguageService(ApiClient()));
    _interestRepo = InterestRepository(InterestService(ApiClient()));
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      if (token.isEmpty) throw Exception("Missing token");

      final langsFuture = _languageRepo.getAllLanguages(token, lang: 'vi');
      final interestsFuture = _interestRepo.getAllInterests(token, lang: 'vi');

      final results = await Future.wait([langsFuture, interestsFuture]);
      final langs = results[0] as List<LanguageModel>;
      final interests = results[1] as List<InterestModel>;

      setState(() {
        _languages = langs;
        _interests = interests;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _toggle(Set<String> target, String id) {
    setState(() {
      if (target.contains(id)) {
        target.remove(id);
      } else {
        target.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.4),
      body: SafeArea(
        child: Container(
          color: theme.scaffoldBackgroundColor,
          width: double.infinity,
          height: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'Bộ lọc',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              const Divider(thickness: 1),

              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                    ? AppErrorState(onRetry: _loadData)
                    : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ngôn ngữ muốn học',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _languages
                            .map((lang) => FilterChip(
                          label: Text(lang.name),
                          selected: _selectedLearn.contains(lang.id),
                          onSelected: (_) =>
                              _toggle(_selectedLearn, lang.id),
                        ))
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      const Divider(thickness: 1),

                      const Text(
                        'Ngôn ngữ đã biết',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _languages
                            .map((lang) => FilterChip(
                          label: Text(lang.name),
                          selected: _selectedKnown.contains(lang.id),
                          onSelected: (_) =>
                              _toggle(_selectedKnown, lang.id),
                        ))
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      const Divider(thickness: 1),

                      const Text(
                        'Sở thích',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _interests
                            .map((interest) => FilterChip(
                          label: Text(interest.name),
                          selected: _selectedInterests
                              .contains(interest.id),
                          onSelected: (_) => _toggle(
                              _selectedInterests, interest.id),
                        ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Áp dụng bộ lọc'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context, {
                      'learn': _selectedLearn
                          .map((id) {
                        final lang = _languages.firstWhere((x) => x.id == id);
                        return {'id': lang.id, 'name': lang.name};
                      }).toList(),
                      'known': _selectedKnown
                          .map((id) {
                        final lang = _languages.firstWhere((x) => x.id == id);
                        return {'id': lang.id, 'name': lang.name};
                      }).toList(),
                      'interests': _selectedInterests
                          .map((id) {
                        final interest = _interests.firstWhere((x) => x.id == id);
                        return {'id': interest.id, 'name': interest.name};
                      }).toList(),
                    });

                  },

                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
