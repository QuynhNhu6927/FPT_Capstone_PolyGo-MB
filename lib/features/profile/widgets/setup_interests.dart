import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/api/api_client.dart';
import '../../../data/models/interests/interest_model.dart';
import '../../../data/models/profile/profile_setup_request.dart';
import '../../../data/repositories/interest_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/services/interest_service.dart';
import '../../../data/services/user_service.dart';
import '../../../main.dart';
import '../../../routes/app_routes.dart';

class SetupInterests extends StatefulWidget {
  final VoidCallback onBack;
  final List<String> learningLangs;
  final List<String> speakingLangs;

  const SetupInterests({
    super.key,
    required this.onBack,
    required this.learningLangs,
    required this.speakingLangs,
  });

  @override
  State<SetupInterests> createState() => _SetupInterestsState();
}

class _SetupInterestsState extends State<SetupInterests> {
  final List<String> _selected = [];
  List<InterestModel> _interests = [];
  bool _isLoading = true;
  String? _error;

  late final InterestRepository _repo;
  Locale? _currentLocale;

  @override
  void initState() {
    super.initState();
    _repo = InterestRepository(InterestService(ApiClient()));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = InheritedLocale.of(context).locale;
    if (_currentLocale == null || _currentLocale!.languageCode != locale.languageCode) {
      _currentLocale = locale;
      _fetchInterests(lang: locale.languageCode);
    }
  }

  Future<void> _fetchInterests({String? lang}) async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final data = await _repo.getAllInterests(token, lang: lang ?? 'vi');

      setState(() {
        _interests = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load interests: $e';
        _isLoading = false;
      });
    }
  }

  void _toggle(String id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else if (_selected.length < 5) {
        _selected.add(id);
      }
    });
  }

  Future<void> _handleProfileSetup({
    required List<String> interestIds,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final req = ProfileSetupRequest(
        learningLanguageIds: widget.learningLangs,
        speakingLanguageIds: widget.speakingLangs,
        interestIds: interestIds,
      );

      final userRepo = UserRepository(UserService(ApiClient()));
      await userRepo.profileSetup(token, req);

      final isAllEmpty = req.learningLanguageIds.isEmpty &&
          req.speakingLanguageIds.isEmpty &&
          req.interestIds.isEmpty;

      if (!isAllEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(AppLocalizations.of(context).translate("profile_setup_success")),
          ),
        );
      }

      Navigator.pushReplacementNamed(context, AppRoutes.userInfo);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(AppLocalizations.of(context).translate("profile_setup_failed")),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final theme = Theme.of(context);

    final borderColorDefault = theme.dividerColor;
    final borderColorSelected = theme.colorScheme.primary;
    final textColorDefault = theme.textTheme.bodyMedium!.color;
    final textColorSelected = theme.colorScheme.primary;
    final backgroundDefault = theme.cardColor;
    final backgroundSelected = theme.colorScheme.primary.withOpacity(0.1);

    return SingleChildScrollView(
      padding: EdgeInsets.all(sw(context, 24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 🔹 Icon đầu
          Center(
            child: Container(
              padding: EdgeInsets.all(sw(context, 12)),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(sw(context, 12)),
                boxShadow: [
                  BoxShadow(
                    color: theme.brightness == Brightness.dark
                        ? Colors.black.withOpacity(0.5)
                        : Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.star, // icon đại diện sở thích
                size: sw(context, 36),
                color: theme.colorScheme.primary,
              ),
            ),
          ),

          SizedBox(height: sh(context, 20)),

          // Title + Subtitle
          Text(
            loc.translate("step_3_title"),
            textAlign: TextAlign.center,
            style: t.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: st(context, 24),
            ),
          ),
          SizedBox(height: sh(context, 6)),
          Text(
            loc.translate("choose_interests"),
            textAlign: TextAlign.center,
            style: t.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: st(context, 14),
            ),
          ),
          SizedBox(height: sh(context, 20)),

          // Container danh sách sở thích
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
                ? Text(
              _error!,
              style: TextStyle(color: theme.colorScheme.error),
            )
                : Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _interests.map((i) {
                final selected = _selected.contains(i.id);
                return GestureDetector(
                  onTap: () => _toggle(i.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (i.iconUrl.isNotEmpty)
                          Image.network(
                            i.iconUrl,
                            width: 24,
                            height: 24,
                            errorBuilder: (_, __, ___) =>
                            const SizedBox.shrink(),
                          ),
                        if (i.iconUrl.isNotEmpty) const SizedBox(width: 8),
                        Text(
                          i.name,
                          style: t.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: selected
                                ? textColorSelected
                                : textColorDefault,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          SizedBox(height: sh(context, 32)),

          // Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppButton(
                text: loc.translate("back"),
                variant: ButtonVariant.outline,
                onPressed: widget.onBack,
              ),
              Row(
                children: [
                  AppButton(
                    text: loc.translate("skip"),
                    variant: ButtonVariant.outline,
                    onPressed: () => _handleProfileSetup(interestIds: []),
                  ),
                  const SizedBox(width: 8),
                  AppButton(
                    text: loc.translate("finish"),
                    onPressed: _selected.isEmpty
                        ? () => _handleProfileSetup(interestIds: [])
                        : () => _handleProfileSetup(interestIds: _selected),
                    disabled: false,
                  ),
                ],
              ),
            ],
          ),
        ],
      ).animate().fadeIn(duration: 400.ms),
    );
  }
}
