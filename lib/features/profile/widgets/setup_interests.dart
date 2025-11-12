import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/api/api_client.dart';
import '../../../data/models/interests/interest_model.dart';
import '../../../data/models/user/profile_setup_request.dart';
import '../../../data/repositories/interest_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/services/apis/interest_service.dart';
import '../../../data/services/apis/user_service.dart';
import '../../../main.dart';
import '../../../routes/app_routes.dart';
import '../../shared/app_error_state.dart';

class SetupInterests extends StatefulWidget {
  final VoidCallback onBack;
  final List<String> learningLangs;
  final List<String> speakingLangs;
  final List<String> initialSelected;
  final void Function(List<String>)? onFinish;

  const SetupInterests({
    super.key,
    required this.onBack,
    required this.learningLangs,
    required this.speakingLangs,
    this.initialSelected = const [],
    this.onFinish,
  });

  @override
  State<SetupInterests> createState() => _SetupInterestsState();
}

class _SetupInterestsState extends State<SetupInterests> {
  late List<String> _selected;
  List<InterestModel> _interests = [];
  bool _isLoading = true;
  String? _error;

  late final InterestRepository _repo;
  Locale? _currentLocale;

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.initialSelected);
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
      widget.onFinish?.call(_selected);
    });
  }

  Future<void> _handleProfileSetup({required List<String> interestIds}) async {
    widget.onFinish?.call(_selected);

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
        final loc = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.translate("profile_setup_success")),
            duration: const Duration(seconds: 2),
          ),
        );
      }

      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } catch (e) {
      final loc = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.translate("profile_setup_failed")),
          duration: const Duration(seconds: 2),
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
                Icons.star,
                size: sw(context, 36),
                color: theme.colorScheme.primary,
              ),
            ),
          ),

          SizedBox(height: sh(context, 20)),

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
                  ? AppErrorState(onRetry: () => _fetchInterests()
              )
                  : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _interests.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: (MediaQuery.of(context).size.width ~/ 220).clamp(2, 6),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 3.8,
                ),
                itemBuilder: (context, index) {
                  final i = _interests[index];
                  final selected = _selected.contains(i.id);
                  return GestureDetector(
                    onTap: () => _toggle(i.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected ? borderColorSelected : borderColorDefault,
                          width: 1,
                        ),
                        color: selected ? backgroundSelected : backgroundDefault,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (i.iconUrl.isNotEmpty)
                            Image.network(
                              i.iconUrl,
                              width: 24,
                              height: 24,
                              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                            ),
                          if (i.iconUrl.isNotEmpty) const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              i.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: t.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: selected ? textColorSelected : textColorDefault,
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
