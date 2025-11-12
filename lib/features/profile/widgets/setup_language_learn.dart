import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/api/api_client.dart';
import '../../../data/models/languages/language_model.dart';
import '../../../data/repositories/language_repository.dart';
import '../../../data/services/apis/language_service.dart';
import '../../../main.dart';
import '../../shared/app_error_state.dart';

class SetupLanguageLearn extends StatefulWidget {
  final void Function(List<String> selected) onNext;
  final List<String> initialSelected;

  const SetupLanguageLearn({
    super.key,
    required this.onNext,
    this.initialSelected = const [],
  });

  @override
  State<SetupLanguageLearn> createState() => _SetupLanguageLearnState();
}

class _SetupLanguageLearnState extends State<SetupLanguageLearn> {
  late List<String> _selectedLangs;
  List<LanguageModel> _languages = [];
  bool _isLoading = true;
  String? _error;

  late final LanguageRepository _repo;
  Locale? _currentLocale;

  @override
  void initState() {
    super.initState();
    _selectedLangs = List.from(widget.initialSelected);
    _repo = LanguageRepository(LanguageService(ApiClient()));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = InheritedLocale.of(context).locale;
    if (_currentLocale == null ||
        _currentLocale!.languageCode != locale.languageCode) {
      _currentLocale = locale;
      _fetchLanguages(lang: locale.languageCode);
    }
  }

  Future<void> _fetchLanguages({String? lang}) async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final langs = await _repo.getAllLanguages(token, lang: lang ?? 'vi');
      setState(() {
        _languages = langs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load languages: $e';
        _isLoading = false;
      });
    }
  }

  void _toggle(String code) {
    setState(() {
      if (_selectedLangs.contains(code)) {
        _selectedLangs.remove(code);
      } else if (_selectedLangs.length < 3) {
        _selectedLangs.add(code);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = theme.textTheme;
    final loc = AppLocalizations.of(context);

    final borderColorDefault = theme.dividerColor;
    final borderColorSelected = theme.colorScheme.primary;
    final textColorDefault = theme.textTheme.bodyMedium!.color;
    final textColorSelected = theme.colorScheme.primary;
    final backgroundDefault = theme.cardColor;
    final backgroundSelected = theme.colorScheme.primary.withOpacity(0.1);

    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = (screenWidth ~/ 220).clamp(2, 6);

    return SingleChildScrollView(
      padding: EdgeInsets.all(sw(context, 24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              padding: EdgeInsets.all(sw(context, 12)),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(sw(context, 12)),
                boxShadow: [
                  BoxShadow(
                    color: theme.brightness == Brightness.dark
                        ? Colors.black.withOpacity(0.4)
                        : Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.language,
                size: sw(context, 36),
                color: theme.colorScheme.primary,
              ),
            ),
          ),

          SizedBox(height: sh(context, 20)),

          Text(
            loc.translate("step_1_title"),
            textAlign: TextAlign.center,
            style: t.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: st(context, 24),
            ),
          ),
          SizedBox(height: sh(context, 6)),
          Text(
            loc.translate("choose_up_to_3_langs"),
            textAlign: TextAlign.center,
            style: t.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: st(context, 14),
            ),
          ),
          SizedBox(height: sh(context, 20)),

          Container(
            padding: EdgeInsets.all(sw(context, 16)),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(sw(context, 16)),
              boxShadow: [
                BoxShadow(
                  color: theme.brightness == Brightness.dark
                      ? Colors.grey.withOpacity(0.1)
                      : Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? AppErrorState(onRetry: () => _fetchLanguages())
                : GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _languages.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 3.8,
              ),
              itemBuilder: (context, index) {
                final lang = _languages[index];
                final selected = _selectedLangs.contains(lang.id);
                return GestureDetector(
                  onTap: () => _toggle(lang.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected
                            ? borderColorSelected
                            : borderColorDefault,
                        width: 1,
                      ),
                      color: selected
                          ? backgroundSelected
                          : backgroundDefault,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (lang.iconUrl.isNotEmpty)
                          Image.network(
                            lang.iconUrl,
                            width: 24,
                            height: 24,
                            errorBuilder: (_, __, ___) =>
                            const SizedBox.shrink(),
                          ),
                        if (lang.iconUrl.isNotEmpty)
                          const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            lang.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: t.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: selected
                                  ? textColorSelected
                                  : textColorDefault,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

          ),

          SizedBox(height: sh(context, 32)),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AppButton(
                text: loc.translate("skip"),
                variant: ButtonVariant.outline,
                onPressed: () => widget.onNext([]),
              ),
              const SizedBox(width: 8),
              AppButton(
                text: loc.translate("next"),
                onPressed: _selectedLangs.isEmpty
                    ? null
                    : () => widget.onNext(_selectedLangs),
                disabled: _selectedLangs.isEmpty,
              ),
            ],
          ),
        ],
      ).animate().fadeIn(duration: 400.ms),
    );
  }
}
