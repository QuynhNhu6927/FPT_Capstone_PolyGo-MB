import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../data/models/languages/language_model.dart';
import '../../../../data/repositories/language_repository.dart';
import '../../../../data/services/apis/language_service.dart';
import '../../../shared/app_error_state.dart';

class WordSetFilter extends StatefulWidget {
  const WordSetFilter({super.key});

  @override
  State<WordSetFilter> createState() => _WordSetFilterState();
}

class _WordSetFilterState extends State<WordSetFilter> {
  late final LanguageRepository _languageRepo;
  bool _loading = true;
  String? _error;

  List<LanguageModel> _languages = [];
  final Set<String> _selectedLanguages = {};
  String? _selectedDifficulty;
  String? _selectedCategory;

  final List<String> _difficulties = ['Easy', 'Medium', 'Hard'];
  final List<String> _categories = ['Food', 'Travel', 'Business', 'Tech', 'Culture', 'Daily', 'Education', 'Health'];

  @override
  void initState() {
    super.initState();
    _languageRepo = LanguageRepository(LanguageService(ApiClient()));
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

      final langs = await _languageRepo.getAllLanguages(token, lang: 'vi');
      setState(() {
        _languages = langs;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _toggleLanguage(String id) {
    setState(() {
      if (_selectedLanguages.contains(id)) {
        _selectedLanguages.remove(id);
      } else {
        _selectedLanguages.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.4),
      body: SafeArea(
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(loc.translate("filter"),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                    ? AppErrorState(onRetry: _loadData)
                    : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Ngôn ngữ", style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _languages
                            .map((lang) => FilterChip(
                          label: Text(lang.name),
                          selected: _selectedLanguages.contains(lang.id),
                          onSelected: (_) => _toggleLanguage(lang.id),
                        ))
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const Text("Độ khó", style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _difficulties
                            .map((diff) => ChoiceChip(
                          label: Text(diff),
                          selected: _selectedDifficulty == diff,
                          onSelected: (_) =>
                              setState(() => _selectedDifficulty = diff),
                        ))
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const Text("Danh mục", style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _categories
                            .map((cat) => ChoiceChip(
                          label: Text(cat),
                          selected: _selectedCategory == cat,
                          onSelected: (_) =>
                              setState(() => _selectedCategory = cat),
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
                  label: Text(loc.translate("apply_filters")),
                  onPressed: () {
                    Navigator.pop(context, {
                      'languages': _selectedLanguages
                          .map((id) => _languages.firstWhere((x) => x.id == id))
                          .map((lang) => {'id': lang.id, 'name': lang.name})
                          .toList(),
                      'difficulty': _selectedDifficulty,
                      'category': _selectedCategory,
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
